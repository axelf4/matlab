from functools import reduce, partial
from itertools import accumulate, product
import math
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from numba import jit, vectorize, int32, float32, float64

hsum = partial(np.sum, axis=1)
hsum.__doc__ = "Horizontal sum"

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

# Global mean surface temperature From NASA, 1880-2019
# Ökningen i global temperatur över perioden 1880-2019, normaliserat mot ett medelvärde beräknat över perioden 1951-1980
nasaGiss = pd.read_csv("NASA_GISS.csv")

# In GtC
B0 = np.array([600, 600, 1500])
# In GtC/year
F120 = 60
F210 = 15
F230 = 45
F310 = 45

β = 0.35  # CO2-fertilisation factor

# (1) 𝑑𝐵1/𝑑𝑡=𝛼31𝐵3+𝛼21𝐵2−𝑁𝑃𝑃+𝑈
# (2) 𝑑𝐵2/𝑑𝑡=𝑁𝑃𝑃−𝛼23𝐵2−𝛼21𝐵2
# (3) 𝑑𝐵3/𝑑𝑡=𝛼23𝐵2−𝛼31𝐵3
@jit(nopython=True)
def calc_dB(B, x, *, β):
    _, U = x
    NPP0 = F120
    NPP = NPP0 * (1 + β * np.log(B[1 - 1] / B0[1 - 1]))
    return np.array(
        [
            F310 / B0[3 - 1] * B[3 - 1] + F210 / B0[2 - 1] * B[2 - 1] - NPP + U,
            NPP - F230 / B0[2 - 1] * B[2 - 1] - F210 / B0[2 - 1] * B[2 - 1],
            F230 / B0[2 - 1] * B[2 - 1] - F310 / B0[3 - 1] * B[3 - 1],
        ]
    )


def modelBs(*, β=β, U=U, calc_dB=calc_dB):
    Bs = np.array(
        [
            *accumulate(
                enumerate(U), func=lambda B, U: B + calc_dB(B, U, β=β), initial=B0
            )
        ]
    )[1:, :]
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
    Bs = modelBs(β=β)
    return [ppmCO2perGtonC * Bs[-1, 0], Bs[-1, 1], Bs[-1, 2]]


resCByβ = pd.DataFrame(
    np.array([*map(sampleβ, βs)]),
    index=βs,
    columns=["Atmospheric CO2Conc", "C in Biomass", "C in Ground"],
)

# The sea
k = 3.06e-3

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


@jit(float64(int32, float64[:], float32), nopython=True)
def calc_M(t, U, *, k=k):
    A = [0.113, 0.213, 0.258, 0.273, 0.1430]
    τ0 = [2.0, 12.2, 50.4, 243.3, math.inf]

    def τ(i):
        return τ0[i] * (1 + k * np.sum(U[0 : t - 1 + 1]))

    M0 = B0[1 - 1]
    M = M0
    for i in range(5):
        τi = τ(i)
        for s in range(t + 1):
            M += (A[i] * np.exp(-(t - s) / τi)) * U[s]

    return M


# # Exercise 4:
# fig, ax = plt.subplots()
# ts = np.fromiter(range(concentrations.CO2ConcRCP45.shape[0]), int)
# x = 1765 + ts
# M = np.vectorize(lambda t: calc_M(t, U.to_numpy(), k=k))
# ax.plot(x, ppmCO2perGtonC * M(ts), label="Atmosphere with sea absorption")
# ax.plot(x, concentrations.CO2ConcRCP45, label="RCP45")
# ax.set_xlabel("Year")
# ax.set_ylabel("CO_2 concentration in atmosphere")
# ax.legend()


def get_calc_dB_with_sea(*, k=k):
    dB1s = np.zeros(1 + len(U))

    def f(B, x, *, β):
        t, U = x
        dB = calc_dB(B, x, β=β)

        dB1s[t] = dB[1 - 1]
        M = calc_M(t, dB1s[: t + 1], k=k)

        dB[1 - 1] = M - B[1 - 1]

        return dB

    return f


