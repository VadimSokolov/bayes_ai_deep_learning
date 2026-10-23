# Reproduce fig-horseshoe: Unit balls for different norms
library(ggplot2)
library(dplyr)
library(gridExtra)

# Function to generate unit ball for L_p norm
generate_unit_ball <- function(p, n_points = 1000) {
  if (p == 0) {
    # L_0 "norm" - just the coordinate axes
    data.frame(
      x = c(-1, 1, 0, 0),
      y = c(0, 0, -1, 1),
      norm = "L_0"
    )
  } else if (p == Inf) {
    # L_infinity norm - square
    t <- seq(0, 2*pi, length.out = n_points)
    x <- sign(cos(t))
    y <- sign(sin(t))
    data.frame(x = x, y = y, norm = "L_inf")
  } else {
    # General L_p norm
    # Parametric representation: x = sign(cos(t))|cos(t)|^(2/p), y = sign(sin(t))|sin(t)|^(2/p)
    t <- seq(0, 2*pi, length.out = n_points)
    x <- sign(cos(t)) * abs(cos(t))^(2/p)
    y <- sign(sin(t)) * abs(sin(t))^(2/p)
    data.frame(x = x, y = y, norm = paste0("L_", p))
  }
}

# Function to generate unit ball for Cauchy prior
# Penalty: phi(theta) = log(1 + theta1^2) + log(1 + theta2^2)
# Unit ball: phi(theta) <= c for some constant c
generate_cauchy_ball <- function(penalty_level = 2, n_points = 1000) {
  # Use numerical approach to find contour
  # Create a grid and find points where penalty approx. penalty_level
  
  theta_range <- seq(-3, 3, length.out = 200)
  grid <- expand.grid(theta1 = theta_range, theta2 = theta_range)
  
  # Cauchy penalty: sum of log(1 + theta_i^2) for independent components
  grid$penalty <- log(1 + grid$theta1^2) + log(1 + grid$theta2^2)
  
  # Find contour at specified penalty level
  # Use a tolerance for numerical contour finding
  tolerance <- 0.1
  contour_points <- grid[abs(grid$penalty - penalty_level) < tolerance, ]
  
  if (nrow(contour_points) > 0) {
    # Sort by angle to create smooth curve
    contour_points$angle <- atan2(contour_points$theta2, contour_points$theta1)
    contour_points <- contour_points[order(contour_points$angle), ]
    
    data.frame(
      x = contour_points$theta1,
      y = contour_points$theta2,
      norm = "Cauchy"
    )
  } else {
    # Fallback: approximate circle
    t <- seq(0, 2*pi, length.out = n_points)
    r <- sqrt(exp(penalty_level) - 1)  # Approximate radius
    data.frame(
      x = r * cos(t),
      y = r * sin(t),
      norm = "Cauchy"
    )
  }
}

# Function to generate unit ball for Horseshoe prior
# Penalty: phi(theta_i) = -log(log(1 + 2*tau^2/theta_i^2))
# For multivariate: sum over components
generate_horseshoe_ball <- function(tau = 0.5, penalty_level = 0, n_points = 1000) {
  # Horseshoe penalty function for each component
  horseshoe_penalty <- function(theta, tau) {
    # Handle theta = 0 case
    theta[theta == 0] <- 1e-10
    -log(log(1 + 2*tau^2/theta^2))
  }
  
  # Use numerical approach
  theta_range <- seq(-2, 2, length.out = 150)
  grid <- expand.grid(theta1 = theta_range, theta2 = theta_range)
  
  # Remove points too close to origin to avoid numerical issues
  grid <- grid[sqrt(grid$theta1^2 + grid$theta2^2) > 0.05, ]
  
  # Compute penalty for each point
  penalty1 <- horseshoe_penalty(grid$theta1, tau)
  penalty2 <- horseshoe_penalty(grid$theta2, tau)
  grid$penalty <- penalty1 + penalty2
  
  # Find contour at specified penalty level
  tolerance <- 0.3
  contour_points <- grid[abs(grid$penalty - penalty_level) < tolerance, ]
  
  if (nrow(contour_points) > 0) {
    # Sort by angle for smooth curve
    contour_points$angle <- atan2(contour_points$theta2, contour_points$theta1)
    contour_points <- contour_points[order(contour_points$angle), ]
    
    data.frame(
      x = contour_points$theta1,
      y = contour_points$theta2,
      norm = paste0("Horseshoe(τ=", tau, ")")
    )
  } else {
    # Fallback: return empty data frame
    data.frame(x = numeric(0), y = numeric(0), norm = character(0))
  }
}

