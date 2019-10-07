# Assignment 1
# b)
data <- read.csv2("stockdata.txt")
attach(data)

# Utility function for positive x.
#
# k != 0 is some parameter and K is the amount of money invested.
u <- function(x, k, K) (1 - (x / K)^(-k)) / k

# XXX: These are transposed compared to the lecture notes
X <- cbind(Comp1, Comp2) # X_ji is the price of stock i, after day j
Z <- diff(log(X)) # Z_ji = log(X_ij / X_i,j-1)

num_stocks <- ncol(X) # Number of stocks

# Estimate parameters from data
gamma <- apply(Z, 2, mean); Sigma <- var(Z)

optimizeWeights <- function(k) {
	result <- optimize(function(w_1) {
		w <- c(w_1, 1 - w_1) # Σw_i = 1 => w_2 = 1 - w_1
		n <- num_stocks # With n = k

		n * crossprod(w, gamma) - k * n * crossprod(w, Sigma %*% w) / 2
	}, interval = c(0, 1), maximum = TRUE)
	result$maximum
}

k <- c(3, 1.5, 1, 0.5, 0.1, -1)
w_1 <- sapply(k, function(k) optimizeWeights(k))
barplot(w_1, main = "Amount that should be invested in Comp1 given the value of $k$",
	xlab = "$k$", ylab = "$w_1$",
	names.arg = k,
	ylim = 0:1)
# See that w_1 ratio decreases with k => Comp1 is more instable
# We also have that: var(Comp1) > var(Comp2)

# Assignment 2
# a)
matureKnee <- read.table("matureKnee.txt")
immatureKnee <- read.table("immatureKnee.txt")

f_1 <- function(x, a, b) exp(a + b * (x - 18)) / (1 + exp(a + b * (x - 18)))
f_0 <- function(...) 1 - f_1(...)

# Likelihood function
L <- function(a = 1, b = 1) prod(f_1(matureKnee, a, b)) * prod(f_0(immatureKnee, a, b))
l <- function(a = 1, b = 1) {
	sum(log(f_1(matureKnee, a, b))) + sum(log(f_0(immatureKnee, a, b)))
}

res <- optim(par = formals(L), fn = L,
	control = list(fnscale = -1) # Maximize instead of minimizing
)
a <- res$par[["a"]]; b <- res$par[["b"]]

# Plot the fucker
x <- seq(0, 40, length.out = 500)
plot(x, f_1(x, a, b), 'l')
points(x = matureKnee$V1, y = sapply(matureKnee$V1, function(x) 1))
points(x = immatureKnee$V1, y = sapply(immatureKnee$V1, function(x) 0))

normalize <- function(a) a / sum(a)

a_min = -0.4; a_max = 2.1; b_min = 0.9; b_max = 3.1
a <- seq(a_min, a_max, length.out = 100); b <- seq(b_min, b_max, length.out = 100)
# Uniform prior
prior = outer(a, b, FUN = Vectorize(function(a, b) 1 / (100 * 100)))
likelihood <- outer(a, b, FUN = Vectorize(L))
posterior <- normalize(prior * likelihood)

par(mfrow = c(1, 3), pty="s")
for (grid in list(list(prior, "Prior"), list(likelihood, "Likelihood"), list(posterior, "Posterior"))) {
	image(a, b, grid[[1]], xlab = "a", ylab = "b",
		main = grid[[2]])
}

# c)
