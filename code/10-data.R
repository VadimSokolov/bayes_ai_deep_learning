# Code of chapter: Unreasonable Effectiveness of Data
# Every R chunk of the chapter in book order, including the ones the book does not print. Chunks the book does not run are commented out.
# Run from the book folder: Rscript code/10-data.R. Data are read from the data folder. Figures go to the graphics device (Rplots.pdf under Rscript).
# Data: data/boscovich.csv
# Packages: knitr

source("code/common.R")

# ---- Boscovich and Shape of Earth ------------------------------------------

d <- read.csv("data/boscovich.csv")
knitr::kable(d, digits = 8)
plot(d$sin2Latitude, d$ArcLength, ylab = "Arc Length", xlab = expression(10^4 ~ sin^2 ~ (theta)), pch = 16, ylim = c(56700, 57450), xlim = c(-30, 8590), col = as.factor(d$Location))
text(d$sin2Latitude, d$ArcLength, labels = d$Location, pos = 1, offset = 0.5, cex = 0.7)

d <- read.csv("data/boscovich.csv")
sl <- matrix(NA, 5, 5)
for (i in 1:5) {
    for (j in 1:(i - 1)) {
        dx <- d$sin2Latitude[i] - d$sin2Latitude[j]
        dy <- d$ArcLength[i] - d$ArcLength[j]
        sl[i, j] <- dy / dx
    }
}
rownames(sl) <- d$Location
colnames(sl) <- d$Location
options(knitr.kable.NA = "")
knitr::kable(sl, digits = 4)

# [fig-boscovich-pairs]
plot(d$sin2Latitude, d$ArcLength, ylab = "Arc Length", xlab = expression(10^4 ~ sin^2 ~ (theta)), pch = 16, ylim = c(56700, 57800), xlim = c(-30, 8590), col = as.factor(d$Location))
text(d$sin2Latitude, d$ArcLength, labels = d$Location, pos = c(3, 3, 3, 1, 3), offset = 1.6, cex = 0.7)
for (i in 1:4) {
    for (j in (i + 1):5) {
        slope <- (d$ArcLength[i] - d$ArcLength[j]) / (d$sin2Latitude[i] - d$sin2Latitude[j])
        intercept <- d$ArcLength[i] - slope * d$sin2Latitude[i]
        abline(a = intercept, b = slope, col = 2, lwd = 0.8, lty = 2)
    }
}

# [fig-Boscovich]
d <- read.csv("data/boscovich.csv")
plot(d$sin2Latitude, d$ArcLength, ylab = "Arc Length", xlab = expression(10^4 ~ sin^2 ~ (theta)), pch = 16, ylim = c(56700, 57450), xlim = c(-30, 8590))
abline(56751, 0.06670097, lwd = 3, col = "red")
plot(d$sin2Latitude, d$ArcLength, ylab = "Arc Length", xlab = expression(10^4 ~ sin^2 ~ (theta)), pch = 16, ylim = c(56700, 57450), xlim = c(-30, 8590))
abline(lm(ArcLength ~ sin2Latitude, data = d), lwd = 3, col = "red")
