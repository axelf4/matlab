include("dat.jl")

"""
Constructs the model.
"""
function build_model()
m = Model()

# Area in hectar to use to grow crop i
@variable(m, x[instances(Crop)] >= 0)

# Produced vegatable oil in litres
veg_oil = @expression(m, sum(oil_content[c] * yield[c] * x[c]
							 for c in instances(Crop)))
# All oil is transesterificated into biodiesel
biodiesel_amount = @expression(m, 0.9 * veg_oil)

# Liters of the different blends produced
@variable(m, y[instances(Product)] >= 0)

petrol_usage = @expression(m, sum((1 - biodiesel_prop[p]) * y[p]
								  for p in instances(Product)))

# Maximize the profits
@objective(m, Max, sum(effective_price[p] * y[p]
					   for p in instances(Product))
		   - price_methanol * 0.2 * veg_oil # Methanol cost
		   - price_petrol * petrol_usage # Petrol cost
		   )

# Cannot use more biodiesel than have produced
@constraint(m, sum(biodiesel_prop[p] * y[p] for p in instances(Product))
			<= biodiesel_amount)

# Water constraint
water_constraint = @constraint(m, sum(water_demand[c] * x[c] for c in instances(Crop)) <= water_max)

# Area constraint
area_constraint = @constraint(m, sum(x) <= area_max)

# Petrol constraint
@constraint(m, petrol_constraint, petrol_usage <= petrol_max)

# Delivery constraint
@constraint(m, sum(y) >= fuel_min)

return m, x, y, petrol_constraint, water_constraint, area_constraint
end
