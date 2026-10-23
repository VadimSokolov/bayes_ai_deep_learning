# Chapter 22. Convolutional Neural Networks

<!-- cite:begin -->
From *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science* by Nick Polson and Vadim Sokolov (2026), chapter 22. Cite as Polson and Sokolov (2026), *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science*, edition 1, https://doi.org/10.5281/zenodo.23603837. Book page: https://vsokolov.org/books/bayes_ai_deep_learning/. Source: https://github.com/VadimSokolov/bayes_ai_deep_learning.
<!-- cite:end -->

This chapter asks how a neural network for image data can use the spatial structure of images, and how a convolutional neural network (CNN) compares with a fully connected network on handwritten digits. It starts from two priors, locality and translation equivariance, and from the history of the Neocognitron. A filter (kernel) is a small matrix of weights shared across positions. A hand calculation of a diagonal filter on $3\times3$ patches of a $5\times5$ cross yields responses 3 and 1, and shifting a stroke one pixel moves the response, which is translation equivariance, whereas invariance would leave the output unchanged. The chapter defines stride, receptive field and same and valid padding, notes that deep learning libraries compute cross correlation and call it convolution, and applies a moving average filter of length 10 to a noisy sine wave. A toy example with two fixed $3\times3$ filters, a global maximum and a softmax layer separates cross, diagonal and right diagonal images, and global pooling discards position. On MNIST (28 by 28 grayscale digits, ten classes), a fully connected JAX network (784, 1024, 1024 and 10 units, tanh, log softmax, minibatch SGD) reaches 80 percent training and 77 percent held out accuracy. A PyTorch CNN (two Conv2d layers, ReLU, 2 by 2 max pooling, two linear layers, Adadelta) reaches 93 percent, with 1,199,882 parameters against 1,863,690. Most CNN parameters sit in its dense head, and the chapter warns that the gap does not isolate convolution, since architecture, activation, optimizer and framework all differ. The chapter develops intuition and code; it states no theorems.

## From the literature

the Neocognitron, a hierarchical network with convolutional and pooling layers inspired by simple and complex cells of the visual cortex (Fukushima 1980; Hubel and Wiesel are named without a reference); backpropagation applied to a simplified Neocognitron for alphabet recognition (Zhang, Itoh, Tanida and Ichioka 1988)

## New results

<!-- results:begin -->
No new results of this chapter are catalogued.
<!-- results:end -->

## Key terms

convolutional neural network, CNN, ConvNet, convolution, convolutional layer, cross correlation, filter, kernel, receptive field, stride, padding, zero padding, max pooling, pooling layer, weight sharing, parameter sharing, local connectivity, translation invariance, inductive bias, image classification, computer vision, MNIST, handwritten digit recognition, fully connected network, multilayer perceptron, feed forward network, softmax, log softmax, cross entropy, stochastic gradient descent, Adadelta, JAX, PyTorch, Conv2d, moving average, kernel smoothing, Neocognitron, Fukushima, Hubel and Wiesel
