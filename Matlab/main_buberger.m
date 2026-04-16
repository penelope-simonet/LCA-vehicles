addpath(genpath(pwd()));

tic

run_all = 1;
if run_all == 1
    
    fprintf('importing lockup table \n');
    filename_lockup = 'input/lockup_table.xlsx';

    fprintf('importing vehicle data at "grunnkrets" level \n')
    ncid = netcdf.open('input/biler_anon_grunnkrets_v8.nc');

    vehicle_age = netcdf.getVar(ncid,1);
    vehicle_year = netcdf.getVar(ncid,4);
    fuel_code = netcdf.getVar(ncid,6);
    vehicle_weight = netcdf.getVar(ncid,7);
    vehicle_municipality = netcdf.getVar(ncid,9);
    vehicle_model_id = netcdf.getVar(ncid,5);
    netcdf.close(ncid);

    %fuel_strings = {'gasoline', 'diesel', 'gasoline_hybrid', 'diesel_hybrid', 'electric'};
    %fuel_codes = [1 2 7 8 5 ];

    unique_vehicle_models = unique(vehicle_model_id);
    n_vehicles_per_unique_vehicle_model = zeros(1,length(unique_vehicle_models));
    for v = 1:length(unique_vehicle_models )
        n_vehicles_per_unique_vehicle_model(v) = sum(vehicle_model_id == unique_vehicle_models(v));
    end

    [n_vehicles_sorted_after_most_popular_model, idx_vehicles_sorted_after_most_popular_model] = sort(n_vehicles_per_unique_vehicle_model, 'descend');


    fuel_strings = cell(1,length(fuel_code));

    fprintf('Importing municipal ids \n')

    ncid = netcdf.open('input/municipal_ids.nc');
    municipal_ids_5arcmin = netcdf.getVar(ncid,2);
    county_ids_5arcmin = netcdf.getVar(ncid,3);
    lat = netcdf.getVar(ncid,0);
    lon = netcdf.getVar(ncid,1);
    netcdf.close(ncid);



    % Get lockup tables
    [lockup_municipal] = readtable(filename_lockup,'Sheet', 'Kommune');
    [lockup_county] = readtable(filename_lockup, 'Sheet', 'Fylke');
    lockup_fuel = readtable(filename_lockup, 'Sheet', 'Fuel');
    lockup_vehicle_models = readtable(filename_lockup, 'Sheet', 'Vehicle models');
    lockup_grunnkrets = readtable(filename_lockup, 'Sheet', 'Grunnkrets');

    n_fuels = size(lockup_fuel,1);
    fuel_codes_lockup = lockup_fuel{:,2};

    get_fuel_strings = 0;
    if get_fuel_strings == 1
        for i = 1:length(fuel_strings)
            for j = 1:n_fuels
                if fuel_code(i) == fuel_codes_lockup(j)
                    fuel_strings{i} = lockup_fuel{j,1};
                end
            end
        end
    end


    n_municipalities = size(lockup_municipal,1);
    n_counties = size(lockup_county,1);

    municipal_ids_vec = lockup_municipal{:,2};
    
    calc_buberger =0;
    if calc_bubgerger ==1

        %% Parameterization, Buberger (2022)
        % Values in vectors represents [a b c] in equation e_life(mass) = a*mass^2 + b*mass +c.
        par_gasoline = [3.701*10^-5 3.953*10^-2 51.28];
        par_diesel = [1.049*10^-5 7.874*10^-2 7.834];
        par_lpg = [0 1.087*10^-1 6.439];
        par_cng = [0 5.320*10^-2 30.45];
        par_cbg = [0 1.997*10^-2 8.509];
        par_gasoline_phev_conv = [2.759*10^-5 -2.253*10^-2 65.98];
        par_gasoline_phev_renew = [1.323*10^-5 -5.429*10^-3 30.07];
        par_diesel_phev_conv = [0 6.343*10^-2 1.226];
        par_diesel_phev_renew = [0 -8.232*10^-3 88.26];
        par_bev_conv = [0 4.510*10^-2 9.892];
        par_bev_renew = [0 1.614*10^-2 -2.970];

        %% Calc LCA emissions
        vehicle_life_cycle_emissions_gco2eq_per_km = zeros(1,length(fuel_code));
        for fuels = 1:length(fuel_codes_lockup)
            binary_this_fuel = fuel_code == fuel_codes_lockup(fuels);

            if fuel_codes_lockup(fuels) == 2 % Diesel
                vehicle_life_cycle_emissions_gco2eq_per_km(binary_this_fuel) = par_diesel(1).*(vehicle_weight(binary_this_fuel)).^2 ...
                    + par_diesel(2).*vehicle_weight(binary_this_fuel) + par_diesel(3);
            elseif fuel_codes_lockup(fuels) == 1 % Gasoline
                vehicle_life_cycle_emissions_gco2eq_per_km(binary_this_fuel) = par_gasoline(1).*(vehicle_weight(binary_this_fuel)).^2 ...
                    + par_gasoline(2).*vehicle_weight(binary_this_fuel) + par_gasoline(3);
            elseif fuel_codes_lockup(fuels) == 8 % Diesel hybrid
                vehicle_life_cycle_emissions_gco2eq_per_km(binary_this_fuel) = par_diesel_phev_renew(1).*(vehicle_weight(binary_this_fuel)).^2 ...
                    + par_diesel_phev_renew(2).*vehicle_weight(binary_this_fuel) + par_diesel_phev_renew(3);
            elseif fuel_codes_lockup(fuels) == 7 % Gasoline hybrid
                vehicle_life_cycle_emissions_gco2eq_per_km(binary_this_fuel) = par_gasoline_phev_renew(1).*(vehicle_weight(binary_this_fuel)).^2 ...
                    + par_gasoline_phev_renew(2).*vehicle_weight(binary_this_fuel) + par_gasoline_phev_renew(3);
            elseif fuel_codes_lockup(fuels) == 5 % Battery electric vehicle
                vehicle_life_cycle_emissions_gco2eq_per_km(binary_this_fuel) = par_bev_renew(1).*(vehicle_weight(binary_this_fuel)).^2 ...
                    + par_bev_renew(2).*vehicle_weight(binary_this_fuel) + par_bev_renew(3);
            elseif fuel_codes_lockup(fuels) == 6 % Hydrogen
                vehicle_life_cycle_emissions_gco2eq_per_km(binary_this_fuel) = 19740/220; % ASSUMED EQUAL TO TOYOTA MIRAI
            elseif fuel_codes_lockup(fuels) == 4 % GAS, assumed biogas
                vehicle_life_cycle_emissions_gco2eq_per_km(binary_this_fuel) = par_cbg(1).*(vehicle_weight(binary_this_fuel)).^2 ...
                    + par_cbg(2).*vehicle_weight(binary_this_fuel) + par_cbg(3);
            else % ASSUMED GASOLINE
                vehicle_life_cycle_emissions_gco2eq_per_km(binary_this_fuel) = par_gasoline(1).*(vehicle_weight(binary_this_fuel)).^2 ...
                    + par_gasoline(2).*vehicle_weight(binary_this_fuel) + par_gasoline(3);
            end

        end

    end

    %% Etablish structure
    OS = OverallStructure;
    OS.MunicipalArray(1:n_municipalities) = Municipality;

    %% Make vehicle arrays, municipal level