# Generate data for different norms
norms_to_plot <- c(0.5, 1, 1.5, 2)
colors <- c("#E31A1C", "#1F78B4", "#33A02C", "#FF7F00")

plot_data <- do.call(rbind, lapply(seq_along(norms_to_plot), function(i) {
  p <- norms_to_plot[i]
  df <- generate_unit_ball(p)
  df$norm_label <- case_when(
    p == 0.5 ~ "ℓ₀.₅ (Bridge α=0.5)",
    p == 1 ~ "ℓ₁ (Lasso)",
    p == 1.5 ~ "ℓ₁.₅ (Bridge α=1.5)", 
    p == 2 ~ "ℓ₂ (Ridge)",
    TRUE ~ paste0("ℓ", p)
  )
  df$color_group <- i
  df
}))

# Add Cauchy and Horseshoe unit balls
cauchy_data <- generate_cauchy_ball(penalty_level = 2.5)
cauchy_data$norm_label <- "Cauchy Prior"
cauchy_data$color_group <- 6

horseshoe_data <- generate_horseshoe_ball(tau = 0.3, penalty_level = 0)
horseshoe_data$norm_label <- "Horseshoe Prior (τ=0.3)"
horseshoe_data$color_group <- 7

# Add L_0 "norm" as discrete points
l0_data <- data.frame(
  x = c(-1, 1, 0, 0),
  y = c(0, 0, -1, 1),
  norm_label = "ℓ₀ (Subset Selection)",
  color_group = 5
)

# Create the main plot
p1 <- ggplot() +
  # Plot the continuous norms
  geom_path(data = plot_data, 
            aes(x = x, y = y, color = norm_label), 
            linewidth = 1.2) +
  # Add Cauchy contour
  geom_path(data = cauchy_data,
            aes(x = x, y = y),
            color = "#FF1493", linewidth = 1.2) +
  # Add Horseshoe contour  
  geom_path(data = horseshoe_data,
            aes(x = x, y = y),
            color = "#8B4513", linewidth = 1.2) +
  # Add L_0 points
  geom_point(data = l0_data, 
             aes(x = x, y = y), 
             color = "#6A3D9A", size = 4, shape = 16) +
  # Styling
  scale_color_manual(values = c("#E31A1C", "#1F78B4", "#33A02C", "#FF7F00")) +
  coord_fixed() +
  xlim(-1.5, 1.5) +
  ylim(-1.5, 1.5) +
  labs(
    title = "Unit Balls for Different Priors",
    subtitle = "Comparison of regularization geometries",
    x = "β₁",
    y = "β₂",
    color = "Prior/Norm Type"
  ) +
  theme_minimal() +
  theme(
    panel.grid.major = element_line(color = "gray90", linewidth = 0.5),
    panel.grid.minor = element_blank(),
    axis.line = element_line(color = "black"),
    legend.position = "bottom",
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10),
    plot.title = element_text(size = 14, hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5)
  ) +
  geom_hline(yintercept = 0, color = "black", linewidth = 0.3) +
  geom_vline(xintercept = 0, color = "black", linewidth = 0.3)

# Add manual legend entries for Cauchy and Horseshoe
p1 <- p1 + 
  # Annotations for non-standard priors
  annotate("text", x = 1.3, y = 1.3, label = "Cauchy", 
           color = "#FF1493", size = 3, fontface = "bold") +
  annotate("text", x = -1.3, y = 1.3, label = "Horseshoe", 
           color = "#8B4513", size = 3, fontface = "bold") +
  # L_0 annotations
  annotate("text", x = 0.15, y = 0.85, label = "ℓ₀", 
           color = "#6A3D9A", size = 4, fontface = "bold") +
  annotate("text", x = 0.85, y = 0.15, label = "ℓ₀", 
           color = "#6A3D9A", size = 4, fontface = "bold") +
  annotate("text", x = -0.15, y = -0.85, label = "ℓ₀", 
           color = "#6A3D9A", size = 4, fontface = "bold") +
  annotate("text", x = -0.85, y = -0.15, label = "ℓ₀", 
           color = "#6A3D9A", size = 4, fontface = "bold")

print(p1)

# Save the plot
ggsave("fig/fig_horseshoe_reproduction.png", p1, width = 10, height = 8, dpi = 300)

# Create a more detailed version with more bridge norms
bridge_alphas <- c(0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2)
bridge_colors <- grey.colors(length(bridge_alphas), start = 0, end = 0.75)

