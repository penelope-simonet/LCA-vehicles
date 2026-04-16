classdef EndpointCategories
    %ENDPOINTCATEGORIES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name
        id
        damage_pathway
        framework
        unit
        time
        value
        
        value_glider
        value_powertrain
        value_energy_storage
        value_energy_chain
        value_maintenance
        value_EoL
        value_road
        value_direct_non_exhaust
        value_direct_exhaust
    end
    
    methods
           obj = calc_total_impacts(obj)
    end
end

