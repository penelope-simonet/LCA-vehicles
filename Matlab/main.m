addpath(genpath(pwd()));

tic

import_grunnkrets = 0;


fprintf('importing lockup table \n');
filename_lockup = 'input/lockup_table.xlsx';

fprintf('importing vehicle data at "grunnkrets" level (GEODATA) \n')
ncid = netcdf.open('input/biler_anon_grunnkrets_v8.nc');

vehicle_age = netcdf.getVar(ncid,1);
vehicle_year = netcdf.getVar(ncid,4);
fuel_code = netcdf.getVar(ncid,6);
vehicle_weight = netcdf.getVar(ncid,7);
vehicle_municipality = netcdf.getVar(ncid,9);
vehicle_model_id = netcdf.getVar(ncid,5);
netcdf.close(ncid);

calc_unique_models = 0;
if calc_unique_models
    unique_vehicle_models = unique(vehicle_model_id);
    n_vehicles_per_unique_vehicle_model = zeros(1,length(unique_vehicle_models));
    for v = 1:length(unique_vehicle_models )
        n_vehicles_per_unique_vehicle_model(v) = sum(vehicle_model_id == unique_vehicle_models(v));
    end

    [n_vehicles_sorted_after_most_popular_model, idx_vehicles_sorted_after_most_popular_model] = sort(n_vehicles_per_unique_vehicle_model, 'descend');
end


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

%% Etablish structure
OS = OverallStructure;
OS.MunicipalArray(1:n_municipalities) = Municipality;


year_now = 2023;

fprintf('Assigning individual cars to municipalities. \n')

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

end

file_pop = 'input/Population_projections_municipal.xlsx';
OS = OS.get_pop_projections_municipal(file_pop);


OS.lat_5arcmin = lat;
OS.lon_5arcmin = lon;
OS.municipality_ids_5arcmin = municipal_ids_5arcmin;

for i = 1:n_municipalities
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

%% Get vehicle archetypes
OS.VehicleArchetypeArray =  get_vehicle_archetypes();
OS.MidpointImpactArray = get_midpoint_categories();
OS.EndpointImpactArray = get_endpoint_categories();


%% Getting data from Rousseau et al.

fprintf(['Importing car data from Rousseau et al. \n'])

% Dataset 1
filename = 'input/Rousseau_dataset_1.xlsx';
T_R1 = readtable(filename, Sheet='Sheet1');
cell_municipalities = T_R1{:,2};
unique_cell_municipalities = unique(cell_municipalities);

municipal_ids_rousseau = zeros(1,length(cell_municipalities));
unique_municipal_ids_rousseau = zeros(1,length(unique_cell_municipalities));

for i = 1:length(municipal_ids_rousseau)
    this = cell_municipalities{i};
    municipal_ids_rousseau(i) = str2double(this(1:4));
end

for i = 1:length(unique_municipal_ids_rousseau)
    this = unique_cell_municipalities{i};
    unique_municipal_ids_rousseau(i) = str2double(this(1:4));
end

% Dataset 2
filename = 'input/Rousseau_dataset_2.xlsx';
T_R2 = readtable(filename, Sheet='Sheet1');

time_hybrid = [2016:1:2024];

% REF: https://www.ssb.no/statbank/table/11823/tableViewLayout1/?loadedQueryId=10101968&timeType=item
hev_g = [55483	76070	92144	108971	123489	136052	146007	150949	157280];
hev_d = 	[1058	1107	1192	1722	2494	3306	3892	4070	4220];

phev_g = [32251	62580	89657	108575	137310	173917	187758	195776	196976];
phev_d = [2180	4735	6476	7467	8843	10586	11083	11245	11192];

share_hev_g_plugin = phev_g./(hev_g+phev_g);
share_hev_d_plugin = phev_d./(hev_d+phev_d);
share_hev_g_no_plugin = 1-share_hev_g_plugin;
share_hev_d_no_plugin = 1-share_hev_d_plugin;

% Dataset 3
filename = 'input/Rousseau_dataset_3.xlsx';
T_R3 = readtable(filename, Sheet='Sheet1');
size_TR3 = size(T_R3);

