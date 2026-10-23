# Chapter 24. Large Language Models

<!-- cite:begin -->
From *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science* by Nick Polson and Vadim Sokolov (2026), chapter 24. Cite as Polson and Sokolov (2026), *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science*, edition 1. Book page: https://vsokolov.org/books/bayes_ai_deep_learning/. Source: https://github.com/VadimSokolov/bayes_ai_deep_learning.
<!-- cite:end -->

This chapter asks how a large language model (LLM) is built, adapted, aligned, evaluated and deployed, with a fictional shop assistant and two return policies as a running example. It starts from character level n gram generation, then shows next token prediction and temperature sampling with SmolLM2. Learning and inference covers fine tuning, LoRA, knowledge distillation, and alignment: RLHF, direct preference optimization (DPO) with a sketch of its derivation, constitutional AI, safety alignment and reward hacking. It then treats data quality (s1, LIMO, rStar Math), verifiable rewards with GRPO, inference time reasoning (chain of thought, tree of thoughts, Reflexion, test time compute) and what reasoning traces show. Context engineering covers retrieval augmented generation (RAG), hybrid retrieval, reranking, lost in the middle, compression and tiered memory. The chapter then turns to evaluation, model choice, scale, quantization, speculative decoding, KV caching, FlashAttention and small models, and closes with neural memory research and a table of how the techniques combine. It states no theorems.

## From the literature

the Transformer (Vaswani et al. 2017); neural machine translation with attention (Bahdanau et al. 2014); knowledge distillation (Hinton et al. 2015); DistilBERT (Sanh et al. 2019); Flan PaLM instruction tuning (Chung et al. 2022); InstructGPT with RLHF (Ouyang et al. 2022); direct preference optimization (Rafailov et al. 2023); constitutional AI (Bai et al. 2022); s1 (Muennighoff et al. 2025); LIMO (Ye et al. 2025); rStar Math (Guan et al. 2025); chain of thought prompting (Wei et al. 2023); tree of thoughts (Yao et al. 2023); Chain of Action (Pan et al. 2025); Reflexion (Shinn et al. 2023); lost in the middle (Liu et al. 2024); RAPTOR (Sarthi et al. 2024); HyDE (Gao et al. 2022); LLMLingua 2 (Pan et al. 2024); MemGPT (Packer et al. 2023); speculative decoding (Leviathan et al. 2023; Chen et al. 2023); FlashAttention (Dao et al. 2022; Shah et al. 2024); Ring Attention (Liu et al. 2023); Titans and MIRAS (Behrouz et al. 2025); Larimar (Das et al. 2024)

## New results

<!-- results:begin -->
No new results of this chapter are catalogued.
<!-- results:end -->

## Key terms

large language model, LLM, Transformer, autoregressive generation, fine tuning, LoRA, knowledge distillation, alignment, RLHF, DPO, constitutional AI, reward hacking, verifiable rewards, GRPO, chain of thought, test time compute, RAG, retrieval augmented generation, reranking, context window, context engineering, lost in the middle, quantization, speculative decoding, KV cache, FlashAttention, neural memory
