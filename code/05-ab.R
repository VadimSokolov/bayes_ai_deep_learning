# Code of chapter: A/B Testing
# Every R chunk of the chapter in book order, including the ones the book does not print. Chunks the book does not run are commented out.
# Run from the book folder: Rscript code/05-ab.R. Data are read from the data folder. Figures go to the graphics device (Rplots.pdf under Rscript).
# Data: data/PNAS_data_2011.csv, data/cancer-diet.csv
# Packages: dplyr, knitr

source("code/common.R")

# ---- Pyx Trial -------------------------------------------------------------

# [mi-vote-sim]
set.seed(17) # Kharlamov
allcoins <- runif(1000000, 4.95, 5.05)

survey_sample <- sample(allcoins, size = 100, replace = FALSE)
xbar <- mean(survey_sample)

survey_sample <- sample(allcoins, size = 100, replace = FALSE)
xbar <- mean(survey_sample)

# [mi-vote-plot]
prep <- replicate(2000, mean(sample(allcoins, size = 100, replace = FALSE)))
hist(prep, breaks = 30, freq = F, main = "", xlab = "Sample mean weight (grams)", col = "lightblue")
p <- seq(4.9, 5.1, length.out = 500)
lines(p, dnorm(p, mean(prep), sd(prep)), col = "red", lwd = 3)

sd(prep)
sd(allcoins)

sd(prep)
sd(allcoins) / sqrt(100)

# [fig-galton]
set.seed(1889)
n <- 1000
rows <- 12
steps <- matrix(rbinom(n * rows, 1, 0.5), n, rows)
bin <- rowSums(steps)
hist(bin, breaks = seq(-0.5, rows + 0.5), main = "", col = "gray80",
     xlab = "Bin (number of right steps)", ylab = "Number of balls",
     ylim = c(0, 250))
curve(n * dnorm(x, rows / 2, sqrt(rows / 4)), add = TRUE, lwd = 2)

# ---- Confidence Intervals --------------------------------------------------

0.76 + c(-1.96, 1.96) * sqrt(0.0073)

# ---- Mythbusters Example ---------------------------------------------------

par(mar = c(2.5, 2.5, 0.7, 1.5), bty = "n")
set.seed(1)
a <- replicate(2000, mean(rbinom(100, 1, 0.3)))
plot(density(a), main = "", xlab = expression(hat(p)))
se <- sqrt(0.3 * (1 - 0.3) / 100) #  0.046
x <- seq(0, 0.5, length.out = 300)
lines(x, dnorm(x, mean = 0.3, sd = se), col = "red", lwd = 3)
legend("topright", c("simulated", "normal approximation"), col = c("black", "red"), lwd = c(1, 3), bty = "n", cex = 0.7)

1 - pnorm(0.044, 0, sqrt(0.0177))

# ---- Coke vs Pepsi ---------------------------------------------------------

prop.test(56, 100, alternative = "greater", conf.level = 0.95) %>% fmt_prop_test()

# ---- Avonex ----------------------------------------------------------------

prop.test(45, 75, 0.95) %>% fmt_prop_test()

# ---- Pfizer ----------------------------------------------------------------

prop.test(x = c(11, 77), n = c(1500000, 6000000), alternative = "greater", conf.level = .95) %>%
  fmt_prop_test()

# ---- Lord Rayleigh's Argon Discovery ---------------------------------------

air <- c(2.31017, 2.30986, 2.31010, 2.31001, 2.31024, 2.31010, 2.31028, NA) # Missing data point
decomp <- c(2.30143, 2.29890, 2.29816, 2.30182, 2.29869, 2.29940, 2.29849, 2.29889)
d <- data.frame("Air" = air, "Chemical Decomposition" = decomp, check.names = FALSE)
knitr::kable(d, booktabs = TRUE)
boxplot(d, col = c("red", "green"), names = c("Air", "Chemical decomposition"), ylab = "Gas density")

# [argon-code]
# \ echo: true
t.test(air, decomp, var.equal = T)

# ---- SimCity ---------------------------------------------------------------

site1 <- c(.40, 500) # pink
site2 <- c(.30, 550) # black
abtestfunc <- function(ad1, ad2) {
  d <- ad1[1] - ad2[1]
  se <- sqrt(ad1[1] * (1 - ad1[1]) / ad1[2] + ad2[1] * (1 - ad2[1]) / ad2[2])
  p <- (ad1[1] * ad1[2] + ad2[1] * ad2[2]) / (ad1[2] + ad2[2])
  z <- d / sqrt(p * (1 - p) * (1 / ad1[2] + 1 / ad2[2]))
  round(c(diff = d, lower = d - 1.96 * se, upper = d + 1.96 * se, z = z), 3)
}
abtestfunc(site1, site2)

# ---- Mythbusters -----------------------------------------------------------

par(mar = c(4, 4, 0.1, 0.1), bty = "n")
p <- seq(0.0, 0.6, length.out = 200)
plot(p, dnorm(p, 0.25, sqrt(0.188 / 16)), col = 2, type = "l", lwd = 3, ylab = "Density", ylim = c(0, 5))
lines(p, dnorm(p, 0.294, sqrt(0.208 / 34)), col = 3, lwd = 3, lty = 2, ylim = c(0, 6))
legend("topright", c("control", "experiment"), col = c(2, 3), lwd = 3, lty = c(1, 2), bty = "n")

