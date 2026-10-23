###################################################
## Fit a regression tree to medv~lstat in the boston housing data.
## The tree is plotted as well as a plot of the corresponding step function
## fit to the data.
## The cutpoints from tree are added to the plot so you can see how
## the tree corresponds to the function.
###################################################

library(tree)
library(MASS)
data(Boston)
attach(Boston)

#--------------------------------------------------
#fit a tree to boston data just using lstat.

#first get a big tree using a small value of mindev
temp = tree(medv~lstat,data=Boston,mindev=.0001)
cat('first big tree size: \n')
print(length(unique(temp$where)))

#then prune it down to one with 7 leaves
boston.tree=prune.tree(temp,best=7)
cat('pruned tree size: \n')
print(length(unique(boston.tree$where)))

#--------------------------------------------------
#plot the tree and the fits.
par(mfrow=c(1,2))

#plot the tree
plot(boston.tree,type="uniform")
text(boston.tree,col="blue",label=c("yval"),cex=.8)

#plot data with fit
boston.fit = predict(boston.tree) #get training fitted values

plot(lstat,medv,cex=.5,pch=16) #plot data
oo=order(lstat)
lines(lstat[oo],boston.fit[oo],col='red',lwd=3) #step function fit

cvals=c(9.725,4.65,3.325,5.495,16.085,19.9) #cutpoints from tree
for(i in 1:length(cvals)) abline(v=cvals[i],col='magenta',lty=2) #cutpoints

rm(list=ls())



################################################################################
## Fit a regression tree to mev~dis+lstat from the Boston housing data.
## The tree is plotted as well as the corresponding partition of the two-dimensional
## x=(dis,lstat) space.
################################################################################

library(MASS)
data(Boston)
attach(Boston)
library(tree)

#--------------------------------------------------
df2=Boston[,c(8,13,14)] #pick off dis,lstat,medv
print(names(df2))

#--------------------------------------------------
#big tree
temp = tree(medv~.,df2,mindev=.0001)
cat('first big tree size: \n')
print(length(unique(temp$where)))

#--------------------------------------------------
#then prune it down to one with 7 leaves
boston.tree=prune.tree(temp,best=7)
cat('pruned tree size: \n')
print(length(unique(boston.tree$where)))

#--------------------------------------------------
# plot tree and partition in x.
par(mfrow=c(1,2))
plot(boston.tree,type="u")
text(boston.tree,col="blue",label=c("yval"),cex=.8)
partition.tree(boston.tree)

rm(list=ls())

################################################################################
## Fit a regression tree to medv~dis+lstat and then do a perpective
## plot of (x1,x2) vs. y.
################################################################################

library(MASS)
data(Boston)
attach(Boston)
library(tree)

#--------------------------------------------------
df2=Boston[,c(8,13,14)] #pick off dis,lstat,medv
print(names(df2))

#--------------------------------------------------
#big tree
temp = tree(medv~.,df2,mindev=.0001)
cat('first big tree size: \n')
print(length(unique(temp$where)))

#then prune it down to one with 7 leaves
boston.tree=prune.tree(temp,best=7)
cat('pruned tree size: \n')
print(length(unique(boston.tree$where)))

#--------------------------------------------------
#get predictions on 2d grid
pv=seq(from=.01,to=.99,by=.05)
x1q = quantile(df2$lstat,probs=pv)
x2q = quantile(df2$dis,probs=pv)
xx = expand.grid(x1q,x2q) #matrix with two columns using all combinations of x1q and x2q
dfpred = data.frame(dis=xx[,2],lstat=xx[,1])
lmedpred = predict(boston.tree,dfpred)

#make perspective plot

par(mfrow=c(1,1))
persp(x1q,x2q,matrix(lmedpred,ncol=length(x2q),byrow=T),
      theta=150,xlab='dis',ylab='lstat',zlab='medv',
      zlim=c(min(df2$medv),1.1*max(df2$medv)))