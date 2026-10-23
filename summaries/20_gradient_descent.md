# Chapter 20. Gradient Descent

<!-- cite:begin -->
From *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science* by Nick Polson and Vadim Sokolov (2026), chapter 20. Cite as Polson and Sokolov (2026), *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science*, edition 1, https://doi.org/10.5281/zenodo.23603837. Book page: https://vsokolov.org/books/bayes_ai_deep_learning/. Source: https://github.com/VadimSokolov/bayes_ai_deep_learning.
<!-- cite:end -->

How are the parameters of a model with millions of weights fitted when second order methods such as Newton's method and BFGS are too costly? The chapter treats estimation as minimizing a negative log likelihood and develops first order methods. It covers gradient descent and the learning rate, with least squares and logistic regression fitted on the iris data and compared with lm and glm, and stochastic gradient descent with mini batches. It traces backpropagation from the perceptron and the delta rule, and explains automatic differentiation in forward mode and reverse mode with dual numbers, a computational graph and a JAX example. It surveys momentum, Nesterov acceleration, AdaGrad, RMSprop and Adam, states the Robbins Monro stochastic approximation algorithm and its step size conditions, and presents the EM, ECM and ECME algorithms and simulated annealing.

## From the literature

stochastic approximation and the Robbins Monro algorithm (Robbins and Monro 1951); the perceptron (Rosenblatt 1958); the delta rule (Widrow and Hoff 1960); limits of single layer perceptrons (Minsky and Papert 1969); generalized linear models and iteratively reweighted least squares (Nelder and Wedderburn 1972); multilayer network training (Galushkin 1974); backpropagation as reverse mode differentiation (Linnainmaa 1970; Werbos 1974; Werbos 1982; Rumelhart, Hinton and Williams 1986), with precursors in control theory (Bryson 1961; Dreyfus 1962; Bryson and Ho 1969) and a historical account (Schmidhuber 2015); SGD on strongly convex functions (Bottou, Curtis and Nocedal 2018); the large batch generalization gap (Keskar et al. 2016); momentum (Polyak 1964); Nesterov acceleration (Nesterov 1983); AdaGrad (Duchi, Hazan and Singer 2011); RMSprop (Hinton, Srivastava and Swersky 2012); Adam (Kingma and Ba 2014); the monotonicity proof for EM (Dempster et al. 1977); the ECME algorithm (Liu and Rubin 1994); latent variable simulated annealing for maximum likelihood (Jacquier, Johannes and Polson 2007).

## New results

<!-- results:begin -->
No new results of this chapter are catalogued.
<!-- results:end -->

## Key terms

gradient descent, stochastic gradient descent, steepest descent, SGD, minibatch, learning rate, step size, loss function, negative log likelihood, backprop, back propagation, automatic differentiation, algorithmic differentiation, AD, forward mode, reverse mode, dual numbers, computational graph, autograd, JAX, heavy ball, Nesterov accelerated gradient, NAG, Robbins Monro, stochastic approximation, M estimation, EM algorithm, expectation maximization, ECM, ECME, simulated annealing, LVSA, Newton's method, Hessian, BFGS, IRLS
