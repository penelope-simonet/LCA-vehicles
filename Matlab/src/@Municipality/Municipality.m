classdef Municipality
    %MUNICIPALITY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        id
        name
        fylke_id


        time_projection
        VehicleArray = Vehicle;

        vehicle_weight
        vehicle_year_reg
        vehicle_fuel_code

        vehicle_life_cycle_emissions_gco2eq_per_km
        vehicle_lifetime_km = 230000;
        vehicle_lifetime_yrs = 15.7;

        vehicle_is_fossil
        vehicle_is_hybrid
        vehicle_is_electric
        vehicle_is_other
        
        fossil_share
        electrification_share
        hybrid_share
        other_share

        total_lca_emissions_tco2eq

        total_lca_emissions_per_capita_tco2eq_per_cap
        total_annual_lca_emissions_per_capita_tco2eq_per_cap_yr

        population
        population_projection_men_0_17
        population_projection_men_above_18
        population_projection_women_0_17
        population_projection_women_above_18
        population_projection_tot_0_17
        population_projection_tot_above_18
        population_projection_tot

        population_projection_men_0_17_low
        population_projection_men_above_18_low
        population_projection_women_0_17_low
        population_projection_women_above_18_low
        population_projection_tot_0_17_low
        population_projection_tot_above_18_low
        population_projection_tot_low

        population_projection_men_0_17_high
        population_projection_men_above_18_high
        population_projection_women_0_17_high
        population_projection_women_above_18_high
        population_projection_tot_0_17_high
        population_projection_tot_above_18_high
        population_projection_tot_high
        
    end
    
    methods

    end
end

