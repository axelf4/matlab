# 1.
lambda = 36
# (b)
sizeA <- 0.4^2; sizeD <- 0.2^2; sizeB <- sizeA - sizeD
cat(sprintf("The probability of exactly 4 trees in the two squares simultaneously\n\t= %f\n",
		sum(sapply(0:4, function(k) dpois(k, lambda * sizeD) * dpois(4 - k, lambda * sizeB)^2))))
