# Chapter 14. Tree Models

<!-- cite:begin -->
From *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science* by Nick Polson and Vadim Sokolov (2026), chapter 14. Cite as Polson and Sokolov (2026), *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science*, edition 1. Book page: https://vsokolov.org/books/bayes_ai_deep_learning/. Source: https://github.com/VadimSokolov/bayes_ai_deep_learning.
<!-- cite:end -->

How can nested if then rules predict a response, how can trees be combined to cut variance, and how can tree ensembles estimate causal effects from observational data? The chapter builds regression trees by greedy recursive binary splitting (CART), prunes them by cost complexity pruning, and builds classification trees that split by the Gini index or cross entropy. It presents bagging, random forests and gradient boosting. A long section applies Bayesian additive regression trees (BART) to causal inference, covering potential outcomes, ATE, ATT and CATE, SUTVA, ignorability, positivity, regularization priors, Bayesian backfitting MCMC and counterfactual posterior draws, with the Lalonde job training data compared against propensity score matching. An appendix covers the 1/N variance rule, the curse of dimensionality, trees as adaptive nearest neighbors, equal weights for exchangeable predictors, and a Chebyshev bound relating ensemble error to margin and covariance between trees.

## From the literature

the fundamental problem of causal inference (Holland 1986); the Bayesian view of causal inference as a missing data problem (Rubin 1978); standard econometric models of the era failing to replicate the experimental benchmark (Lalonde 1986); a widely used sample of the Lalonde data (Dehejia and Wahba 1999); the propensity score as a predictor in BART to mitigate regularization induced confounding (Hahn, Murray and Carvalho 2020); the connection between classifier strength and correlation in voting ensembles (Amit, Blanchard and Wilder 2000); asymptotic one nearest neighbor error rate bounded by twice the Bayes risk (Cover and Hart 1967); central limit behavior of projections of the uniform distribution on a high dimensional ball (Maxwell; history in Diaconis and Freedman 1987; more general results in Klartag 2007); asymptotic theory of finite dimensional normed spaces (Milman and Schechtman 2009); a result on exchangeability supporting equal weight averaging of predictors (Kingman 1975).

## New results

<!-- results:begin -->
No new results of this chapter are catalogued.
<!-- results:end -->

## Key terms

decision tree, regression tree, classification tree, CART, recursive binary splitting, cost complexity pruning, weakest link pruning, Gini index, cross entropy, bagging, bootstrap aggregation, random forest, gradient boosting, diamonds data, Boston housing data, BART, Bayesian additive regression trees, causal inference, potential outcomes, ATE, ATT, CATE, SUTVA, ignorability, positivity, propensity score, double machine learning, Lalonde, National Supported Work, curse of dimensionality, nearest neighbor, Bayes risk, exchangeability, bias variance tradeoff
