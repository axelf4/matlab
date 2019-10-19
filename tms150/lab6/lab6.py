from random import normalvariate
from itertools import chain, accumulate, filterfalse, repeat, islice
from matplotlib import pyplot as plt

μ = 1; σ = 1

H = [1 / 2**i for i in range(1, 11)]

# 1. Compute a sample path of a Brownian motion at all resolutions
# For the finest resolution:
N = 2**11 # Number of intervals
η = (normalvariate(0, 1 / 2**10) for _ in repeat(0))
W = list(islice(chain((0,), accumulate(η)), N + 1))
t = [n * h for n, w in enumerate(W)]

fig, ax = plt.subplots()
for i in range(1, 11):
    # Sum of normal distributions equals normal distribution
    W_tilde, t_tilde = zip(*((w, t) for n, (w, t) in enumerate(zip(W, t)) if not n % 2**(10 - i)))
    plt.plot(t_tilde, W_tilde)

ax.set(xlabel = 't', ylabel = 'W(t)')
plt.show()
