# 1.
lambda = 36
# (b)
sizeA <- 0.4^2; sizeD <- 0.2^2; sizeB <- sizeA - sizeD
cat(sprintf("The probability of exactly 4 trees in the two squares simultaneously\n\t= %f\n",
		sum(sapply(0:4, function(k) dpois(k, lambda * sizeD) * dpois(4 - k, lambda * sizeB)^2))))

# (c) Plot simulated trees
N <- rpois(1, lambda * 1^2) # Number of points
# Conditioning on n, the location of points are uniformly distributed
plot(x = runif(N, 0, 1), y = runif(N, 0, 1),
	pch = 2, xlim = c(0, 1), ylim = c(0, 1))
