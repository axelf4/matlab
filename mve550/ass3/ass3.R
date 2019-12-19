# 1.
lambda = 36
# (b)
sizeA <- 0.4^2; sizeD <- 0.2^2; sizeB <- sizeA - sizeD
cat(sprintf("The probability of exactly 4 trees in the two squares simultaneously\n\t= %f\n",
		sum(sapply(0:4, function(k) dpois(k, lambda * sizeD) * dpois(4 - k, lambda * sizeB)^2))))

# (c) Plot simulated trees
simTrees <- function(lambda) {
	N <- rpois(1, lambda * 1^2) # Number of points
	# Conditioning on N, the location of points are uniformly distributed
	list(x = runif(N, 0, 1), y = runif(N, 0, 1))
}
plotSim <- function(sim) plot(x = sim$x, y = sim$y, pch = 2, xlim = c(0, 1), ylim = c(0, 1))

plotSim(simTrees(lambda))

# (d) Sample lambda from posterior in (c)
alpha_1 <- 36; beta_1 <- 1
rlambda <- function() rgamma(1, alpha_1, beta_1)
plotSim(simTrees(rlambda()))

# (e)
calcX <- function(sim) {
	points <- mapply(list, sim$x, sim$y, SIMPLIFY = FALSE)
	distances <- outer(points, points, function(a, b)
		mapply(function(a, b) (b[[1]] - a[[1]])^2 + (b[[2]] - a[[2]])^2, a, b))
	diag(distances) <- NA
	minDistances <- sqrt(apply(distances, 1, min, na.rm = TRUE))
	mean(minDistances)
}
calcX(sim)
Xs <- replicate(1000, calcX(simTrees(rlambda())))
hist(Xs, probability = T)

		       
# 2.
# Table 1
state <- c(1, 3, 2, 3, 1, 2, 1, 3, 1, 2)
duration <- c(6.83, 4.01, 6.63, 0.44, 5.11, 0.29, 2.87, 1.3, 4.76, 1.92)
D <- matrix(c(state, duration), nrow = 10)
colnames(D) <- c("state", "duration")

# The embedded matrix. 
Ptilde <- matrix(c(0, 0.5, 0.5, 0.5, 0, 0.5, 0.5, 0.5, 0), nrow = 3)

# a) Generator matrix Q.
q <- c(1/5, 1, 1/2)
Q <- matrix(c(-1/5, 1/2, 1/4, 1/10, -1, 1/4, 1/10, 1/2, -1/2), nrow = 3)

# The limiting distribution is obtained by taking e^(tQ) with a big t.
library(expm)
print(expm(50*Q))

# b) Joint distribution for the parameters. 
# The priors for the q's.
rq_1 <- function() rgamma(1, 1, q[1])
rq_2 <- function() rgamma(1, 1, q[2])
rq_3 <- function() rgamma(1, 1, q[3])

# The priors for Ptilde. (Same prior for p_12, p_21 and p_31)
rp <- function() rbeta(1, 1/2, 1/2)

# The product of the q's multiplied with the rows of Ptilde.
jointP <- function(rq, rp) rq * rp

# Posterior = [q1 * 0, q1 * p12, q1 * p12,
#              q2 * p21, q2 * 0, q2 * p21,
#              q3 * p31, q3 * p31, q3 * 0]?

# c) Based on this posterior, simulate from an 
posteriorSim <- matrix(c(0, jointP(rq_1(), rp()), jointP(rq_1(), rp()), jointP(rq_2(), rp()), 0 ,jointP(rq_2(), rp()), jointP(rq_3(), rp()), jointP(rq_3(), rp()), 0), nrow = 3)
Qsim <- posteriorSim + matrix(c(-rowSums(posteriorSim, 3)[1], 0, 0, 0, -rowSums(posteriorSim, 3)[2], 0, 0, 0, -rowSums(posteriorSim, 3)[3]), nrow = 3)