end


year_now = 2023;

for i = 1:n_municipalities
    binary_vehicles = vehicle_municipality == municipal_ids_vec(i);
    OS.MunicipalArray(i).VehicleArray(1:sum(binary_vehicles)) = Vehicle;
    c=1;
    %         for vh = 1:length(binary_vehicles)
    %             if binary_vehicles(vh) == 1
    %                 OS.MunicipalArray(i).VehicleArray(c).weight_kg = vehicle_weight(vh);
    %                 OS.MunicipalArray(i).VehicleArray(c).fuel_id = fuel_code(vh);
    %                 OS.MunicipalArray(i).VehicleArray(c).year_reg = vehicle_year(vh);
    %                 %OS.MunicipalArray(i).VehicleArray(c).fuel_string = fuel_strings{vh};
    %
    %
    %                 c=c+1;
    %             end
    %         end
    OS.MunicipalArray(i).id = municipal_ids_vec(i);
    OS.MunicipalArray(i).name = lockup_municipal{i,1};
    OS.MunicipalArray(i).vehicle_weight = vehicle_weight(binary_vehicles);
    OS.MunicipalArray(i).vehicle_year_reg = vehicle_year(binary_vehicles);
    OS.MunicipalArray(i).vehicle_fuel_code = fuel_code(binary_vehicles);

    vehicle_life_cycle_emissions_gco2eq_per_km_this = zeros(length(OS.MunicipalArray(i).vehicle_weight),1);

    for fuels = 1:length(fuel_codes_lockup)
        binary_this_fuel = OS.MunicipalArray(i).vehicle_fuel_code == fuel_codes_lockup(fuels);

        if fuel_codes_lockup(fuels) == 2 % Diesel
            vehicle_life_cycle_emissions_gco2eq_per_km_this(binary_this_fuel) = par_diesel(1).*(OS.MunicipalArray(i).vehicle_weight(binary_this_fuel)).^2 ...
                + par_diesel(2).*OS.MunicipalArray(i).vehicle_weight(binary_this_fuel) + par_diesel(3);
        elseif fuel_codes_lockup(fuels) == 1 % Gasoline
            vehicle_life_cycle_emissions_gco2eq_per_km_this(binary_this_fuel) = par_gasoline(1).*(OS.MunicipalArray(i).vehicle_weight(binary_this_fuel)).^2 ...
                + par_gasoline(2).*OS.MunicipalArray(i).vehicle_weight(binary_this_fuel) + par_gasoline(3);
        elseif fuel_codes_lockup(fuels) == 8 % Diesel hybrid
            vehicle_life_cycle_emissions_gco2eq_per_km_this(binary_this_fuel) = par_diesel_phev_renew(1).*(OS.MunicipalArray(i).vehicle_weight(binary_this_fuel)).^2 ...
                + par_diesel_phev_renew(2).*OS.MunicipalArray(i).vehicle_weight(binary_this_fuel) + par_diesel_phev_renew(3);
        elseif fuel_codes_lockup(fuels) == 7 % Gasoline hybrid
            vehicle_life_cycle_emissions_gco2eq_per_km_this(binary_this_fuel) = par_gasoline_phev_renew(1).*(OS.MunicipalArray(i).vehicle_weight(binary_this_fuel)).^2 ...
                + par_gasoline_phev_renew(2).*OS.MunicipalArray(i).vehicle_weight(binary_this_fuel) + par_gasoline_phev_renew(3);
        elseif fuel_codes_lockup(fuels) == 5 % Battery electric vehicle
            vehicle_life_cycle_emissions_gco2eq_per_km_this(binary_this_fuel) = par_bev_renew(1).*(OS.MunicipalArray(i).vehicle_weight(binary_this_fuel)).^2 ...
                + par_bev_renew(2).*OS.MunicipalArray(i).vehicle_weight(binary_this_fuel) + par_bev_renew(3);
        elseif fuel_codes_lockup(fuels) == 6 % Hydrogen
            vehicle_life_cycle_emissions_gco2eq_per_km_this(binary_this_fuel) = 19740/220; % ASSUMED EQUAL TO TOYOTA MIRAI
        elseif fuel_codes_lockup(fuels) == 4 % GAS, assumed biogas
            vehicle_life_cycle_emissions_gco2eq_per_km_this(binary_this_fuel) = par_cbg(1).*(OS.MunicipalArray(i).vehicle_weight(binary_this_fuel)).^2 ...
                + par_cbg(2).*OS.MunicipalArray(i).vehicle_weight(binary_this_fuel) + par_cbg(3);
        else % ASSUMED GASOLINE
            vehicle_life_cycle_emissions_gco2eq_per_km_this(binary_this_fuel) = par_gasoline(1).*(OS.MunicipalArray(i).vehicle_weight(binary_this_fuel)).^2 ...
                + par_gasoline(2).*OS.MunicipalArray(i).vehicle_weight(binary_this_fuel) + par_gasoline(3);
        end

    end

    OS.MunicipalArray(i).vehicle_life_cycle_emissions_gco2eq_per_km = vehicle_life_cycle_emissions_gco2eq_per_km_this;
    OS.MunicipalArray(i).total_lca_emissions_tco2eq = 10^-6*sum(OS.MunicipalArray(i).vehicle_life_cycle_emissions_gco2eq_per_km.*OS.MunicipalArray(i).vehicle_lifetime_km);

