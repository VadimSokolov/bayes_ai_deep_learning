# Code of chapter: Tree Models
# Every R chunk of the chapter in book order, including the ones the book does not print. Chunks the book does not run are commented out.
# Run from the book folder: Rscript code/14-tree.R. Data are read from the data folder. Figures go to the graphics device (Rplots.pdf under Rscript).
# Packages: MASS, bartCause, gbm, ggplot2, lattice, randomForest, rpart, rpart.plot, tree

source("code/common.R")

# ---- Tree Models -----------------------------------------------------------

library(ggplot2)
data(diamonds)
head(diamonds)

# [fig-price-carat]
ggplot(diamonds, aes(x = carat, y = price, color = clarity)) +
  geom_point(size = 0.6) +
  theme_gray(base_size = 8) +
  theme(legend.key.size = unit(0.35, "cm"))
# Create log-transformed price for better linear relationships
diamonds <- diamonds %>%
  mutate(
    log_price = log(price),
    log_carat = log(carat)
  )

# Examine the linearized relationship
ggplot(diamonds, aes(x = log_carat, y = log_price)) +
  geom_point(alpha = 0.05, color = "darkblue", size = 0.6) +
  geom_smooth(method = "lm", color = "red", linewidth = 0.5) +
  labs(x = "Log(Carat)", y = "Log(Price)") +
  theme_gray(base_size = 8)

# use density plot to compare price for different clarity levels
ggplot(diamonds, aes(x = price)) +
  geom_density() +
  facet_wrap(~ clarity) +
  scale_x_continuous(breaks = c(0, 5000, 10000, 15000), labels = c("0", "5k", "10k", "15k"))

library(rpart)
library(rpart.plot)
tree_model <- rpart(price ~ carat + clarity, data = diamonds)
# node means in full, with thousands separators (the default prints 12e+3)
plain <- function(x, labs, digits, varlen) {
  value <- format(round(x$frame$yval), big.mark = ",", trim = TRUE)
  paste0(value, sub("^[^\n]*", "", labs))
}
rpart.plot(tree_model, node.fun = plain)

ggplot(diamonds, aes(x = carat, y = clarity, colour = price)) +
  geom_point() +
  scale_color_viridis_c(end = 0.9)

# Plot the rectangle areas that represent the regions of the tree
pred_data <- expand.grid(
  carat = seq(min(diamonds$carat), max(diamonds$carat), length.out = 50),
  clarity = unique(diamonds$clarity)
)

pred_data$pred_price <- predict(tree_model, pred_data)

# Plot regions
ggplot(pred_data, aes(x = carat, y = clarity, fill = pred_price)) +
  geom_raster() +
  scale_fill_viridis_c(end = 0.9) +
  labs(title = "Tree Regions: Carat vs Clarity", fill = "Predicted price")

# ---- Example: Boston Housing Data ------------------------------------------

library(MASS)
data(Boston)
head(Boston)

# [bostontree]
library(tree)
# mindev param controls stopping: smaller value = bigger tree
temp <- tree(medv ~ lstat, data = Boston, mindev = .0001)
length(unique(temp$where)) # first big tree size

boston.tree <- prune.tree(temp, best = 7)
length(unique(boston.tree$where)) # pruned tree size

plot(boston.tree, type = "uniform") # pruned tree
text(boston.tree, label = NULL, col = "blue", cex = .8, adj = 1.05) # rules end left of the branch that comes down
text(boston.tree, splits = FALSE, col = "blue", label = "yval", cex = .8, digits = 3)
boston.fit <- predict(boston.tree) # get training fitted values
plot(Boston$lstat, Boston$medv, cex = .5, pch = 16, xlab = "lstat", ylab = "medv") # plot data
oo <- order(Boston$lstat)
lines(Boston$lstat[oo], boston.fit[oo], col = "red", lwd = 3) # step function fit
cvals <- c(9.725, 4.65, 3.325, 5.495, 16.085, 19.9) # cutpoints from tree
for (i in seq_along(cvals)) abline(v = cvals[i], col = "magenta", lty = 2) # cutpoints

# Select specific columns by name
df2 <- Boston[, c("dis", "lstat", "medv")]
print(names(df2))

temp <- tree(medv ~ ., df2, mindev = .0001)
length(unique(temp$where)) #

boston.tree <- prune.tree(temp, best = 7)

# [boston-partition]
plot(boston.tree, type = "u") # plot tree and partition in x.
text(boston.tree, label = NULL, col = "blue", cex = .8, adj = 1.05)
text(boston.tree, splits = FALSE, col = "blue", label = "yval", cex = .8, digits = 3)
partition.tree(boston.tree)

pv <- seq(from = .01, to = .99, by = .05)
x1q <- quantile(df2$lstat, probs = pv)
x2q <- quantile(df2$dis, probs = pv)
xx <- expand.grid(x1q, x2q) # matrix with two columns using all combinations of x1q and x2q
dfpred <- data.frame(dis = xx[, 2], lstat = xx[, 1])
lmedpred <- predict(boston.tree, dfpred)

