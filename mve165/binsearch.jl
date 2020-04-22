using JuMP, Gurobi

include("mod.jl")

function bin_search(lo, hi)
    @show (lo, hi)
    mid = (lo + hi) / 2
    if (hi - lo) < 1e-4
        return mid
    end
    yield[sunflower] = mid
    model, x, y, petrol_constraint, water_constraint, area_constraint = build_model()

    set_optimizer(model, Gurobi.Optimizer)
    optimize!(model)

    @show value.(x.data)
    @show value.(x.data)[2]

    if value.(x.data)[2] > 0
        return bin_search(lo, mid)
    else
        return bin_search(mid, hi)
    end
end

@show bin_search(1.4e3, 3e3)