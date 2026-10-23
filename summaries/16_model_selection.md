# Chapter 16. Model Selection

<!-- cite:begin -->
From *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science* by Nick Polson and Vadim Sokolov (2026), chapter 16. Cite as Polson and Sokolov (2026), *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science*, edition 1. Book page: https://vsokolov.org/books/bayes_ai_deep_learning/. Source: https://github.com/VadimSokolov/bayes_ai_deep_learning.
<!-- cite:end -->

How should a predictive model be chosen without fitting noise? The chapter covers overfitting and underfitting, prediction versus interpretation (Breiman's two cultures), Q Q plots, the Runge function, and the bias variance decomposition of squared error, which it derives. It compares a single split, cross validation and the bootstrap on simulated data, and presents ROC, AUC, calibration and proper scoring rules. It develops Bayesian model selection: marginal likelihood (evidence), posterior model probabilities, Occam's razor, dice and death penalty examples, the Bayesian information criterion (BIC) via the Laplace approximation, MacKay's evidence framework with automatic relevance determination, and WBIC. It also covers the asymptotic carrier, explainability methods, and the Dickey Savage density ratio.

## From the literature

the two cultures of statistical modeling (Breiman 2001); ROC analysis, cited to Fawcett (2006); proper scoring rules, cited to Gneiting and Raftery (2007); the Brier score (Brier 1950); posterior predictive checks, cited to Gelman et al. (2013); the evidence framework for model comparison and hyperparameter selection (MacKay 1992); an illustration, through Laplace's approximation, of how dimensionality is weighted in the Bayesian paradigm (Lindley 1961); scalable Laplace approximation for neural networks (Ritter et al. 2018); scalable marginal likelihood estimation in deep learning (Immer et al. 2021); the widely applicable Bayesian information criterion (Watanabe 2013); posterior limits under misspecification (Berk 1966); the Dickey Savage density ratio (named in the chapter, no year); LIME (Ribeiro et al. 2016); SHAP (Lundberg and Lee 2017); partial dependence plots (Friedman 2001); individual conditional expectation plots (Goldstein et al. 2015); accumulated local effects (Apley and Zhu 2020); saliency maps (Simonyan et al. 2013); integrated gradients (Sundararajan et al. 2017); Grad CAM (Selvaraju et al. 2017); attention (Bahdanau et al. 2014); rule extraction (Craven and Shavlik 1996); counterfactual explanations (Wachter et al. 2017).

## New results

<!-- results:begin -->
No new results of this chapter are catalogued.
<!-- results:end -->

## Key terms

model selection, overfitting, underfitting, bias variance tradeoff, cross validation, bootstrap, Runge function, Q Q plot, ROC, AUC, calibration, proper scoring rule, posterior predictive check, marginal likelihood, Bayes factor, Occam's razor, Laplace approximation, Bayesian information criterion, BIC, Schwarz criterion, evidence framework, automatic relevance determination, ARD, WBIC, asymptotic carrier, misspecification, Kullback Leibler divergence, nested models, Savage Dickey ratio, explainability, LIME, SHAP, Shapley values, partial dependence, saliency map, integrated gradients, Grad CAM, counterfactual explanation
