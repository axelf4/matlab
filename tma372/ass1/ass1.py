import numpy as np
import scipy.integrate as integrate
import matplotlib
from matplotlib import pyplot as plt
from itertools import accumulate
from math import e

def get_h(m, a=0, b=1):
    """
    Returns the step size with a uniform partition with m interior nodes.
    """
    return (b - a) / (m + 1)

class NumFn:
    """
    Functions with overloaded numerical operators.
    """

    def __init__(self, f):
        self.f = f

    def __call__(self, value):
        return self.f(value)

    def __add__(self, other):
        if isinstance(other, (int, float)):
            return NumFn(lambda x: self(x) + other)
        elif isinstance(other, NumFn):
            return NumFn(lambda x: self(x) + other(x))
        else:
            return NotImplemented

    def __radd__(self, other):
        return self.__add__(other)

    def __mul__(self, other):
        if isinstance(other, (int, float)):
            return NumFn(lambda x: other * self(x))
        elif isinstance(other, NumFn):
            return NumFn(lambda x: self(x) * other(x))
        else:
            return NotImplemented

    def __rmul__(self, other):
        return self.__mul__(other)

def phi(m, j, a=0, b=1):
    h = get_h(m, a, b)
    return NumFn(lambda x:
                 np.maximum(0, 1 - np.abs(x - h * j) / h)
                 * (0 <= x if j == 0
                    else x <= 1 if j == m + 1
                    else 1))

def phi2(m, j, a=0, b=1):
    if m % 2 != 1:
        raise "Bad inner node number!"
    h = get_h(m, a, b)

    c = h * j # Node center
    l = j % 2 # Local node number

    return NumFn(
        lambda x: np.maximum(0, (x - (c - h)) * ((c + h) - x) / h**2) if l == 1
        else lambda x: (np.abs(x - c) <= 2*h)
        * (np.abs(x - c) - h) * (np.abs(x - c) - 2 * h) / (h * 2*h)
    )

def mat_fromfn(f, n, m=None):
    if m is None:
        m = n # Default to square matrix

    return np.fromiter((f(i, j)
                        for i in range(n)
                        for j in range(m)), float).reshape(n, m)


def tridiagonal_mat(m, a, b, c=None):
    """Returns a square tridiagonal matrix.
    
    Keyword arguments:
    m -- the size of the matrix
    a -- the values on the diagonal
    b -- the values on the superdiagonal
    c -- the values on the subdiagonal
    """
    if c is None:
        c = b
    return np.fromfunction(
        lambda i, j: a * (i == j) + b * (j == i + 1) + c * (i == j + 1),
        (m, m)
    )

def stiffness_mat(m):
    # Integrals of product of hat function derivatives
    h = get_h(m)
    return 1/h * tridiagonal_mat(m, 2, -1)

def convection_mat(m):
    return 1/2 * tridiagonal_mat(m, 0, 1, -1)

def galerkin(m, f):
    S = stiffness_mat(m)
    b = np.fromiter((integrate.quad(NumFn(f) * phi(m, j), 0, 1)[0]
                        for j in range(1, m + 1)), float) # The load vector

    zeta = np.linalg.solve(S, b)
    return zeta

def stiffness2_mat(m):
    h = get_h(m)

    def elem_fn(i, j):
        li = (i + 1) % 2; lj = (j + 1) % 2

        if i == j:
            return 1/(3*h) * (7 if li == 0 else 8)
        elif abs(j - i) == 1:
            return 1/(3*h) * (-4)
        elif abs(j - i) == 2:
            return 1/(3*h) * 1/2 if li == 0 else 0
        else:
            return 0

    return mat_fromfn(elem_fn, m)

def galerkin2(m, f):
    S = stiffness2_mat(m)
    b = np.fromiter(
        (integrate.quad(NumFn(f) * phi2(m, j), 0, 1)[0]
         for j in range(1, m + 1)),
        float)

    return np.linalg.solve(S, b)