T_R3_years_state =  T_R3{:,1};
T_R3_muni_cat = T_R3{:,2};
T_R3_fuel = T_R3{:,3};
T_R3_first_reg_year = T_R3{:,4};
T_R3_weight_category = T_R3{:,5};
T_R3_number_of_cars = T_R3{:,6};




%% Set states

years = [2000:1:2023];
OS.State(1:length(years)) = State;

assigned_cars = 0;

for i = 1:length(years)
    OS.State(i).year = years(i);
    years_this = T_R3_years_state == OS.State(i).year;


    OS.State(i).VehicleArchetype = get_vehicle_archetypes();
    OS.State(i).Midpoint_impacts = get_midpoint_categories();
    OS.State(i).Endpoint_impacts = get_endpoint_categories();
    OS.State(i).Midpoint_impacts_new_cars= get_midpoint_categories();
    OS.State(i).Endpoint_impacts_new_cars= get_endpoint_categories();

    % Fill archetype stock data

    for at = 1:length(OS.State(i).VehicleArchetype)
        OS.State(i).VehicleArchetype(at).year_state = OS.State(i).year;
        OS.State(i).VehicleArchetype(at).year_cars_produced = [1999:1:OS.State(i).year];

        % preallocation
        prealloc_vec = zeros(1,length(OS.State(i).VehicleArchetype(at).year_cars_produced));

        OS.State(i).VehicleArchetype(at).number_of_cars_from_year = prealloc_vec;
        OS.State(i).VehicleArchetype(at).number_of_cars_from_year_mun_sub5k = prealloc_vec;
        OS.State(i).VehicleArchetype(at).number_of_cars_from_year_mun_5k_10k = prealloc_vec;
        OS.State(i).VehicleArchetype(at).number_of_cars_from_year_mun_10k_20k = prealloc_vec;
        OS.State(i).VehicleArchetype(at).number_of_cars_from_year_mun_20k_50k = prealloc_vec;
        OS.State(i).VehicleArchetype(at).number_of_cars_from_year_mun_50k_plus = prealloc_vec;
        OS.State(i).VehicleArchetype(at).number_of_cars_from_year_Trondheim = prealloc_vec;
        OS.State(i).VehicleArchetype(at).number_of_cars_from_year_Bergen = prealloc_vec;
        OS.State(i).VehicleArchetype(at).number_of_cars_from_year_Oslo = prealloc_vec;
        OS.State(i).VehicleArchetype(at).number_of_cars_from_year_unknown = prealloc_vec;

        powertrain_this = strcmp(OS.State(i).VehicleArchetype(at).powertrain_Rousseau_string, T_R3_fuel);
        weight_category_this = strcmp(OS.State(i).VehicleArchetype(at).size, T_R3_weight_category);

        binary_this = years_this & powertrain_this & weight_category_this;

        muni_cat_this = T_R3_muni_cat(binary_this);
        number_this = T_R3_number_of_cars(binary_this);
        first_reg_this = T_R3_first_reg_year(binary_this);

        pos = -1;
        for dp = 1:length(muni_cat_this)
            % Find correct position in vector
            for t = 1:length(OS.State(i).VehicleArchetype(at).year_cars_produced)
                if first_reg_this(dp) == OS.State(i).VehicleArchetype(at).year_cars_produced(t)
                    pos = t;
                    break
                end
            end

            if pos == -1
                error('Error: could not identify correct year of production')
            end

            % assign cars
            if strcmp(muni_cat_this{dp}, 'less than 5000')
                OS.State(i).VehicleArchetype(at).number_of_cars_from_year_mun_sub5k(pos) = number_this(dp);
            elseif strcmp(muni_cat_this{dp}, '5000 to 10000')
                OS.State(i).VehicleArchetype(at).number_of_cars_from_year_mun_5k_10k(pos) = number_this(dp);
            elseif strcmp(muni_cat_this{dp}, '10000 to 20000')
                OS.State(i).VehicleArchetype(at).number_of_cars_from_year_mun_10k_20k(pos) = number_this(dp);
                assigned_cars = assigned_cars+number_this(dp);
            elseif strcmp(muni_cat_this{dp}, '20000 to 50000')
                OS.State(i).VehicleArchetype(at).number_of_cars_from_year_mun_20k_50k(pos) = number_this(dp);
            elseif strcmp(muni_cat_this{dp}, 'more than 50000 excl Oslo, Bergen, Trondheim')
                OS.State(i).VehicleArchetype(at).number_of_cars_from_year_mun_50k_plus(pos) = number_this(dp);
            elseif strcmp(muni_cat_this{dp}, 'Trondheim')
                OS.State(i).VehicleArchetype(at).number_of_cars_from_year_Trondheim(pos) = number_this(dp);
            elseif strcmp(muni_cat_this{dp}, 'Oslo')
                OS.State(i).VehicleArchetype(at).number_of_cars_from_year_Oslo(pos) = number_this(dp);
            elseif strcmp(muni_cat_this{dp}, 'Bergen')
                OS.State(i).VehicleArchetype(at).number_of_cars_from_year_Bergen(pos) = number_this(dp);
            elseif strcmp(muni_cat_this{dp}, 'SYSMISS')
                OS.State(i).VehicleArchetype(at).number_of_cars_from_year_unknown(pos) = number_this(dp);
            else
                % fprintf('Could not find municipality category. \n');

            end


        end % for dp


        % Adjust hybrid cars based on shares of plugin / non plugin
        if OS.State(i).VehicleArchetype(at).is_hybrid == 1
            if strcmp(OS.State(i).VehicleArchetype(at).powertrain, 'HEV-d')
                actual_share = share_hev_d_no_plugin;
            elseif strcmp(OS.State(i).VehicleArchetype(at).powertrain, 'HEV-p')
                actual_share = share_hev_g_no_plugin;
            elseif strcmp(OS.State(i).VehicleArchetype(at).powertrain, 'PHEV-d')
                actual_share = share_hev_d_plugin;
            elseif strcmp(OS.State(i).VehicleArchetype(at).powertrain, 'PHEV-p')
                actual_share = share_hev_g_plugin;
            end

            share_vec = ones(1,length(OS.State(i).VehicleArchetype(at).year_cars_produced));

            for p = 1:length(share_vec)
                for q = 1:length(time_hybrid)
                    if OS.State(i).VehicleArchetype(at).year_cars_produced(p) == time_hybrid(q)
                        share_vec(p) = actual_share(q);
                    end

                    if q == 1
                        value_to_backfill = actual_share(q);
                        year_to_backfill_from = time_hybrid(q);
                        for p2 = 1:length(share_vec)
                            if OS.State(i).VehicleArchetype(at).year_cars_produced(p2) < year_to_backfill_from
                                share_vec(p2) = value_to_backfill;
                            end
                        end % for p2 share_Vec
                    end % if q==1

                end % for q time hybrid
            end % for p share_vec

            


            OS.State(i).VehicleArchetype(at).number_of_cars_from_year_mun_sub5k =  OS.State(i).VehicleArchetype(at).number_of_cars_from_year_mun_sub5k.*share_vec;
            OS.State(i).VehicleArchetype(at).number_of_cars_from_year_mun_5k_10k = OS.State(i).VehicleArchetype(at).number_of_cars_from_year_mun_5k_10k.*share_vec;
            OS.State(i).VehicleArchetype(at).number_of_cars_from_year_mun_10k_20k = OS.State(i).VehicleArchetype(at).number_of_cars_from_year_mun_10k_20k.*share_vec;
            OS.State(i).VehicleArchetype(at).number_of_cars_from_year_mun_20k_50k=  OS.State(i).VehicleArchetype(at).number_of_cars_from_year_mun_20k_50k.*share_vec;
            OS.State(i).VehicleArchetype(at).number_of_cars_from_year_mun_50k_plus = OS.State(i).VehicleArchetype(at).number_of_cars_from_year_mun_50k_plus.*share_vec;
            OS.State(i).VehicleArchetype(at).number_of_cars_from_year_Trondheim = OS.State(i).VehicleArchetype(at).number_of_cars_from_year_Trondheim.*share_vec;
            OS.State(i).VehicleArchetype(at).number_of_cars_from_year_Bergen =  OS.State(i).VehicleArchetype(at).number_of_cars_from_year_Bergen.*share_vec;
            OS.State(i).VehicleArchetype(at).number_of_cars_from_year_Oslo =  OS.State(i).VehicleArchetype(at).number_of_cars_from_year_Oslo.*share_vec;
            OS.State(i).VehicleArchetype(at).number_of_cars_from_year_unknown = OS.State(i).VehicleArchetype(at).number_of_cars_from_year_unknown.*share_vec;

        end % if hybrid


        % Calc total cars in archetype
        OS.State(i).VehicleArchetype(at).number_of_cars_from_year = OS.State(i).VehicleArchetype(at).number_of_cars_from_year_mun_sub5k + ...
            OS.State(i).VehicleArchetype(at).number_of_cars_from_year_mun_5k_10k + ...
            OS.State(i).VehicleArchetype(at).number_of_cars_from_year_mun_10k_20k + ...
            OS.State(i).VehicleArchetype(at).number_of_cars_from_year_mun_20k_50k + ...
            OS.State(i).VehicleArchetype(at).number_of_cars_from_year_mun_50k_plus + ...
            OS.State(i).VehicleArchetype(at).number_of_cars_from_year_Trondheim + ...
            OS.State(i).VehicleArchetype(at).number_of_cars_from_year_Bergen + ...
            OS.State(i).VehicleArchetype(at).number_of_cars_from_year_Oslo + ...
            OS.State(i).VehicleArchetype(at).number_of_cars_from_year_unknown;


    end % for at - archetype

    if i == 24
        OS.State(i).VehicleArchetype(at)
    end

