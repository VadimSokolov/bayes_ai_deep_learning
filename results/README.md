# Stored output of the chunks that the book does not run

A few chunks take too long to run every time the book is built; one of them, for example, loads a language model of 1.7 billion parameters. The chapter keeps the code of such a chunk with `eval: false` and shows the output that the chunk had when it was last run, from the files in this folder. The code is in the code file of the chapter (`code/STEM.R` or `code/STEM.py`), in a chunk whose label ends in `-code`.

The files of a chunk are named `results/STEM/NAME-k.png` and `NAME-k.pdf` for figure k (the PDF is the vector figure of the print edition), `NAME.txt` for the text output and `NAME.md` for a table. The chapter shows them with `cached_fig("STEM/NAME")`, `cached_text("STEM/NAME")` and `cached_md("STEM/NAME")`, three functions defined in `misc/common.qmd`.

To refresh an output, run the chunk (the code file of the chapter has it) and replace the files. The book does not run the chunk, so a change of its code does not change the output shown: run the chunk again after every change.

| Chapter | Name | Files |
|---|---|---|
| Chapter 13: Logistic Regression and Generalized Linear Models | `bayesian-betting-results` | `bayesian-betting-results.rds`; Posterior summaries of the betting model, written by `code/13-logistic-benter.R`. |
| Chapter 15: Forecasting | `fig-pl-mixture` | `fig-pl-mixture-1.pdf`, `fig-pl-mixture-1.png`, `fig-pl-mixture-2.pdf`, `fig-pl-mixture-2.png` |
| Chapter 15: Forecasting | `tft-forecast` | `tft-forecast.csv`; Quantile forecasts of the Temporal Fusion Transformer ensemble, written by `code/15-forecasting-tft.py`. |
| Chapter 24: Large Language Models | `fig-next-word-logprob` | `fig-next-word-logprob-1.pdf`, `fig-next-word-logprob-1.png` |
| Chapter 24: Large Language Models | `generate-step-by-step` | `generate-step-by-step.txt` |
| Chapter 24: Large Language Models | `generate-temperature-0p8` | `generate-temperature-0p8.txt` |
| Chapter 24: Large Language Models | `generate-temperature-1p2` | `generate-temperature-1p2.txt` |
| Chapter 24: Large Language Models | `next-word-suggestions` | `next-word-suggestions.txt` |
