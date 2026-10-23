# Chapter 11. Pattern Matching

<!-- cite:begin -->
From *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science* by Nick Polson and Vadim Sokolov (2026), chapter 11. Cite as Polson and Sokolov (2026), *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science*, edition 1. Book page: https://vsokolov.org/books/bayes_ai_deep_learning/. Source: https://github.com/VadimSokolov/bayes_ai_deep_learning.
<!-- cite:end -->

This chapter asks how a prediction rule is learned from data and how its accuracy is judged. It treats supervised learning as finding a map $y = f(x)$ from a training dataset, and separates classification, regression and ranking. It contrasts the mean rule and the nearest neighbor rule as the two ends of the bias variance trade off, then parametric and nonparametric models, and traditional models (linear regression, generalized linear and additive models, principal component regression) with deep learning as a composition of layers instead of a sum of functions. Estimation is developed through the likelihood: maximum likelihood, the negative log likelihood as a loss, least squares derived from a normal model, the logistic function for Bernoulli responses, penalized likelihood and regularization, and the Bayesian posterior with its maximum a posteriori estimate. Predictive performance is assessed with train test splits, cross validation, MSE, MAE, precision, recall, F1 score and the confusion matrix, with an argument against R squared.

## From the literature

the unreasonable effectiveness of data (Halevy, Norvig and Pereira 2009), cited for relationships that defy simple mathematical description; Albert Salomon's 1913 monograph on mammography, whose author was among the first to link microcalcifications to breast cancer (Salomon 1913, reported by Nicosia and coauthors 2023; molecular aspects reviewed by Bonfiglio and coauthors 2021); regularization of ill posed problems (Tikhonov 1943; Tikhonov 1963); the James Stein estimator (James and Stein 1961) and the inadmissibility, under squared error, of the maximum likelihood estimate of a normal mean in three or more dimensions; the argument that R squared does not measure goodness of fit (Shalizi, The Truth About Linear Regression, linked in the chapter, no year); Feynman's remarks on chess and on machines that need not think like people (quoted in the chapter, no reference).

## New results

<!-- results:begin -->
No new results of this chapter are catalogued.
<!-- results:end -->

## Key terms

pattern matching, supervised learning, prediction, regression, classification, nonparametric regression, nearest neighbor, nearest neighbour, bias variance tradeoff, linear regression, GLM, GAM, PCR, deep learning, likelihood, MLE, negative log likelihood, cross entropy, loss function, least squares, logistic function, penalized likelihood, regularization, Tikhonov, James Stein estimator, shrinkage, posterior, MAP, train test split, cross validation, MSE, RMSE, MAE, MAPE, R squared, precision, recall, F1 score, confusion matrix, AlphaZero, Feynman
