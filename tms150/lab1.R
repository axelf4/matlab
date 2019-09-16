# cars
attach(cars)

x <- speed; y <- dist
plot(x, y)
n <- length(x)

m1 <- lm(dist ~ speed)

# Exercise 1: Compute the estimated slope and intercept "by hand"
Sxy <- crossprod(x, y) - 1/n * sum(x) * sum(y)
Sxx <- crossprod(x) - 1/n * sum(x)^2
Syy <- crossprod(y) - 1/n * sum(y)^2

bhat1 <- drop(Sxy/Sxx)
bhat1
bhat0 <- drop(mean(y) - bhat1 * mean(x))
bhat0

# Exercise 2: Compute s "by hand"
s <- sqrt(1/(n-2) * (Syy - Sxy^2/Sxx))
s

# Exercise 3: Calculate "by hand" the confidence intervals for
# b0 and b1 with conf.lvl. 0.90
alpha <- 0.10
z <- qt(1 - alpha/2, n - 2)

# (a_hat - a) / (s*sqrt(Σx²/(n * Sxx))) is t distributed
k <- s * sqrt(crossprod(x) / (n * Sxx)) * z
b0conf <- c(bhat0 - k, bhat0 + k)
b0conf

# (b_hat - b) / (s/sqrt(Sxx)) is t distributed
k <- s/sqrt(Sxx) * z
b1conf <- c(bhat1 - k, bhat1 + k)
b1conf

confint(m1, level = 1 - alpha) # Validate correctness

# Exercise 4: Simulate some fucks
bstar0 <- bhat0; bstar1 <- bhat1; bstar = c(bstar0, bstar1)

verifyConfIntervals <- function(rand, alpha = 0.01) {
	simulate_obs <- function(speed)
		bstar0 + bstar1 * speed + rand(length(speed))
	replicate(1000, {
		D <- data.frame(speed, dist = simulate_obs(speed))
		m <- lm(dist ~ speed, data = D)
		ci <- confint(m, level = 1 - alpha)
		ci[1:2, 1] <= bstar & bstar <= ci[1:2, 2]
}) -> inConfIntervals
	cat(sprintf(fmt = "Expected value: %.3f
			Percentage that include β_0^*: %.3f
			Percentage that include β_1^*: %.3f
			", 1 - alpha, mean(inConfIntervals[1,]), mean(inConfIntervals[2,])))
}

rnormssd <- function(...) do.call(rnorm, c(sd = s, list(...)))
verifyConfIntervals(rand = rnormssd)

# Exercise 5: Same thing but generating error terms from the Chi-squared distribution
rchisq10df <- function(...) do.call(rchisq, c(df = 10, list(...)))
verifyConfIntervals(rand = rchisq10df)
# Chi-squared is almost like a shifted normal distribution,
# not symmetric
