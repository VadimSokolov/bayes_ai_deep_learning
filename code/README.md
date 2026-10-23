# Code of the book

This folder holds the code of the book, so that every example can be run without building the book.

## One file per language per chapter

Each chapter has its code in one file per language: `NN-topic.R` for the R code and `NN-topic.py` for the Python code, for example `03-bl.R` and `24-llm.py`. A file holds every code chunk of the chapter in book order, the ones the book prints and the ones it keeps hidden (data preparation, helper functions, figures), under a comment for each section of the chapter. The files are made from the chapters by `misc/catalog/tangle.py`: to change the code, change the chapter and make the files again.

A chunk that the book does not run when it builds is commented out in the file, as `knitr::purl()` does, so that the file runs from top to bottom. The exception are the chunks that take too long to run at every build (a language model, a training run). The book shows their stored output from `results/` (see `results/README.md`), and in the file they stay active, with a note that names the stored files, so that you can run them and refresh the output.

The code of the exercise solutions, which the printed book does not show, stays in the `ex/` files.

## Running a file

Run a file from the book folder, so that the data are found in `data/`:

```
Rscript code/03-bl.R
python code/24-llm.py
```

The datasets are not in the repository. Download `data.zip` from the release of the book and unpack it in the book folder, so that `data/` sits next to `code/`. `data/README.md` gives the source and the terms of every file. The R packages are installed by `Rscript misc/install_packages.R`, the Python packages by `pip install -r requirements.txt`. Every R file starts with `source("code/common.R")`. Figures go to the graphics device (`Rplots.pdf` under `Rscript`).

## Files by chapter

| Chapter | R | Python | Data read from `data/` |
|---|---|---|---|
| Chapter 1: Probability and Uncertainty | `01-prob.R` |  | data/dc_travel_time.csv |
| Chapter 2: Bayes' Rule | `02-bayes.R` |  | data/pres_polls.csv |
| Chapter 3: Bayesian Learning | `03-bl.R` |  | data/GOOG2019.csv, data/SPMonthly.csv, data/epl.csv, data/epl_season_match_stats.json |
| Chapter 4: Utility, Risk and Decisions | `04-dec.R` |  |  |
| Chapter 5: A/B Testing | `05-ab.R` |  | data/PNAS_data_2011.csv, data/cancer-diet.csv |
| Chapter 6: Bayesian Hypothesis Testing | `06-hyp.R` |  |  |
| Chapter 7: Stochastic Processes | `07-sp.R` |  | data/sea_bubble.csv |
| Chapter 8: Gaussian Processes | `08-gp.R` |  |  |
| Chapter 9: Reinforcement Learning | `09-rl.R` |  | data/secretary.csv, data/student-mdp.tab, data/student-reward.tab |
| Chapter 10: Unreasonable Effectiveness of Data | `10-data.R` |  | data/boscovich.csv |
| Chapter 11: Pattern Matching | `11-pattern.R` |  |  |
| Chapter 12: Linear Regression | `12-regression.R` |  | data/SaratogaHouses.csv, data/keynes.csv, data/mammals.csv, data/newfood.csv, data/oj.csv, data/pga-2000.csv, data/pga-2018.csv |
| Chapter 13: Logistic Regression and Generalized Linear Models | `13-logistic.R` |  | data/NBAspread.csv, data/df_hkjc_with_factors.csv, data/tennis.csv |
| Chapter 14: Tree Models | `14-tree.R` |  |  |
| Chapter 15: Forecasting | `15-forecasting.R` |  | data/AAPL.csv, data/GSPC.csv, data/timeseries/model12-sp500.RData, data/timeseries/model123.RData, data/timeseries/rec_data_20160613.csv, data/timeseries/tsmodel-nber.RData |
| Chapter 16: Model Selection | `16-select.R` |  | data/babyboom.csv |
| Chapter 17: Statistical Learning Theory and Regularization | `17-theoryai.R` |  | data/EfronMorrisBB.txt, data/clemente.csv |
| Chapter 18: Neural Networks | `18-nn.R` | `18-nn.py` |  |
| Chapter 19: Theory of Deep Learning | `19-theorydl.R` | `19-theorydl.py` |  |
| Chapter 20: Gradient Descent | `20-sgd.R` | `20-sgd.py` | data/circle.csv |
| Chapter 21: Quantile Neural Networks | `21-qnn.R` |  |  |
| Chapter 22: Convolutional Neural Networks |  | `22-cnn.py` | data/img-filter.tsv, data/img-x.tsv, data/t10k-images-idx3-ubyte.gz, data/t10k-labels-idx1-ubyte.gz |
| Chapter 23: Natural Language Processing |  | `23-nlp.py` | data/embedding_words.txt, data/warpeace.txt |
| Chapter 24: Large Language Models | `24-llm.R` | `24-llm.py` | data/wikipedia-cat.txt |
| Chapter 25: AI Agents | `25-robots.R` |  |  |