# Create a perspective plot (3D surface)
# theta sets the viewing angle, zlim ensures the vertical axis covers the data range
persp(x1q, x2q, matrix(lmedpred, ncol = length(x2q), byrow = T),
  theta = 150, xlab = "dis", ylab = "lstat", zlab = "medv",
  zlim = c(min(df2$medv), 1.1 * max(df2$medv))
)

# ---- Example: Classifying Diamond Quality ----------------------------------

par(mar = c(1, 1, 2, 1))
diamonds_class <- diamonds %>%
  mutate(is_ideal = as.factor(ifelse(cut == "Ideal", "Ideal", "Non-Ideal")))

# Fit classification tree
class_tree <- rpart(is_ideal ~ carat + price + clarity, data = diamonds_class, method = "class")
rpart.plot(class_tree, main = "Classification Tree for Ideal Cut")

# ---- Bagging ---------------------------------------------------------------

library(randomForest)
set.seed(1)
n <- nrow(Boston)
ntreev <- c(10, 500, 5000)
fmat <- matrix(0, n, 3)
for (i in 1:3) {
  rffit <- randomForest(medv ~ lstat, data = Boston, ntree = ntreev[i], maxnodes = 15)
  fmat[, i] <- predict(rffit)
  mse <- mean((fmat[, i] - Boston$medv)^2, na.rm = TRUE)
  cat("Mean Squared Error with", ntreev[i], "trees:", round(mse), "\n")
}

oo <- order(Boston$lstat)
for (i in 1:3) {
  plot(Boston$lstat, Boston$medv, xlab = "lstat", ylab = "medv", pch = 16, cex = 0.3, col = "grey60")
  ok <- !is.na(fmat[oo, i])
  lines(Boston$lstat[oo][ok], fmat[oo, i][ok], col = "black", lwd = 1.5)
  title(main = paste0("Bagging, ", ntreev[i], " trees"))
}

# ---- Random Forest ---------------------------------------------------------

par(cex.axis = 0.8, mfrow = c(1, 2), mar = c(4, 5, 0.5, 1), mgp = c(2, 0.8, 0))
set.seed(1)
rf.boston <- randomForest(medv ~ ., data = Boston, mtry = 4, importance = TRUE, ntree = 50)
imp <- importance(rf.boston)
for (j in 1:2) dotchart(sort(imp[, j]), xlim = c(min(0, imp[, j]), max(imp[, j])), pch = 21, bg = "lightblue", cex = 0.7, xlab = colnames(imp)[j])

set.seed(1)
rf.boston <- randomForest(medv ~ ., data = Boston, mtry = 6, ntree = 50, maxnodes = 50)
yhat.rf <- predict(rf.boston, newdata = Boston)
oo <- order(Boston$lstat)
plot(Boston$lstat[oo], Boston$medv[oo], pch = 21, bg = "grey", xlab = "lstat", ylab = "medv") # plot data
lines(Boston$lstat[oo], yhat.rf[oo], col = "red", lwd = 3) # step function fit

# ---- Boosting --------------------------------------------------------------

library(gbm)
set.seed(1)
boost.boston <- gbm(medv ~ .,
  data = Boston, distribution = "gaussian",
  n.trees = 5000, interaction.depth = 4
)
yhat.boost <- predict(boost.boston, newdata = Boston, n.trees = 5000)
mean((yhat.boost - Boston$medv)^2)

par(mar = c(0, 2, 0, 0))
summary(boost.boston, plotit = FALSE)

lattice::trellis.par.set(fontsize = list(text = 8))
plot(boost.boston, i = "rm", ylab = "Partial dependence")
plot(boost.boston, i = "lstat", ylab = "Partial dependence",
  scales = list(x = list(at = seq(0, 40, 10))))

# ---- BART for Causal Inference ---------------------------------------------

# [bartc-fit]
# (the book does not run this chunk when it builds; it has no output in the book, and it is commented out here: remove the comment marks to run it)
# # Load the package and the non-experimental sample
# library(bartCause)
# data(lalonde, package = "MatchIt") # 185 NSW treated, 429 PSID controls
# lalonde$black <- as.integer(lalonde$race == "black")
# lalonde$hisp <- as.integer(lalonde$race == "hispan")

# # Define confounders
# confounders <- c("age", "educ", "black", "hisp", "married", "nodegree", "re74", "re75")

# # Fit the BART model
# fit <- bartc(
#   response = lalonde$re78,
#   treatment = lalonde$treat,
#   confounders = lalonde[, confounders],
#   estimand = "att",
#   commonSup.rule = "sd" # Rule to handle poor overlap
# )

# ---- The Problem of High Dimensions ----------------------------------------

# [fig-hd-ball]
set.seed(66) # Lemieux
n <- 1000
p <- 50
z <- matrix(rnorm(n * p), n, p)
y <- z / sqrt(rowSums(z^2)) * runif(n)^(1 / p)
plot(y[, 1], y[, 2], cex = 0.4, col = adjustcolor("black", 0.4), asp = 1, xlim = c(-1, 1), ylim = c(-1, 1), xlab = expression(e[1]^T * Y), ylab = expression(e[2]^T * Y))
theta <- seq(0, 2 * pi, length.out = 200)
lines(cos(theta), sin(theta))
