# Chapter 17. Statistical Learning Theory and Regularization

<!-- cite:begin -->
From *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science* by Nick Polson and Vadim Sokolov (2026), chapter 17. Cite as Polson and Sokolov (2026), *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science*, edition 1. Book page: https://vsokolov.org/books/bayes_ai_deep_learning/. Source: https://github.com/VadimSokolov/bayes_ai_deep_learning.
<!-- cite:end -->

How does shrinkage reduce estimation risk in high dimensions, and why is regularization the same as choosing a prior? The chapter starts from the normal means problem and presents Stein's paradox: the maximum likelihood estimator (MLE) of a multivariate normal mean has constant risk and is inadmissible under squared error loss in dimension three or more. It covers the James Stein estimator and its empirical Bayes interpretation, the bias variance decomposition and sparse signal recovery. Its main theme is maximum a posteriori (MAP) estimation, where the penalty is a negative log prior. Ridge regression (Gaussian prior), the Lasso (Laplace prior), the bridge estimator (exponential power prior), the horseshoe prior, spike and slab priors and L0 subset selection (single best replacement algorithm) are developed in this frame, with scale mixture representations and proximal operators. Examples use baseball batting averages, firm performance screening and traffic speed filtering.

## From the literature

Stein's paradox for three or more normal means (Stein 1956; James and Stein 1961); the empirical Bayes view of the James Stein estimator (Efron and Morris 1975) and its batting average illustration (Efron and Morris 1977); Tikhonov regularization (Tikhonov 1943); the Hodrick Prescott filter (Hodrick and Prescott 1997); the Laplace distribution as a scale mixture of normals (Andrews and Mallows 1974); variance mean mixture data augmentation for support vector machines (Polson and Scott 2011); quantile regression (Koenker 2005) and its asymmetric Laplace pseudo likelihood (Johannes, Polson and Yae 2009); the horseshoe prior (Carvalho, Polson and Scott 2010) and the shrinkage threshold of its posterior mean (van der Pas et al. 2014); screening firms with heavy tailed priors (Polson and Scott 2012); the oracle property of bridge estimators (Huang, Horowitz and Ma 2008); the Bayesian bridge (Polson, Scott and Windle 2014).

## New results

One entry is catalogued: the Bartlett Fejer scale mixture representation of the exponential power prior in the Bayesian bridge, stated without proof and credited to Polson, Scott and Windle (2014).

<!-- results:begin -->
- [Bartlett Fejer scale mixture representation of the exponential power prior](../RESULTS.md#bayesian_bridge_bartlett_fejer_mixture) (Section 17.11.1, page 602; conditional on the representation, which the chapter states without proof and cites to Polson, Scott and Windle (2014), and an exponent in (0,1], so that the mixing weights are nonnegative): The exponential power prior of the Bayesian bridge with exponent in (0,1] is a scale mixture of triangular Bartlett Fejer kernels with a two component gamma mixing distribution, stated in the chapter without proof and credited to Polson, Scott and Windle (2014). First stated in Polson, Scott and Windle (2014), The Bayesian Bridge, Journal of the Royal Statistical Society Series B 76(4), 713 to 733.
<!-- results:end -->

## Key terms

Stein paradox, James Stein estimator, shrinkage, empirical Bayes, normal means, inadmissibility, bias variance tradeoff, regularization, MAP estimate, ridge regression, weight decay, Lasso, L1 penalty, L2 penalty, soft thresholding, horseshoe prior, spike and slab, L0 penalty, single best replacement, proximal operator, scale mixture of normals, sparsity, variable selection, trend filtering
