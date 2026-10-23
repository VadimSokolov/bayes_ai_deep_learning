# Code of chapter: Model Selection
# Every R chunk of the chapter in book order, including the ones the book does not print. Chunks the book does not run are commented out.
# Run from the book folder: Rscript code/16-select.R. Data are read from the data folder. Figures go to the graphics device (Rplots.pdf under Rscript).
# Data: data/babyboom.csv

source("code/common.R")

# ---- Normal Q-Q Plot -------------------------------------------------------

# [fig-qqplot]
babyboom <- read.csv("data/babyboom.csv")
qqnorm(babyboom$wt, bg = "lightblue", main = "", ylab = "Weight (g)")
qqline(babyboom$wt, col = "red", lwd = 3)

# [fig-qqplot-gender]
par(pch = 21, cex = 1.1)
g <- babyboom %>%
    filter(gender == "girl") %>%
    pull(wt)
b <- babyboom %>%
    filter(gender == "boy") %>%
    pull(wt)
qqnorm(g, bg = "lightblue", main = "", ylab = "Weight (g)")
qqline(g, col = 2)
qqnorm(b, bg = "lightblue", main = "", ylab = "Weight (g)")
qqline(b, col = 2)

hr <- ceiling(babyboom$running.time / 60)
BirthsByHour <- tabulate(hr)
# Number of hours with 0, 1, 2, 3, 4 births
ObservedCounts <- table(BirthsByHour)
# Average number of births per hour
BirthRate <- sum(BirthsByHour) / 24
# Expected counts for Poisson distribution, the last bin holds 4 or more births
ExpectedCounts <- c(dpois(0:3, BirthRate), ppois(3, BirthRate, lower.tail = FALSE)) * 24
# bind into matrix for plotting
ObsExp <- rbind(ObservedCounts, ExpectedCounts)
barplot(ObsExp, names = c(0:3, "4+"), beside = TRUE, legend = c("Observed", "Expected"),
        xlab = "Births per hour", ylab = "Number of hours")

# birth intervals
birthinterval <- diff(babyboom$running.time)
# quantiles of standard exponential distribution (rate=1)
exponential.quantiles <- qexp(ppoints(43))
qqplot(exponential.quantiles, birthinterval, bg = "lightblue",
       xlab = "Exponential quantiles", ylab = "Time between births (minutes)")
lmb <- mean(birthinterval)
lines(exponential.quantiles, exponential.quantiles * lmb, col = 2) # Overlay a line

# ---- Hard Function ---------------------------------------------------------

x <- seq(-2, 2, by = 0.01)
y <- 1 / (1 + 25 * x^2)
# Approximate with polynomial of degree 1 and 2
m1 <- lm(y ~ x)
m2 <- lm(y ~ poly(x, 2))
# Approximate with polynomial of degree 20 and 5
m20 <- lm(y ~ poly(x, 20))
m5 <- lm(y ~ poly(x, 5))

# [fig-runge]
x <- seq(-3, 3, by = 0.01)
y <- 1 / (1 + 25 * x^2)
plot(x, y, type = "l", col = "black", lwd = 2)
abline(v = c(-2, 2), col = "gray60")
lines(x, predict(m1, list(x = x)), lwd = 2, col = 1, lty = 3)
lines(x, predict(m2, poly(x, 2)), lwd = 2, col = 2, lty = 2)
lines(x, predict(m5, poly(x, 5)), lwd = 2, col = 3, lty = 4)
lines(x, predict(m20, poly(x, 20)), lwd = 2, col = 4, lty = 5)
legend(0.6, 1.02, legend = c("f(x)", "m1", "m2", "m5", "m20"), col = c("black", 1:4), lty = c(1, 3, 2, 4, 5), lwd = 2, seg.len = 3, cex = 0.8, bty = "n")
