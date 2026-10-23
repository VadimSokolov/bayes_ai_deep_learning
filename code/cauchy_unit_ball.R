# Plot Unit Ball for Cauchy Prior
# Penalty: phi(theta_i) = log(1 + theta_i^2)

library(ggplot2)
library(dplyr)

# Function to generate unit ball for Cauchy prior
generate_cauchy_ball <- function(penalty_level = 2, n_points = 1000) {
  # Cauchy penalty function for each component
  cauchy_penalty <- function(theta) {
    log(1 + theta^2)
  }
  
  # Create grid for numerical contour finding
  theta_range <- seq(-4, 4, length.out = 250)
  grid <- expand.grid(theta1 = theta_range, theta2 = theta_range)
  
  # Compute penalty for each point (sum over components)
  penalty1 <- cauchy_penalty(grid$theta1)
  penalty2 <- cauchy_penalty(grid$theta2)
  grid$penalty <- penalty1 + penalty2
  
  # Find contour at specified penalty level
  tolerance <- 0.05
  contour_points <- grid[abs(grid$penalty - penalty_level) < tolerance, ]
  
  if (nrow(contour_points) > 0) {
    # Sort by angle for smooth curve
    contour_points$angle <- atan2(contour_points$theta2, contour_points$theta1)
    contour_points <- contour_points[order(contour_points$angle), ]
    
    data.frame(
      x = contour_points$theta1,
      y = contour_points$theta2,
      penalty_level = penalty_level
    )
  } else {
    # Fallback: analytical approximation for large penalty levels
    t <- seq(0, 2*pi, length.out = n_points)
    r <- sqrt(exp(penalty_level) - 1)  # Approximate radius
    data.frame(
      x = r * cos(t),
      y = r * sin(t),
      penalty_level = penalty_level
    )
  }
}

# Generate Cauchy unit balls for different penalty levels
penalty_levels <- c(1.5, 2.0, 2.5, 3.0, 3.5)
colors <- c("#FF1493", "#FF69B4", "#FF20B2", "#DC143C", "#B22222")

cauchy_data <- do.call(rbind, lapply(seq_along(penalty_levels), function(i) {
  level <- penalty_levels[i]
  df <- generate_cauchy_ball(penalty_level = level)
  if (nrow(df) > 0) {
    df$level_label <- paste0("φ = ", level)
    df$color_index <- i
    df
  } else {
    NULL
  }
}))

# Create the plot
if (nrow(cauchy_data) > 0) {
  p <- ggplot(cauchy_data, aes(x = x, y = y, color = level_label)) +
    geom_path(linewidth = 1.5, alpha = 0.8) +
    scale_color_manual(values = colors) +
    coord_fixed() +
    xlim(-3, 3) +
    ylim(-3, 3) +
    labs(
      title = "Cauchy Prior Unit Balls",
      subtitle = "Penalty contours: φ(θ) = Σᵢ log(1 + θᵢ²)",
      x = "θ₁",
      y = "θ₂",
      color = "Penalty Level",
      caption = "Cauchy prior provides robust regularization with heavy tails"
    ) +
    theme_minimal() +
    theme(
      panel.grid.major = element_line(color = "gray90", linewidth = 0.3),
      panel.grid.minor = element_blank(),
      axis.line = element_line(color = "black", linewidth = 0.5),
      legend.position = "bottom",
      legend.title = element_text(size = 12, face = "bold"),
      legend.text = element_text(size = 10),
      plot.title = element_text(size = 16, hjust = 0.5, face = "bold"),
      plot.subtitle = element_text(size = 12, hjust = 0.5, face = "italic"),
      plot.caption = element_text(size = 10, hjust = 0.5, color = "gray50"),
      axis.title = element_text(size = 12, face = "bold")
    ) +
    geom_hline(yintercept = 0, color = "black", linewidth = 0.3, alpha = 0.7) +
    geom_vline(xintercept = 0, color = "black", linewidth = 0.3, alpha = 0.7)
  
  print(p)
  
  # Save the plot
  ggsave("fig/cauchy_unit_ball.png", p, width = 8, height = 8, dpi = 300)
  
  cat("Cauchy unit ball plot saved as: fig/cauchy_unit_ball.png\n")
  cat("Number of penalty levels successfully plotted:", length(unique(cauchy_data$penalty_level)), "\n")
  
} else {
  cat("Warning: No valid Cauchy contour data generated. Check parameters.\n")
}

