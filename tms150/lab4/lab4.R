# Assignment 1
# b) Optimize weight for the case with the two stocks
data <- read.csv2("stockdata.txt")
attach(data)

# XXX: These are transposed compared to the lecture notes
X <- cbind(Comp1, Comp2) # X_ji is the price of stock i after day j
Z <- diff(log(X)) # Z_ji := log(X_ij / X_i,j-1)
gamma <- apply(Z, 2, mean); Sigma <- var(Z) # Estimate parameters from data

optimizeWeights <- function(k) {
	result <- optimize(function(w_1) {
		w <- c(w_1, 1 - w_1) # Σw_i = 1 => w_2 = 1 - w_1
		crossprod(w, gamma) - k * crossprod(w, Sigma %*% w) / 2
	}, interval = c(0, 1), maximum = TRUE)
	result$maximum
}

k <- c(3, 1.5, 1, 0.5, 0.1, -1)
w_1 <- sapply(k, function(k) optimizeWeights(k))
barplot(w_1, main = "Amount that should be invested in Comp1 given the value of $k$",
	xlab = "$k$", ylab = "$w_1$",
	names.arg = k,
	ylim = 0:1)

# Assignment 2
# a) Fit logistic regression by numerical ML for the data given parameters a, b
matureKnee <- read.table("matureKnee.txt"); immatureKnee <- read.table("immatureKnee.txt")

f_1 <- function(x, a, b) 1 - 1 / (1 + exp(a + b * (x - 18)))
f_0 <- function(...) 1 - f_1(...)

# Likelihood function
L <- function(a = 1, b = 1.5) prod(f_1(matureKnee, a, b)) * prod(f_0(immatureKnee, a, b))
l <- function(a = 1, b = 1.5) sum(log(f_1(matureKnee, a, b))) + sum(log(f_0(immatureKnee, a, b)))

res <- optim(par = formals(l), fn = function(x) L(x[["a"]], x[["b"]]),
	control = list(fnscale = -1) # Maximize instead of minimize
)
a <- res$par[["a"]]; b <- res$par[["b"]]

# Plot the data together with the logistic regression curve
x <- seq(0, 40, length.out = 500)
plot(x, f_1(x, a, b), 'l')
points(x = matureKnee$V1, y = sapply(matureKnee$V1, function(x) 1))
points(x = immatureKnee$V1, y = sapply(immatureKnee$V1, function(x) 0))

# b) With a uniform prior, plot the posterior on a grid with values of a and b
a_min <- -0.4; a_max <- 2.1; b_min <- 0.9; b_max <- 3.1; grid_length <- 21
A <- seq(a_min, a_max, length.out = grid_length); B <- seq(b_min, b_max, length.out = grid_length)

normalize <- function(a) a / sum(a)

prior <- outer(A, B, FUN = Vectorize(function(A, B) 1 / grid_length^2)) # Uniform prior
likelihood <- outer(A, B, FUN = Vectorize(L))
posterior <- normalize(prior * likelihood)

par(mfrow = c(1, 3), pty="s")
for (grid in list(list(prior, "Prior"), list(likelihood, "Likelihood"), list(posterior, "Posterior"))) {
	image(A, B, grid[[1]], xlab = "a", ylab = "b",
		main = grid[[2]])
}

# c) Find μ, α in the distribution of true ages so that the optimal decision is to classify
# persons with mature knees as adults
local({
	B <- 10
	c_1 <<- function(x) ifelse(x <= 18, B, 1)
	c_2 <<- function(x) ifelse(x <= 18, B * (18 - x), x - 18)
})

# Density function of the distribution of true ages.
dtrueages <- function(x, mu, alpha) dgamma(x - 14, alpha, alpha / (mu - 14))

mu_min <- 15; mu_max <- 25; alpha_min <- 2; alpha_max <- 9; grid_length <- 31
Mu <- seq(mu_min, mu_max, length.out = grid_length);
Alpha <- seq(alpha_min, alpha_max, length.out = grid_length)

calc_opt_mature_adults <- function(integrate_fun, c) {
	opt_mature_adults <- outer(Mu, Alpha, FUN = Vectorize(function(mu, alpha) {
			f <- function(x, a, b) dtrueages(x, mu, alpha) * f_1(x, a, b) * c(x)
			C_c <- integrate_fun(f, lower = 18, upper = Inf)
			C_a <- integrate_fun(f, lower = 0, upper = 18)
			C_c > C_a # Whether optimal to classify as adult
}))
	image(Mu, Alpha, opt_mature_adults, xlab = "$\\mu$", ylab="$\\alpha$") # Red is TRUE
	opt_mature_adults
}

opt_mature_adults_c1 <- calc_opt_mature_adults(function(f, ...) integrate(f, ..., a, b)$value, c_1)
opt_mature_adults_c2 <- calc_opt_mature_adults(function(f, ...) integrate(f, ..., a, b)$value, c_2)

# d) Same as c) but sum over the uncertainty in the parameters a and b
uncertainty_int_fun <- function(f, ...)
	sum(posterior * outer(A, B, FUN = Vectorize(function(a, b) integrate(f, ..., a, b)$value)))

opt_mature_adults_d1 <- calc_opt_mature_adults(uncertainty_int_fun, c_1)
opt_mature_adults_d2 <- calc_opt_mature_adults(uncertainty_int_fun, c_2)
