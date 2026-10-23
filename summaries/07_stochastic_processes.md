# Chapter 7. Stochastic Processes

<!-- cite:begin -->
From *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science* by Nick Polson and Vadim Sokolov (2026), chapter 7. Cite as Polson and Sokolov (2026), *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science*, edition 1, https://doi.org/10.5281/zenodo.23603837. Book page: https://vsokolov.org/books/bayes_ai_deep_learning/. Source: https://github.com/VadimSokolov/bayes_ai_deep_learning.
<!-- cite:end -->

The chapter introduces stochastic processes as distributions over functions from an index set to a state space, with the Markov property, and develops Brownian motion (the Wiener process) and the Poisson process as building blocks of continuous time models. For geometric Brownian motion it derives the mean and variance of a price at a horizon and states the Merton rule, the continuous time analog of the Kelly criterion. Sports betting examples define implied volatility: a Brownian motion model of the score difference gives win probabilities and a time varying implied volatility for Super Bowl XLVII, and a Skellam process calibrated to bookmaker odds does the same for an English Premier League match. It states the Lévy Itô decomposition and presents stochastic volatility models with jumps (SV, SVJ, SVCJ, SVIJ) with Bayesian MCMC inference.

## From the literature

Brownian motion as a model of asset prices (Bachelier 1900); the motion of pollen particles (Brown 1827) and its statistical description (Einstein 1905); log returns rather than price changes (Samuelson); random walk behavior of stock and commodity prices (Kendall 1953); the Black Scholes option pricing model (Black and Scholes); jumps added to Bachelier's model (Merton); the Kelly criterion (Kelly 1956); a Brownian motion model for sports scores (Stern 1994); independent Poisson models of football scores (Dixon and Coles 1997); the effect of a red card on scoring intensities (Vecer, Kopriva and Ichiba 2009); the Skellam process model of English Premier League odds (Feng, Polson and Xu 2016); the Lévy Itô decomposition (Lévy and Itô, as presented in Sato 1999).

## New results

<!-- results:begin -->
No new results of this chapter are catalogued.
<!-- results:end -->

## Key terms

stochastic process, random process, state space, index set, sample path, Markov property, Markov chain, random walk, Brownian motion, Wiener process, geometric Brownian motion, log normal distribution, Poisson process, counting process, exponential waiting time, Gamma Poisson conjugate prior, Skellam distribution, implied volatility, Black Scholes, option pricing, Kelly criterion, fractional Kelly, Merton rule, point spread, moneyline odds, vig, sports betting, win probability, Super Bowl XLVII, English Premier League, Levy Ito decomposition, Lévy process, Lévy measure, compound Poisson, jump diffusion, stochastic volatility, SVJ, SVCJ, SVIJ, leverage effect, MCMC, Metropolis Hastings, South Sea bubble