end % for i years

%% Importing Carculator data
%tic
fprintf('Importing Carculator data \n');

n_scens = 3;
scenarios = {'SSP2-NPi', 'SSP2-PkBudg1150', 'SSP2-PkBudg500'};

% Dataset SSP2-NPi
filename = 'input/carculator_results_SSP2-NPi_NOR_WLTC.csv';
T_SSP2_NPi_midpoint = readtable(filename);

filename = 'input/carculator_results_SSP2-NPi_NOR_WLTC_endpoint.csv';
T_SSP2_NPi_endpoint = readtable(filename);

% Dataset SSP2-PkBudg1150
filename = 'input/carculator_results_SSP2-PkBudg1150_NOR_WLTC.csv';
T_SSP2_PkBudg1150_midpoint = readtable(filename);

filename = 'input/carculator_results_SSP2-SSP2-PkBudg1150_NOR_WLTC_endpoint.csv';
T_SSP2_PkBudg1150_endpoint = readtable(filename);

% Dataset SSP2-PkBudg500
filename = 'input/carculator_results_SSP2-PkBudg500_NOR_WLTC.csv';
T_SSP2_PkBudg500_midpoint = readtable(filename);

filename = 'input/carculator_results_SSP2-SSP2-PkBudg500_NOR_WLTC_endpoint.csv';
T_SSP2_PkBudg500_endpoint = readtable(filename);



