# The network used in the questions:
#     ╭──T_1──╮
#     │       │
# A ──┼──T_2──┼──T_4── B
#     │       │
#     ╰──T_3──╯

# 1. Compute expected life length of network in figure 6
lambda_1 <- function(t) 1 / (2 * sqrt(t)); lambda_4 <- function(t) t^(11/10) / 50
S_1 <- function(t) exp(-sqrt(t)); S_4 <- function(t) exp(-t^(21/10) / 105)

# Returns the expected life length given the survival function.
expectedLifetime <- function(S) integrate(S, 0, Inf)$value

# S_1 <- function(t) exp(-integrate(lambda_1, 0, t)); S_4 <- function(t) exp(-integrate(lambda_4, 0, t))
S_I <- function(t) 1 - (1 - S_1(t))^3
S <- function(t) S_I(t) * S_4(t)
expectedLifetime(S)

# 2. Plot the hazard function lambda_T(t)
Lambda <- deriv(as.expression(do.call('substitute', list(
		quote(-log((1 - (1 - S_1)^3) * S_4)),
		list(
			S_1 = quote(exp(-sqrt(t))),
			S_4 = quote(exp(-t^(21/10) / 105))
		)))), "t", function.arg = TRUE)
lambda <- function(t) attr(Lambda(t), "gradient")
x <- seq(0, 6, length = 200)
plot(x, lambda(x), 'l')

# 3. Compute the probability that network failure is caused by the failure of T_4
# Pr(T = T_4) = Pr(T_4 < T_I) = int_0^Inf f_{T_I}(t) * S_{T_4}(t) dt
# f = S * lambda
probabilityT4Cause <- integrate(function(t) S_4(t) * lambda_4(t) * S_I(t), 0, Inf)
probabilityT4Cause

# 4.
probabilityT4PrimeCause <- Vectorize(function(k) integrate(function(t) dgamma(t, k) * S_I(t), 0, Inf)$value)
k <- 1:10
plot(k, probabilityT4PrimeCause(k))

# 5.
k <- 1:10
y <- Vectorize(function(k) expectedLifetime(function(t) S_I(t) * (1 - pgamma(t, k))))
plot(k, y(k))

# 6.
cost <- function(lambda) 1/5 + lambda # The cost of a component with a Weibull(lambda, 1/4) dist
f <- function(gamma) {
	mu <- (11/5 - gamma) / 3
	expectedLifetime(function(t) (1 - pweibull(t, mu, 1/4)^3) * pweibull(t, gamma, 1/4, lower.tail = FALSE))
}
res <- optimize(f, interval = c(0, 11/5), maximum = TRUE)
sprintf("Maximum %f acheived at mu = %f, gamma = %f", res$objective, (11/5 - res$maximum) / 3,
	res$maximum)
