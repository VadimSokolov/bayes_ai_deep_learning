# Chapter 12. Linear Regression

<!-- cite:begin -->
From *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science* by Nick Polson and Vadim Sokolov (2026), chapter 12. Cite as Polson and Sokolov (2026), *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science*, edition 1, https://doi.org/10.5281/zenodo.23603837. Book page: https://vsokolov.org/books/bayes_ai_deep_learning/. Source: https://github.com/VadimSokolov/bayes_ai_deep_learning.
<!-- cite:end -->

How can an output be predicted from inputs with a model linear in its parameters, and how certain are the estimated coefficients? The chapter covers least squares: the model $y = X\beta + \epsilon$, basis functions, the normal equations $X^\top y = X^\top X \beta$ and their closed form solution, and fitting with the R function lm. It derives the mean and covariance of the least squares estimator, argues that it is normally distributed under independent normal errors with constant variance, and uses this for standard errors, t statistics, p values, confidence and prediction intervals, residuals, outliers, influential points and regression to the mean. Examples cover house prices, stock and portfolio return regressions including the Capital Asset Pricing Model (Keynes, Google, Yahoo!), log and log log transformations, power laws, price elasticity, interactions, dummy variables, and golf earnings. It shows that the median minimizes the sum of absolute deviations, presents the quantile loss, and mentions the Huber loss. It ends with Bayesian linear regression: a Gaussian prior, the conjugate Gaussian posterior, ridge and lasso as Gaussian and Laplace priors, and a pointer to the horseshoe prior.

## From the literature

a noncalculus proof that the median minimizes the sum of absolute deviations (Schwertman, Gilks and Cameron 1990); the Lindeberg central limit theorem, invoked for the normality of the estimates (Lindeberg); regression towards mediocrity in heights (Galton); the pilot training example of regression to the mean (Kahneman and Tversky); Cook's distance (Cook); the Fama French three factor model (Fama and French); the Huber loss (Huber); data on 62 mammal species (collected by Jerison 1973)

## New results

<!-- results:begin -->
No new results of this chapter are catalogued.
<!-- results:end -->

## Key terms

linear regression, ordinary least squares, OLS, regression coefficients, design matrix, normal equations, hat matrix, residuals, outliers, influential points, Cook's distance, regression to the mean, standard error, t statistic, p value, confidence interval, prediction interval, homoscedasticity, CAPM, alpha, beta, Fama French, feature engineering, log log model, power law, price elasticity, interaction term, dummy variables, quantile regression, least absolute deviations, Huber loss, Bayesian linear regression, conjugate posterior, ridge regression, lasso, Laplace prior, shrinkage, horseshoe prior
