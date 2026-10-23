# Code of chapter: Large Language Models
# Every Python chunk of the chapter in book order, including the ones the book does not print. Chunks the book does not run are commented out.
# Run from the book folder: python code/24-llm.py. Data are read from the data folder.
# Data: data/wikipedia-cat.txt
# Packages: collections, matplotlib, numpy, os, pathlib, random, seaborn, textwrap, torch, transformers

# ---- Building Intuition: Character-Level Text Generation -------------------

# [fetch-cat-article]
# Plain text of the Wikipedia article "Cat", cached locally so the book renders
# without network access. To refresh it (Wikipedia returns 403 without a
# User-Agent, and a silent error page would poison every count below):
#     r = requests.get("https://en.wikipedia.org/wiki/Cat",
#                      headers={"User-Agent": "BayesAIBook/1.0"}, timeout=30)
#     r.raise_for_status()
#     text = BeautifulSoup(r.text, "html.parser").get_text()
with open("data/wikipedia-cat.txt", encoding="utf-8") as fh:
    cat_text = "".join(ln for ln in fh if not ln.startswith("#"))

# [letter-counts]
from collections import Counter
letter_counts = Counter(c.lower() for c in cat_text if c.isalpha())
# Sort by frequency
sorted_letter_counts = sorted(letter_counts.items(), key=lambda x: x[1], reverse=True)

# [plot-letter-frequencies]
import matplotlib.pyplot as plt
sorted_letter_counts = sorted_letter_counts[:26];  # Limit to top 26 letters
letters, counts = zip(*sorted_letter_counts);
plt.bar(letters, counts, color='skyblue')
plt.xlabel('Letters')
plt.ylabel('Frequency')
plt.title('Letter Frequencies in Wikipedia Article on Cats')
plt.xticks(rotation=0);
plt.tight_layout()
plt.show()

# [generate-random-letters]
import numpy as np
# Generate text one letter at a time by sampling from the letter frequencies
counts = np.array(counts)/sum(counts)  # Normalize counts to probabilities
import random
random.seed(42)  # Fix the seed for reproducibility
gentext = random.choices(letters, weights=counts, k=20)
print("Generated letters:", ''.join(gentext))

# [bigram-heatmap]
from collections import defaultdict
bigram_counts = defaultdict(int)
for i in range(len(cat_text) - 1):
    if cat_text[i].isalpha() and cat_text[i + 1].isalpha():
        a, b = cat_text[i].lower(), cat_text[i + 1].lower()
        # Only process standard English letters (a-z)
        if 'a' <= a <= 'z' and 'a' <= b <= 'z':
            bigram = (a, b)
            bigram_counts[bigram] += 1

# Sort by frequency
sorted_bigram_counts = sorted(bigram_counts.items(), key=lambda x: x[1], reverse=True)

# Plot the heatmap of bigram frequencies
import seaborn as sns
bigram_matrix = np.zeros((26, 26))
for (a, b), count in sorted_bigram_counts:
    bigram_matrix[ord(a) - ord('a'), ord(b) - ord('a')] = count

sns.heatmap(bigram_matrix, cmap='Blues')
plt.xlabel('Second Letter')
plt.ylabel('First Letter')
plt.title('Bigram Frequencies in Wikipedia Article on Cats')
plt.xticks(ticks=np.arange(26) + 0.5, labels=[chr(i + ord('a')) for i in range(26)], rotation=0, fontsize=6);
plt.yticks(ticks=np.arange(26) + 0.5, labels=[chr(i + ord('a')) for i in range(26)], rotation=0, fontsize=6);
plt.tight_layout()

# ---- Pretraining and Generation: One Token at a Time -----------------------

# [load-pkg]
# (the book does not run this chunk when it builds; it has no output in the book, and it stays active here because the chunks after it use what it defines)
import os, sys
from pathlib import Path
import torch
import textwrap
from transformers import AutoModelForCausalLM, AutoTokenizer

# [load-model]
# (the book does not run this chunk when it builds; it has no output in the book, and it stays active here because the chunks after it use what it defines)
sys.path.append('./code')
# Import our custom functions
from llm_chapter import (ask_smol_lm, get_next_word_suggestions, generate_text_step_by_step)

local_cache_dir = "./models_cache"  # or the path of any other folder with room for the model files
# Create directory if it doesn't exist
Path(local_cache_dir).mkdir(parents=True, exist_ok=True)
# Load model with custom cache directory
model_id = "HuggingFaceTB/SmolLM2-1.7B-Instruct"
# Downloads once into local_cache_dir. Once it is there, set HF_HUB_OFFLINE=1
# to load straight from disk: otherwise every call checks the Hub for a newer
# revision, so the book stops building the day that endpoint moves.
if (Path(local_cache_dir) / f"models--{model_id.replace('/', '--')}").exists():
    os.environ["HF_HUB_OFFLINE"] = "1"