# # Exercise 6:
# seaBs = modelBs(β = 0.32, calc_dB = get_calc_dB_with_sea())
# fig, ax = plt.subplots()
# x = 1765 + np.fromiter(range(concentrations.CO2ConcRCP45.shape[0]), int)
# ax.plot(x, ppmCO2perGtonC * seaBs[:, 0], label='Model')
# ax.plot(x, concentrations.CO2ConcRCP45, label='RCP45')
# ax.legend()

# # Exercise 7:
# # Higher values of beta means more carbon gets bound into biomass and
# # the ground, which is taken from the carbon in atmosphere and the sea.
# # Higher values of k means less carbon gets bound into the sea from
# # the atmosphere. There is a small increase in the amount of carbon in
# # biomass and the ground from the increased carbon in the atmosphere.
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

# # Exercise 8:
pCO2 = concentrations.CO2ConcRCP45


def RFCO2(pCO2):
    pCO20 = concentrations.CO2ConcRCP45[0]
    return 5.35 * np.log(pCO2 / pCO20)


# fig, ax = plt.subplots()
# x = 1765 + np.fromiter(range(concentrations.CO2ConcRCP45.shape[0]), int)
# ax.plot(x, RFCO2(pCO2), label='Model')
# ax.plot(x, radiativeForcing.CO2RadForc, label='RCP45')
# ax.set_title('Radiative Forcing for CO_2')
# ax.set_xlabel('Year')
# ax.set_ylabel('RF')
# ax.legend()

# Exercise 9:
s = 1  # Standard value for aerosol RF scale factor
totRadForcExclCO2 = (
    lambda s=1: radiativeForcing.totRadForcExclCO2AndAerosols
    + s * radiativeForcing.totRadForcAerosols
)

# Exercise 10:
def solveΔT(RF, *, λ=0.8, κ=0.5):
    WyrPerKm2ToJmkgPerKkgm3 = 31556952
    c = 4186
    ρ = 1020
    h = 50
    C1 = c * h * ρ / WyrPerKm2ToJmkgPerKkgm3
    d = 2000
    C2 = c * d * ρ / WyrPerKm2ToJmkgPerKkgm3

    def dΔT(ΔT, RF):
        return np.array(
            [
                (RF - ΔT[1 - 1] / λ - κ * (ΔT[1 - 1] - ΔT[2 - 1])) / C1,
                κ * (ΔT[1 - 1] - ΔT[2 - 1]) / C2,
            ]
        )

    ΔT = np.array(
        [*accumulate(RF, func=lambda ΔT, RF: ΔT + 1 * dΔT(ΔT, RF), initial=np.zeros(2))]
    )
    return ΔT


# Returns the value of ΔT1 and ΔT2 at equilibrium.
def equilibrium_temp(*, RF, λ):
    return RF * λ


# a)
# testSolution = solveΔT(RF = 1 * np.ones(5000))

# b)
def calc_efolding_time(*, RF, λ, κ):
    ΔT = solveΔT(RF, λ=λ, κ=κ)

    def efolding_time(ΔT):
        return next(
            i
            for i, v in enumerate(ΔT)
            if v > (1 - 1 / math.e) * equilibrium_temp(RF=RF[i], λ=λ)
        )

    return [efolding_time(ΔT[:, 0]), efolding_time(ΔT[:, 1])]


stepRFs = 1 * np.ones(5000)
params = [*product(np.linspace(0.5, 1.3, num=5), np.linspace(0.2, 1, num=5))]
exercise10Results = pd.DataFrame(
    [calc_efolding_time(RF=stepRFs, λ=λ, κ=κ) for (λ, κ) in params],
    index=params,
    columns=["ΔT1", "ΔT2"],
)
# Higher values of lambda gives us higher equilibrium temperature
# because less radiation escapes from T_1.
# Higher values of kappa means more heat gets transmitted from T_1 to T_2.
# This means that T_2 heats up more quickly and hits the equilibrium temperature faster.
# The reverse is true for T_1.

