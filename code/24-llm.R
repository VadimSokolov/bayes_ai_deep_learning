# Code of chapter: Large Language Models
# Every R chunk of the chapter in book order, including the ones the book does not print. Chunks the book does not run are commented out.
# Run from the book folder: Rscript code/24-llm.R. Data are read from the data folder. Figures go to the graphics device (Rplots.pdf under Rscript).

source("code/common.R")

# ---- Temperature and Sampling Strategies -----------------------------------

# Simulated logits for a vocabulary of 10 tokens
set.seed(123)
vocab <- paste0("token_", 1:10)
logits <- c(4.5, 3.2, 2.8, 2.1, 1.5, 0.8, 0.3, -0.5, -1.2, -2.0)
names(logits) <- vocab
