howell <- read.table("Howell.txt") # Load the data
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
		pMSE <- mean((Dtest$height - predict(m, Dtest["age"]))^2)
})
	list(p = p, pMSE = pMSE)
}

# Given the polynomial regression from doPolyReg returns the best p.
getBestP <- function(reg) {
	which.min(reg$pMSE + reg$p * 50)
}

# i) pMSE for polynomial regression with response height and covariate age, p=1:6
set.seed(123)
out <- doPolyReg(D)
plot(out$p, out$pMSE, type = "o")

# ii)
samplePWins <- function(D) {
	set.seed(123)
	freq <- factor(replicate(2000, getBestP(doPolyReg(D))), levels = p)
}

freq <- samplePWins(D)
print('Frequencies of best p')
print(table(freq))

# iii)
freq <- samplePWins(Dbad)
print('With outlier')
print(table(freq))

# iv)
age0 <- seq(min(Dbad$age), max(Dbad$age), length = 100)
plotPredictions <- function(D) {
	plot(x = D$age, y = D$height, xlab ="age", ylab = "height", xlim = c(age0[1], tail(age0, n = 1)), ylim = c(50, 200),
		main = paste("Predictions by model with dataset", substitute(D)))
	for (p in 1:6) lines(
		x = age0,
		y = predict(lm(height ~ poly(age, p, raw = TRUE), data = D), data.frame(age = age0)),
		col = p
	)
	legend(40, 130, legend = sapply(1:6, function(x) paste("p =", x)), col = 1:6,
		lty = 1, cex = 0.6)
}
tikz("pred_plot.tex", width = 6, height = 7)
par(mfrow = c(2, 1))
plotPredictions(D); plotPredictions(Dbad)
dev.off()

# Exercise 3:
set.seed(123)
B <- 2000 # Number of bootstrap samples
alpha <- 1 - .95

bHat <- replicate(B, unname(lm(height ~ age,
			data = D[sample.int(N, replace = TRUE), ])$coefficients))
percentileCI <- function(x) quantile(x, probs = c(alpha / 2, 1 - alpha / 2))
bHat0CI <- percentileCI(bHat[1,]); bHat1CI <- percentileCI(bHat[2,])
bHat0CI; bHat1CI

confint(lm(height ~ age, data = D)) # Real values
