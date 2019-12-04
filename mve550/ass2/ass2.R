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

# (d) Use simulation to check result in (c) Ska man köra (c) många ggr bara?
simExtP <- c()
for (i in 1:1000) {
  simExtP[i] <- extinctionProbability(1.1) 
}
hist(simExtP); print(mean(simExtP))

simBranch <- c()
for (i in 1:100000) {
  simBranch[i] <- branch(1.1)
}
hist(simBranch); print(mean(simBranch))
  
# (e) Compute MLE for λ. Probability of extinction using that λ?


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
