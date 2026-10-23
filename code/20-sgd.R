# Code of chapter: Gradient Descent
# Every R chunk of the chapter in book order, including the ones the book does not print. Chunks the book does not run are commented out.
# Run from the book folder: Rscript code/20-sgd.R. Data are read from the data folder. Figures go to the graphics device (Rplots.pdf under Rscript).
# Packages: knitr

source("code/common.R")

# ---- Gradient Descent ------------------------------------------------------

# [fig-learning_rates]
plot(c(-3,3),c(0,9), type='n', xlab=expression(theta), ylab=expression(l(theta)), bty='n')
curve(x^2, from=-3, to=3, col="blue", lwd=2, add=TRUE)
arrows(2, 0, -2, 0, col="red", lwd=2, length=0.1)
# Dashed line to show projection of the point on the x-axis
abline(v=2, lty=2, col="gray")
abline(v=-2, lty=2, col="gray")
text(-1.1, 7, expression(alpha==1), col="red", cex=0.6)

plot(c(-3,3),c(0,9), type='n', xlab=expression(theta), ylab=expression(l(theta)), bty='n')
curve(x^2, from=-3, to=3, col="blue", lwd=2, add=TRUE)
arrows(2, 0, 0, 0, col="red", lwd=2, length=0.1)
# Dashed line to show projection of the point on the x-axis
abline(v=2, lty=2, col="gray")
abline(v=0, lty=2, col="gray")
text(-1.1, 7, expression(alpha==0.5), col="red", cex=0.6)

plot(c(-3,3),c(0,9), type='n', xlab=expression(theta), ylab=expression(l(theta)), bty='n')
curve(x^2, from=-3, to=3, col="blue", lwd=2, add=TRUE)
arrows(2, 0, 1, 0, col="red", lwd=2, length=0.1)
# Dashed line to show projection of the point on the x-axis
abline(v=2, lty=2, col="gray")
abline(v=1, lty=2, col="gray")
text(-1.1, 7, expression(alpha==0.25), col="red", cex=0.6)

# ---- Linear Regression -----------------------------------------------------

data(iris)
y = iris$Petal.Length
x = cbind(rep(1,150),iris$Petal.Width)

# initialize theta
theta <- matrix(c(0, 0), nrow = 2, ncol = 1)
# learning rate
alpha <- 0.0001
# number of iterations
n_iter <- 40
loss = numeric(n_iter)
# gradient descent
for (i in 1:n_iter) {
    # compute gradient
    grad <- -2 * t(x) %*% (y - x %*% theta)
    # update theta
    theta <- theta - alpha * grad
    # compute loss
    loss[i] <- sum((y - x %*% theta)^2)
}

# [gd-coef]
knitr::kable(t(theta), col.names = c("Intercept ($\\theta_0$)","Petal.Width ($\\theta_1$)"))

# [iris-gd-plot]
par(mar=c(4,4,1,1), bty='n')
plot(x[,2],y,pch=16, xlab="Petal width (cm)", ylab="Petal length (cm)")
abline(a=theta[1], b=theta[2], lwd=3, col="red")

# [cars-lm]
m = lm(Petal.Length~Petal.Width, data=iris)
knitr::kable(t(coef(m)))

# [iris-gd-loss]
plot(loss[1:40], type='l', xlab="Iteration", ylab="Loss", bty='n', col="blue", lwd=2)
abline(h=min(loss), lty=2, col="red")

# ---- Logistic Regression ---------------------------------------------------

y = ifelse(iris$Species=="setosa",1,0)
x = cbind(rep(1,150),iris$Sepal.Length)
# gradient descent function for logistic regression
lrgd  = function(x,y, alpha, n_iter) {
  theta <- matrix(c(0, 0), nrow = 2, ncol = 1)
  for (i in 1:n_iter) {
    # compute gradient
    p = 1/(1+exp(-x %*% theta))
    grad <- -t(x) %*% (y - p)
    # update theta
    theta <- theta - alpha * grad
  }
  return(theta)
}
theta = lrgd(x,y,0.005,20000)

# [gd-coef-glm]
knitr::kable(t(theta), col.names = c("Intercept ($\\theta_0$)","Sepal.Length ($\\theta_1$)"))

# [iris-gd-plot-glm]
p = 1/(1+exp(-x %*% theta))
plot(x[,2],y,pch=16, xlab="Sepal length (cm)", ylab="Setosa (1) or not (0)")
lines(x[,2],p,type='p', pch=16,col="red")
legend("topright", c("observed", "fitted probability"), pch = 16, col = c("black", "red"), bty = "n", cex = 0.7)

# [iris-glm]
glm(y~x-1, family=binomial(link="logit")) %>% tidy() %>% kable()

# ---- Stochastic Gradient Descent -------------------------------------------

# [sgd-lr]
lrgd_minibatch  = function(x,y, alpha, n_iter, bs) {
  theta <- matrix(c(0, 0), nrow = 2, ncol = n_iter+1)
  n = length(y)
  for (i in 1:n_iter) {
    s = ((i-1)*bs+1)%%n
    e = min(s+bs-1,n)
    xl = x[s:e,]; yl = y[s:e]
    p = 1/(1+exp(-xl %*% theta[,i]))
    grad <- -t(xl) %*% (yl - p)
    # update theta
    theta[,i+1] <- theta[,i] - alpha * grad
  }
  return(theta)
}

# [sgd-mb-run]
set.seed(92) # kuzy
ind = sample(150)
y = ifelse(iris$Species=="setosa",1,0)[ind] # shuffle data
x = cbind(rep(1,150),iris$Sepal.Length)[ind,] # shuffle data
nit=200000
lr = 0.01
th1 = lrgd_minibatch(x,y,lr,nit,5)
th2 = lrgd_minibatch(x,y,lr,nit,15)
th3 = lrgd_minibatch(x,y,lr,nit,30)

par(mar=c(4,4,1,1), bty='n')
ind = seq(1,nit,100)
plot(ind/1000,th1[1,ind], type='l', ylim=c(0,33), col=1, ylab=expression(theta[0]), xlab="Iteration (thousands)")
abline(h=27.83, lty=2)
lines(ind/1000,th2[1,ind], type='l', col=2, lty=4)
lines(ind/1000,th3[1,ind], type='l', col=3, lty=3)
legend("bottomright", legend=c(5,15,30),col=1:3, lty=c(1,4,3), bty='n',title = "Batch Size", cex = 0.7)

# [sgd-scaled-plot]
plot(ind/1000,th1[1,ind], type='l', ylim=c(0,33), col=1, ylab=expression(theta[0]), xlab="Computation (thousands of iterations with batch size 5)")
abline(h=27.83, lty=2)
lines(ind/1000*3,th2[1,ind], type='l', col=2, lty=4)
lines(ind/1000*6,th3[1,ind], type='l', col=3, lty=3)
legend("bottomright", legend=c(5,15,30),col=1:3, lty=c(1,4,3), bty='n',title = "Batch Size", cex = 0.7)

# ---- Automatic Differentiation (Backpropagation) ---------------------------

# [diff-ex]
# (the book does not run this chunk when it builds; it has no output in the book, and it is commented out here: remove the comment marks to run it)
# sigmoid = function(x,b,w){
#   v1 = w*x
#   v2 = v1 + b
#   v3 = 1/(1+exp(-v2))
# }
