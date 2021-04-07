using JuMP, Gurobi

using CSV
using DataFrames

@enum EnergyType wind pv gas hydro batteries transmission nuclear

investmentCosts = Dict(wind => 1100, pv => 600, gas => 550, hydro => 0,
                       batteries => 150, transmission => 2500, nuclear => 7700)

runningCost = Dict(wind => 0.1, pv => 0.1, gas => 2, hydro => 0.1, batteries => 0.1,
                   transmission => 0, nuclear => 4)

fuelCost = Dict(wind => 0, pv => 0, gas => 22, hydro => 0, batteries => 0,
                   transmission => 0, nuclear => 3.2)

lifetime = Dict(wind => 25, pv => 25, gas => 30, hydro => 80, batteries => 10,
                   transmission => 50, nuclear => 50)

gasEfficiency = 0.4
batteryEfficiency = 0.9
transmissionEfficiency = 0.9
nuclearEfficiency = 0.4

gasEmissionFactor = 0.202

timeSeries = CSV.File("TimeSeries.csv") |> DataFrame

discountRate = 0.05
annualizedCost(lt, ic) = ic * discountRate / (1 - 1 / (1 + discountRate)^lt)

@enum Country sweden denmark germany

m = Model()
@variable(m, x[e = instances(EnergyType), c = instances(Country)], Int)

totalInvestmentCosts = @expression(
    m,
    sum(x[e, c] * annualizedCost(lifetime[e], investmentCosts[e])
        for e in instances(EnergyType), c in instances(Country))
)

Time = 1:24 * 365

windEfficiency = Dict(sweden => timeSeries.Wind_SE,
                      germany => timeSeries.Wind_DE,
                      denmark => timeSeries.Wind_DK)

windProd(c, t) = windEfficiency[c][t] * x[wind, c]

pvEfficiency = Dict(sweden => timeSeries.PV_SE,
                    germany => timeSeries.PV_DE,
                    denmark => timeSeries.PV_DK)

pvProd(c, t) = pvEfficiency[c][t] * x[pv, c]

totalVariableCosts = @expression(
    m,
    sum(
        # Running costs for wind power
        1e-3 * runningCost[wind] * windProd(c, t)

        # Running costs for solar
        + 1e-3 * runningCost[pv] * pvProd(c, t)
        for c in instances(Country), t in Time)
)

windCapacity = Dict(sweden => 280, denmark => 90, germany => 180)
for c in instances(Country)
    @constraint(m, 1e-6 * x[wind, c] <= windCapacity[c])
end

pvCapacity = Dict(sweden => 75, denmark => 60, germany => 460)
for c in instances(Country)
    @constraint(m, 1e-6 * x[pv, c] <= pvCapacity[c])
end

load = Dict(sweden => timeSeries.Load_SE,
            germany => timeSeries.Load_DE,
            denmark => timeSeries.Load_DK)
# Load balance condition
for c in instances(Country), t in Time
    @constraint(m, windProd(c, t) + pvProd(c, t) >= load[c][t])
end

set_optimizer(m, Gurobi.Optimizer)
optimize!(m)
