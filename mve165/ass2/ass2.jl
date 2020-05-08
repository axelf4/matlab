module Tmp
export Data, build_model, Res, optimize_model_data, a_res

import Base.show

using JuMP, Gurobi
using SparseArrays
using DataFrames, CSV

mutable struct Data
	# Sets
	Components
	# Parameters
	T::Int # Number of timesteps
	d # Cost of a maintenance occasion
	c # Costs of new components
	U # Lives of new components

	relax_x::Bool
	relax_z::Bool

	model::Function
	r::Int # Min remaining life at end of planning period

	Data(Components, T, d, c, U;
		 relax_x = false, relax_z = false,
		 model = build_model,
		 r = 0) = new(Components, T, d, c, U, relax_x, relax_z, model, r)
end

function set_d!(data::Data, d)
	data.d = ones(1, data.T) * d
end

smallData(; Components = 1:2, T = 4,
		  d = [10 10 1 10], c = [1 1   2   1;
								 1 100 100 1],
		  U = [3 4]) = Data(Components, T, d, c, U)

largeData(; Components = 1:10, T = 150,
		  d = ones(1, T) * 20,
		  c = [34 25 14 21 16 3 10 5 7 10]' * ones(1, T),
		  U = [42 18 90 94 49 49 34 90 37 11]) = Data(Components, T, d, c, U)

"""
Construct and returns the model of this assignment.
"""
function build_model(data::Data)
	#Components - the set of components
	#T - the number of time steps in the model
	#d[1,..,T] - cost of a maintenance occasion
	#c[Components, 1,..,T] - costs of new components
	#U[Components] - lives of new components
	Components = data.Components
	T = data.T
	d = data.d
	c = data.c
	U = data.U
	r = data.r

	m = Model()
	@variable(m, x[Components, 1:T] >= 0, binary = !data.relax_x)
	@variable(m, z[1:T] <= 1, binary = !data.relax_z)

	cost = @objective(m, Min,
					  sum(c[i, t]*x[i, t] for i in Components, t in 1:T) + sum(d[t]*z[t] for t in 1:T))

	ReplaceWithinLife = @constraint(m,
									[i in Components, ell in 0:(T-U[i]); T >= U[i]],
									sum(x[i,t] for t in (ell .+ (1:U[i]))) >= 1)

	ReplaceOnlyAtMaintenance = @constraint(m, [i in Components, t in 1:T],
										   x[i,t] <= z[t])

	MinRemLife = @constraint(m,
							 [i in Components],
							 sum(x[i,t] for t in (T + r - U[i] + 1):T if 1 <= t) >= 1)

	set_optimizer(m, Gurobi.Optimizer)
	return m, x, z
end

function build_model2(data::Data)
	#Components - the set of components
	#T - the number of time steps in the model
	#d[1,..,T] - cost of a maintenance occasion
	Components = data.Components
	T = data.T
	d = data.d
	U = data.U

	# Maintenance after time horizon is free
	c = hcat(data.c, zeros(length(Components), 1))
	# Replacement intervals
	I = [(s, t) for s in 0:T, t in 1:(T + 1) if s < t]

	m = Model()
	@variable(m, x[Components, s = 0:T, t = 1:(T+1); s < t] >= 0, binary = !data.relax_x)
	@variable(m, z[1:T] <= 1, binary = !data.relax_z)

	cost = @objective(m, Min,
					  sum(d[t]*z[t] for t in 1:T)
					  + sum((c[i, t] + (t - s > U[i] ? 1e6 : 0)) * x[i, s, t] for i in Components, (s, t) in I))

	# (2b)
	ReplaceOnlyAtMaintenace = @constraint(m,
										  [i in Components, t in 1:T],
										 sum(x[i, s, t] for s in 0:(t-1)) <= z[t])
	# (2c)
	BalanceCondition = @constraint(m,
								   [i in Components, t in 1:T],
								   sum(x[i, s, t] for s in 0:(t-1)) == sum(x[i, t, r] for r in (t+1):(T+1)))
	# (2d)
	StartFlow = @constraint(m,
							[i in Components],
							sum(x[i, 0, t] for t in 1:(T+1)) == 1)

	set_optimizer(m, Gurobi.Optimizer)
	return m, x, z
