# Chapter 9. Reinforcement Learning

<!-- cite:begin -->
From *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science* by Nick Polson and Vadim Sokolov (2026), chapter 9. Cite as Polson and Sokolov (2026), *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science*, edition 1. Book page: https://vsokolov.org/books/bayes_ai_deep_learning/. Source: https://github.com/VadimSokolov/bayes_ai_deep_learning.
<!-- cite:end -->

How should an agent choose which data to collect, or which action to take, when each choice changes what it learns and earns next? The chapter treats sequential experimental design and sequential decision making under uncertainty. It covers multi armed bandit experiments (Thompson sampling with Beta posteriors, the posterior probability that an arm is best, a regret based stopping rule, contextual bandits), the Bellman principle of optimality and its use to derive the 37% rule for the secretary problem, checked by Monte Carlo simulation, and Markov decision processes (state value and action value functions, the Bellman expectation equation solved by a matrix inverse, the Bellman optimality equation solved by policy iteration and value iteration, with student chain, forest management, maze and Deal or No Deal examples). It then presents model free methods (Monte Carlo prediction with first visit and every visit averaging, epsilon greedy exploration, temporal difference learning, Q learning) and Bayesian optimization with a Gaussian process surrogate and the expected improvement acquisition function, whose closed form is derived and applied to a taxi fleet simulator.

## From the literature

multi armed bandit experiments (Scott 2015); the value remaining stopping rule of Google Analytics (quoted in the chapter, no reference); Thompson sampling (named in the chapter, no reference); the principle of optimality due to Richard Bellman; Markov decision processes, with a core body of research resulting from Howard 1960; finite step termination of policy iteration for finite Markov decision processes (Puterman 2014); trial and error learning demonstrated by Claude Shannon's maze solving mechanical mouse Theseus in the 1950s

## New results

<!-- results:begin -->
No new results of this chapter are catalogued.
<!-- results:end -->

## Key terms

reinforcement learning, RL, multi armed bandit, multiarmed bandit, MAB, contextual bandit, Thompson sampling, regret, value remaining, A/B testing, adaptive experimental design, exploration and exploitation, epsilon greedy, secretary problem, marriage problem, 37% rule, optimal stopping, Bellman equation, principle of optimality, dynamic programming, backward induction, Markov decision process, MDP, Markov reward process, discount factor, value function, action value function, policy iteration, value iteration, Monte Carlo, first visit, every visit, temporal difference, Q learning, off policy, model free, Bayesian optimization, Gaussian process, acquisition function, expected improvement, black box optimization, Deal or No Deal
