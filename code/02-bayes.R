# Code of chapter: Bayes' Rule
# Every R chunk of the chapter in book order, including the ones the book does not print. Chunks the book does not run are commented out.
# Run from the book folder: Rscript code/02-bayes.R. Data are read from the data folder. Figures go to the graphics device (Rplots.pdf under Rscript).
# Data: data/pres_polls.csv
# Packages: dplyr, knitr, lattice, scales, usmap

source("code/common.R")

# ---- Nakamura's Alleged Cheating -------------------------------------------

# [nakamura]
q <- 0.8916
p <- dbinom(45, 46, q)
N <- 10000
odds <- p * N
print(1 - 1 / (1 + odds))
print(1 / (1 + odds))
print(N * p / (N * p + 1))

# [fig-n-p]
N <- seq(500, 10000, by = 250)
plot(99 / N, N, xlab = "p", ylab = "N", type = "l", lwd = 3, col = "blue", xlim = c(0, 0.2), ylim = c(0, 10000), yaxt = "n")
axis(2, at = seq(0, 10000, 2500))

# ---- Birds at a Feeder -----------------------------------------------------

# [naivebayes-birds]
N <- c(Sparrow = 500, Finch = 300, Cardinal = 200)
yes <- rbind(Sparrow = c(450, 30, 0), Finch = c(240, 150, 15),
             Cardinal = c(20, 160, 180))
x <- c(small = 1, red = 1, crested = 0)
posterior <- function(add) {
  p <- (yes + add) / (N + 2 * add)
  lik <- apply(p, 1, function(r) prod(r^x * (1 - r)^(1 - x)))
  score <- N / sum(N) * lik
  score / sum(score)
}
round(rbind(counts = posterior(0), smoothed = posterior(1)), 3)

# ---- Dirichlet Distribution ------------------------------------------------

# [obama]
# Source: "http://www.electoral-vote.com/evp2012/Pres/pres_polls.csv"
election.2012 <- read.csv("data/pres_polls.csv")
# The polls only (the rows of the pollster "Election 2012-1" are the results),
# averaged over the last seven days of each state
elect2012 <- election.2012 %>%
  filter(!grepl("^Election", Pollster)) %>%
  group_by(state) %>%
  filter(Day > max(Day) - 7) %>%
  dplyr::summarise(R.pct = mean(GOP), O.pct = mean(Dem), EV = mean(EV)) %>%
  as.data.frame()

knitr::kable(elect2012[1:5, ], longtable = TRUE)
knitr::kable(elect2012[42:46, ], longtable = TRUE)

set.seed(66) # Lemieux
rdirichlet <- function(n, alpha) {
  g <- matrix(rgamma(n * length(alpha), alpha), ncol = length(alpha), byrow = TRUE)
  g / rowSums(g)
}
prob.Obama <- function(mydata) {
  p <- rdirichlet(1000, 500 * c(mydata$R.pct, mydata$O.pct, 100 - mydata$R.pct -
    mydata$O.pct) / 100 + 1)
  mean(p[, 2] > p[, 1])
}
win.probs <- data.frame(state = elect2012$state)
win.probs$Obama <- sapply(1:nrow(elect2012), function(i) prob.Obama(elect2012[i, ]))

win.probs$EV <- elect2012$EV
# The five states without a poll go to the winner of 2008
unpolled <- data.frame(
  state = c("Alaska", "Delaware", "Kansas", "Mississippi", "Wyoming"),
  Obama = c(0, 1, 0, 0, 0), EV = c(3, 3, 6, 6, 3)
)
win.probs <- rbind(win.probs, unpolled)
win.probs$Romney <- 1 - win.probs$Obama
win.probs <- win.probs[order(win.probs$EV, win.probs$state), ]
rownames(win.probs) <- win.probs$state

# [obama-map]
library(usmap)
plot_usmap(data = win.probs, values = "Obama") +
  scale_fill_gradient(low = "white", high = "navy", name = "Obama Win Probability", label = scales::comma) + theme(legend.position = "right") + coord_sf(expand = FALSE)

set.seed(87) # Crosby
sim.election <- function(win.probs) {
  winner <- rbinom(nrow(win.probs), 1, win.probs$Obama)
  sum(win.probs$EV * winner)
}

sim.EV <- replicate(10000, sim.election(win.probs))
oprob <- sum(sim.EV >= 270) / length(sim.EV)
oprob

# [fig-election-ev]
library(lattice)
# Lattice Graph
densityplot(sim.EV,
  plot.points = "rug", xlab = "Electoral Votes for Obama", ylim = c(0, 0.022),
  panel = function(x, ...) {
    panel.densityplot(x, ...)
    panel.abline(v = 270)
    panel.text(x = 270, y = 0.0205, "270 EV to Win", pos = 2, cex = 0.85)
    panel.abline(v = 332)
    panel.text(x = 332, y = 0.0205, "Actual: 332 EV", pos = 2, cex = 0.85)
  }
)

# ---- Bayes Home Diagnostics ------------------------------------------------

# [fig-alarm]
prior <- seq(0, .1, length.out = 200)
post <- prior / (prior + 0.001 * (1 - prior))
plot(prior, post, type = "l", lwd = 3, col = "red", xlab = expression("prior" ~ P(b)), ylab = expression("posterior" ~ P(b ~ "|" ~ a)))