tokenizer = AutoTokenizer.from_pretrained(model_id, cache_dir=local_cache_dir)
model = AutoModelForCausalLM.from_pretrained(model_id,cache_dir=local_cache_dir,device_map="auto",dtype=torch.float16,low_cpu_mem_usage=True);
device = model.device
# print("Model loaded. Using device:", device)

# [next-word-suggestions-code]
# (the book does not run this chunk when it builds; its output is kept in results/24-llm/next-word-suggestions-*)
# Get next word suggestions for a given text
initial_text = "The best thing about AI is its ability to"
suggestions = get_next_word_suggestions(initial_text, model, tokenizer, top_k=5)
print(f"Next word suggestions for '{initial_text}':")
for i, (word, prob) in enumerate(suggestions):
    print(f"  {i+1}. '{word}' (prob: {prob:.3f})")

# [next-word-logprob-code]
# (the book does not run this chunk when it builds; its output is kept in results/24-llm/fig-next-word-logprob-*)
import matplotlib.pyplot as plt
import numpy as np
suggestions = get_next_word_suggestions(initial_text, model, tokenizer, top_k=10)
indices = list(range(len(suggestions)))
words = [s[0] for s in suggestions]
probabilities = [s[1] for s in suggestions]
# Plotting the next word suggestions with their log probabilities
plt.plot(indices, np.log10(probabilities), marker='o', linestyle='-', color='skyblue')
plt.xticks(indices, words, rotation=45, ha='right');
plt.xlabel('Next Word Suggestions')
plt.ylabel('$\\log_{10}$ Probability')
plt.tight_layout()
plt.show()

# [sampling-step-code]
# (the book does not run this chunk when it builds; it has no output in the book, and it is commented out here: remove the comment marks to run it)
# if sample:
#     probs = torch.softmax(next_token_logits.float() / temperature, dim=-1)
#     next_token_id = torch.multinomial(probs, num_samples=1).item()
# else:
#     next_token_id = torch.argmax(next_token_logits).item()

# [initial-text-setup]
# Let's start with a simple prompt
initial_text = "The best thing about AI is its ability to"
print(f"Initial text: '{initial_text}'")

# [generate-step-by-step-code]
# (the book does not run this chunk when it builds; its output is kept in results/24-llm/generate-step-by-step-*)
# Generate text step by step
generated_text = generate_text_step_by_step(initial_text, model, tokenizer, 
num_steps=10, temperature=1.0, sample=False, print_progress=False)
print("Generated text:")
print(textwrap.fill(generated_text, width=60))

# [generate-temperature-0p8-code]
# (the book does not run this chunk when it builds; its output is kept in results/24-llm/generate-temperature-0p8-*)
# Fix the seed for reproducibility
torch.manual_seed(8)
generated_text = generate_text_step_by_step(initial_text, model, tokenizer,
 num_steps=60, temperature=0.8, sample=True, print_progress=False)
print("Generated text:")
print(textwrap.fill(generated_text, width=60))

# [generate-temperature-1p2-code]
# (the book does not run this chunk when it builds; its output is kept in results/24-llm/generate-temperature-1p2-*)
torch.manual_seed(8)
generated_text = generate_text_step_by_step(initial_text, model, tokenizer,
 num_steps=60, temperature=1.2, sample=True, print_progress=False)
print("Generated text:")
print(textwrap.fill(generated_text, width=60))

# ---- Scale and Its Limits --------------------------------------------------

# [fig-llm-param-growth]
import matplotlib.pyplot as plt
models = [
    ("GPT-1", 2018.45, 0.117, False, (6, -3)),
    ("BERT", 2018.8, 0.34, False, (6, 3)),
    ("GPT-2", 2019.1, 1.5, False, (-6, 5)),
    ("T5", 2019.8, 11, False, (-14, 5)),
    ("GPT-3", 2020.4, 175, False, (-8, 7)),
    ("Gopher", 2021.95, 280, False, (-38, -3)),
    ("Chinchilla", 2022.2, 70, False, (7, -10)),
    ("PaLM", 2022.3, 540, False, (6, 3)),
    ("LLaMA", 2023.15, 65, False, (6, -3)),
    ("Llama 3.1", 2024.6, 405, False, (-26, -14)),
    ("DeepSeek-V3", 2024.98, 671, True, (-36, 6)),
]
fig, ax = plt.subplots(figsize=(5.5, 3))
for name, year, size, moe, offset in models:
    ax.plot(year, size, "o", color="black", markerfacecolor="white" if moe else "black")
    ax.annotate(name, (year, size), textcoords="offset points", xytext=offset, fontsize=7)
ax.set_yscale("log")
ax.set_xlabel("Year of release")
ax.set_ylabel("Parameters (billions)")
ax.set_ylim(0.05, 2000);
plt.tight_layout()
plt.show()
