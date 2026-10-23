# Chapter 25. AI Agents

<!-- cite:begin -->
From *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science* by Nick Polson and Vadim Sokolov (2026), chapter 25. Cite as Polson and Sokolov (2026), *Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science*, edition 1, https://doi.org/10.5281/zenodo.23603837. Book page: https://vsokolov.org/books/bayes_ai_deep_learning/. Source: https://github.com/VadimSokolov/bayes_ai_deep_learning.
<!-- cite:end -->

This chapter asks what changes when the output of a large language model is allowed to act, and how such agents are built, orchestrated, evaluated and kept safe. An LLM agent combines perception, reasoning, memory (retrieval augmented generation) and tools reached by function calling, driven by an orchestrator in a reason act observe loop. The chapter surveys ReAct, orchestration patterns (sequential, parallel, hierarchical, dynamic) for multi agent systems, agent evaluation and benchmarks (SWE bench, TAU bench, WebArena, ALFRED), agent safety (prompt injection, goal misalignment, corrigibility, red teaming) and embodied agents (sensor fusion, the sim to real gap, vision language action models). Case studies cover a Replit agent that destroyed production data, Anthropic's AI Safety Level 3 protections, ChatDev and a red teaming project. The text states no theorems and has no code; R exercises build an agent loop, simulate agent costs and score a rule based red team scanner.

## From the literature

ChatDev, communicative agents for software development with chat chains (Qian et al. 2024); personality, values and demographics of GPT 3 (Miotto, Rossberg and Kleinberg 2022); a psychometric framework for evaluating and shaping personality in language models with the IPIP NEO and Big Five Inventory (Serapio García et al. 2025); generative agent simulations of 1,000 people built from two hour interviews (Park et al. 2024); the ReAct reason plus act framework (Google); AI Safety Level 3 protections with Constitutional Classifiers, activated for Claude Opus 4 in May 2025 (Anthropic); a red teaming study of a computer use agent with over 1,200 test scenarios (Toloka); the July 2025 Replit agent incident (reported by The Register); Shakey the Robot (SRI International, 1960s); Gemini Robotics, a vision language action model built on Gemini 2.0, and the ASIMOV safety dataset (Google DeepMind).

## New results

<!-- results:begin -->
No new results of this chapter are catalogued.
<!-- results:end -->

## Key terms

AI agents, agentic AI, LLM agents, autonomous agents, tool use, function calling, tool calling, ReAct, retrieval augmented generation, RAG, multi agent systems, hierarchical orchestration, SWE bench, TAU bench, WebArena, ALFRED, LLM as a judge, prompt injection, goal misalignment, corrigibility, red teaming, AI safety, Constitutional Classifiers, embodied agents, robotics, SLAM, sim to real gap, domain randomization, vision language action model, VLA, Gemini Robotics
