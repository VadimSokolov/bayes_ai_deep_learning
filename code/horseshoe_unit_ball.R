# Plot Unit Ball for Horseshoe Prior
# Penalty: phi(theta_i) = -log(log(1 + 2*tau^2/theta_i^2))

library(ggplot2)
library(dplyr)

# Function to generate unit ball for Horseshoe prior
generate_horseshoe_ball <- function(tau = 0.5, penalty_level = 0, n_points = 1000) {
  # Horseshoe penalty function for each component
  horseshoe_penalty <- function(theta, tau) {
    # Handle theta = 0 case to avoid numerical issues
    theta[abs(theta) < 1e-8] <- 1e-8
    -log(log(1 + 2*tau^2/theta^2))
  }
  
  # Create grid for numerical contour finding
  theta_range <- seq(-2.5, 2.5, length.out = 200)
  grid <- expand.grid(theta1 = theta_range, theta2 = theta_range)
  
  # Remove points too close to origin to avoid numerical issues
  grid <- grid[sqrt(grid$theta1^2 + grid$theta2^2) > 0.05, ]
  
  # Compute penalty for each point (sum over components)
  penalty1 <- horseshoe_penalty(grid$theta1, tau)
  penalty2 <- horseshoe_penalty(grid$theta2, tau)
  grid$penalty <- penalty1 + penalty2
  
  # Remove infinite or NaN values
  grid <- grid[is.finite(grid$penalty), ]
  
  # Find contour at specified penalty level
  tolerance <- 0.2
  contour_points <- grid[abs(grid$penalty - penalty_level) < tolerance, ]
  
  if (nrow(contour_points) > 0) {
    # Sort by angle for smooth curve
    contour_points$angle <- atan2(contour_points$theta2, contour_points$theta1)
    contour_points <- contour_points[order(contour_points$angle), ]
    
    data.frame(
      x = contour_points$theta1,
      y = contour_points$theta2,
      tau = tau,
      penalty_level = penalty_level
    )
  } else {
    # Return empty data frame if no contour found
    data.frame(x = numeric(0), y = numeric(0), tau = numeric(0), penalty_level = numeric(0))
  }
}

# Generate Horseshoe unit balls for different tau values
tau_values <- c(0.1, 0.3, 0.5, 0.8)
colors <- c("#8B4513", "#CD853F", "#D2691E", "#A0522D")

horseshoe_data <- do.call(rbind, lapply(seq_along(tau_values), function(i) {
  tau <- tau_values[i]
  df <- generate_horseshoe_ball(tau = tau, penalty_level = 0)
  if (nrow(df) > 0) {
    df$tau_label <- paste0("τ = ", tau)
    df$color_index <- i
    df
  } else {
    NULL
  }
}))

# Create the plot
if (nrow(horseshoe_data) > 0) {
  p <- ggplot(horseshoe_data, aes(x = x, y = y, color = tau_label)) +
    geom_path(linewidth = 1.5, alpha = 0.8) +
    scale_color_manual(values = colors) +
    coord_fixed() +
    xlim(-2, 2) +
    ylim(-2, 2) +
    labs(
      title = "Horseshoe Prior Unit Balls",
      subtitle = "Penalty contours: φ(θ) = -Σᵢ log(log(1 + 2τ²/θᵢ²))",
      x = "θ₁",
      y = "θ₂",
      color = "Global Scale Parameter",
      caption = "Horseshoe prior encourages sparsity while preserving large signals"
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
  ggsave("fig/horseshoe_unit_ball.png", p, width = 8, height = 8, dpi = 300)
  
  cat("Horseshoe unit ball plot saved as: fig/horseshoe_unit_ball.png\n")
  cat("Number of tau values successfully plotted:", length(unique(horseshoe_data$tau)), "\n")
  
} else {
  cat("Warning: No valid Horseshoe contour data generated. Check parameters.\n")
}

# Alternative: Single tau value with detailed annotation
tau_single <- 0.3
horseshoe_single <- generate_horseshoe_ball(tau = tau_single, penalty_level = 0)

if (nrow(horseshoe_single) > 0) {
  p_single <- ggplot(horseshoe_single, aes(x = x, y = y)) +
    geom_path(color = "#8B4513", linewidth = 2) +
    coord_fixed() +
    xlim(-2, 2) +
    ylim(-2, 2) +
    labs(
      title = paste0("Horseshoe Prior Unit Ball (τ = ", tau_single, ")"),
      subtitle = "Characteristic 'horseshoe' shape: strong shrinkage near origin, weak shrinkage for large values",
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
    annotate("text", x = 1.5, y = 1.5, 
             label = "Weak shrinkage\nfor large signals", 
             size = 3.5, hjust = 0.5, color = "#8B4513", fontface = "bold") +
    annotate("text", x = 0, y = -1.8, 
             label = "Strong shrinkage near origin\n(encourages sparsity)", 
             size = 3.5, hjust = 0.5, color = "#8B4513", fontface = "bold") +
    annotate("curve", x = 1.2, y = 1.2, xend = 0.8, yend = 0.8,
             arrow = arrow(length = unit(0.02, "npc")), 
             color = "#8B4513", curvature = 0.3) +
    annotate("curve", x = 0, y = -1.5, xend = 0, yend = -0.8,
             arrow = arrow(length = unit(0.02, "npc")), 
             color = "#8B4513", curvature = 0)
  
  print(p_single)
  
  # Save the annotated single plot
  ggsave("fig/horseshoe_unit_ball_annotated.png", p_single, width = 8, height = 8, dpi = 300)
  
  cat("Annotated Horseshoe unit ball plot saved as: fig/horseshoe_unit_ball_annotated.png\n")
} else {
  cat("Warning: Could not generate single Horseshoe contour.\n")
}

# Display penalty function characteristics
cat("\n=== Horseshoe Prior Characteristics ===\n")
cat("Penalty function: φ(θᵢ) = -log(log(1 + 2τ²/θᵢ²))\n")
cat("- Near origin (θᵢ approx. 0): penalty → +∞ (strong shrinkage)\n")
cat("- Large |θᵢ|: penalty grows slowly (weak shrinkage)\n")
cat("- τ controls global shrinkage level\n")
cat("- Optimal for sparse signals with few large effects\n")
cat("- Achieves minimax rates: O(s log(p/s)) for s-sparse vectors\n") 