using Printf, Plots
using JuMP, Gurobi

using CSV
using DataFrames

G2M = 1e3

@enum EnergyType wind pv gas hydro batteries transmission nuclear

investmentCosts = Dict(wind => 1100, pv => 600, gas => 550, hydro => 0,
                       batteries => 150, transmission => 2500, nuclear => 7700)

runningCost = Dict(wind => 0.1, pv => 0.1, gas => 2, hydro => 0.1, batteries => 0.1,
                   transmission => 0, nuclear => 4)

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
# x[e, c] - investment of energy type e in country c measured in MW
@variable(m, 0 <= x[e = instances(EnergyType), c = instances(Country)])

Time = 1:24 * 365

windEfficiency = Dict(sweden => timeSeries.Wind_SE,
                      germany => timeSeries.Wind_DE,
                      denmark => timeSeries.Wind_DK)

@expression(m, windProduction[c = instances(Country), t = Time],
            windEfficiency[c][t] * x[wind, c])

pvEfficiency = Dict(sweden => timeSeries.PV_SE,
                    germany => timeSeries.PV_DE,
                    denmark => timeSeries.PV_DK)

@expression(m, pvProduction[c = instances(Country), t = Time],
            pvEfficiency[c][t] * x[pv, c])

# Gas
gasFuelCost = 22
# The actual amount of gas in MW that we use at any given time
@variable(m, 0 <= g[c = instances(Country), t = Time])
# Cannot use more gas than we have facilities for
for c in instances(Country), t in Time
    @constraint(m, g[c, t] <= x[gas, c])
end

# Hydro
@variables(m, begin
               0 <= r[c = instances(Country), t = Time] # Reservoir size in MWh
               0 <= o[c = instances(Country), t = Time] # Outward flow
           end)
@constraints(m, begin
                 x[hydro, sweden] <= G2M * 14 # Installed capacity is 14 GW
                 x[hydro, germany] == 0
                 x[hydro, denmark] == 0
             end)
for c in instances(Country)
    @constraint(m, r[c, first(Time)] == r[c, last(Time)]) # Continuity condition
    for t in Time
        @constraints(m, begin
                         r[c, t] <= 33e6 # Capped reservoir storage size
                         o[c, t] <= x[hydro, c]
                     end)
    end
end
# Flow balance condition
for t in first(Time):last(Time) - 1
    @constraint(m,
                r[sweden, t] + timeSeries.Hydro_inflow[t] - o[sweden, t] == r[sweden, t + 1])
end

# Batteries
@variables(m, begin
               0 <= b[c = instances(Country), t = Time] # Stored energy in batteries
               0 <= bc[c = instances(Country), t = Time] # Battery charge per the hour
               0 <= bd[c = instances(Country), t = Time] # Battery discharge for each hour
           end)
for c in instances(Country)
    @constraints(m, begin
                     # b[c, first(Time)] == 0 # Stored energy starts at zero
                     b[c, first(Time)] == b[c, last(Time)] # Continuity condition
                     end)
    for t in Time
        @constraints(m, begin
                         b[c, t] <= x[batteries, c] # Cannot store more energy than max capacity
                     end)
    end

    # Flow balance condition
    for t in first(Time):last(Time) - 1
        @constraint(m,
                    b[c, t] + bc[c, t] - bd[c, t] == b[c, t + 1])
    end
end

# Transmission
# transmitted[c1, c2, t] is transmission from c1 to c2 at time t
@variable(m, 0 <= transmitted[c1 = instances(Country), c2 = instances(Country), t = Time])
@variable(m, 0 <= transmission_capacity[c1 = instances(Country), c2 = instances(Country)])
for c1 in instances(Country)
    @constraint(m, transmission_capacity[c1, c1] == 0) # Cannot transmit to itself

    for c2 in instances(Country)
        if c1 < c2
            @constraint(m, transmission_capacity[c1, c2] == transmission_capacity[c2, c1])
        end

        for t in Time
            @constraint(m, transmitted[c1, c2, t] <= transmission_capacity[c1, c2])
        end
    end
end

totalInvestmentCosts = @expression(
    m,
    sum(x[e, c] * annualizedCost(lifetime[e], 1e3 * investmentCosts[e])
        for e in instances(EnergyType), c in instances(Country))
    + 1/2 * sum(transmission_capacity[c1, c2]
                * annualizedCost(lifetime[transmission], 1e3 * investmentCosts[transmission])
                for c1 in instances(Country), c2 in instances(Country))
)

totalVariableCosts = @expression(
    m,
    sum(
        # Running costs for wind power
        runningCost[wind] * windProduction[c, t]

        # Running costs for solar
        + runningCost[pv] * pvProduction[c, t]

        # Running costs for gas
        + runningCost[gas] * g[c, t]
        # Fuel costs for gas
        + gasFuelCost * g[c, t] / gasEfficiency

        # Running costs for hydro
        + runningCost[hydro] * o[c, t]

        # Running costs for batteries
        + runningCost[batteries] * bd[c, t]

        for c in instances(Country), t in Time)
)

# Ton CO₂
co2Emissions = @expression(
    m,
    sum(0.202 * g[c, t] / gasEfficiency
        for c in instances(Country), t in Time)
)

costs = @objective(m, Min, totalInvestmentCosts + totalVariableCosts)

windCapacity = Dict(sweden => 280, denmark => 90, germany => 180)
for c in instances(Country)
    @constraint(m, x[wind, c] <= G2M * windCapacity[c])
end

pvCapacity = Dict(sweden => 75, denmark => 60, germany => 460)
for c in instances(Country)
    @constraint(m, x[pv, c] <= G2M * pvCapacity[c])
end

load = Dict(sweden => timeSeries.Load_SE,
            germany => timeSeries.Load_DE,
            denmark => timeSeries.Load_DK)

@expression(m, production[c = instances(Country), t = Time],
            windProduction[c, t]
            + pvProduction[c, t]
            + g[c, t] # Gas
            + o[c, t] # Hydro
            )

# Load balance condition
for c in instances(Country), t in Time
    @constraint(m, production[c, t]
                + batteryEfficiency * bd[c, t] # Batteries (90% round-trip efficiency)
                + sum(0.98 * transmitted[c2, c, t] - transmitted[c, c2, t] for c2 in instances(Country))
                >= load[c][t]
                + bc[c, t]
                )
end

originalCo2Emissions = 1.388215e+08
@constraint(m, co2Emissions <= 0.1 * originalCo2Emissions)

set_optimizer(m, Gurobi.Optimizer)
optimize!(m)

@show value.(x.data)
@printf "Total emissions: %e\n" value(co2Emissions)

for c in 1:3
    @printf "total production in country %i: %e\n" c sum(value(production.data[c, t]) for t in Time)
end

# firstWeekTimes = 1:168
# plot(firstWeekTimes, value.(view(production.data, 3, firstWeekTimes)))

data = DataFrame(windProduction = value.(view(windProduction.data, 3, firstWeekTimes)),
                 pvProduction = value.(view(pvProduction.data, 3, firstWeekTimes)),
                 gasProduction = value.(view(g.data, 3, firstWeekTimes)),
                 batteryIn = value.(batteryEfficiency * view(bd.data, 3, firstWeekTimes)),
                 transmissionIn = sum(0.98 * value.(view(transmitted.data, c2, 3, firstWeekTimes)) for c2 in 1:3),
                 )
