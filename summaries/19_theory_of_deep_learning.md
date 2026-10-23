# Chapter 19. Theory of Deep Learning

<!-- cite:begin -->
From *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science* by Nick Polson and Vadim Sokolov (2026), chapter 19. Cite as Polson and Sokolov (2026), *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science*, edition 1. Book page: https://vsokolov.org/books/bayes_ai_deep_learning/. Source: https://github.com/VadimSokolov/bayes_ai_deep_learning.
<!-- cite:end -->

This chapter asks what the approximation of multivariate functions says about deep learning. It defines ridge functions and projection pursuit regression, states the Kolmogorov superposition theorem (KST) with the history of its constructive proofs, and describes Kolmogorov Arnold networks and the Kolmogorov generalized additive model (K GAM), a two layer network with fixed inner features and learned outer functions. It compares ReLU partitions of input space with CART trees and reads kernel smoothing, nearest neighbors and transformer attention as kernel estimators. Deep learning is framed as representation learning, with PCA and partial least squares as linear baselines, and double descent is illustrated by polynomial regression. The chapter closes with minimax, posterior concentration and deep learner convergence rates, including a dimension free rate for generalized additive models. Most results are cited rather than proved.

## From the literature

projection pursuit regression (Friedman and Stuetzle 1981; Huber 1985); nonlinear functions of linear combinations (Diaconis and Shahshahani 1984); the Kolmogorov superposition theorem (Kolmogorov 1957); the first explicit construction of the inner functions (Sprecher 1965); a corrected construction and the Köppen function (Köppen 2000, 2002) with a convergence proof (Braun and Griebel 2009); a single outer function (Lorentz 1976); the Kaczmarz method (Kaczmarz 1937); multiple randomized classifiers (Amit, Blanchard and Wilder 2000); kernel regression (Nadaraya 1964; Watson 1964); the nearest neighbor error bound (Cover and Hart 1967); attention as kernel smoothing (Bahdanau, Cho and Bengio 2014); the transformer (Vaswani et al. 2017); double descent (Belkin, Hsu, Ma and Mandal 2019; Hastie, Montanari, Rosset and Tibshirani 2022; Nakkiran et al. 2021); posterior concentration for sparse deep learning (Polson and Ročková 2018); rates for spline estimators of Kolmogorov representations (Coppejans 2004; Igelnik and Parikh 2003) and for deep ReLU networks (Schmidt Hieber 2021).

## New results

The catalog has one entry, a posterior concentration rate cited from Polson and Ročková (2018) and not proved in the chapter.

<!-- results:begin -->
- [Posterior concentration at the minimax rate for sparse deep learning](../RESULTS.md#posterior_concentration_sparse_deep_learning) (Section 19.9.2, page 657; conditional on the smoothness and prior mass conditions of Polson and Ročková (2018), which the chapter does not state, and the result itself, which it cites without proof; the minimax rate is for Hölder smooth regression functions on the unit cube): Under smoothness and prior mass conditions, the posterior distribution of the regression function concentrates around the true function at the minimax rate, up to a factor of log N. First stated in Polson and Ročková (2018), Posterior Concentration for Sparse Deep Learning, Advances in Neural Information Processing Systems 31, arXiv:1803.09138.
<!-- results:end -->

## Key terms

ridge function, projection pursuit, Kolmogorov Arnold representation theorem, KST, KAN, K GAM, generalized additive model, Köppen function, Sprecher, Kaczmarz, space partitioning, ReLU, CART, Bayesian model averaging, kernel smoothing, Nadaraya Watson, k nearest neighbors, attention, transformer, representation learning, PCA, PLS, uncertainty quantification, double descent, interpolation, minimum norm, bias variance tradeoff, minimax rate, posterior concentration, curse of dimensionality