%% Set up impact arrays per vehicle archetype
for i = 1:length(OS.State)
    for j = 1:length(OS.State(i).VehicleArchetype)
        OS.State(i).VehicleArchetype(j).Midpoint_impacts_SSP2_NPi = get_midpoint_categories();
        OS.State(i).VehicleArchetype(j).Endpoint_impacts_SSP2_NPi = get_endpoint_categories();

        OS.State(i).VehicleArchetype(j).Midpoint_impacts_SSP2_PkBudg1150 = get_midpoint_categories();
        OS.State(i).VehicleArchetype(j).Endpoint_impacts_SSP2_PkBudg1150 = get_endpoint_categories();

        OS.State(i).VehicleArchetype(j).Midpoint_impacts_SSP2_PkBudg500 = get_midpoint_categories();
        OS.State(i).VehicleArchetype(j).Endpoint_impacts_SSP2_PkBudg500 = get_endpoint_categories();

        % preallocate
        OS.State(i).VehicleArchetype(j) = OS.State(i).VehicleArchetype(j).preallocate_impact_vecs();

        %         if i == 1
        %             OS.VehicleArchetypeArray(j).Midpoint_impacts = get_midpoint_categories();
        %             OS.VehicleArchetypeArray(j).Endpoint_impacts = get_endpoint_categories();
        %         end
    end
