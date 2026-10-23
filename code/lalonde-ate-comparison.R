suppressMessages({library(bartCause); library(MatchIt); library(Matching); library(dbarts)})

## (1) Experimental benchmark: the NSW randomized trial (Dehejia-Wahba sample)
data(lalonde, package = "Matching"); e <- lalonde
b1 <- e$re78[e$treat==1]; b0 <- e$re78[e$treat==0]
cat(sprintf("Experimental Benchmark    %9.2f  %8.2f\n",
    mean(b1)-mean(b0), sqrt(var(b1)/length(b1)+var(b0)/length(b0))))

## Non-experimental sample: 185 NSW treated + 429 PSID controls
data(lalonde, package = "MatchIt"); d <- lalonde
d$black <- as.integer(d$race=="black"); d$hisp <- as.integer(d$race=="hispan")
conf <- c("age","educ","black","hisp","married","nodegree","re74","re75")
fml <- as.formula(paste("treat ~", paste(conf, collapse=" + ")))

## (2) Naive difference in means
n1 <- d$re78[d$treat==1]; n0 <- d$re78[d$treat==0]
cat(sprintf("Naive Difference-in-Means %9.2f  %8.2f\n",
    mean(n1)-mean(n0), sqrt(var(n1)/length(n1)+var(n0)/length(n0))))

## (3) Propensity score matching (nearest neighbour on a logistic propensity, ATT)
set.seed(1)
md <- match.data(matchit(fml, data=d, method="nearest", distance="glm"))
fm <- lm(re78 ~ treat, data=md, weights=md$weights)
cat(sprintf("Propensity Score Matching %9.2f  %8.2f\n",
    coef(fm)["treat"], sqrt(diag(vcov(fm)))["treat"]))

## (4) Double machine learning (5-fold cross-fitted partially linear, BART nuisances)
set.seed(1)
X <- as.matrix(d[,conf]); Y <- d$re78; D <- d$treat; n <- nrow(d)
folds <- sample(rep(1:5, length.out=n)); resY <- resD <- numeric(n)
for (k in 1:5) {
  tr <- folds!=k; te <- folds==k
  resY[te] <- Y[te] - colMeans(bart(X[tr,], Y[tr], X[te,], verbose=FALSE, keeptrees=FALSE)$yhat.test)
  resD[te] <- D[te] - colMeans(pnorm(bart(X[tr,], factor(D[tr]), X[te,], verbose=FALSE, keeptrees=FALSE)$yhat.test))
}
th <- sum(resD*resY)/sum(resD^2); psi <- resD*(resY-th*resD)
cat(sprintf("Double Machine Learning   %9.2f  %8.2f\n", th, sqrt(mean(psi^2)/n)/mean(resD^2)))

## (5) Causal BART (ATT)
set.seed(1)
sb <- summary(bartc(response=d$re78, treatment=d$treat, confounders=d[,conf],
                    estimand="att", commonSup.rule="sd", verbose=FALSE))$estimates
cat(sprintf("Causal BART               %9.2f  %8.2f   ci [%.0f, %.0f]\n",
    sb$estimate, sb$sd, sb$ci.lower, sb$ci.upper))
