# Chapter 8. Gaussian Processes

<!-- cite:begin -->
From *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science* by Nick Polson and Vadim Sokolov (2026), chapter 8. Cite as Polson and Sokolov (2026), *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science*, edition 1. Book page: https://vsokolov.org/books/bayes_ai_deep_learning/. Source: https://github.com/VadimSokolov/bayes_ai_deep_learning.
<!-- cite:end -->

How can a prior be placed directly on an unknown function, updated with observations, and used to report uncertainty at every input? The chapter introduces the Gaussian process (GP), a collection of random variables any finite number of which have a joint Gaussian distribution, specified by a mean function and a covariance (kernel) function and written $f \sim \mathcal{GP}(m, k)$. It uses the zero mean squared exponential kernel (radial basis function, RBF) with signal variance and length scale hyperparameters, and draws sample paths from the prior with mvrnorm in R. It states the closed form posterior mean and covariance of GP regression, obtained by conditioning a multivariate normal vector on noiseless observations, and applies them to the sine function. Hyperparameters are estimated by maximizing the log marginal likelihood (maximum likelihood estimation, MLE), which the chapter reads as an Occam's razor balance between data fit and a log determinant complexity penalty. The chapter states the gradient for the squared exponential kernel, passes it to BFGS through optim, compares the result with the laGP package, and fits the motorcycle accident data (mcycle in the R package MASS), with wider uncertainty where observations are few. Exercises cover kernel ridge regression and the Matern kernel.

## From the literature

the laGP package, developed by Bobby Gramacy, for estimating Gaussian process hyperparameters and approximate inference on large data sets; the closed form conditioning of a multivariate normal vector that yields the GP posterior mean and covariance, described in the chapter as a standard property of the multivariate normal distribution, with no author named. The chapter gives no authors or years for the squared exponential kernel, jitter or BFGS.

## New results

<!-- results:begin -->
No new results of this chapter are catalogued.
<!-- results:end -->

## Key terms

Gaussian process, GP, Gaussian process regression, distribution over functions, mean function, covariance function, kernel function, squared exponential kernel, radial basis function, RBF kernel, signal variance, length scale, lengthscale, hyperparameters, marginal likelihood, maximum likelihood estimation, MLE, Occam's razor, BFGS, laGP, MASS, mcycle, motorcycle accident data, jitter, posterior mean, kernel ridge regression, Matern kernel, Matérn kernel
