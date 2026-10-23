set.seed(8) # Ovi
t = 1:5
lmb = 1
N = rpois(5,t*lmb)
plot(N, type='l')


# A: rate (beta), a: shape (alpha)
plotgamma = function(a,A,N) {
    x = seq(0,10,0.01)
    plot(x,dgamma(x,a,A),type="l",xlab="t",ylab="Gamma(t)")
    at = N+a
    At = t+A
    mean = at/At
    plot(N, type='l', col="orange", ylim=c(0,5))
    lines(mean, col="blue", lwd=3, lty=2)
    lines(qgamma(0.05,at,At), col="grey", lwd=1, lty=2)
    lines(qgamma(0.95,at,At), col="grey", lwd=1, lty=2)
}
par(mar=c(4,4,0,0), bty='n')

plotgamma(a=4,A=1, N)
plotgamma(a=1,A=1, N)
plotgamma(a=1,A=1, N)
plotgamma(a=1,A=5, N)
