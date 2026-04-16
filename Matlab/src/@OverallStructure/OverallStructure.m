classdef OverallStructure
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        State =State;
        
        MunicipalArray = Municipality;
        VehicleArchetypeArray 
        MidpointImpactArray
        EndpointImpactArray

        lat_5arcmin
        lon_5arcmin
        municipality_ids_5arcmin
    end
    
    methods
        obj = get_pop_projections_municipal(obj, filename);
        Mun = get_municipality_from_name(obj,name)

        plot_internal_normalization_endpoints(obj)

    end
end