end

%%
Midpoint_impacts_SSP2_NPi = get_midpoint_categories();
Endpoint_impacts_SSP2_NPi = get_endpoint_categories();
%
%
%
% midtpoint_strings = {Midpoint_impacts_SSP2_NPi.name};
% midpoint_ids = {Midpoint_impacts_SSP2_NPi.id};
%
% endpoint_strings = {Endpoint_impacts_SSP2_NPi.name};
% endpoint_ids = {Endpoint_impacts_SSP2_NPi.id};
%
% size_midpoint = size(T_SSP2_NPi_midpoint);
% size_endpoint = size(T_SSP2_NPi_endpoint);
%
% T_SSP2_NPi_midpoint_id = zeros(1,size_midpoint(1));
% T_SSP2_NPi_endpoint_id = zeros(1,size_endpoint(1));
%
% for i = 1:length(T_SSP2_NPi_midpoint_id)
%     for j = 1:length(midtpoint_strings)
%         if strcmp(midtpoint_strings{j},T_SSP2_NPi_midpoint{i,1})
%             T_SSP2_NPi_midpoint_id(i) = midpoint_ids(j);
%         end
%     end
%
% end

fprintf('Mapping impact data.. \n')

% --- Reference lists (objects/structs -> vectors) ---
refNames_mid = string({Midpoint_impacts_SSP2_NPi.name});
refIDs_mid   = [Midpoint_impacts_SSP2_NPi.id];

refNames_end = string({Endpoint_impacts_SSP2_NPi.name});
refIDs_end   = [Endpoint_impacts_SSP2_NPi.id];

% --- Query names from your tables/cell arrays ---
% If these are tables, use {:,1}; if they’re cell arrays, this still works.
qMid = string(T_SSP2_NPi_midpoint{:,1});
qEnd = string(T_SSP2_NPi_endpoint{:,1});

% --- Fast mapping via ismember ---
[tfM, locM] = ismember(qMid, refNames_mid);
[tfE, locE] = ismember(qEnd, refNames_end);

T_SSP2_NPi_midpoint_id = nan(numel(qMid),1);
T_SSP2_NPi_endpoint_id = nan(numel(qEnd),1);

T_SSP2_NPi_midpoint_id(tfM) = refIDs_mid(locM(tfM));
T_SSP2_NPi_endpoint_id(tfE) = refIDs_end(locE(tfE));

%% Vehicle sizes
refNames_size = string({OS.VehicleArchetypeArray.size});
refNames_powertrain = string({OS.VehicleArchetypeArray.powertrain});
refIDs_archetype = string({OS.VehicleArchetypeArray.id_archetype});


% Get strings of size/powertrain from tables
qSize_mid = string(T_SSP2_NPi_midpoint{:,2});
qSize_end = string(T_SSP2_NPi_endpoint{:,2});
qPt_mid = string(T_SSP2_NPi_midpoint{:,3});
qPt_end = string(T_SSP2_NPi_endpoint{:,3});

% map via ismember
%[binary_]




%% Vehicle sizes / powertrains → IDs (fast, vectorized)

% --- Reference lists from your archetype catalog ---
refNames_size       = string({OS.VehicleArchetypeArray.size});
refNames_powertrain = string({OS.VehicleArchetypeArray.powertrain});
refIDs_archetype    = [OS.VehicleArchetypeArray.id_archetype];   % numeric

% Optional: normalize (lower + trim) to avoid case/space mismatches
norm = @(s) lower(strtrim(string(s)));
refNames_size_n       = norm(refNames_size);
refNames_powertrain_n = norm(refNames_powertrain);

% --- Queries from tables ---
qSize_mid = norm(T_SSP2_NPi_midpoint{:,2});
qSize_end = norm(T_SSP2_NPi_endpoint{:,2});
qPt_mid   = norm(T_SSP2_NPi_midpoint{:,3});
qPt_end   = norm(T_SSP2_NPi_endpoint{:,3});

% --- Individual mappings (size / powertrain IDs) ---
[tfS_mid, locS_mid] = ismember(qSize_mid, refNames_size_n);
[tfS_end, locS_end] = ismember(qSize_end, refNames_size_n);

