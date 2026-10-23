# Chapter 3. Bayesian Learning

<!-- cite:begin -->
From *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science* by Nick Polson and Vadim Sokolov (2026), chapter 3. Cite as Polson and Sokolov (2026), *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science*, edition 1, https://doi.org/10.5281/zenodo.23603837. Book page: https://vsokolov.org/books/bayes_ai_deep_learning/. Source: https://github.com/VadimSokolov/bayes_ai_deep_learning.
<!-- cite:end -->

How does one learn about an unknown parameter from data and predict new observations using Bayes' rule? The chapter develops Bayesian parameter learning: prior, likelihood, posterior, marginal likelihood, posterior predictive distribution and sequential updating. It motivates the approach with exchangeability, de Finetti's representation theorem, subjective probability elicited by betting and the Dutch book argument. It introduces sufficient statistics and conjugate priors and gives closed form posteriors for the Beta Binomial model (Black Swan problem, Thompson sampling for clinical trials, shrinkage of batting averages), the Poisson Gamma model (count data, Poisson and Cox processes, Peso problem), the Exponential Gamma model, the Normal model with unknown mean, with unknown variance (inverse gamma prior) and with both unknown (Normal Gamma), the multivariate Normal, and mixtures of conjugate priors. It derives the Normal posterior by completing the square. Examples use English Premier League scores, stock returns and an American football point spread. The final section bridges to computation: posterior consistency, Monte Carlo integration, Markov chain Monte Carlo, detailed balance for the Metropolis rule, the Gibbs sampler and posterior predictive simulation.

## From the literature

de Finetti's representation theorem for exchangeable sequences (de Finetti; a general version in Heath and Sudderth 1976); subjective probability as willingness to bet (Ramsey 1926); the Black Swan problem (Taleb 2007); Thompson sampling; inference about batter and pitcher matchups in baseball from small samples (Stern et al. 2007); a Poisson model for football scores (Spiegelhalter and Ng 2009); Chebyshev's inequality; the Monte Carlo method (Metropolis and Ulam 1949) and its early history (Metropolis 1987); the Metropolis algorithm (Metropolis et al. 1953) and the Metropolis Hastings algorithm; convergence of Markov chain Monte Carlo algorithms (Polson 1996).

## New results

<!-- results:begin -->
No new results of this chapter are catalogued.
<!-- results:end -->

## Key terms

Bayes theorem, Bayes rule, Bayesian updating, conjugacy, exchangeable sequence, de Finetti theorem, probability elicitation, rule of succession, gamma Poisson, normal normal, normal inverse gamma, Student t, credible interval, shrinkage estimator, hierarchical model, doubly stochastic Poisson process, Gaussian, MLE, MCMC, ergodic theorem, law of large numbers, Chebyshev inequality, point spread, batting average
