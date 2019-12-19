# library(expm)
# library(MASS)
normalize <- function(v) v / sum(v)

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

plotSim <- function(sim) {
	par(pty = "s")
	plot(x = sim$x, y = sim$y, pch = 2,
		xlim = c(0, 1), ylim = c(0, 1),
		xlab = "", ylab = "", main = NULL)
}

tikz("trees.tex", width = 4, height = 4)
plotSim(simTrees(lambda))
dev.off()

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
Xs <- replicate(1000, calcX(simTrees(rlambda())))
hist(Xs, probability = T)

# 2.

# Rows are probability vectors and sum to one.
calcPtilde <- function(p12, p21, p31) matrix(
		c(0, p12, 1 - p12,
			p21, 0, 1 - p12,
			p31, 1 - p31, 0),
		nrow = 3, byrow = TRUE,
		dimnames = list(states, states))

calcQ <- function(q, p12, p21, p31) {
	Ptilde <- calcPtilde(p12, p21, p31)
	Q <- q * Ptilde
	diag(Q) <- -q
	Q
}

# a)
states <- c(1, 2, 3)
q <- c(1/5, 1, 1/2)
p12 <- p13 <- p21 <- p23 <- p31 <- p32 <- 0.5
Q <- calcQ(q, p12, p21, p31)
stat <- normalize(t(Null(Q)))
cat(paste0("Stat is (", toString(stat), ")\n"))

# b)
X <- data.frame(state = c(1, 3, 2, 3, 1, 2, 1, 3, 1, 2),
		duration = c(6.83, 4.01, 1.63, 0.44, 5.11, 0.29, 2.87, 1.3, 4.76, 1.92))

# Returns a random draw from the posterior for the parameters.
rposterior <- function() list(q1 = rgamma(1, 4, 19.57), q2 = rgamma(1, 4, 3.84),
	q3 = rgamma(1, 4, 5.75), p12 = rbeta(1, 5/2, 5/2),
	p21 = rbeta(1, 3/2, 3/3), p31 = rbeta(1, 5/2, 3/2))

# (c)

simulate <- function() {
	params <- rposterior()
	q <- c(params$q1, params$q2, params$q3)
	Q <- calcQ(q, params$p12, params$p21, params$p31)

	Qnodiag <- Q
	diag(Qnodiag) <- NA

	state <- 1 # Start in state 1

	num_values <- 10
	values <- list()
	for (k in 1:(num_values - 1)) {
		row <- Qnodiag[state,]
		times <- sapply(row, function(q) if (is.na(q)) NA else rexp(1, q))
		min_index <- which.min(times)
		values[[k]] <- list(state = state, dur = times[[min_index]])
		state <- min_index
	}
	values
}

sim <- simulate()
