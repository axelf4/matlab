@enum Crop soy sunflower cotton

yield = Dict(soy => 2.6e3, sunflower => 1.4e3, cotton => 0.9e3)
# Water demand in liter per hectar
water_demand = Dict(soy => 5.0e6, sunflower => 4.2e6, cotton => 1.0e6)
oil_content = Dict(soy => 0.178, sunflower => 0.216, cotton => 0.433)

@enum Product B5 B30 B100

biodiesel_prop = Dict(B5 => 0.05, B30 => 0.30, B100 => 1.00)

effective_price = Dict(B5 => 1.43 * (1 - 0.20), B30 => 1.29 * (1 - 0.05), B100 => 1.16)

# Max area to grow crops on in hectar
area_max = 1_600
# Maximum available amount of water in litres
water_max = 5_000e6

# Minimum amount of litres of fuel delivered
fuel_min = 280_000

# Price of methanol in euro/l
price_methanol = 1.5
# Price of petrol in euro/l
price_petrol = 1

# In liters
petrol_max = 150_000