end

"""
Adds the constraint:  z[1] + x[1,2] + x[2,2] + x[1,3] + x[2,3] + z[4] >= 2
which is a VI for the small instance
"""
function add_cut_to_small(m::Model)
	@constraint(m, z[1] + x[1,2] + x[2,2] + x[1,3] + x[2,3] + z[4] >= 2)
end

struct Res
	obj
	x_val
	z_val
	solve_time
end

function number_of_maintenances(res::Res)
	sum(res.z_val)
end

function number_of_replaced_components(res::Res)
	sum(res.x_val)
end

function show(io::IO, res::Res)
	print(io, "RESULT OF OPTIMIZATION:\n")
	print(io, "obj:\t\t")
	show(io, res.obj)
	print(io, "\nsolution time:\t")
	show(io, res.solve_time)
	print(io, "\nx_val:\n")
	show(io, res.x_val)
	print(io, "\nz_val:\n")
	show(io, res.z_val)
	print(io, "\nEND OF RESULT OF OPTIMIZATION\n")
end

function optimize_model_data(data::Data)
	m, x, z = data.model(data)
	optimize!(m)
	Res(objective_value(m),
		data.model == build_model ? sparse(value.(x.data)) : value.(x),
		# sparse(value.(x)),
		sparse(value.(z)),
		solve_time(m))
end

function calc_1a_res()
	# 1. (a)
	a_res = map(((relax_x, relax_z),) -> begin
					data = largeData()
					data.relax_x = relax_x
					data.relax_z = relax_z
					optimize_model_data(data)
				end, [(false, false), (true, false), (true, true)])
end

function calc_2a()
	df = map(50:20:200) do T
			@show T
			data = largeData(T = T)
			# Note: d is 20 by default
			data.relax_x = true
			res = optimize_model_data(data)
			(T = T, ComputingTime = res.solve_time)
		end |> DataFrame
	CSV.write("cpu2a.csv", df)
end

function calc_2b()
	df = map(50:20:700) do T
			data = largeData(T = T)
			# Note: d is 20 by default
			data.relax_x = true
			data.relax_z = true
			res = optimize_model_data(data)
			(T = T, ComputingTime = res.solve_time)
		end |> DataFrame
	CSV.write("cpu2b.csv", df)
end

# 4.
function testR()
	data = largeData(T = 100)
	set_d!(data, 20)
	data.r = 1
	res = optimize_model_data(data)
	show(res)
	@show number_of_maintenances(res)
end

function calc_3a_other()
	df = map(50:20:200) do T
			@show T
			data = largeData(T = T)
			data.relax_x = true
			data.model = build_model2
			res = optimize_model_data(data)
			(T = T, ComputingTime = res.solve_time, Objective = res.obj)
		end |> DataFrame
	CSV.write("cpu3a_other.csv", df)
end

function calc_3b_other()
	df = map(50:20:700) do T
			@show T
			data = largeData(T = T)
			data.relax_x = true
			data.relax_z = true
			data.model = build_model2
			res = optimize_model_data(data)
			(T = T, ComputingTime = res.solve_time, Objective = res.obj)
		end |> DataFrame
	CSV.write("cpu3b_other.csv", df)
end

# calc_3a_other()
calc_3b_other()

function calc_4b()
	df = map(0:10) do r
		data = largeData(T = 100)
		data.r = r
		res = optimize_model_data(data)
		(r = r, cost = res.obj, numMaintenances = number_of_maintenances(res), numReplaced = number_of_replaced_components(res))
	end |> DataFrame
	CSV.write("4bValues.csv", df)
end

end