end

file_pop = 'input/Population_projections_municipal.xlsx';
OS = OS.get_pop_projections_municipal(file_pop);


OS.lat_5arcmin = lat;
OS.lon_5arcmin = lon;
OS.municipality_ids_5arcmin = municipal_ids_5arcmin;

for i = 1:n_municipalities
    OS.MunicipalArray(i).total_lca_emissions_per_capita_tco2eq_per_cap = OS.MunicipalArray(i).total_lca_emissions_tco2eq/OS.MunicipalArray(i).population_projection_tot(1);
    OS.MunicipalArray(i).total_annual_lca_emissions_per_capita_tco2eq_per_cap_yr = OS.MunicipalArray(i).total_lca_emissions_per_capita_tco2eq_per_cap/OS.MunicipalArray(i).vehicle_lifetime_yrs;

    n_cars = length(OS.MunicipalArray(i).vehicle_fuel_code);

    OS.MunicipalArray(i).vehicle_is_fossil = OS.MunicipalArray(i).vehicle_fuel_code == 2;
    OS.MunicipalArray(i).vehicle_is_fossil(OS.MunicipalArray(i).vehicle_fuel_code == 1) = true;

    OS.MunicipalArray(i).vehicle_is_hybrid =OS.MunicipalArray(i).vehicle_fuel_code == 8;
    OS.MunicipalArray(i).vehicle_is_hybrid(OS.MunicipalArray(i).vehicle_fuel_code == 7) = true;

    OS.MunicipalArray(i).vehicle_is_electric =OS.MunicipalArray(i).vehicle_fuel_code == 5;

    OS.MunicipalArray(i).vehicle_is_other = true(1,length(OS.MunicipalArray(i).vehicle_fuel_code));
    OS.MunicipalArray(i).vehicle_is_other(OS.MunicipalArray(i).vehicle_is_fossil) = false;
    OS.MunicipalArray(i).vehicle_is_other(OS.MunicipalArray(i).vehicle_is_hybrid) = false;
    OS.MunicipalArray(i).vehicle_is_other(OS.MunicipalArray(i).vehicle_is_electric) = false;

    OS.MunicipalArray(i).fossil_share = sum(OS.MunicipalArray(i).vehicle_is_fossil)/n_cars;
    OS.MunicipalArray(i).electrification_share = sum(OS.MunicipalArray(i).vehicle_is_electric)/n_cars;
    OS.MunicipalArray(i).hybrid_share = sum(OS.MunicipalArray(i).vehicle_is_hybrid)/n_cars;
    OS.MunicipalArray(i).other_share = sum(OS.MunicipalArray(i).vehicle_is_other)/n_cars;

