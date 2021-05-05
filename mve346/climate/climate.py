from functools import reduce, partial
from itertools import accumulate, product
import math
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

hsum = partial(np.sum, axis=1)
hsum.__doc__ = 'Horizontal sum'

# Utsläpp från RCP45_EMISSIONS för 1765-2500 
# CO2 är i GtK/år
# CH4 är angivet i MtCH4/år
# N2O är angivet i MtN/år - OBS. vikta ner med 28/44 - för att
# molekylmassan skall stämma för utsläppsdata och beräkningsmetoden.
emission = pd.read_csv("emissionRCP45.csv")
U = emission.CO2Emissions
cumU = np.cumsum(U)

ppmCO2perGtonC = 0.469
# Atmosfäriska koncentrationer från RCP45_EMISSIONS för 1765-2500 
# CO2 är i ppm 
# CH4 och N2O är i ppb
concentrations = pd.read_csv("concentrationsRCP45.csv")

# Radiative Forcing från från RCP45_MidyearRF för 1765-2500 
# Radiative forcing in global mean W/m^2
radiativeForcing = pd.read_csv("radiativeForcingRCP45.csv")

# In GtC
B0 = np.array([600, 600, 1500])
# In GtC/year
F120 = 60; F210 = 15; F230 = 45; F310 = 45

β = 0.35 # CO2-fertilisation factor

# (1) 𝑑𝐵1/𝑑𝑡=𝛼31𝐵3+𝛼21𝐵2−𝑁𝑃𝑃+𝑈
# (2) 𝑑𝐵2/𝑑𝑡=𝑁𝑃𝑃−𝛼23𝐵2−𝛼21𝐵2
# (3) 𝑑𝐵3/𝑑𝑡=𝛼23𝐵2−𝛼31𝐵3
def calc_dB(B, x, *, β):
    _, U = x
    NPP0 = F120
    NPP = NPP0 * (1 + β * np.log(B[1-1] / B0[1-1]))
    return np.array([
        F310/B0[3-1]*B[3-1] + F210/B0[2-1]*B[2-1] - NPP + U,
        NPP - F230/B0[2-1]*B[2-1] - F210/B0[2-1]*B[2-1],
        F230/B0[2-1]*B[2-1] - F310/B0[3-1]*B[3-1],
    ])

def modelBs(*, β = β, calc_dB = calc_dB):
    Bs = np.array([*accumulate(enumerate(U),
                               func=lambda B, U: B + calc_dB(B, U, β = β),
                               initial=B0)])[1:, :]
    return Bs

# Exercise 1:
# # Vi borde få högre koncentrationer då havet som balanserar saknas
# fig, ax = plt.subplots()
# Bs = modelBs()
# x = 1765 + np.fromiter(range(concentrations.CO2ConcRCP45.shape[0]), int)
# ax.plot(x, ppmCO2perGtonC * Bs[:, 0], label='Model')
# ax.plot(x, concentrations.CO2ConcRCP45, label='RCP45')
# ax.legend()

# Exercise 2:
# Higher β means more CO2 gets bound in plants from the atmosphere
# (which finds its way underground)
βs = β + np.fromiter(range(-2, 2), int) / (2 * 4)
def sampleβ(β):
    Bs = modelBs(β = β)
    return [ppmCO2perGtonC * Bs[-1, 0], Bs[-1, 1], Bs[-1, 2]]
resCByβ = pd.DataFrame(np.array([*map(sampleβ, βs)]), index=βs,
                   columns=["Atmospheric CO2Conc", "C in Biomass", "C in Ground"])

# The sea
A = [0.113, 0.213, 0.258, 0.273, 0.1430]
τ0 = [2.0, 12.2, 50.4, 243.3, math.inf]
k = 3.06e-3
def getI(U, *, k = k):
    τ = np.vectorize(lambda i, t: τ0[i] * (1 + k * sum(U[s] for s in range(t-1+1))))
    I = lambda t: sum(A[i] * np.exp(-t / τ(i, t)) for i in range(5))
    return I

# # Exercise 3:
# x = np.fromiter(range(500), int)
# fig, ax = plt.subplots()
# ax.set_ylim([0, 1])
# U0s = [0, 140, 560, 1680]
# for U0 in U0s:
    # impulseU = np.zeros(emission.CO2Emissions.shape)
    # impulseU[0] = U0
    # I = getI(impulseU)
    # y = I(x)
    # ax.plot(x, y, label=f'{U0} GtC')
# ax.set_xlabel('Tid efter utsläppspuls (år)')
# ax.set_ylabel('Andel kvar i atmosfären')
# ax.legend()

