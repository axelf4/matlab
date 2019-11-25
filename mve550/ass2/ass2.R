# 1. Branching processes

# (b) Given λ, compute numerically prob that branching process in
# Fig4 becomes extinct
extinctionProbability <- function(lambda) {
	# Returns Z_n using the lambda in question
	branch <- function(n = 100) {
		Z <- 7
		for (i in seq(n - 4)) Z <- sum(rpois(Z, lambda))
		Z
	}

	num_trials <- 1000
	simulations <- replicate(num_trials, branch())
	sum(simulations == 0) / num_trials # Estimate of extinction probability
}

print(extinctionProbability(1.1))
