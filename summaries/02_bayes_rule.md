# Chapter 2. Bayes' Rule

<!-- cite:begin -->
From *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science* by Nick Polson and Vadim Sokolov (2026), chapter 2. Cite as Polson and Sokolov (2026), *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science*, edition 1, https://doi.org/10.5281/zenodo.23603837. Book page: https://vsokolov.org/books/bayes_ai_deep_learning/. Source: https://github.com/VadimSokolov/bayes_ai_deep_learning.
<!-- cite:end -->

How should probabilities be revised when new evidence arrives? The chapter develops Bayes' rule (Bayes' theorem) for conditional probability, turning a prior probability and a likelihood into a posterior probability, with sequential updating, conditional independence, the law of total probability and the odds form with the Bayes factor. Worked examples include base rate neglect, craps, the Monty Hall problem, the search for the submarine USS Scorpion, Wald and damage to returning aircraft, the prosecutor's fallacy, the island problem, Cromwell's rule, Hume on miracles, the Sally Clark case, the O. J. Simpson case, and the chess cheating accusation against Nakamura. It then treats the naive Bayes classifier, sensitivity, specificity, type I and type II errors, positive predictive value, Monte Carlo simulation of the 2012 US presidential election with a Dirichlet distribution, and Bayesian networks with explaining away.

## From the literature

Banburismus, the sequential use of conditional probability by Alan Turing against the Enigma machine (Simpson 2010); Abraham Wald's analysis of damage to returning aircraft in the Second World War; Cromwell's rule, named for Oliver Cromwell's 1650 letter to the General Assembly of the Church of Scotland; David Hume's argument on miracles; the Monty Hall problem and Marilyn vos Savant's column; the analysis of the Dershowitz argument in the Simpson case (Good 1995); the positive predictive value of the Apple Watch atrial fibrillation algorithm by age group (Yazdi 2019).

## New results

The one catalog entry is the authors' Bayesian analysis of the Kramnik and Nakamura chess cheating controversy (Maharaj, Polson and Sokolov 2023), reproduced in the chapter.

<!-- results:begin -->
- [Posterior probability that Nakamura did not cheat given a 45 win streak](../RESULTS.md#nakamura_streak_posterior_innocence) (Example 2.10, page 82; conditional on prior odds of innocence N = 10000, the assessment attributed to Viswanathan Anand (N = 500 in the sensitivity analysis), a streak of 45 wins in 46 games with a draw counted as not a win, independent games with one common win probability q = 0.8916 (Nakamura's own estimate), and probability 1 of the evidence under guilt): Under Anand's prior of 1 in 10000 and a binomial model of the streak, the posterior probability that Nakamura did not cheat is 0.9965. First stated in Maharaj, Polson and Sokolov (2023), Kramnik vs Nakamura or Bayes vs P Value, SSRN 4648621.
<!-- results:end -->

## Key terms

Bayes rule, Bayes theorem, Bayesian updating, conditional probability, prior, posterior, likelihood, base rate fallacy, law of total probability, odds form, Bayes factor, conditional independence, naive Bayes classifier, sensitivity, specificity, positive predictive value, type I error, type II error, confusion matrix, Monty Hall, prosecutor's fallacy, island problem, Cromwell's rule, Sally Clark, explaining away, Bayesian network, Dirichlet distribution
