# Code of chapter: AI Agents
# Every R chunk of the chapter in book order, including the ones the book does not print. Chunks the book does not run are commented out.
# Run from the book folder: Rscript code/25-robots.R. Data are read from the data folder. Figures go to the graphics device (Rplots.pdf under Rscript).

source("code/common.R")

# ---- Agent Cost and Performance Analysis -----------------------------------

# Simulated agent runs on 50 tasks
set.seed(42)
n_tasks <- 50

# Each task has: n_llm_calls, input_tokens, output_tokens, n_tool_calls, success
tasks <- data.frame(
  task_id = 1:n_tasks,
  n_llm_calls = rpois(n_tasks, 4) + 1,
  avg_input_tokens = round(rnorm(n_tasks, 800, 200)),
  avg_output_tokens = round(rnorm(n_tasks, 200, 80)),
  n_tool_calls = rpois(n_tasks, 2)
)
tasks$avg_input_tokens <- pmax(tasks$avg_input_tokens, 100)
tasks$avg_output_tokens <- pmax(tasks$avg_output_tokens, 50)

tasks$success <- rbinom(n_tasks, 1, plogis(-3 + 0.8 * tasks$n_llm_calls))
