from random import normalvariate
from itertools import chain, accumulate, filterfalse, repeat, islice, tee
from matplotlib import pyplot as plt
from math import exp

μ = 1; σ = 1

# 1. Compute a sample path of a Brownian motion at all resolutions
# For the finest resolution:
N = 2**10 # Number of intervals
h = 1 / N
η = (normalvariate(0, h) for _ in repeat(0))
W = list(islice(chain((0,), accumulate(η)), N + 1))
t = [n * h for n, w in enumerate(W)]

# Sum of normal distributions equals normal distribution
coarse_i = lambda W, i: (w for n, w in enumerate(W) if not n % 2**(10 - i))
W_t_by_i = lambda i: (list(coarse_i(W, i)), list(coarse_i(t, i)))

fig, ax = plt.subplots()
for i in range(1, 11):
    W_tilde, t_tilde = W_t_by_i(i)
    plt.plot(t_tilde, W_tilde)

ax.set(xlabel = 't', ylabel = 'W(t)')
plt.show()

# 2.
X = (exp((μ - σ**2 / 2) * t + σ * w) for t, w in zip(t, W))
plt.plot(t, list(X), label = 'X')

def pairwise(iterable):
    a, b = tee(iterable)
    return zip(a, islice(b, 1, None))

def X_h(i):
    h = 1 / 2**i
    X = 1
    W_tilde = pairwise(coarse_i(W, i))
    while True:
        yield X
        w_prev, w_cur = next(W_tilde)
        X = (1 + h * μ) * X + σ * X * (w_cur - w_prev)

for i in range(1, 11):
    print(len(list(X_h(i))))
    plt.plot(list(coarse_i(t, i)), list(X_h(i)), label = f'X_h, i = {i}')
plt.legend()
plt.show()
