# Load the data
howell <- read.table("Howell.txt")
# Includes height (cm), weight (kg), age (years) and gender (1 for male, 0 otherwise)
attach(howell)
D <- howell[c("height", "age")]
N <- nrow(howell) # Number of subjects
n <- floor(0.7 * N) # Number of rows for the training data
p <- 1:6

# Dataset but with an outlier
Dbad <- rbind(D, data.frame(age = 120, height = 200))

# Plot Dbad vs D
par(mfrow = c(2, 1))
plot(x = D$age, y = D$height)
plot(x = Dbad$age, y = Dbad$height)

doPolyReg <- function(D) {
	# Sample training and testing data
	trainIndices <- sample.int(N, n)
	Dtrain <- D[trainIndices,]; Dtest <- D[-trainIndices,]

	pMSE <- sapply(p, function(p) {
		# Fit yTrain using a polynomial of order p based on xTrain
		m <- lm(height ~ poly(age, p, raw = TRUE), data = Dtrain)
		# Make predictions based on xTest covariates
		pMSE <- mean((Dtest[["height"]] - predict(m, Dtest["age"]))^2)
})
	list(p = p, pMSE = pMSE)
}

# Given the polynomial regression from doPolyReg returns the best p.
getBestP <- function(reg) {
	which.min(reg$pMSE + reg$p * 50)
}

# Replicates `expr`, `n` times, then folds using the function `f` and the initial value.
foldRep <- function(n, expr, f, init) {
	for (i in 1:n) init <- f(init, eval.parent(substitute(expr)))
	init
}

# Simple forward pipe
`%>%` <- function(x, f) f(x)

# i) pMSE for polynomial regression with response height and covariate age, p=1:6
set.seed(123)
out <- doPolyReg(D)
plot(out$p, out$pMSE, type = "o")

# ii)
samplePWins <- function(D) {
	set.seed(123)

	# foldRep(
	# 	n = 20,
	# 	expr = doPolyReg(D) %>% getBestP,
	# 	f = function(a,x) {a[[x]] <- a[[x]] + 1; a},
	# 	init = integer(6)
	# )

	freq <- factor(replicate(2000, doPolyReg(D) %>% getBestP), levels = p)
}

freq <- samplePWins(D)
print('Frequencies of best p')
print(table(freq))

# iii)
freq <- samplePWins(Dbad)
print('With outlier')
print(table(freq))

# iv)
