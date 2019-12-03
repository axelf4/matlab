# 1. Branching processes

# (a) Compute posterior
local({
	propto <- function(lambda) lambda^10 * exp(-4 * lambda)
	int_const <- 1 / integrate(propto, 0, Inf)$value
	posterior <<- function(lambda) int_const * propto(lambda)
})

# Returns Z_n using the specified lambda
branch <- function(lambda, n = 10) {
	Z <- 7
	for (i in (4 + 1):n) {
		if (Z > 5000) {
			return(Z)
		}
		Z <- sum(rpois(Z, lambda))
	}
	Z
}

# (b) Given λ, compute numerically prob that branching process in
# Fig4 becomes extinct
extinctionProbability <- function(lambda) {
	num_trials <- 1000
	simulations <- replicate(num_trials, branch(lambda))
	sum(simulations == 0) / num_trials # Estimate of extinction probability
}

print(extinctionProbability(1.1))

# (c) Probability of extinction for the brancing process taking uncertainty into account
probability_of_extinction <- integrate(Vectorize(function(lambda)
	extinctionProbability(lambda) * posterior(lambda)), 0, Inf)
cat(sprintf("The probability of extinction for the process in question: %f\n",
		probability_of_extinction$value))

# (d) Use simulation to check result in (c)

# (e) Compute MLE for λ. Probability of extinction using that λ?

