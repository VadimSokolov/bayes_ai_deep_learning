# Chapter 23. Natural Language Processing

<!-- cite:begin -->
From *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science* by Nick Polson and Vadim Sokolov (2026), chapter 23. Cite as Polson and Sokolov (2026), *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science*, edition 1. Book page: https://vsokolov.org/books/bayes_ai_deep_learning/. Source: https://github.com/VadimSokolov/bayes_ai_deep_learning.
<!-- cite:end -->

This chapter asks how discrete text can be turned into vectors a neural network can use, and how attention and the Transformer produce context dependent representations of language. It starts with one hot encoding, Twenty Questions and the distributional hypothesis. Word2vec (skip gram and continuous bag of words, CBOW) is followed by two remedies for the cost of the softmax, negative sampling and hierarchical softmax, then by GloVe as weighted matrix factorization of log co occurrence counts, a War and Peace example, and subword tokenization by FastText n grams and byte pair encoding (BPE). Attention is developed from queries, keys and values and from kernel smoothing (Nadaraya Watson regression), then as self attention over a sequence, multi head attention, and sinusoidal positional encodings. The Transformer is an encoder decoder stack with masked decoding, feed forward layers, residual connections and layer normalization, followed by the encoder only, decoder only and encoder decoder families. BERT is a historical case study (masked language modeling, next sentence prediction, ELMo and GPT). Transfer learning covers a sentiment decision, natural language inference, named entity recognition and extractive question answering, and compression covers knowledge distillation. The chapter closes with theoretical limits. It states known results without proof and develops no new theorem.

## From the literature

the distributional hypothesis (Firth 1957); word2vec (Mikolov et al. 2013); the optimum of negative sampling as shifted pointwise mutual information (Levy and Goldberg 2014); GloVe (Pennington, Socher and Manning 2014); FastText (Bojanowski et al. 2017); attention for machine translation (Bahdanau, Cho and Bengio 2014); Nadaraya Watson kernel regression (Nadaraya 1964; Watson 1964); the Eckart Young theorem; the Transformer with sinusoidal positional encodings (Vaswani et al. 2017); hierarchical softmax (Morin and Bengio 2005); attention trained by reinforcement learning (Mnih et al. 2014); T5 (Raffel et al. 2020); BERT (Devlin et al. 2019); DistilBERT (Sanh et al. 2019); universal approximation of sequence to sequence functions by Transformers (Yun et al. 2020)

## New results

<!-- results:begin -->
No new results of this chapter are catalogued.
<!-- results:end -->

## Key terms

NLP, word embeddings, word vectors, distributed representations, distributional semantics, word2vec, skip gram, SGNS, CBOW, negative sampling, hierarchical softmax, GloVe, FastText, subword tokenization, byte pair encoding, BPE, WordPiece, attention, self attention, cross attention, multi head attention, positional encoding, permutation equivariance, Transformer, BERT, GPT, language model, pretraining, fine tuning, knowledge distillation, DistilBERT, machine translation, universal approximation
