# Chapter 18. Neural Networks

<!-- cite:begin -->
From *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science* by Nick Polson and Vadim Sokolov (2026), chapter 18. Cite as Polson and Sokolov (2026), *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science*, edition 1, https://doi.org/10.5281/zenodo.23603837. Book page: https://vsokolov.org/books/bayes_ai_deep_learning/. Source: https://github.com/VadimSokolov/bayes_ai_deep_learning.
<!-- cite:end -->

This chapter asks how deep learning extends generalized linear models and what hidden layers add to regression and classification. A feedforward neural network is a composition of layers, each an affine map followed by a nonlinear activation function; wide and shallow models are contrasted with deep and narrow networks that learn features. Products and maxima are written through univariate functions of linear combinations, and nested ReLU layers reduce to a max sum network. R examples separate an inner cluster from an outer ring with a hand specified hidden layer and fit one hidden layer networks by BFGS to noisy quadratic and interaction data. The chapter then covers activation functions, vanishing gradients, autoencoders, transfer learning, mixture of experts and ensembles. It proves no theorems.

## From the literature

nonlinear functions of linear combinations, discussed in the context of projection pursuit regression (Diaconis and Shahshahani 1984); nested positive parts as a maximum of partial sums (Feller 1971); autoencoders for smart indexing in finance (Heaton, Polson and Witte 2016); PCA, PLS and sliced inverse regression as factor models (see Cook 2007); adaptive mixtures of local experts (Jacobs, Jordan, Nowlan and Hinton 1991); denseness, approximation rate and identifiability of mixtures of experts (Jiang and Tanner 1999); an auxiliary mixture of linear experts for nonlinear state space models (Stroud, Müller and Polson 2003); sparsely gated mixture of experts layers (Shazeer et al. 2017); Switch Transformers (Fedus, Zoph and Shazeer 2022); sparse mixture of experts for vision (Riquelme et al. 2021); ensembles of accurate and diverse models (Dietterich 2000); snapshot ensembles (Huang et al. 2017); dropout (Srivastava et al. 2014); dropout as approximate Bayesian inference (Gal and Ghahramani 2016); BERT (Devlin et al. 2019); GPT (Radford et al. 2018; Brown et al. 2020).

## New results

<!-- results:begin -->
No new results of this chapter are catalogued.
<!-- results:end -->

## Key terms

neural network, artificial neural network, deep learning, feedforward network, multilayer perceptron, MLP, hidden layer, activation function, sigmoid, tanh, ReLU, leaky ReLU, softplus, vanishing gradient, universal approximator, max sum network, projection pursuit regression, BFGS, autoencoder, auto encoder, dimension reduction, ADMM, sliced inverse regression, transfer learning, fine tuning, mixture of experts, MoE, gating network, ensemble, snapshot ensemble, dropout, Monte Carlo dropout, bias variance, AlexNet
