from random import normalvariate
from itertools import chain, accumulate, filterfalse, repeat, islice, tee
from matplotlib import pyplot as plt
from math import exp, sqrt

μ = 1; σ = 1
T = 1 # Endpoint of the time interval
H = [1 / 2**i for i in range(1, 11)] # List of all values of h

# Returns the specified iterable at a different resolution i.
#
# Since the sum of normal distributions equals a normal distribution
#     coarsify(W_10, i) = W_i,    for all i = 1, ..., 10
def coarsify(W, i): return (w for n, w in enumerate(W) if not n % 2**(10 - i))

def last(a):
    """Return the last element of the specified iterable."""
    *_, last = a
    return last

def pairwise(iterable):
    """Return a 2-len sliding window iterator for the specified iterable."""
    a, b = tee(iterable)
    return zip(a, islice(b, 1, None))

def gen_W_10():
    """Return lists t, W for the case of h = 1 / 2**10."""
    N = 2**10 # Number of intervals
    h = 1 / N
    η = (normalvariate(0, sqrt(h)) for _ in repeat(0))
    W = list(islice(chain((0,), accumulate(η)), N + 1))
    t = [n * h for n, w in enumerate(W)]
    return t, W

# 1. Compute a sample path of a Brownian motion at all resolutions
fig, ax = plt.subplots()
t, W = gen_W_10()
for i in range(1, 11):
    plt.plot(list(coarsify(t, i)), list(coarsify(W, i)))
ax.set(xlabel = 't', ylabel = 'W(t)')
plt.title('Sample path of a Brownian motion at different resolutions')
plt.show()

# 2.
X = lambda t, W: (exp((μ - σ**2 / 2) * t + σ * w) for t, w in zip(t, W))
plt.plot(t, list(X(t, W)), label = 'X')

def X_h(W, i):
    h = 1 / 2**i
    X = 1
    W_tilde = pairwise(coarsify(W, i))
    while True:
        yield X
        try:
            w_prev, w_cur = next(W_tilde)
        except StopIteration:
            break
        X = (1 + h * μ) * X + σ * X * (w_cur - w_prev)

for i in range(1, 11):
    plt.plot(list(coarsify(t, i)), list(X_h(W, i)), label = f'X_h, i = {i}')
plt.legend()
plt.title('Sample paths of X and X_h')
plt.show()

# 3. Estimate the strong error with MC
M = 1000

def diff_X_and_X_h(i):
    """Return the difference between X(T) and X_h(T) for the same noise."""
    t, W = gen_W_10()
    return last(X(t, W)) - last(X_h(W, i))

plt.loglog(H, [sqrt(h) for h in H], label = 'Reference slope h^{1/2}')
strong_errors = [sqrt(sum(diff_X_and_X_h(i)**2 for _ in range(M)) / M)
        for i in range(1, 11)]
plt.loglog(H, strong_errors, label = 'Monte Carlo estimates')
plt.legend()
plt.title('Strong error for different h')
plt.show()

# 4. Estimate the weak error of |E[X(1)] - E[X_h(1)]| with MC
M = 1000
def φ(x): return x # The test function in question
expectation_X_1 = exp(μ)
plt.loglog(H, [h for h in H], label = 'Reference slope h')
plt.loglog(H, [abs(expectation_X_1 - sum(φ(last(X_h(gen_W_10()[1], i))) for _ in range(M)) / M)
    for i in range(1, 11)])
plt.legend()
plt.title('Weak error of |E[X(1)] - E[X_h(1)]|')
plt.show()
