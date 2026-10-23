# Chapter 15. Forecasting

<!-- cite:begin -->
From *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science* by Nick Polson and Vadim Sokolov (2026), chapter 15. Cite as Polson and Sokolov (2026), *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science*, edition 1. Book page: https://vsokolov.org/books/bayes_ai_deep_learning/. Source: https://github.com/VadimSokolov/bayes_ai_deep_learning.
<!-- cite:end -->

How can time series be forecast with Bayesian state space models, and how do such forecasts compare with machine learning forecasters? The chapter builds structural time series models (local level, local linear and semilocal linear trend, seasonal and regression components) from an observation equation and a transition equation, fitted by Markov chain Monte Carlo with the bsts R package. Examples are nowcasting weekly initial claims for unemployment insurance from Google search data with spike and slab variable selection, long term forecasting of the S&P 500 index, and dynamic logistic regression for recession probabilities. It then describes quantile regression forests and the temporal fusion transformer, with a benchmark against bsts. An optional section derives the Kalman filter recursions and presents the forward filtering backward sampling algorithm, forward backward recursions for hidden Markov models, regime switching and changepoint models. The chapter closes with particle learning for general mixtures and a Poisson mixture example.

## From the literature

a smallpox transmission model (Daniel Bernoulli 1766); nowcasting with structural time series, Google search data and spike and slab variable selection (Scott and Varian 2014, 2015); Bayesian model averaging for recession prediction (Berge, Sinha and Smolyansky 2016); data augmentation for logistic regression (Fruhwirth Schnatter and Fruhwirth 2007; Gramacy and Polson 2012) and support vector machines (Polson and Scott 2011); quantile regression forests (Meinshausen 2006); the temporal fusion transformer (Lim et al. 2021); the Kalman filter (Kalman 1960; Kalman and Bucy 1961); the Baum Welch algorithm (Baum, Petrie, Soules and Weiss 1970); the Viterbi algorithm (Viterbi 1967); MCMC for nonlinear non Gaussian state space models (Carlin, Polson and Stoffer 1992); forward filtering backward sampling (Carter and Kohn 1994); a review of forward filtering backward sampling for discrete hidden Markov models (Scott 2002); a Bayesian single changepoint model (Smith 1975) and multiple changepoint models (Chib 1998); particle learning for general mixtures (Carvalho, Lopes, Polson and Taddy 2010).

## New results

<!-- results:begin -->
No new results of this chapter are catalogued.
<!-- results:end -->

## Key terms

forecasting, time series, Bayesian structural time series, state space model, dynamic linear model, local linear trend, nowcasting, spike and slab prior, Bayesian model averaging, Kalman filter, FFBS, hidden Markov model, Viterbi, regime switching, changepoint, particle learning, quantile regression forest, temporal fusion transformer, recession prediction, robot localization, Eyam plague, SEIR
