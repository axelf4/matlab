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