# Alternative: Single penalty level with detailed annotation
penalty_single <- 2.5
cauchy_single <- generate_cauchy_ball(penalty_level = penalty_single)

if (nrow(cauchy_single) > 0) {
  p_single <- ggplot(cauchy_single, aes(x = x, y = y)) +
    geom_path(color = "#FF1493", linewidth = 2.5) +
    coord_fixed() +
    xlim(-3, 3) +
    ylim(-3, 3) +
    labs(
      title = paste0("Cauchy Prior Unit Ball (φ = ", penalty_single, ")"),
      subtitle = "Heavy-tailed regularization: robust to outliers, intermediate between Ridge and Lasso",
      x = "θ₁", 
      y = "θ₂"
    ) +
    theme_minimal() +
    theme(
      panel.grid.major = element_line(color = "gray90", linewidth = 0.3),
      panel.grid.minor = element_blank(),
      axis.line = element_line(color = "black", linewidth = 0.5),
      plot.title = element_text(size = 16, hjust = 0.5, face = "bold"),
      plot.subtitle = element_text(size = 12, hjust = 0.5, face = "italic"),
      axis.title = element_text(size = 12, face = "bold")
    ) +
    geom_hline(yintercept = 0, color = "black", linewidth = 0.3, alpha = 0.7) +
    geom_vline(xintercept = 0, color = "black", linewidth = 0.3, alpha = 0.7) +
    # Add annotations about the shape
    annotate("text", x = 2.2, y = 2.2, 
             label = "Heavy tails allow\nlarge coefficients", 
             size = 3.5, hjust = 0.5, color = "#FF1493", fontface = "bold") +
    annotate("text", x = 0, y = -2.7, 
             label = "Smooth curvature (no exact sparsity)\nbut stronger shrinkage than Ridge", 
             size = 3.5, hjust = 0.5, color = "#FF1493", fontface = "bold") +
    annotate("text", x = -2.2, y = 2.2, 
             label = "Robust to outliers\n(heavy-tailed prior)", 
             size = 3.5, hjust = 0.5, color = "#FF1493", fontface = "bold") +
    # Add arrows pointing to features
    annotate("curve", x = 1.8, y = 1.8, xend = 1.3, yend = 1.3,
             arrow = arrow(length = unit(0.02, "npc")), 
             color = "#FF1493", curvature = 0.3) +
    annotate("curve", x = 0, y = -2.4, xend = 0, yend = -1.5,
             arrow = arrow(length = unit(0.02, "npc")), 
             color = "#FF1493", curvature = 0) +
    annotate("curve", x = -1.8, y = 1.8, xend = -1.3, yend = 1.3,
             arrow = arrow(length = unit(0.02, "npc")), 
             color = "#FF1493", curvature = -0.3)
  
  print(p_single)
  
  # Save the annotated single plot
  ggsave("fig/cauchy_unit_ball_annotated.png", p_single, width = 9, height = 8, dpi = 300)
  
  cat("Annotated Cauchy unit ball plot saved as: fig/cauchy_unit_ball_annotated.png\n")
} else {
  cat("Warning: Could not generate single Cauchy contour.\n")
}

# Create comparison with other common priors
# Generate comparison data
theta_vals <- seq(-3, 3, length.out = 100)
comparison_data <- expand.grid(theta1 = theta_vals, theta2 = theta_vals)

