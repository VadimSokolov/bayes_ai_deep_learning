# Chapter 4. Utility, Risk and Decisions

<!-- cite:begin -->
From *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science* by Nick Polson and Vadim Sokolov (2026), chapter 4. Cite as Polson and Sokolov (2026), *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science*, edition 1. Book page: https://vsokolov.org/books/bayes_ai_deep_learning/. Source: https://github.com/VadimSokolov/bayes_ai_deep_learning.
<!-- cite:end -->

The chapter asks how an agent should choose actions under uncertainty and how a posterior distribution becomes a decision. It presents expected utility theory, its axioms and the uniqueness of utility up to positive affine transformation, risk aversion, certainty equivalents, risk premium and constant relative risk aversion (CRRA), and the Kelly criterion for growth optimal betting with a leveraged Berkshire Hathaway example. A historical section treats de Finetti's reinsurance retention problem, Markowitz mean variance portfolios, Bellman's principle of optimality and Livermore's trading maxims. Statistical decision theory covers loss functions, classical risk, Bayes risk, minimax rules, posterior expected loss and generalized Bayes rules. Paradoxes and puzzles include Saint Petersburg, Newcomb, Ellsberg, Allais, the winner's curse, lemons and two envelopes, with decision trees for medical testing and a mudslide wall. The chapter ends with Nash equilibrium, mixed strategies and tit for tat in a marble game.

## From the literature

expected utility from the axioms of completeness, transitivity, continuity and independence (Ramsey 1926; de Finetti 1931; Savage 1954; von Neumann and Morgenstern); the Saint Petersburg paradox (Daniel Bernoulli 1738); Newcomb's problem (Nozick 1969; Seidenfeld 1984); the Kelly criterion (Kelly 1956; Thorp 2011); reinsurance retention and the index of stability (de Finetti 1940), with Markowitz's acknowledgement and correct last segment theorem (Markowitz 2006), mean variance portfolios (Markowitz 1952; Roy 1952) and the critical line algorithm (Markowitz 1956); the principle of optimality (Bellman 1957); the Ellsberg paradox (Ellsberg 1961); the Allais paradox (Maurice Allais); the market for lemons (Akerlof 1970); the two envelope problem (Christensen and Utts 1992; Blachman, Christensen and Utts 1996); Nash equilibrium (Nash 1950); tit for tat in Axelrod's tournaments

## New results

The catalog records two informal results cited to earlier papers of Polson and coauthors: Livermore's maxims as Bellman value comparisons (Polson and Witte 2014) and the option value of learning in Bernoulli Beta asset allocation (Jacquier and Polson 2013).

<!-- results:begin -->
- [Option value of learning in Bernoulli Beta asset allocation](../RESULTS.md#bernoulli_beta_option_value_of_learning) (Section 4.2.3, page 162; conditional on the dynamic Bellman solution of Jacquier and Polson (2013), which the chapter quotes and does not derive; the utility function, the payoff structure and the recursion behind the 11.7 percent allocation are not specified): With a Beta prior on an unknown success probability and unfavorable prior odds, the myopic Kelly rule invests nothing while the dynamic Bellman solution invests a small positive amount because of the option value of learning. First stated in Jacquier and Polson (2013), Asset Allocation in Finance: A Bayesian Perspective, in Bayesian Theory and Applications, Oxford University Press, pages 501 to 515.
- [Livermore's trading maxims as Bellman value comparisons](../RESULTS.md#livermore_maxims_bellman_view) (Section 4.2.4, page 163; conditional on the claim, which the chapter asserts by an appeal to Bayes' theorem and does not derive (it cites Polson and Witte 2014), that observing a loss lowers the value of the long action below the value of the neutral action, and, for never average down, that no outside information beyond what the market revealed has arrived): Livermore's maxims to cut losses and never average down are read as inequalities between Bellman action values after Bayesian updating of beliefs. First stated in Polson and Witte (2014), A Bellman View of Jesse Livermore, arXiv:1407.2642.
<!-- results:end -->

## Key terms

expected utility, risk aversion, risk premium, certainty equivalent, Kelly criterion, Saint Petersburg paradox, St Petersburg paradox, Newcomb's paradox, Ellsberg paradox, Allais paradox, winner's curse, lemons problem, adverse selection, two envelope paradox, exchange paradox, decision tree, value of information, loss function, Bayes risk, Bayes rule, posterior expected loss, minimax, dynamic programming, Nash equilibrium, mixed strategy, prisoner's dilemma, tit for tat