def u_h(m, zeta):
    return sum(zeta[j] * phi(m, 1 + j) for j in range(m))

X = np.linspace(0, 1, 256)

# Question 1
f = lambda x: 6 * x
m = 3
plt.plot(X, -np.power(X, 3) + X, label=r'$u$')
zeta = galerkin(m, f)
plt.plot(X, u_h(m, zeta)(X), label=r'$cG(1)$')
# Question 2
zeta2 = galerkin2(m, f)
plt.plot(X, sum(zeta2[j] * phi2(m, 1 + j) for j in range(m))(X), label=r'$cG(2)$')
plt.legend()

# Question 3
epsilon = 0.01
u = lambda x: (e**(1/epsilon) - np.exp(x / epsilon)) / (e**(1/epsilon) - 1)

def cG1_bvp_3(m):
    h = get_h(m)

    b = np.zeros(m)
    b[0] = -1 * (epsilon * (-1/h) + (-1/2))

    zeta = np.linalg.solve(epsilon * stiffness_mat(m) + convection_mat(m), b)
    return 1 * phi(m, 0) + u_h(m, zeta)

plt.plot(X, u(X), label=r"$u$")
plt.plot(X, cG1_bvp_3(10)(X), label=r"$cG(1) \quad m=10$")
plt.plot(X, cG1_bvp_3(11)(X), label=r"$cG(1) \quad m=11$")
plt.plot(X, cG1_bvp_3(100)(X), label=r"$cG(1) \quad m=100$")
plt.legend()

# Question 4.(b)

def cG1_ivp_4(m):
    u0 = 1; a = 4

    T = 1
    h = get_h(m, 0, T)
    def do_iter(U_j, j):
        t_j = h * j; t_i = h * (j + 1)

        f_int = (t_i**3 - t_j**3) / 3 # Integral of t^2
        U_i = (U_j * (1 - a * 1/2 * h) + f_int) / (1 + a * 1/2 * h)
        return U_i

    js = range(m + 2)
    Us = accumulate(js, func=do_iter, initial=u0)
    return sum(U_j * phi(m, j, 0, T) for j, U_j in zip(js, Us))

u = lambda t: 31/32 * np.exp(-4 * t) + (1/4 * t**2 - 1/8 * t + 1/32)
plt.plot(X, u(X), label=r'$u$')
plt.plot(X, cG1_ivp_4(3)(X), label=r'$U \quad m=3$')
plt.plot(X, cG1_ivp_4(10)(X), label=r'$U \quad m=10$')
plt.legend()

# Question 4.(c)

a = 10
u0 = 1
u = lambda t: np.exp(-a * t)
T = np.linspace(0, 1, 256)

def explicit_euler(k):
    N = int(1 / k)
    def explicit_euler_step(prev, n):
        (tn, yn) = prev
        tm = tn + k
        ym = yn + k * (-a * yn)
        return (tm, ym)
    return accumulate(range(N), func=explicit_euler_step, initial=(0, u0))
    
def implicit_euler(k):
    N = int(1 / k)
    def implicit_euler_step(prev, n):
        (tn, yn) = prev
        tm = tn + k
        ym = yn / (1 + k * a)
        return (tm, ym)
    return accumulate(range(N), func=implicit_euler_step, initial=(0, u0))
    
def crank_nicolson(k):
    N = int(1 / k)
    def crank_nicolson_step(prev, n):
        (tn, yn) = prev
        tm = tn + k
        ym = (1 - k/2 * a) * yn / (1 + k/2 * a)
        return (tm, ym)
    return accumulate(range(N), func=crank_nicolson_step, initial=(0, u0))
    
plt.plot(T, u(T))
plt.plot(*zip(*explicit_euler(0.2)), label=r'explicit Euler $\quad k=0.2$')
plt.plot(*zip(*implicit_euler(0.2)), label=r'implicit Euler $\quad k=0.2$')
plt.plot(*zip(*crank_nicolson(0.2)), label=r'Crank-Nicolson $\quad k=0.2$')
plt.legend()
plt.show()