[tfP_mid, locP_mid] = ismember(qPt_mid,   refNames_powertrain_n);
[tfP_end, locP_end] = ismember(qPt_end,   refNames_powertrain_n);

SizeID_mid       = nan(numel(qSize_mid),1);
SizeID_end       = nan(numel(qSize_end),1);
PowertrainID_mid = nan(numel(qPt_mid),1);
PowertrainID_end = nan(numel(qPt_end),1);

SizeID_mid(tfS_mid)         = locS_mid(tfS_mid);
SizeID_end(tfS_end)         = locS_end(tfS_end);
PowertrainID_mid(tfP_mid)   = locP_mid(tfP_mid);
PowertrainID_end(tfP_end)   = locP_end(tfP_end);

% --- Direct Archetype ID by composite (size|powertrain) ---
% Build composite keys for the reference catalog and the queries
refKey = refNames_size_n + "|" + refNames_powertrain_n;

qKey_mid = qSize_mid + "|" + qPt_mid;
qKey_end = qSize_end + "|" + qPt_end;

[tfA_mid, locA_mid] = ismember(qKey_mid, refKey);
[tfA_end, locA_end] = ismember(qKey_end, refKey);

ArchetypeID_mid = nan(numel(qKey_mid),1);
ArchetypeID_end = nan(numel(qKey_end),1);

ArchetypeID_mid(tfA_mid) = refIDs_archetype(locA_mid(tfA_mid));
ArchetypeID_end(tfA_end) = refIDs_archetype(locA_end(tfA_end));

% --- (Optional) quick diagnostics ---
if any(~tfA_mid),  warning('Unmatched mid archetype keys: %s', strjoin(unique(qKey_mid(~tfA_mid)))); end
if any(~tfA_end),  warning('Unmatched end archetype keys: %s', strjoin(unique(qKey_end(~tfA_end)))); end

%% Impact contributors

% refEmCont = unique(string(T_SSP2_NPi_midpoint{:,5}));
% refId_EmCont = 1:1:length(refEmCont);
%
% %query from table
% qEmCont_mid = string(T_SSP2_NPi_midpoint{:,5});
% qEmCont_end = string(T_SSP2_NPi_endpoint{:,5});

%%%

% --- Build canonical list from the data (mid + end to be safe) ---
norm = @(s) lower(strtrim(regexprep( ...
    replace(replace(string(s), ["–","—","−"], "-"), "  ", " "), '\s+', ' ')));

allContrib = [ T_SSP2_NPi_midpoint{:,5} ; T_SSP2_NPi_endpoint{:,5} ];
refEmCont  = unique(norm(allContrib), 'stable');   % canonical, normalized order
refId_EmCont = (1:numel(refEmCont)).';             % numeric ids

% --- Query from tables (normalized) ---
qEmCont_mid = norm(T_SSP2_NPi_midpoint{:,5});
qEmCont_end = norm(T_SSP2_NPi_endpoint{:,5});

% --- Map via ismember ---
[tfM, locM] = ismember(qEmCont_mid, refEmCont);
[tfE, locE] = ismember(qEmCont_end, refEmCont);

EmContID_mid = nan(numel(qEmCont_mid),1);
EmContID_end = nan(numel(qEmCont_end),1);

EmContID_mid(tfM) = refId_EmCont(locM(tfM));
EmContID_end(tfE) = refId_EmCont(locE(tfE));

% --- Optional diagnostics ---
if any(~tfM), warning('Unmatched midpoint contributors: %s', strjoin(unique(qEmCont_mid(~tfM)))); end
if any(~tfE), warning('Unmatched endpoint contributors: %s', strjoin(unique(qEmCont_end(~tfE)))); end


%% NEW ATTEMPT


%% --- Pre-sliced columns (all numeric/strings already built earlier) ---
ar_mid  = ArchetypeID_mid;            % n×1 double
cat_mid = T_SSP2_NPi_midpoint_id;     % n×1 double (midpoint category id)
con_mid = EmContID_mid;               % n×1 uint8/double (contributor id 1..9)
yr_mid  = T_SSP2_NPi_midpoint{:,4};   % n×1 double/int
val_mid = T_SSP2_NPi_midpoint{:,7};   % n×1 double