# Exercise 11.
def model_temp(*, β=0.32, U=U, λ=0.8, κ=0.5, s=1, RF_pert=0):
    Bs = modelBs(β=β, U=U, calc_dB=get_calc_dB_with_sea())
    totRadForcCO2 = RFCO2(ppmCO2perGtonC * Bs[:, 1 - 1])

    totRadForc = totRadForcCO2 + totRadForcExclCO2(s)[: len(U)] + RF_pert

    ΔT = solveΔT(RF=totRadForc, λ=λ, κ=κ)

    return ΔT[:, 1 - 1]


def exercise11(*, λ, κ, s):

    # 11a) Time period before industrialization would be suitable,
    # because then the relative temps would be increasing.
    # Reference period gives us the index temperature only translates in y-led.

    ΔT1 = model_temp(λ=λ, κ=κ, s=s)

    refYears = np.array(range(1951, 1980 + 1)) - 1765
    refMean = np.mean(ΔT1[refYears])

    relTemp = ΔT1 - refMean

    nasaSlice = relTemp[np.array(range(1880, 2019 + 1)) - 1765]

    return nasaSlice


# 11b)
λs = [0.5, 0.8, 1.3]
κs = np.linspace(0.2, 1, 3)
ss = [0.1, 1, 2]
for (λ, κ, s) in product(λs, κs, ss):
    fig, ax = plt.subplots()
    ax.plot(exercise11(λ=λ, κ=κ, s=s), label="Model")
    ax.plot(nasaGiss, label="NASA data")
    ax.set_title(f"λ = {λ}, κ = {κ}, s = {s}")
    ax.legend()


def U_scenarios():
    Uslice = U[: 2200 - 1765]
    return [
        (
            "linjär minskning",
            np.concatenate(
                (
                    Uslice[: 2021 - 1765],
                    np.maximum(
                        0,
                        Uslice[2021 - 1765]
                        - Uslice[2021 - 1765]
                        * np.arange(len(Uslice) - (2021 - 1765))
                        / (2070 - 2021),
                    ),
                )
            ),
        ),
        (
            "konstant",
            np.concatenate(
                (Uslice[: 2021 - 1765], Uslice[2021 - 1765] * np.ones(2200 - 2021))
            ),
        ),
        (
            "linjär ökning",
            np.concatenate(
                (
                    Uslice[: 2021 - 1765],
                    np.minimum(
                        1.5 * Uslice[2021 - 1765],
                        np.maximum(
                            0,
                            Uslice[2021 - 1765]
                            * (
                                1
                                + 0.5
                                * np.arange(len(Uslice) - (2021 - 1765))
                                / (2100 - 2021)
                            ),
                        ),
                    ),
                )
            ),
        ),
    ]


def exercise12():
    Us = U_scenarios()
    params = [(0.5, 0.2, 1), (0.8, 1.0, 1), (1.3, 0.6, 2)]
    fig, ax = plt.subplots()
    for (λ, κ, s) in params:
        for (U_type, U) in Us:
            T = model_temp(U=U, λ=λ, κ=κ, s=s)
            xs = 1765 + np.arange(len(T))
            ax.plot(xs, T, label=f"{U_type} (λ={λ}, κ={κ}, s={s})")
    ax.set_title("Temperaturscenarior över perioden 1765-2100.")
    ax.legend()
    plt.show()


def exercise13():
    U = U_scenarios()[3 - 1][1]
    RF_pert = np.concatenate(
        (np.zeros(2050 - 1765), -4 * np.ones(2100 - 2050), np.zeros(2200 - 2100))
    )
    params = [(0.5, 0.2, 1), (0.8, 1.0, 1), (1.3, 0.6, 2)]
    fig, ax = plt.subplots()
    for (λ, κ, s) in params:
        T = model_temp(U=U, λ=λ, κ=κ, s=s, RF_pert=RF_pert)
        xs = 1765 + np.arange(len(T))
        ax.plot(xs, T, label=f"(λ={λ}, κ={κ}, s={s})")
    ax.set_title("Temperaturscenarior över perioden 1765-2100 med SAI.")
    ax.legend()
    plt.show()


# exercise12()
