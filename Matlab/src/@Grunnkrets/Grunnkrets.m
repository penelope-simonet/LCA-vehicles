classdef Grunnkrets
    %GRUNNKRETS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        fylke_id
        kommune_id
        grunnkrets_id

        ald_u_5
        ald_6_12
        ald_13_15
        ald_16_18
        ald_19_23
        ald_24_34
        ald_35_44
        ald_45_54
        ald_55_64
        ald_65_74
        ald_75_84
        ald_85_o
        ald_snitt
        ald_totalt

        for_0
        for_0_50
        for_50_200
        for_200_400
        for_400_700
        for_700_1000
        for_1000_2000
        for_2000_3000
        for_3000_4000
        for_4000_over
        for_personer
        for_snitt
        for_totalt

        int_0
        int_0_100
        int_200_300
        int_300_400
        int_400_500
        int_500_600
        int_600_700
        int_700_800
        int_800_1000
        int_1000_1500
        int_1500_over
        int_personer
        int_snitt
        int_totalt
        
        utn_ingen_eller_uoppgitt
        utn_grunnskole
        utn_videregaende
        utn_hogskole_universitet_lavt
        utn_hogskole_universitet_hoyt

        ald_under_18
        ald_above_18
        
        mean_vehicle_weight
        mean_electric_vehicle_weight
        mean_fossil_vehicle_weight
        mean_hybrid_vehicle_weigth
        mean_vehicle_age
        mean_electric_vehicle_age
        mean_fossil_vehicle_age
        mean_hybrid_vehicle_age
        
        vehicles_per_capita
        vehicles_per_capita_above_18
        electrification_share
        hybrid_share
        fossil_share   

        utn_score

        lca_emissions_tCO2eq_tot
        mean_lca_emissions_per_capita
        mean_lca_emissions_per_capita_above_18
        mean_lca_emissions_gram_per_km

    end
    
    methods
        function obj = Grunnkrets(filename)

            fields = fieldnames(obj);

            ncid = netcdf.open(filename);
            [~,nvars,~,~] = netcdf.inq(ncid);
            for i = 0:nvars-1
                [varname,~,~,~] = netcdf.inqVar(ncid,i);
                for f = 1:length(fields)

                    if strcmp(varname, fields{f})
                        obj.(varname) = netcdf.getVar(ncid,i);
                    end
                end
            end
            n_utn = obj.utn_ingen_eller_uoppgitt+obj.utn_grunnskole+obj.utn_videregaende+obj.utn_hogskole_universitet_lavt+obj.utn_hogskole_universitet_hoyt;
            obj.utn_score = (0*obj.utn_ingen_eller_uoppgitt+1/4*obj.utn_grunnskole+2/4*obj.utn_videregaende+3/4*obj.utn_hogskole_universitet_lavt+obj.utn_hogskole_universitet_hoyt)./n_utn;
        end

    end
end