ar_end  = ArchetypeID_end;
cat_end = T_SSP2_NPi_endpoint_id;
yr_end  = T_SSP2_NPi_endpoint{:,4};
val_end = T_SSP2_NPi_endpoint{:,7};

% contributor id -> field name (keep your encoding!)
midFields = { ...
    'value_glider','value_powertrain','value_energy_storage','value_energy_chain',...
    'value_maintenance','value_EoL','value_road','value_direct_non_exhaust','value_direct_exhaust'};

%% --- Speed: group rows by archetype once (contiguous blocks) ---
% (Sorting avoids building a logical mask for every vehicle.)

tic
[ar_mid_s, ordM] = sort(ar_mid);
[ar_end_s, ordE] = sort(ar_end);

% Start/end indices for each archetype block
uMid = unique(ar_mid_s(~isnan(ar_mid_s)));
uEnd = unique(ar_end_s(~isnan(ar_end_s)));

% Optional: a fast map id_archetype -> (i,j) (build once before this loop)
% arIndex: containers.Map(double -> [i j])
%%

fprintf( 'Assigning impact data to arrays .. \n')

for i = 1:numel(OS.State)
    for j = 1:numel(OS.State(i).VehicleArchetype)
        v    = OS.State(i).VehicleArchetype(j);   % local copy (value class)
        arID = v.id_archetype;

        % -------- MIDPOINTS for this vehicle (batch) --------
        % Find contiguous block in sorted arrays (binary search via histcounts)
        if ~isempty(uMid) && any(uMid==arID)
            % locate block bounds
            k1 = find(ar_mid_s==arID, 1, 'first');
            k2 = find(ar_mid_s==arID, 1, 'last');
            rows = ordM(k1:k2);

            % Map years -> indices (vectorized)
            [tfY, yIdx] = ismember(yr_mid(rows), v.year_cars_produced(:).');

            % Map category ids -> local category indices (vectorized)
            idsLocal = [v.Midpoint_impacts_SSP2_NPi.id];
            [tfL, lIdx] = ismember(cat_mid(rows), idsLocal);

            % Valid rows only
            cIdx = con_mid(rows);
            ok = tfY & tfL & cIdx>=1 & cIdx<=numel(midFields) & ~isnan(cIdx);
            if any(ok)
                l   = lIdx(ok);
                m   = yIdx(ok);
                c   = cIdx(ok);
                val = val_mid(rows(ok));

                % Group by (category, contributor) and bulk-assign
                % Build a single uint64 key to avoid slow table/group overhead
                key = uint64(l) .* 10 + uint64(c);  % (since c in 1..9)
                [G,~,gIdx] = unique(key, 'stable');
                for g = 1:numel(G)
                    sel = (gIdx==g);
                    l0  = l(find(sel,1,'first'));
                    c0  = c(find(sel,1,'first'));
                    fld = midFields{c0};
                    % bulk write
                    v.Midpoint_impacts_SSP2_NPi(l0).(fld)(m(sel)) = val(sel);
                end
            end
        end

        % -------- ENDPOINTS for this vehicle (batch, with contributors) --------
        if ~isempty(uEnd) && any(uEnd==arID)
            k1 = find(ar_end_s==arID, 1, 'first');
            k2 = find(ar_end_s==arID, 1, 'last');
            rows = ordE(k1:k2);

            % Year mapping (exact match; switch to carry-forward if needed)
            [tfY, yIdx] = ismember(double(yr_end(rows)), double(v.year_cars_produced(:).'));

            % Category mapping
            idsLocalE   = [v.Endpoint_impacts_SSP2_NPi.id];
            [tfL, lIdx] = ismember(cat_end(rows), idsLocalE);

            % Contributor IDs for these rows
            cIdx = EmContID_end(rows);

            % Valid rows: year + category + contributor in range
            ok = tfY & tfL & cIdx>=1 & cIdx<=numel(midFields) & ~isnan(cIdx);
            if any(ok)
                l   = lIdx(ok);
                m   = yIdx(ok);
                c   = cIdx(ok);
                val = val_end(rows(ok));

                % Bulk-assign by (category, contributor)
                key = uint64(l)*10 + uint64(c);   % composite key
                [G,~,gIdx] = unique(key,'stable');
                for g = 1:numel(G)
                    sel = (gIdx==g);
                    l0  = l(find(sel,1,'first'));
                    c0  = c(find(sel,1,'first'));
                    fld = midFields{c0};   % e.g. 'value_glider'
                    v.Endpoint_impacts_SSP2_NPi(l0).(fld)(m(sel)) = val(sel);
                end
            end
        end


        % Single assign-back per vehicle
        OS.State(i).VehicleArchetype(j) = v;




    end
end

%%



%% Estimate total impacts per km
for i = 1:numel(OS.State)
    for j = 1:numel(OS.State(i).VehicleArchetype)
        for k = 1:length(OS.State(i).VehicleArchetype(j).Midpoint_impacts_SSP2_NPi)
            OS.State(i).VehicleArchetype(j).Midpoint_impacts_SSP2_NPi(k) = OS.State(i).VehicleArchetype(j).Midpoint_impacts_SSP2_NPi(k).calc_total_impacts();
            OS.State(i).VehicleArchetype(j).Midpoint_impacts_SSP2_NPi(k).time = OS.State(i).VehicleArchetype(j).year_cars_produced;
        end

        for k = 1:length(OS.State(i).VehicleArchetype(j).Endpoint_impacts_SSP2_NPi)
            OS.State(i).VehicleArchetype(j).Endpoint_impacts_SSP2_NPi(k) = OS.State(i).VehicleArchetype(j).Endpoint_impacts_SSP2_NPi(k).calc_total_impacts();
            OS.State(i).VehicleArchetype(j).Endpoint_impacts_SSP2_NPi(k).time = OS.State(i).VehicleArchetype(j).year_cars_produced;
        end
    end

end


%% Backfill data
fprintf('Backfilling impact data.. \n')
% Backfill last state, use afterwards as donor
for i = 1:length(OS.State(end).VehicleArchetype)
    OS.State(end).VehicleArchetype(i) = OS.State(end).VehicleArchetype(i).backfill_vectorized();
end


% Fill non-zero values based on previous years



for i = 1:numel(OS.State)
  for j = 1:numel(OS.State(i).VehicleArchetype)
    v = OS.State(i).VehicleArchetype(j);
    v_end = OS.State(end).VehicleArchetype(j);
    
    
    % Midpoints
    for k = 1:numel(v.Midpoint_impacts_SSP2_NPi)
      v.Midpoint_impacts_SSP2_NPi(k) = backfill_if_total_zero(v.Midpoint_impacts_SSP2_NPi(k),v_end.Midpoint_impacts_SSP2_NPi(k));
    end

    % Endpoints
    for k = 1:numel(v.Endpoint_impacts_SSP2_NPi)
      v.Endpoint_impacts_SSP2_NPi(k) = backfill_if_total_zero(v.Endpoint_impacts_SSP2_NPi(k),v_end.Endpoint_impacts_SSP2_NPi(k));
    end
    
    OS.State(i).VehicleArchetype(j) = v;
  end
end

% Estimate total impacts per km
for i = 1:numel(OS.State)
    for j = 1:numel(OS.State(i).VehicleArchetype)
        for k = 1:length(OS.State(i).VehicleArchetype(j).Midpoint_impacts_SSP2_NPi)
            OS.State(i).VehicleArchetype(j).Midpoint_impacts_SSP2_NPi(k) = OS.State(i).VehicleArchetype(j).Midpoint_impacts_SSP2_NPi(k).calc_total_impacts();
        end

        for k = 1:length(OS.State(i).VehicleArchetype(j).Endpoint_impacts_SSP2_NPi)
            OS.State(i).VehicleArchetype(j).Endpoint_impacts_SSP2_NPi(k) = OS.State(i).VehicleArchetype(j).Endpoint_impacts_SSP2_NPi(k).calc_total_impacts();
        end
    end

end

%% Calculating average impacts of driving for whole vehicle stock over time
tic
for i = 1:numel(OS.State)
OS.State(i) = OS.State(i).calc_average_impacts_of_driving();
end



toc