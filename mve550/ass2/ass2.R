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

# (d) Use simulation to check result in (c) Ska man köra (c) många ggr bara?
n <- 1e2
# Draw n λ:s from the posterior distribution, and average simulations on those
sim_extinction_prob <- mean(sapply(rposterior(n), extinctionProbability)) / n
cat(sprintf("Simulated probability of extinction for THE process: %f\n",
		sim_extinction_prob))

# (e) Compute MLE for λ. Probability of extinction using that λ?

lambda_mle <- optimize(function(lambda) dgamma(lambda, shape = 12, rate = 4),
	lower = 0, upper = 10, maximum = TRUE)$maximum
cat(paste0("MLE estimate for lambda: lambda_mle = ", lambda_mle,
		", extinctionProbability(lambda_mle) = ", extinctionProbability(lambda_mle)))

# 2. Metropolis Hastings

# (a) Plot the data
D <- read.table("Regressiondata.txt")
plot(D)
x <- D[,1]

# (b) Log of P(theta*|data)/P(theta|data)
prior <- function(theta1, theta2, theta3, theta4) {
  prior <- theta1*rnorm(1, 10, 10^2) * theta2*rgamma(1, 1/2, 1/10) * theta3*runif(1, 0, 1) * theta4*rgamma(1, 2, 2)
}
likelihood <- function(x, theta1, theta2, theta3, theta4) {
  likelihood <- rnorm(theta1 + theta2*sin((x - theta3)*2*pi), theta4^2)
}
