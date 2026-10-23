# Data

Every dataset that the code of the book reads, in one folder. The chapters and the code files in `code/` are run from the book folder and read their data as `data/NAME`.

The files are not part of the repository. They come as the archive `data.zip` of the release, which unpacks into `data/`.

Most of the data come from other people. For each file the entries below give what it is, where the book uses it, where it comes from, and the terms of its owner as found when this list was made. Those terms apply to the data; the licenses of the book and of its code do not cover them.

| File | Used in |
|---|---|
| [`AAPL.csv`](#aaplcsv) | 15-forecasting |
| [`ab_browser_test.csv`](#ab_browser_testcsv) | 05-ab (exercises) |
| [`babyboom.csv`](#babyboomcsv) | 16-select |
| [`boscovich.csv`](#boscovichcsv) | 10-data |
| [`CAhousing.csv`](#cahousingcsv) | 14-tree (exercises) |
| [`cancer-diet.csv`](#cancer-dietcsv) | 05-ab |
| [`chi_homicide.rds`](#chi_homiciderds) | 01-prob (exercises) |
| [`circle.csv`](#circlecsv) | 13-logistic (exercises), 20-sgd |
| [`clemente.csv`](#clementecsv) | 17-theoryai |
| [`credit.csv`](#creditcsv) | 13-logistic, 16-select, 17-theoryai (exercises) |
| [`dc_travel_time.csv`](#dc_travel_timecsv) | 01-prob |
| [`derby2016.csv`](#derby2016csv) | 01-prob (exercises) |
| [`df_hkjc_with_factors.csv`](#df_hkjc_with_factorscsv) | 13-logistic |
| [`EfronMorrisBB.txt`](#efronmorrisbbtxt) | 17-theoryai |
| [`embedding_words.txt`](#embedding_wordstxt) | 23-nlp |
| [`epl.csv`](#eplcsv) | 03-bl |
| [`epl_season_match_stats.json`](#epl_season_match_statsjson) | 03-bl |
| [`ev.csv`](#evcsv) | 02-bayes (exercises) |
| [`GOOG2019.csv`](#goog2019csv) | 03-bl |
| [`GSPC.csv`](#gspccsv) | 15-forecasting |
| [`Hitters.csv`](#hitterscsv) | 17-theoryai (exercises) |
| [`homes2004.csv`](#homes2004csv) | 12-regression (exercises), 13-logistic (exercises) |
| [`homes2004code.txt`](#homes2004codetxt) | 12-regression (exercises) |
| [`img-filter.tsv`](#img-filtertsv) | 22-cnn |
| [`img-x.tsv`](#img-xtsv) | 22-cnn |
| [`Kentucky_Derby_2014.csv`](#kentucky_derby_2014csv) | 01-prob (exercises) |
| [`keynes.csv`](#keynescsv) | 12-regression |
| [`mammals.csv`](#mammalscsv) | 12-regression |
| [`MCMCexampleData.txt`](#mcmcexampledatatxt) | 03-bl (exercises) |
| [`NBAspread.csv`](#nbaspreadcsv) | 13-logistic |
| [`newfood.csv`](#newfoodcsv) | 12-regression |
| [`oj.csv`](#ojcsv) | 12-regression |
| [`oj_thin.csv`](#oj_thincsv) | 12-regression (exercises) |
| [`pga-2000.csv`](#pga-2000csv) | 12-regression |
| [`pga-2018.csv`](#pga-2018csv) | 12-regression |
| [`PNAS_data_2011.csv`](#pnas_data_2011csv) | 05-ab |
| [`pres_polls.csv`](#pres_pollscsv) | 02-bayes |
| [`SaratogaHouses.csv`](#saratogahousescsv) | 12-regression |
| [`sea_bubble.csv`](#sea_bubblecsv) | 07-sp |
| [`secretary.csv`](#secretarycsv) | 09-rl |
| [`spam.csv`](#spamcsv) | 13-logistic (exercises) |
| [`SPMonthly.csv`](#spmonthlycsv) | 03-bl |
| [`state_abbr.csv`](#state_abbrcsv) | 02-bayes (exercises) |
| [`student-mdp.tab`](#student-mdptab) | 09-rl |
| [`student-reward.tab`](#student-rewardtab) | 09-rl |
| [`superbowl1.txt`](#superbowl1txt) | 01-prob (exercises) |
| [`t10k-images-idx3-ubyte.gz`](#t10k-images-idx3-ubytegz) | 22-cnn |
| [`t10k-labels-idx1-ubyte.gz`](#t10k-labels-idx1-ubytegz) | 22-cnn |
| [`tennis.csv`](#tenniscsv) | 13-logistic |
| [`warpeace.txt`](#warpeacetxt) | 23-nlp, 24-llm |
| [`weather_dca.csv`](#weather_dcacsv) | 01-prob (exercises) |
| [`wikipedia-cat.txt`](#wikipedia-cattxt) | 24-llm |
| [`wine.csv`](#winecsv) | 16-select (exercises) |
| [`hkjc/races.csv`](#hkjcracescsv) | 13-logistic (through code/13-logistic-hkjc-prepare.py, which builds df_hkjc_with_factors.csv) |
| [`hkjc/runs.csv`](#hkjcrunscsv) | 13-logistic (through code/13-logistic-hkjc-prepare.py, which builds df_hkjc_with_factors.csv) |
| [`quantmod/AAPL.rds`](#quantmodaaplrds) | 01-prob (exercises), 12-regression |
| [`quantmod/BRK-A.rds`](#quantmodbrk-ards) | 01-prob (exercises) |
| [`quantmod/GOOG.rds`](#quantmodgoogrds) | 01-prob (exercises), 12-regression |
| [`quantmod/KO.rds`](#quantmodkords) | 03-bl (exercises) |
| [`quantmod/MSFT.rds`](#quantmodmsftrds) | 03-bl |
| [`quantmod/PEP.rds`](#quantmodpeprds) | 03-bl (exercises) |
| [`quantmod/SPY.rds`](#quantmodspyrds) | 03-bl, 12-regression |
| [`quantmod/VTV.rds`](#quantmodvtvrds) | 01-prob (exercises) |
| [`quantmod/VUG.rds`](#quantmodvugrds) | 01-prob (exercises) |
| [`tft/bsts_results.csv`](#tftbsts_resultscsv) | 15-forecasting (through code/15-forecasting-tft.py) |
| [`tft/claims.csv`](#tftclaimscsv) | 15-forecasting (through code/15-forecasting-tft.py) |
| [`timeseries/model12-sp500.RData`](#timeseriesmodel12-sp500rdata) | 15-forecasting |
| [`timeseries/model123.RData`](#timeseriesmodel123rdata) | 15-forecasting |
| [`timeseries/rec_data_20160613.csv`](#timeseriesrec_data_20160613csv) | 15-forecasting |
| [`timeseries/tsmodel-nber.RData`](#timeseriestsmodel-nberrdata) | 15-forecasting |

## Files

### AAPL.csv

503 rows, 6 columns (AAPL.Open, AAPL.High, AAPL.Low, AAPL.Close, AAPL.Volume, AAPL.Adjusted): daily Apple prices from 4 January 2021 to 30 December 2022. The date is the first field and has no header name.

Used in: 15-forecasting

Source: Yahoo Finance daily prices as returned by quantmod::getSymbols (the column names follow that pattern).

Terms: The Yahoo Finance help page says "You must not redistribute information displayed on or provided by Yahoo Finance." (https://help.yahoo.com/kb/SLN2310.html).

### ab_browser_test.csv

566,134 rows by 6 columns: click and query counts per user and browser from an A/B test (284,554 control, 281,580 exp).

Used in: 05-ab (exercises)

Source: Assignment data of the Coursera specialization Machine Learning and Data Analysis by MIPT and Yandex; the assignment says the test ran on real Yandex users.

Terms: Coursera Terms of Use (https://www.coursera.org/about/terms): a limited, personal, non exclusive, non transferable license for personal, non commercial use of the services; course content belongs to its providers. No dataset license was found.

### babyboom.csv

44 rows, 5 columns (row index, clock.time, gender, wt, running.time): birth time, sex and weight in grams of 44 babies born at a Brisbane hospital on 18 December 1997.

Used in: 16-select

Source: Same variables and size as babyboom in the R package UsingR, from the Journal of Statistics Education archive, submitted by Peter K. Dunn (1999). First printed in The Sunday Mail, Brisbane, 21 December 1997 (https://jse.amstat.org/datasets/babyboom.txt).

Terms: The archive page states no license. UsingR lists the license GPL version 2 or version 3 (https://cran.r-project.org/web/packages/UsingR/index.html).

### boscovich.csv

5 rows by 4 columns (Location, Latitude, ArcLength, sin2Latitude): length in toises of a degree of meridian arc at Quito, Cape of Good Hope, Rome, Paris and Lapland, with latitude in decimal degrees.

Used in: 10-data

Source: Eighteenth century meridian arc measurements compiled by Roger Boscovich, also tabulated in Richard Pulskamp's translation, Boscovich's Example (https://probabilityandfinance.com/pulskamp/Boscovich/boscovich%20problem.pdf).

Terms: Public domain. The Cornell copyright term guide (https://guides.library.cornell.edu/copyright/publicdomain) lists works published before 1931 as public domain in the United States, and says facts are excluded from copyright.

### CAhousing.csv

20,640 rows by 9 columns (longitude, latitude, housingMedianAge, totalRooms, totalBedrooms, population, households, medianIncome, medianHouseValue): one row per California census block group of the 1990 Census.

Used in: 14-tree (exercises)

Source: R. Kelley Pace and Ronald Barry (1997), Sparse Spatial Autoregressions, Statistics and Probability Letters 33, 291 to 297, distributed by StatLib (http://lib.stat.cmu.edu/datasets/houses.zip, file cadata.txt). The rows equal cadata.txt with the columns reordered and named.

Terms: No terms were found.

### cancer-diet.csv

25 rows by 4 columns (Label, p value, Rank, BH): 25 dietary variables sorted by p value, with rank and the Benjamini and Hochberg cutoff.

Used in: 05-ab

Source: The p values are from Table 3 of García-Arenzana et al. (2014), International Journal of Cancer 134(8) (https://doi.org/10.1002/ijc.28513).

Terms: The article is open access under the Creative Commons Attribution NonCommercial NoDerivs license (copyright 2013 The Authors; https://pmc.ncbi.nlm.nih.gov/articles/PMC4166692/), which allows use and distribution with citation, non commercial only and without modifications or adaptations.

### chi_homicide.rds

R data frame, 8,330 rows by 19 columns: one row per Chicago homicide, 1 January 2001 to 22 February 2017.

Used in: 01-prob (exercises)

Source: Made by the authors from the City of Chicago Data Portal (https://data.cityofchicago.org/Public-Safety/Crimes-2001-to-Present/ijzp-q8t2).

Terms: License "See Terms of Use", attribution Chicago Police Department. The City's Terms of Use (https://www.chicago.gov/city/en/narr/foia/data_disclaimer.html) provide the data as is, let the City require users to stop displaying or distributing it, and require a secondary application to carry the City's disclaimer and follow further agency terms.

### circle.csv

CSV with a header, 200 rows by 3 columns (label 0 or 1, x1, x2). Each row is a point with its class: 100 points of class 0 lie within radius 4 of the origin and 100 of class 1 in the ring between radius 8 and 10.

Used in: 13-logistic (exercises), 20-sgd

Source: Made for this book, simulated by the authors.

Terms: The authors' own synthetic data, with no third party terms.

### clemente.csv

108 rows, 19 columns: Roberto Clemente's game by game batting log for the 1970 regular season, 7 April to 27 September 1970 (date, opponent, AB, R, H, 2B, 3B, HR, RBI, BB, IBB, K, HBP, SH, SF, AVG, OBP, SLG, position). The file starts with a byte order mark.

Used in: 17-theoryai

Source: Baseball Almanac, Roberto Clemente 1970 hitting logs (https://www.baseball-almanac.com/players/hittinglogs.php?p=clemero01&y=1970).

Terms: The footer of the same page states copyright by Baseball Almanac, Inc., all rights reserved. No reuse license was found.

### credit.csv

1,000 rows by 21 columns (Default, checkingstatus1, ..., foreign): one row per German credit applicant, 700 good and 300 bad (Default is 1 for bad).

Used in: 13-logistic, 16-select, 17-theoryai (exercises)

Source: UCI Machine Learning Repository, Statlog (German Credit Data), Hans Hofmann, University of Hamburg, 1994 (https://archive.ics.uci.edu/dataset/144/statlog+german+credit+data, DOI 10.24432/C5NC77). The 20 attribute columns equal UCI german.data; column names and the Default flag were added.

Terms: CC BY 4.0, stated on the UCI page (https://archive.ics.uci.edu/dataset/144/statlog+german+credit+data): sharing and adaptation for any purpose, with appropriate credit.

### dc_travel_time.csv

30 rows by 23 columns: Uber Movement travel times for one origin and destination pair (Thomas Avenue, Arlington to 8900 Moreland Lane, Annandale), one row per day from 1 to 30 September 2019, with daily, AM, PM, midday, evening and early morning mean travel times in seconds and their lower and upper bounds.

Used in: 01-prob

Source: Uber Movement travel times from Uber (https://movement.uber.com/).

Terms: No terms were found.

### derby2016.csv

142 rows by the same 9 columns as Kentucky_Derby_2014.csv: one row per Kentucky Derby from 1875 to 2016, with the winning time, the distance in miles and the average speed in mph.

Used in: 01-prob (exercises)

Source: From Nick Polson's course Business Statistics 41000 at Chicago Booth, identical to the course file (https://faculty.chicagobooth.edu/nicholas.polson/teaching/41000/Kentucky_Derby_2016.csv). The compiler's own source for the times is not recorded.

Terms: No terms for the data; the course page states Copyright © 2010 University of Chicago Booth School of Business.

### df_hkjc_with_factors.csv

73722 rows, 24 columns: one row per horse in 5885 Hong Kong Jockey Club races from November 1997 to August 2005, with win flag, odds, implied probability, draw, weights, rating, and jockey and trainer win rates.

Used in: 13-logistic

Source: Derived from races.csv and runs.csv of Graham Daley's Kaggle data set Horse Racing in HK (https://www.kaggle.com/datasets/gdaley/hkracing) by the code of the book.

Terms: The Kaggle page lists the license "CC0: Public Domain" and says the data were obtained from various free sources.

### EfronMorrisBB.txt

18 rows, 10 columns, tab separated (FirstName, LastName, AtBats, Hits, BattingAverage, RemainingAtBats, RemainingAverage, SeasonAtBats, SeasonHits, SeasonAverage): hits of 18 baseball players in their first 45 at bats of the 1970 season and in the rest of the season.

Used in: 17-theoryai

Source: A copy of the Efron and Morris batting data (Efron and Morris 1977, Scientific American 236(5)) hosted at Swarthmore College (https://www1.swarthmore.edu/NatSci/peverso1/Sports%20Data/JamesSteinData/Efron-Morris%20Baseball/EfronMorrisBB.txt). The header names differ from the hosted file (hyphens removed).

Terms: No terms were found.

### embedding_words.txt

Plain text with 14 words, one per line: society, court, family, ballroom, marriage, friendship, battle, regiment, soldier, war, history, power, nation, peace. They are the words plotted in the Word2Vec figure.

Used in: 23-nlp

Source: Made for this book: the authors chose the words for the figure.

Terms: No terms apply: a list of 14 common English words picked by the authors.

### epl.csv

380 rows by 9 columns (row number, home_team_id, away_team_id, home_team_name, away_team_name, date_string, half_time_score, home_score, guest_score): one row per match of the 2016/17 Premier League season.

Used in: 03-bl

Source: Derived from epl_season_match_stats.json by the code of the book, so it also comes from WhoScored.

Terms: The same as for epl_season_match_stats.json: the WhoScored Terms of Use (https://www.whoscored.com/termsofuse) prohibit the copying, downloading, reproduction, republication, framing, broadcasting and transmission of its content, including all statistics, data, products, tables, graphics and other information, without an official license.

### epl_season_match_stats.json

JSON object with 380 matches (keys are match ids 1080506 to 1080885), each with 7 fields: home_team_id, away_team_id, home_team_name, away_team_name, date_string, half_time_score, full_time_score. It covers one full 2016/17 Premier League season.

Used in: 03-bl

Source: The match ids are WhoScored.com ids (example: https://www.whoscored.com/Matches/1080506/Live). WhoScored's data provider is Opta (https://www.whoscored.com/aboutus).

Terms: The WhoScored Terms of Use (https://www.whoscored.com/termsofuse) prohibit the copying, downloading, reproduction, republication, framing, broadcasting and transmission of its content, including all statistics, data, products, tables, graphics and other information, without an official license.

### ev.csv

51 rows by 2 columns, tab separated, no header (state name, electoral votes): the 50 states and District of Columbia, 538 votes in total.

Used in: 02-bayes (exercises)

Source: From the authors' course; its original source is not recorded. All 51 values equal the National Archives table for the 2004 presidential election (https://www.archives.gov/electoral-college/2004).

Terms: Works of the United States Government are not eligible for copyright: 17 U.S.C. 105 (https://www.law.cornell.edu/uscode/text/17/105).

### GOOG2019.csv

251 rows by 7 columns (Date, Open, High, Low, Close, Adj Close, Volume): daily Google (Alphabet, GOOG) stock prices from 2 January to 30 December 2019.

Used in: 03-bl

Source: Most likely Yahoo Finance historical data (https://finance.yahoo.com/).

Terms: The Yahoo Terms of Service (https://legal.yahoo.com/us/en/yahoo/terms/otos/index.html) prohibit collecting data from the Services by automated means for any purpose without express prior permission. They also prohibit reproducing, distributing or transmitting any portion of the Services, including content, without explicit written permission, and commercial reuse unless expressly stated.

### GSPC.csv

2518 rows, 6 columns (GSPC.Open, GSPC.High, GSPC.Low, GSPC.Close, GSPC.Volume, GSPC.Adjusted): daily S&P 500 index values from 2 January 2013 to 30 December 2022. The date is the first field and has no header name.

Used in: 15-forecasting

Source: Yahoo Finance daily values of the index symbol GSPC as returned by quantmod::getSymbols (the column names follow that pattern).

Terms: The Yahoo Finance help page says "You must not redistribute information displayed on or provided by Yahoo Finance." (https://help.yahoo.com/kb/SLN2310.html).

### Hitters.csv

322 rows by 21 columns (player name, AtBat, ..., Salary, NewLeague): 1986 season and career statistics of major league batters with the 1987 salary (59 missing).

Used in: 17-theoryai (exercises)

Source: Equal to Hitters in the R package ISLR, which credits StatLib (http://lib.stat.cmu.edu/datasets/baseball.data), with salaries from Sports Illustrated and career statistics from The 1987 Baseball Encyclopedia Update.

Terms: The ISLR package is under the GNU General Public License version 2 (https://cran.r-project.org/web/packages/ISLR/index.html). StatLib states no license, and the terms of the other sources are unknown.

### homes2004.csv

15,565 rows by 29 columns (AMMORT, EAPTBL, ECOM1, ..., DWNPAY, VALUE, FRSTHO): survey records of home buyers with mortgage amount, price, value, down payment and first home flag.

Used in: 12-regression (exercises), 13-logistic (exercises)

Source: Extract of the 2004 American Housing Survey (https://www.huduser.gov/portal/datasets/ahs.html) from Matt Taddy's Chicago Booth Big Data course (https://github.com/TaddyLab/MBAcourse); the exact public use file is not identified.

Terms: The survey is a US Government product (17 U.S.C. 105, https://www.law.cornell.edu/uscode/text/17/105), but this extract comes from course materials with no license found.

### homes2004code.txt

92 lines of text: the variable dictionary for homes2004.csv (a line with the variable name, a line with its description, a blank line).

Used in: 12-regression (exercises)

Source: Same origin as homes2004.csv: Matt Taddy's Chicago Booth Big Data course (https://github.com/TaddyLab/MBAcourse).

Terms: As for homes2004.csv: the course repository (https://github.com/TaddyLab/MBAcourse) declares no license, and the survey itself is a US Government product (17 U.S.C. 105, https://www.law.cornell.edu/uscode/text/17/105).

### img-filter.tsv

Tab separated, no header, 6 rows by 3 columns of 0 and 1. It stacks two 3 by 3 filters (main diagonal and anti diagonal).

Used in: 22-cnn

Source: From the authors' course. The same two filters are in a modified copy of Jeremy Howard's workbook conv-example.xlsx (fast.ai course repository, https://github.com/fastai/courses/blob/master/deeplearning1/excel/conv-example.xlsx).

Terms: The file has no license statement. The fast.ai repository that holds the original workbook is under the Apache License 2.0 (https://api.github.com/repos/fastai/courses).

### img-x.tsv

Tab separated, no header, 20 rows by 5 columns of 0.00 and 1.00. It stacks four 5 by 5 images (cross, diagonal, right diagonal, plus sign), and the chapter reads the first three.

Used in: 22-cnn

Source: From the authors' course. The first image is the cross used as input in a modified copy of Jeremy Howard's workbook conv-example.xlsx (fast.ai course repository, https://github.com/fastai/courses/blob/master/deeplearning1/excel/conv-example.xlsx).

Terms: The file has no license statement. The fast.ai repository that holds the original workbook is under the Apache License 2.0 (https://api.github.com/repos/fastai/courses).

### Kentucky_Derby_2014.csv

140 rows by 9 columns (year, year_num, date, winner, mins, secs, timeinsec, distance, speedmph): one row per Kentucky Derby from 1875 to 2014, with the winning time, the distance in miles and the average speed in mph. Later dates are saved as day, month, two digit year text.

Used in: 01-prob (exercises)

Source: From Nick Polson's course Business Statistics 41000 at Chicago Booth, identical to the course file (https://faculty.chicagobooth.edu/nicholas.polson/teaching/41000/Kentucky_Derby_2014.csv). The compiler's own source for the times is not recorded.

Terms: No terms for the data; the course page states Copyright © 2010 University of Chicago Booth School of Business.

### keynes.csv

18 rows, 4 columns (Year, Keynes, Market, Rate), one row per year: annual percent returns of Keynes's investment fund and of the market, with an interest rate, 1928 to 1945.

Used in: 12-regression

Source: The origin of the table is not established. A possible source is the Chest Fund series for 1928 onward in Keynes, Collected Writings, vol. XII, p. 91, Table 7, analyzed by Chua and Woodward, Journal of Finance 38(1), 1983 (https://www.jstor.org/stable/2327650).

Terms: No terms were found.

### mammals.csv

62 rows, 3 columns (Mammal, Brain, Body): brain weight in grams and body weight in kilograms of 62 land mammal species.

Used in: 12-regression

Source: Same species as the data set mammals in the R package MASS, documented there as Weisberg (1985), Applied Linear Regression, 2nd edition, Wiley, pp. 144 to 145, selected from Allison and Cicchetti (1976), Science 194, 732 to 734 (https://rdrr.io/cran/MASS/man/mammals.html). At least one value differs from MASS.

Terms: The MASS package lists the license GPL version 2 or version 3 (https://cran.r-project.org/web/packages/MASS/index.html).

### MCMCexampleData.txt

50 numbers in 10 lines of 5 values, no header (mean about negative 0.07, standard deviation 1.36): the sample for the Gibbs sampler with Normal data, a Normal prior on the mean and a Gamma prior on the precision.

Used in: 03-bl (exercises)

Source: Penn State STAT 515 homework data (the handout cites http://sites.stat.psu.edu/~dhunter/515/hw/MCMCexampleData.txt), also in the GitHub repository Murali-Haran/Murali-Haran.github.io. The model is from Gilks, Richardson and Spiegelhalter (1996), Markov Chain Monte Carlo in Practice.

Terms: No terms were found.

### NBAspread.csv

553 rows, 7 columns (favwin, favscr, undscr, spread, favhome, fregion, uregion): outcome and Las Vegas point spread of 553 college basketball games.

Used in: 13-logistic

Source: Matches the data set pntsprd of the R package wooldridge in row count and variable names: 553 men's college basketball games of the 1994 and 1995 seasons, collected by Scott Resnick from newspaper sources and taken from the Cengage files of Wooldridge's econometrics text (https://rdrr.io/cran/wooldridge/man/pntsprd.html).

Terms: The R package wooldridge lists the license GPL version 3 (https://cran.r-project.org/web/packages/wooldridge/index.html).

### newfood.csv

72 rows, 8 columns (sales, price, adv, locat, income, svol, city, indx): sales of a new breakfast cereal by store, with price, advertising level, shelf location, neighborhood income, store volume and city.

Used in: 12-regression

Source: The origin of this file is not established.

Terms: No terms were found.

### oj.csv

28947 rows, 17 columns: weekly orange juice sales (log of units moved), price, feature flag and store demographics for 3 brands in 83 Chicago area Dominick's stores, weeks 40 to 160.

Used in: 12-regression

Source: Extract of the Dominick's Finer Foods scanner database of the Kilts Center, Chicago Booth (https://www.chicagobooth.edu/research/kilts/research-data/dominicks).

Terms: The Kilts page says "These data are for academic research purposes only." and requires acknowledgment of the Kilts Center for Marketing at the University of Chicago Booth School of Business in working papers and/or publications.

### oj_thin.csv

28,947 rows by 4 columns (sales, price, brand, feat): weekly store sales of orange juice for three brands (9,649 each), with price and an ad feature flag.

Used in: 12-regression (exercises)

Source: Copy of examples/oj.csv in Matt Taddy's course repository (https://github.com/TaddyLab/MBAcourse). The brand names point to the Dominick's Finer Foods scanner data of the Kilts Center at Chicago Booth.

Terms: Kilts Center (https://www.chicagobooth.edu/research/kilts/research-data/dominicks): "These data are for academic research purposes only." Users must acknowledge the Kilts Center in working papers or publications.

### pga-2000.csv

195 rows, 7 columns (name, nevents, money, drivedist, ROUNDS, gir, avgputts): season statistics and prize money of PGA Tour golfers for 2000.

Used in: 12-regression

Source: Compiled by the authors from tables headed like the PGA Tour statistics pages, so the inferred origin is the PGA Tour (https://www.pgatour.com/stats).

Terms: The PGA Tour Terms of Use state: "intended for Your personal, noncommercial use only". Scrapers and robots are barred. Copying, redistribution, retransmission, publication or exploitation of downloaded material requires the express permission of PGA Tour, Inc. (https://www.pgatour.com/company/terms-of-use).

### pga-2018.csv

192 rows, 7 columns (name, nevents, money, drivedist, ROUNDS, gir, avgputts): season statistics and prize money of PGA Tour golfers for 2018.

Used in: 12-regression

Source: Compiled by the authors from tables headed like the PGA Tour statistics pages, so the inferred origin is the PGA Tour (https://www.pgatour.com/stats).

Terms: The PGA Tour Terms of Use state: "intended for Your personal, noncommercial use only". Scrapers and robots are barred. Copying, redistribution, retransmission, publication or exploitation of downloaded material requires the express permission of PGA Tour, Inc. (https://www.pgatour.com/company/terms-of-use).

### PNAS_data_2011.csv

3164 rows by 37 columns: one row per Moscow polling station in the December 2011 Duma election, with the station id uik, observer and violation counts, ballots, votes for seven parties, region, tik, population, turnout, vote and registered shares, and the columns s, n, n_obs, pair_id, N and pseudo.

Used in: 05-ab

Source: Moscow observer dataset analyzed in Enikolopov, Korovkin, Petrova, Sonin and Zakharov (2013), Field experiment estimate of electoral fraud in Russian parliamentary elections, PNAS 110(2) (https://doi.org/10.1073/pnas.1206770110).

Terms: No terms were found.

### pres_polls.csv

924 rows by 16 columns: 873 polls of the 2012 US presidential election in 45 states and DC (one row per poll) and 51 rows of the pollster "Election 2012-1", the results of the election of 6 November 2012 (one per state and DC). The columns are Day, Len, state, EV, Dem, GOP, Ind, Date, seven empty columns and Pollster.

Used in: 02-bayes

Source: The 2012 presidential polls file of the Electoral Vote website (http://www.electoral-vote.com/evp2012/Pres/pres_polls.csv), whose pages are signed by the Votemaster and Zenger (https://www.electoral-vote.com/). An archived copy from October 2012 has the same layout (https://web.archive.org/web/20121021234242if_/http://www.electoral-vote.com/evp2012/Pres/pres_polls.csv).

Terms: No terms were found.

### SaratogaHouses.csv

1728 rows (one per house), 17 columns (row index and 16 variables): sale price, lot size, age, living area, rooms, heating and other features of houses in Saratoga County, New York, 2006.

Used in: 12-regression

Source: From the data set SaratogaHouses of the R package mosaicData (1728 observations, 16 variables), collected by Candice Corvetti for a Stat 101 case study (https://rdrr.io/cran/mosaicData/man/SaratogaHouses.html). The values were not compared with the package.

Terms: The R package mosaicData lists the license GPL version 2 or version 3 (https://cran.r-project.org/web/packages/mosaicData/index.html).

### sea_bubble.csv

499 rows by 6 columns: share prices from 21 August 1719 to 31 December 1720, with many empty cells.

Used in: 07-sp

Source: Subset of the database of Frehen, Goetzmann and Rouwenhorst (2013), the South Sea Bubble 1720 Project (https://som.yale.edu/centers/international-center-for-finance/data/historical-financial-research-data/south-seas-bubble-1720).

Terms: The data are supplied solely for academic research purposes, and "any commercial use or redistribution without the authorization of the authors and the International Center for Finance at Yale is prohibited" (https://som.yale.edu/centers/international-center-for-finance/data/historical-financial-research-data/south-seas-bubble-1720). The project workbook requests the authors' expressed permission before circulation.

### secretary.csv

300 rows by 4 columns (cnt, quality, nmc, rules): Monte Carlo results for the secretary problem with 1000 candidates and 1000 simulated runs per rule, for rules from 2 to 800 (the first candidate allowed to be chosen). The column cnt is how often the best candidate was picked, and quality sums the value picked.

Used in: 09-rl

Source: Made for this book. It is simulated by the code of the book (set.seed(17)).

Terms: The authors' own simulation output, with no third party terms.

### spam.csv

4,601 rows by 58 columns (word_make, ..., spam), one per email: 48 word and 6 character indicators, 3 capital letter run length measures and the class (1,813 spam, 2,788 not spam).

Used in: 13-logistic (exercises)

Source: UCI Spambase, Mark Hopkins, Erik Reeber, George Forman and Jaap Suermondt, 1999 (https://archive.ics.uci.edu/dataset/94/spambase, DOI 10.24432/C53G6X). Word and character frequencies are replaced by 0 or 1 (frequency above zero).

Terms: CC BY 4.0, stated on the UCI page (https://archive.ics.uci.edu/dataset/94/spambase): sharing and adaptation for any purpose, with appropriate credit.

### SPMonthly.csv

717 rows by 7 columns (Date, Open, High, Low, Close, Adj Close, Volume): monthly index values from January 1928 to September 1987, used in the book as the S&P 500 history.

Used in: 03-bl

Source: Most likely Yahoo Finance historical monthly data for the S&P 500 index (https://finance.yahoo.com/).

Terms: The same Yahoo Terms of Service as for GOOG2019.csv (https://legal.yahoo.com/us/en/yahoo/terms/otos/index.html). They prohibit, among other things, reproducing, distributing or transmitting any portion of the Services, including content, without explicit written permission.

### state_abbr.csv

51 rows by 2 columns (state, abbr) with a header: the 50 states and District of Columbia with their two letter postal codes.

Used in: 02-bayes (exercises)

Source: From the authors' course; its original source is not recorded. All 51 rows equal the Census Bureau state list, STUSAB field (https://www2.census.gov/geo/docs/reference/state.txt).

Terms: Works of the United States Government are not eligible for copyright: 17 U.S.C. 105 (https://www.law.cornell.edu/uscode/text/17/105).

### student-mdp.tab

8 rows by 8 columns plus state names: the transition probability matrix of the Student chain over Facebook, Class 1, Class 2, Class 3, Pub, Pass, Fail and Sleep. Each row sums to 1.

Used in: 09-rl

Source: The authors' variant of the Student example in David Silver's UCL Lecture 2 on Markov Decision Processes (https://davidstarsilver.wordpress.com/wp-content/uploads/2025/04/lecture-2-mdp.pdf), with the Fail state and its transitions added.

Terms: The same as for student-reward.tab: CC BY NC 4.0 (https://creativecommons.org/licenses/by-nc/4.0/legalcode), according to David Silver's Teaching page (https://davidstarsilver.wordpress.com/teaching/).

### student-reward.tab

8 rows by 1 value column plus state names: the reward of each state of the Student Markov reward process.

Used in: 09-rl

Source: The authors' variant of the Student example in David Silver's UCL course Reinforcement Learning, Lecture 2 Markov Decision Processes (https://davidstarsilver.wordpress.com/wp-content/uploads/2025/04/lecture-2-mdp.pdf), with an added Fail state.

Terms: David Silver's Teaching page (https://davidstarsilver.wordpress.com/teaching/) says all of the material listed on that page is made available under CC BY NC 4.0 (https://creativecommons.org/licenses/by-nc/4.0/legalcode) and that some content from third parties is not included in the license.

### superbowl1.txt

48 rows by 5 columns, comma separated with a header: Favorite, Underdog, the point Spread, the Outcome (favorite's score minus underdog's) and an Upset flag (1 in 16 rows). One row per Super Bowl, from the first (GreenBay v KansasCity) to the 48th (Denver v Seattle).

Used in: 01-prob (exercises)

Source: From Nick Polson's course Business Statistics 41000 at Chicago Booth (https://faculty.chicagobooth.edu/nicholas.polson/teaching/41000/superbowl1.txt), without its 49th data row. The original source of the scores and spreads is not stated.

Terms: No terms for the data; the course page states Copyright © 2010 University of Chicago Booth School of Business.

### t10k-images-idx3-ubyte.gz

Gzip compressed IDX file with 10,000 MNIST test images, 28 by 28 pixels, 8 bit gray levels.

Used in: 22-cnn

Source: MNIST database of handwritten digits by Yann LeCun, Corinna Cortes and Christopher Burges (http://yann.lecun.com/exdb/mnist/, archived at https://web.archive.org/web/20231229081350/http://yann.lecun.com/exdb/mnist/), built from NIST Special Databases 3 and 1.

Terms: The archived page states no copyright, license or terms of use. The Keras source (https://raw.githubusercontent.com/keras-team/keras/master/keras/src/datasets/mnist.py) says LeCun and Cortes hold the copyright and MNIST is available under CC BY SA 3.0; the Hugging Face card (https://huggingface.co/datasets/ylecun/mnist) lists the MIT license.

### t10k-labels-idx1-ubyte.gz

Gzip compressed IDX file with 10,000 MNIST test labels, digits 0 to 9, one byte each.

Used in: 22-cnn

Source: MNIST database of handwritten digits by Yann LeCun, Corinna Cortes and Christopher Burges (http://yann.lecun.com/exdb/mnist/, archived at https://web.archive.org/web/20231229081350/http://yann.lecun.com/exdb/mnist/), built from NIST Special Databases 3 and 1.

Terms: The archived page states no copyright, license or terms of use. The Keras source (https://raw.githubusercontent.com/keras-team/keras/master/keras/src/datasets/mnist.py) says LeCun and Cortes hold the copyright and MNIST is available under CC BY SA 3.0; the Hugging Face card (https://huggingface.co/datasets/ylecun/mnist) lists the MIT license.

### tennis.csv

943 rows, 44 columns: match statistics (serve percentages, aces, double faults, winners, break points, set scores) for men's and women's singles at the four 2013 majors, the 42 UCI columns plus gender and surf.

Used in: 13-logistic

Source: UCI Machine Learning Repository, Tennis Major Tournament Match Statistics, donated 31 May 2014, creators Shruti Jauhari, Aniket Morankar and Ernest Fokoue, DOI 10.24432/C54C7K (https://archive.ics.uci.edu/dataset/300/tennis+major+tournament+match+statistics).

Terms: The UCI page states "This dataset is licensed under a Creative Commons Attribution 4.0 International (CC BY 4.0) license".

### warpeace.txt

Plain text, 62,014 lines, 561,697 words, 3,196,232 bytes: the English translation of Tolstoy's War and Peace without chapter headings.

Used in: 23-nlp, 24-llm

Source: Project Gutenberg ebook 2600, translated by Aylmer and Louise Maude (https://www.gutenberg.org/ebooks/2600). The same text is distributed as warpeace_input.txt on Andrej Karpathy's page (https://cs.stanford.edu/people/karpathy/char-rnn/).

Terms: Project Gutenberg lists it as "Public domain in the USA", and its policy (https://www.gutenberg.org/policy/permission.html) says you can freely redistribute any eBook, but outside the US you must confirm yourself whether it is free to redistribute where you are.

### weather_dca.csv

140,161 rows by 6 columns (DateUTC, TemperatureF, PrecipitationIn, CloudCover, Humidity, WindSpeedMPH): one row per hour from 1 January 2008 00:00 to 28 December 2023 00:00 UTC, presented as the DCA airport weather station.

Used in: 01-prob (exercises)

Source: The generator of this file is not recorded. The values are synthetic, not station data: the annual mean temperature is 54.9 or 55.0 F in each of the 15 full years, and they differ from real records for the location.

Terms: No third party source for this file.

### wikipedia-cat.txt

Plain text, 2,524 lines, 19,722 words, 140,209 bytes, extracted from the rendered English Wikipedia article Cat, menus and footer included. Three comment lines at the top give the date, the license and the refresh recipe.

Used in: 24-llm

Source: The English Wikipedia article Cat (https://en.wikipedia.org/wiki/Cat), retrieved on 24 Aug 2026.

Terms: Wikipedia text is under the Creative Commons Attribution ShareAlike 4.0 license (http://creativecommons.org/licenses/by-sa/4.0/). Reuse requires crediting the authors, indicating changes, licensing modifications under CC BY SA 4.0 or later and including a licensing notice with a link to the license (https://en.wikipedia.org/wiki/Wikipedia:Reusing_Wikipedia_content).

### wine.csv

6,497 rows by 13 columns (fixed.acidity, ..., quality, color): 1,599 red wines followed by 4,898 white wines.

Used in: 16-select (exercises)

Source: UCI Wine Quality, Paulo Cortez, A. Cerdeira, F. Almeida, T. Matos and J. Reis (2009), Modeling wine preferences by data mining from physicochemical properties, Decision Support Systems (https://archive.ics.uci.edu/dataset/186/wine+quality, DOI 10.24432/C56S3T). The red and white UCI files are stacked with a color column.

Terms: CC BY 4.0, stated on the UCI page (https://archive.ics.uci.edu/dataset/186/wine+quality): sharing and adaptation for any purpose, with appropriate credit.

### hkjc/races.csv

6,349 rows by 37 columns: one row per Hong Kong Jockey Club race from June 1997 to August 2005, with venue (Shatin or Happy Valley), track configuration, surface, distance, going, rating band, prize, race class, the leader's sectional times and the win and place dividends. The uploader obscured the calendar dates and kept the intervals between races.

Used in: 13-logistic (through code/13-logistic-hkjc-prepare.py, which builds df_hkjc_with_factors.csv)

Source: The Kaggle dataset "Horse Racing in HK" by Graham Daley (https://www.kaggle.com/datasets/gdaley/hkracing), files races.csv and runs.csv. The uploader writes that the data were obtained from various free sources and that names of horses and jockeys were left out.

Terms: The Kaggle page labels the dataset CC0 1.0 Public Domain Dedication (https://creativecommons.org/publicdomain/zero/1.0/). That is the label of the uploader; the Hong Kong Jockey Club, whose results the data record, is not named in it.

### hkjc/runs.csv

79,447 rows by 37 columns: one row per horse in each race of races.csv, with finishing position, age, country, sex, rating, gear, weights, draw, sectional positions and times, finishing time, win and place odds, and anonymous horse, trainer and jockey ids.

Used in: 13-logistic (through code/13-logistic-hkjc-prepare.py, which builds df_hkjc_with_factors.csv)

Source: The Kaggle dataset "Horse Racing in HK" by Graham Daley (https://www.kaggle.com/datasets/gdaley/hkracing), file runs.csv.

Terms: The Kaggle page labels the dataset CC0 1.0 Public Domain Dedication (https://creativecommons.org/publicdomain/zero/1.0/), the label of the uploader.

### quantmod/AAPL.rds

R xts object saved with saveRDS: 8,565 daily rows, 6 columns (AAPL.Open, AAPL.High, AAPL.Low, AAPL.Close, AAPL.Volume, AAPL.Adjusted), 2 Jan 1990 to 29 Dec 2023.

Used in: 01-prob (exercises), 12-regression

Source: Yahoo Finance prices for AAPL, downloaded 24 Aug 2026 with the R package quantmod.

Terms: Yahoo's Terms of Service (https://legal.yahoo.com/us/en/yahoo/terms/otos/index.html) forbid reproducing or distributing any portion of the Services without explicit written permission. The Yahoo Finance help page (https://help.yahoo.com/kb/SLN2310.html) says: "You must not redistribute information displayed on or provided by Yahoo Finance".

### quantmod/BRK-A.rds

R xts object saved with saveRDS: 8,565 daily rows, 6 columns (Open, High, Low, Close, Volume, Adjusted, prefixed by the symbol), 2 Jan 1990 to 29 Dec 2023.

Used in: 01-prob (exercises)

Source: Yahoo Finance, Berkshire Hathaway class A shares, downloaded 24 Aug 2026 with the R package quantmod.

Terms: Yahoo's Terms of Service (https://legal.yahoo.com/us/en/yahoo/terms/otos/index.html) forbid reproducing or distributing any portion of the Services without explicit written permission. The Yahoo Finance help page (https://help.yahoo.com/kb/SLN2310.html) says: "You must not redistribute information displayed on or provided by Yahoo Finance".

### quantmod/GOOG.rds

R xts object saved with saveRDS: 4,875 daily rows, 6 columns (GOOG.Open, GOOG.High, GOOG.Low, GOOG.Close, GOOG.Volume, GOOG.Adjusted), 19 Aug 2004 to 29 Dec 2023.

Used in: 01-prob (exercises), 12-regression

Source: Yahoo Finance prices for GOOG, downloaded 24 Aug 2026 with the R package quantmod.

Terms: Yahoo's Terms of Service (https://legal.yahoo.com/us/en/yahoo/terms/otos/index.html) forbid reproducing or distributing any portion of the Services without explicit written permission. The Yahoo Finance help page (https://help.yahoo.com/kb/SLN2310.html) says: "You must not redistribute information displayed on or provided by Yahoo Finance".

### quantmod/KO.rds

R xts object saved with saveRDS: 8,565 daily rows, 6 columns (KO.Open, KO.High, KO.Low, KO.Close, KO.Volume, KO.Adjusted), 2 Jan 1990 to 29 Dec 2023.

Used in: 03-bl (exercises)

Source: Yahoo Finance prices for KO, downloaded 24 Aug 2026 with the R package quantmod.

Terms: Yahoo's Terms of Service (https://legal.yahoo.com/us/en/yahoo/terms/otos/index.html) forbid reproducing or distributing any portion of the Services without explicit written permission. The Yahoo Finance help page (https://help.yahoo.com/kb/SLN2310.html) says: "You must not redistribute information displayed on or provided by Yahoo Finance".

### quantmod/MSFT.rds

R xts object saved with saveRDS: 8,565 daily rows, 6 columns (MSFT.Open, MSFT.High, MSFT.Low, MSFT.Close, MSFT.Volume, MSFT.Adjusted), 2 Jan 1990 to 29 Dec 2023.

Used in: 03-bl

Source: Yahoo Finance prices for MSFT, downloaded 24 Aug 2026 with the R package quantmod.

Terms: Yahoo's Terms of Service (https://legal.yahoo.com/us/en/yahoo/terms/otos/index.html) forbid reproducing or distributing any portion of the Services without explicit written permission. The Yahoo Finance help page (https://help.yahoo.com/kb/SLN2310.html) says: "You must not redistribute information displayed on or provided by Yahoo Finance".

### quantmod/PEP.rds

R xts object saved with saveRDS: 8,565 daily rows, 6 columns (PEP.Open, PEP.High, PEP.Low, PEP.Close, PEP.Volume, PEP.Adjusted), 2 Jan 1990 to 29 Dec 2023.

Used in: 03-bl (exercises)

Source: Yahoo Finance prices for PEP, downloaded 24 Aug 2026 with the R package quantmod.

Terms: Yahoo's Terms of Service (https://legal.yahoo.com/us/en/yahoo/terms/otos/index.html) forbid reproducing or distributing any portion of the Services without explicit written permission. The Yahoo Finance help page (https://help.yahoo.com/kb/SLN2310.html) says: "You must not redistribute information displayed on or provided by Yahoo Finance".

### quantmod/SPY.rds

R xts object saved with saveRDS: 7,786 daily rows, 6 columns (SPY.Open, SPY.High, SPY.Low, SPY.Close, SPY.Volume, SPY.Adjusted), 29 Jan 1993 to 29 Dec 2023.

Used in: 03-bl, 12-regression

Source: Yahoo Finance prices for SPY, downloaded 24 Aug 2026 with the R package quantmod.

Terms: Yahoo's Terms of Service (https://legal.yahoo.com/us/en/yahoo/terms/otos/index.html) forbid reproducing or distributing any portion of the Services without explicit written permission. The Yahoo Finance help page (https://help.yahoo.com/kb/SLN2310.html) says: "You must not redistribute information displayed on or provided by Yahoo Finance".

### quantmod/VTV.rds

R xts object saved with saveRDS: 5,014 daily rows, 6 columns (VTV.Open, VTV.High, VTV.Low, VTV.Close, VTV.Volume, VTV.Adjusted), 30 Jan 2004 to 29 Dec 2023.

Used in: 01-prob (exercises)

Source: Yahoo Finance prices for VTV (Vanguard value ETF), downloaded 24 Aug 2026 with the R package quantmod.

Terms: Yahoo's Terms of Service (https://legal.yahoo.com/us/en/yahoo/terms/otos/index.html) forbid reproducing or distributing any portion of the Services without explicit written permission. The Yahoo Finance help page (https://help.yahoo.com/kb/SLN2310.html) says: "You must not redistribute information displayed on or provided by Yahoo Finance".

### quantmod/VUG.rds

R xts object saved with saveRDS: 5,014 daily rows, 6 columns (VUG.Open, VUG.High, VUG.Low, VUG.Close, VUG.Volume, VUG.Adjusted), 30 Jan 2004 to 29 Dec 2023.

Used in: 01-prob (exercises)

Source: Yahoo Finance prices for VUG (Vanguard growth ETF), downloaded 24 Aug 2026 with the R package quantmod.

Terms: Yahoo's Terms of Service (https://legal.yahoo.com/us/en/yahoo/terms/otos/index.html) forbid reproducing or distributing any portion of the Services without explicit written permission. The Yahoo Finance help page (https://help.yahoo.com/kb/SLN2310.html) says: "You must not redistribute information displayed on or provided by Yahoo Finance".

### tft/bsts_results.csv

92 rows by 6 columns (Date, Actual, Pred_Mean, Pred_Lower, Pred_Upper, Type): the forecast of a Bayesian structural time series (a local linear trend plus a seasonal component with 52 seasons, one per week of the year) for the test weeks of the claims series, with the actual claims, the posterior mean and the interval limits.

Used in: 15-forecasting (through code/15-forecasting-tft.py)

Source: Computed from tft/claims.csv by code/15-forecasting-bsts-claims.R with the R package bsts (1,000 MCMC iterations).

Terms: Derived from the claims series described above.

### tft/claims.csv

456 rows by 4 columns (Date, Claims, Type, time_idx): the weekly series of US initial claims for unemployment insurance, not seasonally adjusted, from the week of 4 January 2004, with the split into a training part (the first 80 percent of the weeks) and a test part used in chapter 15.

Used in: 15-forecasting (through code/15-forecasting-tft.py)

Source: The data set `iclaims` of the R package bsts (Steven L. Scott), whose first column holds the initial claims numbers of FRED (series ICNSA, https://fred.stlouisfed.org/series/ICNSA). The file is written by code/15-forecasting-bsts-claims.R, which also computes the dates and the split.

Terms: The numbers are US Department of Labor statistics distributed by FRED. The bsts package is licensed LGPL-2.1 or MIT + file LICENSE (version 0.9.11).

### timeseries/model12-sp500.RData

Two fitted bsts objects (model1 local linear trend, model2 semilocal linear trend), 1000 MCMC draws each, for the 2518 daily S&P 500 adjusted closes of 2013 to 2022. 82 MB.

Used in: 15-forecasting

Source: Derived from GSPC.csv by the code of the book.

Terms: The R package bsts lists the license LGPL version 2.1, or MIT plus file LICENSE (https://cran.r-project.org/web/packages/bsts/index.html). The embedded prices carry the Yahoo Finance restriction stated for GSPC.csv (https://help.yahoo.com/kb/SLN2310.html).

### timeseries/model123.RData

Three fitted bsts objects (model1, model2, model3), 1000 MCMC draws each, for 456 weekly US initial unemployment claims: local linear trend and 52 week seasonal, with model2 and model3 adding 10 Google search regressors under spike and slab priors. 38 MB.

Used in: 15-forecasting

Source: Derived from the bsts data set initial.claims ("initial claims numbers from FRED" plus Google Correlate query series) by the code of the book (https://rdrr.io/cran/bsts/man/iclaims.html).

Terms: The bsts package lists the license LGPL version 2.1, or MIT plus file LICENSE (https://cran.r-project.org/web/packages/bsts/index.html).

### timeseries/rec_data_20160613.csv

518 rows, 20 columns: monthly NBER recession indicator (nber) and 19 predictors (yield curve, spreads, S&P 500 returns, VIX, payrolls, PMI and others).

Used in: 15-forecasting

Source: The predictors follow the appendix of Berge, Sinha and Smolyansky (2016), FEDS Notes, whose data run from January 1973 to May 2016 (https://www.federalreserve.gov/econresdata/notes/feds-notes/2016/which-market-indicators-best-forecast-recessions-20160802.html).

Terms: The Federal Reserve site says "Unless otherwise indicated, information on Board's website is in the public domain", and non Board material may be copyrighted (https://www.federalreserve.gov/disclaimer.htm). Terms for the underlying series are not established.

### timeseries/tsmodel-nber.RData

One fitted bsts object (ts.model: logit observation model, local level state, 20000 MCMC draws, 20 coefficients) for the 518 monthly NBER recession indicators. 238 MB.

Used in: 15-forecasting

Source: Derived from timeseries/rec_data_20160613.csv by the code of the book. The object embeds the predictor data.

Terms: It inherits the terms of timeseries/rec_data_20160613.csv, which are not established. The R package bsts lists the license LGPL version 2.1, or MIT plus file LICENSE (https://cran.r-project.org/web/packages/bsts/index.html).