end

%% Calc weight distribution of most common models
n_top_vehicles_to_consider = 20;

headers = {'model_name','model_id','fuel_name', 'fuel_code', 'n_vehicles','mean_weigth', 'std_weigth', 'min_weight', 'max_weight',...
    'mean_age','mean_gCO2eq_per_km','std_gCO2eq_per_km','max_gCO2eq_per_km', 'min_gCO2eq_per_km'};
out_matrix = cell(n_top_vehicles_to_consider+1, length(headers));
out_matrix(1,:) = headers;

fuel_ids = lockup_fuel{:,2};

c=2;
for i = 1:n_top_vehicles_to_consider
    
    id_this = idx_vehicles_sorted_after_most_popular_model(i);
    binary_this_id = vehicle_model_id == id_this;
    vehicle_weight_this = vehicle_weight(binary_this_id);
    vehicle_fuel_code_this = fuel_code(binary_this_id);
    vehicle_lca_emissions_gCO2eq_per_km_this = vehicle_life_cycle_emissions_gco2eq_per_km(binary_this_id);
    vehicle_year_this = vehicle_year(binary_this_id);
    model_name = lockup_vehicle_models{id_this,1};
    

    unique_fuel_codes_this = unique(vehicle_fuel_code_this);
    for j = 1:length(unique_fuel_codes_this)
        
        fuel_idx_this = find(fuel_ids == unique_fuel_codes_this(j));
        fuel_string = lockup_fuel{fuel_idx_this,1};

        binary_this_fuel =  vehicle_fuel_code_this ==   unique_fuel_codes_this(j);
        
        out_matrix{c,1} = model_name{:};
        out_matrix{c,2} = id_this;
        out_matrix{c,3} = fuel_string{:};
        out_matrix{c,4} = unique_fuel_codes_this(j);
        out_matrix{c,5} = sum(binary_this_fuel);
        out_matrix{c,6} = mean(vehicle_weight_this(binary_this_fuel));
        out_matrix{c,7} = std(vehicle_weight_this(binary_this_fuel));
        out_matrix{c,8} = min(vehicle_weight_this(binary_this_fuel));
        out_matrix{c,9} = max(vehicle_weight_this(binary_this_fuel));
        out_matrix{c,10} = round(mean(vehicle_year_this(binary_this_fuel)));
        out_matrix{c,11} = mean(vehicle_lca_emissions_gCO2eq_per_km_this(binary_this_fuel));
        out_matrix{c,12} = std(vehicle_lca_emissions_gCO2eq_per_km_this(binary_this_fuel));
        out_matrix{c,13} = max(vehicle_lca_emissions_gCO2eq_per_km_this(binary_this_fuel));
        out_matrix{c,14} = min(vehicle_lca_emissions_gCO2eq_per_km_this(binary_this_fuel));
        c=c+1;
    end
end

outfile = 'Output/Vehicle_model_results.xlsx';
if exist(outfile, 'file')
    delete(outfile)
end

%out_matrix_mat = cell2mat(out_matrix);


writecell(out_matrix, outfile);





toc


