using JuMP, Gurobi
using DelimitedFiles, DataFrames, CSV

@enum Blade long medium short

"""
Wind speed cumulative distribution function, x ≥ 0.

v is the mean wind speed [m/s].
"""
function windSpeedCdf(x::Real, v::Real)
	β = 2.4 # Shape parameter
	α = 0.8 * v # Scale parameter [m/s]
	1 - exp(-(x / α)^β)
end

# Investment cost for a wind turbine [MSEK]
locationCost = 34.5
# Exploitation cost of each of the two groups [MSEK]
groupCost = 6
# Purchase costs for each blade [MSEK]
bladeCost = Dict(long => 2.5, medium => 1.9, short => 1.44)
# Average electricity price [SEK/MWh]
electricityPrice = 274

# Read the data from the tables
T1 = DataFrame(readdlm("Wind-data1.txt", ' ', Float64, '\n'),
			   [:Ws0, :Ws1, :ObsFreq, :LEffect, :LEfficiency, :MEffect, :SEffect])
T2 = DataFrame(readdlm("Wind-data2.txt", ' ', Float64, '\n'),
			   [:Dir1, :Dir2, :N, :NE, :E, :SE, :S3E, :S, :SW, :W, :NW, :N3W, :Freq, :Mws])

reverse = Dict(:N => :S, :NE => :SW, :E => :W, :N3W => :S3E, :NW => :SE)

Locations = 1:7
Edges = [
		 (:NW, 3, 1),
		 (:NE, 2, 1),
		 (:E, 2, 3),
		 (:N3W, 4, 3),
		 (:NE, 5, 4),
		 (:E, 5, 7),
		 (:NW, 6, 5),
		 (:NE, 6, 7),
		 (:N, 6, 4),
		 (:NW, 7, 4),
		 ]
EdgeIndices = 1:length(Edges)

Group1 = 1:3; Group2 = 4:7

@enum Objective maxAvgRevenue minInvestmentCost
@enum BladePolicy onlyMediumBlade onePerGroup anyBlade

mutable struct Params
	n::Int # Max number of turbines
	obj::Objective
	bladePolicy::BladePolicy

	Params(n = 7;
		   obj = maxAvgRevenue,
		   bladePolicy = anyBlade) = new(n, obj, bladePolicy)
end

function build_model(p::Params)
	m = Model()

	# Variables
	# x[l, s], where
	# * l - location
	# * s - size
	x = @variable(m, x[l = Locations, s = instances(Blade)], Bin)
	# y[e, a, b] where
	# * e - the edge between two turbines that both are installed
	y = @variable(m, y[e = EdgeIndices, a = instances(Blade), b = instances(Blade)], Bin)
	@variable(m, g[1:2], Bin)
	h = @variable(m, h[1:2, b = instances(Blade)], Bin)

	blade2EffectKey = Dict(long => :LEffect, medium => :MEffect, short => :SEffect)

	relPowerLevel(dir, relDir, a) = min(1, dir[relDir] + Dict(long => 0, medium => 0.10, short => 0.15)[a])

	avgProd = @expression(m,
						  # Integrate out uncertainty in wind speed/direction
						  sum(sum((windSpeedCdf(v.Ws1, dir.Mws) - windSpeedCdf(v.Ws0, dir.Mws))
								  * (sum(v[blade2EffectKey[b]] * x[l, b]
										 for l in Locations, b in instances(Blade))
									 - sum(y[e, a, b]
										   # Forward edges
										   * ((1 - relPowerLevel(dir, Edges[e][1], a))
										   * v[blade2EffectKey[b]]

										   # Reverse edges
										   + (1 - relPowerLevel(dir, reverse[Edges[e][1]], b))
										   * v[blade2EffectKey[a]])
										   for e in EdgeIndices,
										   a in instances(Blade),
										   b in instances(Blade)))
								  for v in eachrow(T1))
							  * (dir.Freq / 100) for dir in eachrow(T2)))

	investmentCost = @expression(m, # Turbine costs
								 locationCost * sum(x)
								 # Blade costs
								 + sum(bladeCost[b] * sum(x[:, b])
									   for b in instances(Blade))
								 # Exploitation costs
								 + groupCost * sum(g))

	if p.obj == maxAvgRevenue
		@objective(m, Max, electricityPrice * avgProd)

		# Max n turbines
		@constraint(m, sum(x) <= p.n)
	elseif p.obj == minInvestmentCost
		@objective(m, Min, investmentCost)
		# Resulting energy production may not be lower than
		# that from best solution to 2(a) for n = 4
		@constraint(m, avgProd >= 979.83)
	end

	if p.bladePolicy == onlyMediumBlade
		# 2(a) Only the medium blade dimension is available
		for l in Locations
			@constraint(m, x[l, long] == 0)
			@constraint(m, x[l, short] == 0)
		end
	elseif p.bladePolicy == onePerGroup
		# 2(b)
		for g in 1:2 @constraint(m, sum(h[g, b] for b in instances(Blade)) == 1) end
		for b in instances(Blade)
			for l in Group1 @constraint(m, x[l, b] <= h[1, b]) end
			for l in Group2 @constraint(m, x[l, b] <= h[2, b]) end
		end
	end
	# else 2(c)

	# Only one blade at each location
	for l in Locations
		@constraint(m, sum(x[l, :]) <= 1)
	end

	# Force edge to true if both nodes are on
	for e in EdgeIndices
		_, c, d = Edges[e]
		for a in instances(Blade)
			for b in instances(Blade)
				@constraint(m, x[c, a] + x[d, b] <= 1 + y[e, a, b])
			end
		end
	end

	# Set group toggle
	for b in instances(Blade)
		for l in Group1 @constraint(m, x[l, b] <= g[1]) end
		for l in Group2 @constraint(m, x[l, b] <= g[2]) end
	end

	set_optimizer(m, Gurobi.Optimizer)
	m, x, y, investmentCost, h
end

chosenLocations(x) = mapslices(((l, m, s),) -> l == 1 ? 'L'
							   : (m == 1 ? 'M'
								  : s == 1 ? 'S' : '_'), value.(x.data), dims = [2]) |> join

params = Params(5; obj = maxAvgRevenue, bladePolicy = anyBlade)
model, x, y, _, h = build_model(params)
optimize!(model)
@show value.(y.data)
@show value.(h.data)
@show objective_value(model)
@show solve_time(model) # Seconds?
@show chosenLocations(x)

if false
	# Maximize production revenue under varying limits for investment
	df = map(range(0, 271, length = 100)) do eps
		params = Params(obj = maxAvgRevenue)
		model, x, y, investmentCost = build_model(params)
		@constraint(model, investmentCost <= eps)
		optimize!(model)
		revenue = objective_value(model)
		(InvestmentCost = eps, ProductionRevenue = revenue, Locations = chosenLocations(x))
	end |> DataFrame
	CSV.write("5_multi_obj.csv", df)

	prevRev = -1
	df2 = filter(df) do row
		global prevRev
		optimal = row.ProductionRevenue > prevRev
		prevRev = row.ProductionRevenue
		optimal
	end
	CSV.write("5_pareto_front.csv", df2)
end
