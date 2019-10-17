from math import sqrt, log
from random import random
import matplotlib.pyplot as plt

# 1. Compute θ analytically and transform the problem into the right form
"""
g : [0,1] -> [0,1], x |-> f(2x - 1)

θ := int_0^1 g(x) dx = 1/2 * [x^3/3]_{-1}^1 = 1/2 * 2/3 = 1/3
"""
theta = 1/3

g = lambda x: (2 * x - 1)**2

# 2. Estimate θ by crude Monte Carlo for fixed sample size M
def crude_mc(f, M: float) -> float:
    return sum(f(random()) for _ in range(M)) / M
crude_mc.error = lambda M: sqrt(4/45 / M)

# 3. Estimate θ by hit and miss Monte Carlo for fixed sample size M
def hit_and_miss_mc(f, M: float) -> float:
    return sum(random() <= f(random()) for _ in range(M)) / M
hit_and_miss_mc.error = lambda M: sqrt(10/45 / M)

print(crude_mc(g, 10000))
print(hit_and_miss_mc(g, 10000))

# 5. Estimate numerically the rMSE:s
N = 1000; M = 1000
for mc in [crude_mc, hit_and_miss_mc]:
    rMSE = sqrt(sum((theta - mc(g, M))**2 for _ in range(N)) / N)
    print(f'rMSE for {mc.__name__}:\n\tanalytical: {mc.error(M)}\n\tnumerical: {rMSE}')

# 6.
M_values = list(map(lambda i: 2**i, range(1, 21)))
reference = ((M, 1 / sqrt(M)) for M in M_values)
plt.loglog(*zip(*reference), 'r-')
for mc in [crude_mc, hit_and_miss_mc]:
    estimates = ((M, mc(g, M)) for M in M_values)
    errors = ((M, sqrt((theta - y)**2)) for M, y in estimates)
    plt.loglog(*zip(*errors), '-', label = mc.__name__)
    analytical_errors = ((M, mc.error(M)) for M in M_values)
    plt.loglog(*zip(*analytical_errors), 'o--', label = f'{mc.__name__} (analytical)')
plt.legend()
plt.show()

# 7. Estimate rMSE with Monte Carlo, N = 10
N = 10
for mc in [crude_mc, hit_and_miss_mc]:
    rMSE = sqrt(sum(abs(mc(g, M) - theta)**2 for _ in range(N)) / N)
    print(f'MC estimate of rMSE for {mc.__name__}: {rMSE}')