## Scripts written by hand

These files are not made from the chapters. The scripts of the first table belong to a chapter: they prepare its data or make its figures. The second table is earlier code and notebooks that no chapter reads; the chapter in the second column is the one they relate to.

| File | Chapter | What it does |
|---|---|---|
| `common.R` | all | Setup shared by the R code of the book. It loads tidyverse, ggplot2, latex2exp, broom and quantmod, sets the output options, and makes `getSymbols` read `data/quantmod/SYMBOL.rds` when the file exists, so that nothing is downloaded. Every `NN-topic.R` starts with `source("code/common.R")`. |
| `llm_chapter.py` | 24 | Helper functions of the language model examples (`ask_smol_lm`, `get_next_word_suggestions`, `generate_text_step_by_step`). `24-llm.py` imports them. |
| `13-logistic-hkjc-prepare.py` | 13 | Prepares the Hong Kong Jockey Club race data (Kaggle, gdaley/hkracing, 1997 to 2005) for the betting example: historical jockey and trainer win rates without lookahead, draw and rating normalised within each race. Writes `data/df_hkjc_with_factors.csv`. |
| `13-logistic-benter.R` | 13 | Polya-Gamma Bayesian logistic regression for the horse race betting example. Reads `data/df_hkjc_with_factors.csv`; writes `fig/bayesian-betting-plot.png` and `results/13-logistic/bayesian-betting-results.rds`. |
| `15-forecasting-bsts-claims.R` | 15 | Fits the `bsts` model to the initial claims series of the `iclaims` data for the comparison with the Temporal Fusion Transformer. Writes `data/tft/claims.csv` and `data/tft/bsts_results.csv`. |
| `15-forecasting-tft.py` | 15 | Trains an ensemble of three Temporal Fusion Transformers (`pytorch-forecasting`, Lightning; about 80 seconds on a laptop CPU) on those claims, draws `fig/bsts-tft.png` and writes the forecasts to `results/15-forecasting/tft-forecast.csv`. Needs `pip install pytorch-forecasting lightning`. |
| `cauchy_unit_ball.R` | 17 | Unit ball of the Cauchy prior penalty. Writes `fig/cauchy_unit_ball.png`, `fig/cauchy_unit_ball_annotated.png` and `fig/cauchy_vs_others.png`. |
| `horseshoe_unit_ball.R` | 17 | Unit ball of the horseshoe prior penalty. Writes `fig/horseshoe_unit_ball.png` and `fig/horseshoe_unit_ball_annotated.png`. |
| `reproduce_fig_horseshoe.R` | 17 | Unit balls of the L_p norms and of the bridge and horseshoe penalties. Writes `fig/fig_horseshoe_reproduction.png`, `fig/fig_bridge_detailed.png` and `fig/fig_sparsity_priors.png`. |
| `cnn.py` | 22 | A fully connected network for MNIST in JAX. Reads the MNIST test files of `data/` and writes the sample digits `fig/mnist-0.png` to `fig/mnist-3.png` and the test curve `fig/mnist-fc-test.png`. |

### Earlier code and notebooks

| File | Related chapter | What it does |
|---|---|---|
| `bandit-simulations.R` | 6 | Earlier stand-alone version of the bandit simulation of the sequential testing section; the chapter has its own copy of the code. |
| `operating-chars.R` | 6 | Earlier stand-alone version of the operating characteristics simulation of the Bayesian sequential trial; the chapter has its own copy of the code. |
| `boston_keras.R` |  | A one hidden layer network for the Boston housing data in `kerasR`. No chapter reads it. |
| `boston_tree_rf_boost.R` | 14 | Regression tree, random forest and boosting for the Boston housing data. No chapter reads it. |
| `boston_trees.R` | 14 | A regression tree for `medv ~ lstat` in the Boston housing data, with its cutpoints drawn on the fitted step function. No chapter reads it. |
| `lalonde-ate-comparison.R` | 14 | Average treatment effect of the Lalonde data by matching and by BART, against the experimental benchmark. No chapter reads it. |
| `gamma-poisson.r` | 3 | Gamma-Poisson updating: the counts of a Poisson process, and the posterior mean and 90% band of the rate after each count for several Gamma priors. No chapter reads it. |
| `nlp_chapter.py` |  | Gaussian kernel smoothing on a grid, the module that `smoothing.ipynb` imports. No chapter reads it. |
| `smoothing.ipynb` |  | Notebook on Gaussian kernel smoothing and the effect of the bandwidth. No chapter reads it. |
| `language.ipynb` | 23 | Notebook on the GPT-2 tokenizer and model of `transformers`. No chapter reads it. |
| `letter-grams.ipynb` | 23 | Notebook on the letter frequencies of a Wikipedia page, an early version of the n-gram example. No chapter reads it. |
| `SmolLM2.ipynb` | 24 | Notebook version of the SmolLM2 examples of the language model chapter. |

## License

The code is released under the MIT license (`code/LICENSE`).
