using JuMP, Gurobi
using DelimitedFiles, DataFrames

@enum Blade long medium short

bladeRadius = Dict(long => 45, medium => 30, short => 22.5)

# Wake constant (the slope of the spread of the wake, offshore value)
# α = 0.04

# ϱ = 1.25 # Density of air [kg/m3]
# P(R, Cp, v) = 1/2 * π * R² * ϱ * Cp * v³

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
# Edges = vcat(nEdges, [(reverseDir[dir], d, c) for (dir, c, d) in nEdges])
EdgeIndices = 1:length(Edges)

Directions = [:N, :NE, :E, :SE, :S3E, :S, :SW, :W, :NW, :N3W]

function build_model(n::Int)
	m = Model()

	# Variables
	# x[l, s], where
	# * l - location
	# * s - size
	x = @variable(m, x[l = Locations, s = instances(Blade)], Bin)
	y = @variable(m, y[e = EdgeIndices, a = instances(Blade), b = instances(Blade)], Bin)

	blade2EffectKey = Dict(long => :LEffect, medium => :MEffect, short => :SEffect)

	relPowerLevel(dir, relDir, a) = min(1, dir[relDir] + Dict(long => 0, medium => 0.10, short => 0.15)[a])

	@objective(m, Max,
			   sum(sum((windSpeedCdf(v.Ws1, dir.Mws) - windSpeedCdf(v.Ws0, dir.Mws))
					   * (sum(v[blade2EffectKey[s]] * x[l, s]
							  for l in Locations, s in instances(Blade))
						  - sum(
								# Forward edges
								y[e, a, b]
								* (1 - relPowerLevel(dir, Edges[e][1], a))
								* v[blade2EffectKey[b]]

								# Reverse edges
								+ y[e, b, a]
								* (1 - relPowerLevel(dir, reverse[Edges[e][1]], b))
								* v[blade2EffectKey[a]]
								for e in EdgeIndices,
								a in instances(Blade),
								b in instances(Blade)))
					   for v in eachrow(T1))
				   * (dir.Freq / 100) for dir in eachrow(T2)))

	# Only one blade at each location
	for l in Locations
		@constraint(m, sum(x[l, s] for s in instances(Blade)) <= 1)
	end

	# Max n turbines
	@constraint(m, sum(x[l, s] for l in Locations, s in instances(Blade)) <= n)

	# Force arches to be set to true
	for e in EdgeIndices
		_, c, d = Edges[e]
		for a in instances(Blade)
			for b in instances(Blade)
				@constraint(m, x[c, a] + x[d, b] <= 1 + y[e, a, b])
			end
		end
	end

	set_optimizer(m, Gurobi.Optimizer)
	m, x, y
end

model, x, y = build_model(4)
optimize!(model)
@show value.(x.data)
@show value.(y.data)