bridge_data <- do.call(rbind, lapply(seq_along(bridge_alphas), function(i) {
  alpha <- bridge_alphas[i]
  df <- generate_unit_ball(alpha)
  df$alpha <- alpha
  df$alpha_label <- paste0("α = ", alpha)
  df
}))

p2 <- ggplot() +
  geom_path(data = bridge_data, 
            aes(x = x, y = y, color = alpha_label), 
            linewidth = 1) +
  scale_color_manual(values = bridge_colors) +
  coord_fixed() +
  xlim(-1.2, 1.2) +
  ylim(-1.2, 1.2) +
  labs(
    title = "Bridge Penalty Unit Balls",
    subtitle = "ℓₐ norms for different values of α",
    x = "β₁",
    y = "β₂",
    color = "Bridge Parameter"
  ) +
  theme_minimal() +
  theme(
    panel.grid.major = element_line(color = "gray90", linewidth = 0.5),
    panel.grid.minor = element_blank(),
    axis.line = element_line(color = "black"),
    legend.position = "bottom",
    plot.title = element_text(size = 14, hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5)
  ) +
  geom_hline(yintercept = 0, color = "black", linewidth = 0.3) +
  geom_vline(xintercept = 0, color = "black", linewidth = 0.3) +
  guides(color = guide_legend(nrow = 2, title.position = "top"))

print(p2)

# Save the detailed bridge plot
ggsave("fig/fig_bridge_detailed.png", p2, width = 5, height = 6, dpi = 300)

# Create a specialized plot focusing on sparsity-inducing priors
p3 <- ggplot() +
  # Standard norms for comparison
  geom_path(data = plot_data[plot_data$norm_label %in% c("ℓ₁ (Lasso)", "ℓ₂ (Ridge)"), ], 
            aes(x = x, y = y, color = norm_label), 
            linewidth = 1.2, alpha = 0.7) +
  # Sparsity-inducing priors
  geom_path(data = cauchy_data,
            aes(x = x, y = y),
            color = "#FF1493", linewidth = 1.5) +
  geom_path(data = horseshoe_data,
            aes(x = x, y = y),
            color = "#8B4513", linewidth = 1.5) +
  # L_0 points
  geom_point(data = l0_data, 
             aes(x = x, y = y), 
             color = "#6A3D9A", size = 4, shape = 16) +
  coord_fixed() +
  xlim(-1.5, 1.5) +
  ylim(-1.5, 1.5) +
  labs(
    title = "Sparsity-Inducing Priors vs Standard Regularization",
    subtitle = "Unit balls showing different shrinkage behaviors",
    x = "β₁",
    y = "β₂"
  ) +
  theme_minimal() +
  theme(
    panel.grid.major = element_line(color = "gray90", linewidth = 0.5),
    panel.grid.minor = element_blank(),
    axis.line = element_line(color = "black"),
    legend.position = "bottom",
    plot.title = element_text(size = 14, hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5)
  ) +
  geom_hline(yintercept = 0, color = "black", linewidth = 0.3) +
  geom_vline(xintercept = 0, color = "black", linewidth = 0.3) +
  # Add legend manually since we have mixed geoms
  annotate("text", x = -0.5, y = 1.4, label = "ℓ₂ (Ridge)", 
           color = "#FF7F00", size = 4, fontface = "bold") +
  annotate("text", x = 0.5, y = 1.4, label = "ℓ₁ (Lasso)", 
           color = "#1F78B4", size = 4, fontface = "bold") +
  annotate("text", x = 1.2, y = 1.2, label = "Cauchy", 
           color = "#FF1493", size = 4, fontface = "bold") +
  annotate("text", x = -1.2, y = 1.2, label = "Horseshoe", 
           color = "#8B4513", size = 4, fontface = "bold") +
  annotate("text", x = 0, y = -1.4, label = "ℓ₀ (Subset Selection)", 
           color = "#6A3D9A", size = 4, fontface = "bold")

print(p3)

# Save the sparsity comparison plot
ggsave("fig/fig_sparsity_priors.png", p3, width = 10, height = 8, dpi = 300)

cat("Figures saved as:\n")
cat("- fig_horseshoe_reproduction.png (main reproduction with Cauchy & Horseshoe)\n")
cat("- fig_bridge_detailed.png (detailed bridge norms)\n")
cat("- fig_sparsity_priors.png (sparsity-inducing priors comparison)\n") 



