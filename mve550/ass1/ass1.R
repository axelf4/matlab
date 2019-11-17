alpha <- 3; beta <- 4

# (a) Compute the predicted probabilities for getting N customers
# λ ~ Gamma(3, 4), X|λ ~ Poi(λ)
# λ|X ~ Gamma(3 + Σx, 4 + n), ty konjugatpar
#
# Y ~ Poi(λ)
# Y|X ~ Neg-Bin(α_1, β_1 / (β_1 + 1)), ty konjugatpar
x <- c(2, 0, 1)
c <- c(0, 1, 2, 3, 4)
alpha1 <- 3 + sum(x); beta1 <- 3 + length(x)
predicted_probabilities <- dnbinom(c, alpha1, 1 - 1 / (1 + beta1))
prob_4_or_more <- 1 - sum(predicted_probabilities)

# (b) Simulate some things, compute some things
# π(X = 2) = ?
set.seed(123)
N <- 1e6; lambda <- rgamma(N, alpha, beta)
# y <- sapply(lambda, function(lambda) rpois(1, lambda))
selected <- Filter(function(lambda) rpois(1, lambda) == 2, lambda)

cat(sprintf("The expected proportion:\n\tAnalytical results: %f\n\tSimulated results: %f\n",
		dnbinom(2, alpha, 1 - 1 / (1 + beta)),
		length(selected) / N))

# Plot the distributions of selected lambdas
plot(density(selected))
plot(selected, dgamma(selected, alpha + 2, beta + 1)) # λ|X=2 ~ Gamma(3 + 2, 4, + 1)

# (c) Compare Y1,Y2,Y3 ~ Poi(λ_i) to 2,0,1 to approx (a)
sample <- Filter(function(lambda) identical(x, rpois(3, lambda)), lambda)

# 2. Question 3.52
states <- c("1", "3", "4", "6", "7", "9")
P <- matrix(c(2/4, 1/4, 0, 0, 1/4, 0,
		0, 1/4, 1/4, 1/4, 1/4, 0,
		0, 1/4, 1/4, 1/4, 1/4, 0,
		0, 0, 1/4, 1/4, 1/4, 1/4,
		0, 0, 1/4, 0, 2/4, 1/4,
		0, 0, 0, 0, 0, 1),
	nrow = length(states),
	byrow = TRUE,
	dimnames = list(states, states))
Q <- P[1:5, 1:5]
R <- solve(diag(5) - Q)
a <- rowSums(R)
