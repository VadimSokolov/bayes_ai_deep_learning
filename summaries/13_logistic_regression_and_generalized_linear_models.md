# Chapter 13. Logistic Regression and Generalized Linear Models

<!-- cite:begin -->
From *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science* by Nick Polson and Vadim Sokolov (2026), chapter 13. Cite as Polson and Sokolov (2026), *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science*, edition 1, https://doi.org/10.5281/zenodo.23603837. Book page: https://vsokolov.org/books/bayes_ai_deep_learning/. Source: https://github.com/VadimSokolov/bayes_ai_deep_learning.
<!-- cite:end -->

How do we model and assess a binary or multiclass outcome from inputs? The chapter develops logistic regression from a binomial (Bernoulli) likelihood and the logistic function, fitted by maximum likelihood (cross entropy loss, BFGS), with softmax and logits for several classes, log odds interpretation of coefficients, and the probit alternative. Examples use NBA point spreads, tennis match statistics, Hong Kong horse racing and a LinkedIn study of executive careers. Evaluation topics are thresholds, accuracy, the confusion matrix, the ROC curve, AUC, confounding, expected profit and imbalanced data (F1 score, SMOTE). It explains the kernel trick through the Gram matrix, then generalized linear models: link functions, Poisson and Gamma regression, deviance, and likelihood ratio comparison of nested models. It ends with Bayesian logistic regression by Polya Gamma data augmentation and a Gibbs sampler, stated without proof, with an R implementation using the BayesLogit package and a horse race betting application.

## From the literature

Polya Gamma data augmentation, its integral identity and Gibbs sampler for Bayesian logistic regression (Polson, Scott and Windle 2013); the alternating series method for random variate generation (Devroye 1986); uniform ergodicity of that sampler (Choi and Hobert 2013); Polya Gamma augmentation for retrieval models (Ye et al. 2023); optimal scaling of Metropolis Hastings algorithms, cited for proposal tuning (Roberts and Rosenthal 2001); the LinkedIn study of how members become executives (Irwin 2016; Gan and Fritzler 2016); the BFGS method (Broyden, Fletcher, Goldfarb and Shanno; no year in the chapter); Mercer's theorem as the chapter states it (no year in the chapter)

## New results

The chapter catalogs the Polya Gamma integral identity and Gibbs sampler for logistic regression from Polson, Scott and Windle (2013), a paper coauthored by one of the book's authors, and states them without proof.

<!-- results:begin -->
- [Polya Gamma integral identity for binomial likelihoods](../RESULTS.md#polya_gamma_integral_identity) (Section 13.7.1, page 445; conditional on the identity and the conditional Polya Gamma law, which the chapter cites from Polson, Scott and Windle (2013) and does not prove): A binomial likelihood term in the linear predictor equals an exponential factor times a mixture of Gaussian kernels over a Polya Gamma variable, whose conditional law given the linear predictor is again Polya Gamma. First stated in Polson, Scott and Windle (2013), Bayesian Inference for Logistic Models Using Pólya Gamma Latent Variables, Journal of the American Statistical Association 108(504), 1339 to 1349.
- [Polya Gamma Gibbs sampler for Bayesian logistic regression](../RESULTS.md#polya_gamma_gibbs_sampler_logistic) (Section 13.7.1, page 445; conditional on the two conditional distributions, which the chapter quotes from Polson, Scott and Windle (2013) and does not derive from the integral identity, itself stated without proof): For binomial logistic regression with a Gaussian prior, alternating a Polya Gamma draw of one latent variable per observation with a multivariate normal draw of the coefficients gives a two step Gibbs sampler. First stated in Polson, Scott and Windle (2013), Bayesian Inference for Logistic Models Using Pólya Gamma Latent Variables, Journal of the American Statistical Association 108(504), 1339 to 1349.
<!-- results:end -->

## Key terms

logistic regression, logit model, binary classification, multiclass, softmax, cross entropy, maximum likelihood, log odds, probit, link function, generalized linear model, GLM, Poisson regression, deviance, confusion matrix, ROC curve, AUC, imbalanced data, F1 score, SMOTE, kernel trick, Gram matrix, Mercer theorem, BFGS, Polya Gamma, Pólya Gamma, data augmentation, Gibbs sampler, BayesLogit, uniform ergodicity, horse race betting
