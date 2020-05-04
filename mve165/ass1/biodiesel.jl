using JuMP, Gurobi

include("mod.jl")
model, x, y, petrol_constraint, water_constraint, area_constraint = build_model()

set_optimizer(model, Gurobi.Optimizer)
optimize!(model)

@show value.(x.data)
@show value.(y.data)

# RHS perturbation range for petrol/water/area constraints
@show lp_rhs_perturbation_range(petrol_constraint)
@show lp_rhs_perturbation_range(water_constraint)
@show lp_rhs_perturbation_range(area_constraint)