# Calculate penalty levels for different priors
comparison_data$cauchy <- log(1 + comparison_data$theta1^2) + log(1 + comparison_data$theta2^2)
comparison_data$ridge <- comparison_data$theta1^2 + comparison_data$theta2^2
comparison_data$lasso <- abs(comparison_data$theta1) + abs(comparison_data$theta2)

# Create contour comparison plot
p_comparison <- ggplot() +
  # Cauchy contour
  geom_contour(data = comparison_data, aes(x = theta1, y = theta2, z = cauchy), 
               breaks = c(2.5), color = "#FF1493", linewidth = 2) +
  # Ridge contour (L2)
  geom_contour(data = comparison_data, aes(x = theta1, y = theta2, z = ridge), 
               breaks = c(2), color = "#FF7F00", linewidth = 1.5) +
  # Lasso contour (L1) 
  geom_contour(data = comparison_data, aes(x = theta1, y = theta2, z = lasso), 
               breaks = c(2), color = "#1F78B4", linewidth = 1.5) +
  coord_fixed() +
  xlim(-2.5, 2.5) +
  ylim(-2.5, 2.5) +
  labs(
    title = "Cauchy Prior vs Ridge and Lasso",
    subtitle = "Unit ball comparison: Cauchy (pink) vs Ridge (orange) vs Lasso (blue)",
    x = "θ₁",
    y = "θ₂"
  ) +
  theme_minimal() +
  theme(
    panel.grid.major = element_line(color = "gray90", linewidth = 0.3),
    panel.grid.minor = element_blank(),
    axis.line = element_line(color = "black", linewidth = 0.5),
    plot.title = element_text(size = 16, hjust = 0.5, face = "bold"),
    plot.subtitle = element_text(size = 12, hjust = 0.5, face = "italic"),
    axis.title = element_text(size = 12, face = "bold")
  ) +
  geom_hline(yintercept = 0, color = "black", linewidth = 0.3, alpha = 0.7) +
  geom_vline(xintercept = 0, color = "black", linewidth = 0.3, alpha = 0.7) +
  # Add legend manually
  annotate("text", x = -2, y = 2.2, label = "Cauchy Prior", 
           color = "#FF1493", size = 4, fontface = "bold") +
  annotate("text", x = 2, y = 2.2, label = "Ridge (ℓ₂)", 
           color = "#FF7F00", size = 4, fontface = "bold") +
  annotate("text", x = 0, y = -2.2, label = "Lasso (ℓ₁)", 
           color = "#1F78B4", size = 4, fontface = "bold")

print(p_comparison)

# Save the comparison plot
ggsave("fig/cauchy_vs_others.png", p_comparison, width = 9, height = 8, dpi = 300)

cat("Comparison plot saved as: fig/cauchy_vs_others.png\n")

# Display penalty function characteristics
cat("\n=== Cauchy Prior Characteristics ===\n")
cat("Penalty function: φ(θᵢ) = log(1 + θᵢ²)\n")
cat("- At origin (θᵢ = 0): penalty = 0 (no bias at zero)\n")
cat("- Large |θᵢ|: penalty approx. log(θᵢ²) = 2log|θᵢ| (grows logarithmically)\n")
cat("- Heavy-tailed distribution allows large coefficients\n")
cat("- More robust to outliers than Gaussian (Ridge) prior\n")
cat("- Provides intermediate shrinkage between Ridge and Lasso\n")
cat("- No exact sparsity (smooth penalty), but stronger shrinkage than Ridge\n")
cat("- Scale-invariant: penalty shape unchanged under scaling\n")

# Display numerical comparison of penalty growth rates
cat("\n=== Penalty Growth Rate Comparison ===\n")
theta_test <- c(0.1, 0.5, 1, 2, 5, 10)
for (theta in theta_test) {
  cauchy_pen <- log(1 + theta^2)
  ridge_pen <- theta^2
  lasso_pen <- abs(theta)
  cat(sprintf("θ = %.1f: Cauchy = %.3f, Ridge = %.3f, Lasso = %.3f\n", 
              theta, cauchy_pen, ridge_pen, lasso_pen))
} 