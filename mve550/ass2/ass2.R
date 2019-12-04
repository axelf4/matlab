# 1. Branching processes

# (a) Compute posterior
local({
	propto <- function(lambda) lambda^10 * exp(-4 * lambda)
	int_const <- 1 / integrate(propto, 0, Inf)$value
	posterior <<- function(lambda) int_const * propto(lambda)
	# It is a Gamma distribution with parameters
	# α_1 = 11, β_1 = 4
	alpha <- 0; beta <- 0 # Prior parameters
	alpha_1 <<- 11; beta_1 <<- 4
	dposterior <<- function(lambda) dgamma(lambda, shape = alpha_1, rate = beta_1)
	rposterior <<- function(n) rgamma(n, shape = alpha_1, rate = beta_1)
})

# Returns Z_n using the specified lambda
branch <- function(lambda, n = 30) {
	Z <- 7
	for (i in (4 + 1):n) {
		# Large λ:s cause larger populations than R can handle: Prolly won't go extinct
		Z <- sum(rpois(Z, lambda))
		if (Z > 1000) break
	}
	Z
}

# (b) Given λ, compute numerically prob that branching process in
# Fig4 becomes extinct
extinctionProbability <- function(lambda) {
	num_trials <- 1e3
	simulations <- replicate(num_trials, branch(lambda))
	sum(simulations == 0) / num_trials # Estimate of extinction probability
}

# print(extinctionProbability(1.1)) # Test the function

# (c) Probability of extinction for the brancing process taking uncertainty into account
probability_of_extinction <- integrate(Vectorize(function(lambda)
	extinctionProbability(lambda) * dposterior(lambda)), 0, Inf)
cat(sprintf("The probability of extinction for the process in question: %f\n",
		probability_of_extinction$value))

# (d) Use simulation to check result in (c)
n <- 1e3
# Draw n λ:s from the posterior distribution, and average simulations on those
sim_extinction_prob <- mean(sapply(rposterior(n), extinctionProbability))
cat(sprintf("Simulated probability of extinction for THE process: %f\n",
		sim_extinction_prob))

# (e) Compute MLE for λ. Probability of extinction using that λ?

lambda_mle <- optimize(function(lambda) dgamma(lambda, shape = 12, rate = 4),
	lower = 0, upper = 10, maximum = TRUE)$maximum
cat(paste0("MLE estimate for lambda:\n\tlambda_mle = ", lambda_mle,
		"\n\textinctionProbability(lambda_mle) = ", extinctionProbability(lambda_mle),
		"\n"))

# 2. Metropolis Hastings
D <- read.table("Regressiondata.txt", col.names = c("x", "y"))

# (a) Plot the data
# plot(D)
X <- D["x"]

# (b) Log of P(theta'|data)/P(theta|data)
logAlpha <- function(theta, theta_prime) {
	logPosterior <- function(theta1, theta2, theta3, theta4)
		dnorm(theta1, 10, 10, log = T) + dgamma(theta2, 1/2, 1/10, log = T) +
			dunif(theta3, 0, 1, log = T) + dgamma(theta4, 2, 2, log = T) +
			sum(sapply(X,
					function(x) dnorm(theta1 + theta2 * sin((x - theta3) * 2 * pi), theta4))) # Likelihoods
	logPosterior(theta[[1]],theta[[2]],theta[[3]],   theta[[4]]) -
		logPosterior(theta_prime[[1]],theta_prime[[2]],theta_prime[[3]], theta_prime[[4]])
}

# (c) Implement Metropolis-Hastings
# Get starting point by drawing from prior
metropolisHastings <- function() {
	theta <- c(rnorm(1, 10, 10), rgamma(1, 1/2, 1/10), runif(1, 0, 1), rgamma(1, 2, 2))

	n <- 1e5
	for (i in 1:n) {
		local({
			theta1 <- rnorm(1, theta[[1]], 0.1)
			theta2 <- abs(rnorm(1, theta[[2]], 0.1))
			theta3 <- theta[[3]] + runif(1, -0.1, 0.1)
			if (theta3 > 1) theta3 <- theta3 - 1
			if (theta3 < 0) theta3 <- theta3 + 1
			theta4 <- abs(rnorm(1, theta[[4]], 0.1))
			theta_prime <<- c(theta1, theta2, theta3, theta4)
		})

		a <- exp(logAlpha(theta, theta_prime))
		if (runif(1) < a) {
			# Accept the fucker
			theta <- theta_prime
		}
	}

	theta
}

theta <- metropolisHastings()
cat(paste0("The resulting theta is (", toString(theta), ")\n"))

# (d) Repeat (c) a shitton of times
thetas <- replicate(100, metropolisHastings())
means <- apply(thetas, 1, mean)
sds <- apply(thetas, 1, sd)
cat(paste0("The means are\n\t\t(", toString(means), ")\n\tand the standard deviations are\n\t\t(",
		toString(sds), ")\n"))

# (e)
probability_of_y <- mean(apply(thetas, 2, function(theta) 1 -
	pnorm(7.4, theta[[1]] + theta[[2]] * sin((0.6 - theta[[3]]) * 2 * pi), theta[[4]])))
print(probability_of_y)
