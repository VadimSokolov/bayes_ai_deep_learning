# Setup shared by the R code of the book. Every code/NN-topic.R starts with source("code/common.R"); run the scripts from the book folder.

library(tidyverse)
library(ggplot2)
library(latex2exp)
library(broom)
library(quantmod)

# The book builds without network access. quantmod pulls from Yahoo, whose API changes, so getSymbols reads data/quantmod/<SYMBOL>.rds
# when the file exists and falls through to the real quantmod::getSymbols otherwise. To refresh a file:
# getSymbols(s, from = "1990-01-01", to = "2024-01-02", auto.assign = FALSE) |> saveRDS(file.path("data/quantmod", paste0(s, ".rds")))
.quantmod_cache <- "data/quantmod"
getSymbols <- function(Symbols, from = NULL, to = NULL, auto.assign = TRUE,
                       env = parent.frame(), ...) {
  rng <- paste0(if (is.null(from)) "" else from, "/", if (is.null(to)) "" else to)
  got <- character(0)
  for (s in Symbols) {
    f <- file.path(.quantmod_cache, paste0(s, ".rds"))
    if (!file.exists(f)) {
      return(quantmod::getSymbols(Symbols,
        from = from, to = to,
        auto.assign = auto.assign, env = env, ...
      ))
    }
    x <- readRDS(f)
    if (rng != "/") x <- x[rng]
    if (!auto.assign) return(x)
    assign(s, x, envir = env)
    got <- c(got, s)
  }
  invisible(got)
}

library(LearnBayes)
library(knitr)
library(MASS)
library(reticulate)

options(digits = 3, scipen = 999, str = strOptions(strict.width = "cut"))

# Margins and symbols of the base R figures of the book. The book applies them before every chunk; call book_par() before a plot to get the same look.
book_par <- function() {
  par(mar = c(2.5, 2.5, 0.7, 0.5), bty = "n", cex.lab = 0.7, cex.axis = 0.5, cex.main = 0.5, pch = 20, cex = 1, mgp = c(1.5, 0.4, 0))
}

# Format numbers with commas for inline use
fmt <- function(x, digits = 3) {
  format(round(x, digits), big.mark = ",", scientific = FALSE, trim = TRUE)
}

# Format prop.test output with shortened column names
fmt_prop_test <- function(test_result, digits = 2) {
  tidied <- broom::tidy(test_result)

  # Select only columns that exist
  available_cols <- names(tidied)
  desired_cols <- c("estimate", "statistic", "p.value", "parameter", "conf.low", "conf.high", "alternative")
  cols_to_select <- intersect(desired_cols, available_cols)

  result <- tidied %>%
    dplyr::select(dplyr::all_of(cols_to_select))

  # Rename columns
  rename_map <- c(
    estimate = "est",
    statistic = "stat",
    p.value = "p",
    parameter = "param",
    conf.low = "low",
    conf.high = "high",
    alternative = "alt"
  )

  for (old_name in names(rename_map)) {
    if (old_name %in% names(result)) {
      names(result)[names(result) == old_name] <- rename_map[old_name]
    }
  }

  kable(result, digits = digits)
}