ts = np.fromiter(range(concentrations.CO2ConcRCP45.shape[0]), int)
def getM(U, *, k = k):
    Is = getI(U, k = k)(ts[:U.shape[0]])
    M0 = B0[1-1]
    M = np.vectorize(lambda t: M0 + sum(Is[t - s] * U[s] for s in range(t+1)))
    return M

# # Exercise 4:
# fig, ax = plt.subplots()
# x = 1765 + ts
# ax.plot(x, ppmCO2perGtonC * M(t), label='Atmosphere with sea absorption')
# ax.plot(x, concentrations.CO2ConcRCP45, label='RCP45')
# ax.set_xlabel('Year')
# ax.set_ylabel('CO_2 concentration in atmosphere')
# ax.legend()

def get_calc_dB_with_sea(*, k = k):
    dB1s = np.zeros(1 + len(U))

    def f(B, x, *, β):
        t, U = x
        dB = calc_dB(B, x, β = β)

        dB1s[t] = dB[1-1]
        M = getM(dB1s[:t+1], k = k)

        dB[1-1] = M(t) - B[1-1]

        return dB
    
    return f

# Exercise 6:
# seaBs = modelBs(β = 0.15, calc_dB = get_calc_dB_with_sea())
# fig, ax = plt.subplots()
# x = 1765 + np.fromiter(range(concentrations.CO2ConcRCP45.shape[0]), int)
# ax.plot(x, ppmCO2perGtonC * seaBs[:, 0], label='Model')
# ax.plot(x, concentrations.CO2ConcRCP45, label='RCP45')
# ax.legend()

# # Exercise 7:
# # Higher values of beta means more carbon gets bound into biomass and
# # the ground, which is taken from the carbon in atmosphere. This also
# # leads to less carbon in the sea.
# # Higher values of k means less carbon gets bound into the sea from
# # the atmosphere. There is a small increase in the amount of carbon in
# # biomass and the ground from the increased carbon in the atmosphere.
# # This change is very small however.
# ks = [0.4 * k, k, 1.6 * k]
# params = [*product(βs, ks)]
# def sampleβk(β, k):
    # altSeaBs = modelBs(β = β, calc_dB = get_calc_dB_with_sea(k = k))
    # bsYear2100 = altSeaBs[2100 - 1765, :]
    # inSea = cumU[2100 - 1765] - (sum(bsYear2100) - sum(B0))
    # return (*bsYear2100, inSea)
# exercise7Results = pd.DataFrame([sampleβk(*param) for param in params],
                                # index=params,
                                # columns=['Atmos', 'Biomass', 'Ground', 'Sea'])

# Exercise 8:
pCO2 = concentrations.CO2ConcRCP45
pCO20 = concentrations.CO2ConcRCP45[0]
RFCO2 = lambda pCO2: 5.35 * np.log(pCO2 / pCO20)
fig, ax = plt.subplots()
x = 1765 + np.fromiter(range(concentrations.CO2ConcRCP45.shape[0]), int)
ax.plot(x, RFCO2(pCO2), label='Model')
ax.plot(x, radiativeForcing.CO2RadForc, label='RCP45')
ax.set_title('Radiative Forcing for CO_2')
ax.set_xlabel('Year')
ax.set_ylabel('RF')
ax.legend()

# Exercise 9:
s = 1 # Standard value for aerosol RF scale factor
totRadForcExclCO2 = radiativeForcing.totRadForcExclCO2AndAerosols + s * radiativeForcing.totRadForcAerosols

# Exercise 10:
def solveΔT(RF = hsum(radiativeForcing)):
    WyrPerKm2ToJmkgPerKkgm3 = 31556952
    λ = 0.8
    κ = 0.5
    c = 4186
    ρ = 1020
    h = 50
    C1 = c * h * ρ / WyrPerKm2ToJmkgPerKkgm3
    d = 2000
    C2 = c * d * ρ / WyrPerKm2ToJmkgPerKkgm3
    
    def dΔT(ΔT, RF):
        return np.array([
            (RF - ΔT[1-1]/λ - κ * (ΔT[1-1] - ΔT[2-1])) / C1,
            κ * (ΔT[1-1] - ΔT[2-1]) / C2,
        ])

    ΔT = np.array([*accumulate(RF,
                               func=lambda ΔT, RF: ΔT + 1 * dΔT(ΔT, RF),
                               initial=np.zeros(2))])
    return ΔT

# a) Note that RF are cumulative values
testSolution = solveΔT(RF = 1 * np.ones(50000))

# plt.show()
