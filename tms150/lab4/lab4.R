# Assignment 1
# b)
data <- read.csv2("stockdata.txt")
attach(data)

# Utility function for positive x.
#
# k != 0 is some parameter and K is the amount of money invested.
u <- function(x, k, K) (1 - (x / K)^(-k)) / k

# X_ij is the price of stock i, after day j
X <- rbind(Comp1, Comp2)
# Z_ij = log(X_ij / X_i,j-1)
Z <- t(diff(t(log(X))))
