# Load the data
howell <- read.table("Howell.txt")
# Includes height (cm), weight (kg), age (years) and gender (1 for male, 0 otherwise)
attach(howell)
N <- nrow(howell) # Number of subjects

set.seed(123)

# i) pMSE for polynomial regression with response height and covariate age, p=1:6
D <- howell[c("height", "age")]
n <- floor(0.7 * N)
trainIndices <- sample.int(N, n)
Dtrain <- D[trainIndices,]; Dtest <- D[-trainIndices,]

p <- 1:6
pMSE <- lapply(p, function(p) {
	# Fit yTrain using a polynomial of order p based on xTrain
	m <- lm(height ~ poly(age, p, raw = TRUE), data = Dtrain)
	# Make predictions based on xTest covariates
	pMSE <- mean((Dtest[["height"]] - predict(m, Dtest["age"]))^2)
})
plot(p, pMSE, type = "o")