0.044 + c(-1.96, 1.96) * sqrt(0.0177)

# ---- Search Algorithm ------------------------------------------------------

p1 <- 1755 / 2500
p2 <- 1828 / 2500
Algo1 <- round(p1 + c(-1.96, 1.96) * sqrt(p1 * (1 - p1) / 2500), 3)
Algo2 <- round(p2 + c(-1.96, 1.96) * sqrt(p2 * (1 - p2) / 2500), 3)
kable(rbind(Algo1, Algo2), col.names = c("Lower", "Upper"), caption = "95% Confidence Interval for the Proportions")

diff <- p1 - p2 + c(-1.96, 1.96) * sqrt(p1 * (1 - p1) / 2500 + p2 * (1 - p2) / 2500)
print(diff, digits = 5)

# ---- Search Algorithm with Unequal Sample Sizes ----------------------------

p1 <- 1824 / 2600
p2 <- 1867 / 2550
diff <- p1 - p2 + c(-1.96, 1.96) * sqrt(p1 * (1 - p1) / 2600 + p2 * (1 - p2) / 2550)
print(diff, digits = 5)

# ---- Multiple Testing ------------------------------------------------------

plot(1:100, 1 - (1 - 0.05)^{
  1:100
}, type = "l", ylab = "False Positive Rate", xlab = "Number of Tests", col = "red", lwd = 2)

# [cancer-diad]
d <- read.csv("data/cancer-diet.csv")
knitr::kable(d[1:6, ], booktabs = TRUE)

# ---- Russian Election Fraud: A Field Experiment ----------------------------

# [fig-russianfraud]
d <- read.csv("data/PNAS_data_2011.csv")

d %>% ggplot(aes(x = er_share, fill = as.factor(s))) +
  geom_density(alpha = 0.6, color = "#e9ecef") +
  labs(fill = "Observers") +
  xlab(NULL) +
  scale_fill_manual(values = c("#69b3a2", "#404080"), labels = c("Without", "With")) +
  theme_gray(base_size = 8) +
  theme(legend.position = "bottom")
d %>% ggplot(aes(x = turnout_share, fill = as.factor(s))) +
  geom_density(alpha = 0.6, color = "#e9ecef") +
  labs(fill = "Observers") +
  xlab(NULL) +
  scale_fill_manual(values = c("#69b3a2", "#404080"), labels = c("Without", "With")) +
  theme_gray(base_size = 8) +
  theme(legend.position = "bottom")
d %>% ggplot(aes(x = apple_share, fill = as.factor(s))) +
  geom_density(alpha = 0.6, color = "#e9ecef") +
  labs(fill = "Observers") +
  xlab(NULL) +
  scale_fill_manual(values = c("#69b3a2", "#404080"), labels = c("Without", "With")) +
  theme_gray(base_size = 8) +
  theme(legend.position = "bottom")
d %>% ggplot(aes(x = sr_share, fill = as.factor(s))) +
  geom_density(alpha = 0.6, color = "#e9ecef") +
  labs(fill = "Observers") +
  xlab(NULL) +
  scale_fill_manual(values = c("#69b3a2", "#404080"), labels = c("Without", "With")) +
  theme_gray(base_size = 8) +
  theme(legend.position = "bottom")
d %>% ggplot(aes(x = ldpr_share, fill = as.factor(s))) +
  geom_density(alpha = 0.6, color = "#e9ecef") +
  labs(fill = "Observers") +
  xlab(NULL) +
  scale_fill_manual(values = c("#69b3a2", "#404080"), labels = c("Without", "With")) +
  theme_gray(base_size = 8) +
  theme(legend.position = "bottom")
d %>% ggplot(aes(x = com_share, fill = as.factor(s))) +
  geom_density(alpha = 0.6, color = "#e9ecef") +
  labs(fill = "Observers") +
  xlab(NULL) +
  scale_fill_manual(values = c("#69b3a2", "#404080"), labels = c("Without", "With")) +
  theme_gray(base_size = 8) +
  theme(legend.position = "bottom")

# [fig-russianfraud2]
dl <- d %>% dplyr::select(ends_with("_share"), s, uik)
dl <- dl %>% pivot_longer(cols = c(er_share, apple_share, turnout_share, sr_share, ldpr_share, com_share), names_to = "party", values_to = "share")
df2 <- dl %>%
  group_by(party, s) %>%
  dplyr::summarise(mu = mean(share), sd = sd(share) / sqrt(dplyr::n()))
ggplot(df2, aes(x = party, y = mu, fill = as.factor(s))) +
  geom_bar(stat = "identity", color = "#e9ecef", position = position_dodge()) +
  geom_errorbar(aes(ymin = mu - 2.58 * sd, ymax = mu + 2.58 * sd), width = .2, position = position_dodge(.9)) +
  scale_fill_manual(values = c("#69b3a2", "#404080"), name = "", labels = c("Control group", "Treatment group")) +
  scale_x_discrete(labels = c("Yabloko", "Communist", "United Russia", "LDPR", "Just Russia", "Turnout")) +
  ylab("Mean Share") +
  xlab(NULL) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  theme(legend.position = "right", legend.margin = margin(r = -5), plot.margin = margin(5.5, 20, 5.5, 5.5))
