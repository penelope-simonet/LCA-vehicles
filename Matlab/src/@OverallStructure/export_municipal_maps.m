function export_municipal_maps(obj)

filename = 'Output/municipal_results.nc';
if exist(filename, 'file')
    delete(filename);
end

lon_bnds = [0 35];
lat_bnds = [57 72];

lat_5arcmin = obj.lat_5arcmin;
lon_5arcmin = obj.lon_5arcmin;

[~,idx_lat1] = min(abs(lat_5arcmin-lat_bnds(2)));
[~,idx_lat2] = min(abs(lat_5arcmin-lat_bnds(1)));
[~,idx_lon1] = min(abs(lon_5arcmin-lon_bnds(1)));
[~,idx_lon2] = min(abs(lon_5arcmin-lon_bnds(2)));

lon = lon_5arcmin(idx_lon1:idx_lon2);
lat = lat_5arcmin(idx_lat1:idx_lat2);

municipal_ids = obj.municipality_ids_5arcmin(idx_lon1:idx_lon2, idx_lat1:idx_lat2);
%Preallocation
vehicles = zeros(length(lon), length(lat));
vehicles_per_capita = zeros(length(lon), length(lat));
vehicle_weight_mean = zeros(length(lon), length(lat));
electrification_rate = zeros(length(lon), length(lat));
hybrid_rate = zeros(length(lon), length(lat));
fossil_rate = zeros(length(lon), length(lat));
life_cycle_emissions_per_km = zeros(length(lon), length(lat));
life_cycle_emissions = zeros(length(lon), length(lat));
life_cycle_emissions_per_capita = zeros(length(lon), length(lat));
annual_life_cycle_emissions_per_capita = zeros(length(lon), length(lat));

% CAlcs
for i = 1:length(obj.MunicipalArray)
mask_this = municipal_ids == obj.MunicipalArray(i).id;

vehicles(mask_this) = length(obj.MunicipalArray(i).vehicle_weight);
vehicles_per_capita(mask_this) = length(obj.MunicipalArray(i).vehicle_weight)/obj.MunicipalArray(i).population_projection_tot(1);
vehicle_weight_mean(mask_this) = mean(obj.MunicipalArray(i).vehicle_weight);
electrification_rate(mask_this) =obj.MunicipalArray(i).electrification_share;
hybrid_rate(mask_this) = obj.MunicipalArray(i).hybrid_share;
fossil_rate(mask_this) = obj.MunicipalArray(i).fossil_share;
life_cycle_emissions_per_km(mask_this) = mean(obj.MunicipalArray(i).vehicle_life_cycle_emissions_gco2eq_per_km);
life_cycle_emissions(mask_this) = obj.MunicipalArray(i).total_lca_emissions_tco2eq;
life_cycle_emissions_per_capita(mask_this) = obj.MunicipalArray(i).total_lca_emissions_per_capita_tco2eq_per_cap;
annual_life_cycle_emissions_per_capita(mask_this) = obj.MunicipalArray(i).total_annual_lca_emissions_per_capita_tco2eq_per_cap_yr;

end


nccreate(filename,'lat','Dimensions',{'lat' length(lat)});
ncwriteatt(filename, 'lat', 'standard_name', 'latitude');
ncwriteatt(filename, 'lat', 'long_name', 'latitude');
ncwriteatt(filename, 'lat', 'units', 'degrees_north');
ncwriteatt(filename, 'lat', '_CoordinateAxisType', 'Lat');
ncwriteatt(filename, 'lat', 'axis', 'Y');

nccreate(filename,'lon','Dimensions',{'lon' length(lon)});
ncwriteatt(filename, 'lon', 'standard_name', 'longitude');
ncwriteatt(filename, 'lon', 'long_name', 'longitude');
ncwriteatt(filename, 'lon', 'units', 'degrees_east');
ncwriteatt(filename, 'lon', '_CoordinateAxisType', 'Lon');
ncwriteatt(filename, 'lon', 'axis', 'X');

nccreate(filename, 'municipal_ids', 'Dimensions', {'lon' length(lon) 'lat' length(lat)}, 'DeflateLevel', 4);
ncwriteatt(filename, 'municipal_ids', 'standard_name', 'municipal_ids');
ncwriteatt(filename, 'municipal_ids', 'long_name', 'municipal_ids');
ncwriteatt(filename, 'municipal_ids', 'units', 'ID');
ncwriteatt(filename, 'municipal_ids', 'missing_value', '-999');

nccreate(filename, 'vehicles', 'Dimensions', {'lon' length(lon) 'lat' length(lat)}, 'DeflateLevel', 4);
ncwriteatt(filename, 'vehicles', 'standard_name', 'vehicles');
ncwriteatt(filename, 'vehicles', 'long_name', 'vehicles');
ncwriteatt(filename, 'vehicles', 'units', 'vehicles');
ncwriteatt(filename, 'vehicles', 'missing_value', '-999');

nccreate(filename, 'vehicles_per_capita', 'Dimensions', {'lon' length(lon) 'lat' length(lat)}, 'DeflateLevel', 4);
ncwriteatt(filename, 'vehicles_per_capita', 'standard_name', 'vehicles_per_capita');
ncwriteatt(filename, 'vehicles_per_capita', 'long_name', 'vehicles_per_capita');
ncwriteatt(filename, 'vehicles_per_capita', 'units', 'vehicles_per_capita');
ncwriteatt(filename, 'vehicles_per_capita', 'missing_value', '-999');

nccreate(filename, 'vehicle_weight_mean', 'Dimensions', {'lon' length(lon) 'lat' length(lat)}, 'DeflateLevel', 4);
ncwriteatt(filename, 'vehicle_weight_mean', 'standard_name', 'vehicle_weight_mean');
ncwriteatt(filename, 'vehicle_weight_mean', 'long_name', 'vehicle_weight_mean');
ncwriteatt(filename, 'vehicle_weight_mean', 'units', 'kg');
ncwriteatt(filename, 'vehicle_weight_mean', 'missing_value', '-999');

nccreate(filename, 'electrification_rate', 'Dimensions', {'lon' length(lon) 'lat' length(lat)}, 'DeflateLevel', 4);
ncwriteatt(filename, 'electrification_rate', 'standard_name', 'electrification_rate');
ncwriteatt(filename, 'electrification_rate', 'long_name', 'electrification_rate');
ncwriteatt(filename, 'electrification_rate', 'units', '-');
ncwriteatt(filename, 'electrification_rate', 'missing_value', '-999');

nccreate(filename, 'hybrid_rate', 'Dimensions', {'lon' length(lon) 'lat' length(lat)}, 'DeflateLevel', 4);
ncwriteatt(filename, 'hybrid_rate', 'standard_name', 'hybrid_rate');
ncwriteatt(filename, 'hybrid_rate', 'long_name', 'hybrid_rate');
ncwriteatt(filename, 'hybrid_rate', 'units', '-');
ncwriteatt(filename, 'hybrid_rate', 'missing_value', '-999');

nccreate(filename, 'fossil_rate', 'Dimensions', {'lon' length(lon) 'lat' length(lat)}, 'DeflateLevel', 4);
ncwriteatt(filename, 'fossil_rate', 'standard_name', 'fossil_rate');
ncwriteatt(filename, 'fossil_rate', 'long_name', 'fossil_rate');
ncwriteatt(filename, 'fossil_rate', 'units', '-');
ncwriteatt(filename, 'fossil_rate', 'missing_value', '-999');

nccreate(filename, 'life_cycle_emissions_per_km', 'Dimensions', {'lon' length(lon) 'lat' length(lat)}, 'DeflateLevel', 4);
ncwriteatt(filename, 'life_cycle_emissions_per_km', 'standard_name', 'life_cycle_emissions_per_km');
ncwriteatt(filename, 'life_cycle_emissions_per_km', 'long_name', 'mean_life_cycle_emissions_per_km');
ncwriteatt(filename, 'life_cycle_emissions_per_km', 'units', 'gCO2eq km-1');
ncwriteatt(filename, 'life_cycle_emissions_per_km', 'missing_value', '-999');

nccreate(filename, 'life_cycle_emissions', 'Dimensions', {'lon' length(lon) 'lat' length(lat)}, 'DeflateLevel', 4);
ncwriteatt(filename, 'life_cycle_emissions', 'standard_name', 'life_cycle_emissions');
ncwriteatt(filename, 'life_cycle_emissions', 'long_name', 'life_cycle_emissions');
ncwriteatt(filename, 'life_cycle_emissions', 'units', 'ton CO2eq');
ncwriteatt(filename, 'life_cycle_emissions', 'missing_value', '-999');

nccreate(filename, 'life_cycle_emissions_per_capita', 'Dimensions', {'lon' length(lon) 'lat' length(lat)}, 'DeflateLevel', 4);
ncwriteatt(filename, 'life_cycle_emissions_per_capita', 'standard_name', 'life_cycle_emissions_per_capita');
ncwriteatt(filename, 'life_cycle_emissions_per_capita', 'long_name', 'life_cycle_emissions_per_capita');
ncwriteatt(filename, 'life_cycle_emissions_per_capita', 'units', 'ton CO2eq cap-1');
ncwriteatt(filename, 'life_cycle_emissions', 'missing_value', '-999');

nccreate(filename, 'annual_life_cycle_emissions_per_capita', 'Dimensions', {'lon' length(lon) 'lat' length(lat)}, 'DeflateLevel', 4);
ncwriteatt(filename, 'annual_life_cycle_emissions_per_capita', 'standard_name', 'annual_life_cycle_emissions_per_capita');
ncwriteatt(filename, 'annual_life_cycle_emissions_per_capita', 'long_name', 'annual_life_cycle_emissions_per_capita');
ncwriteatt(filename, 'annual_life_cycle_emissions_per_capita', 'units', 'ton CO2eq cap-1 yr-1');
ncwriteatt(filename, 'annual_life_cycle_emissions_per_capita', 'missing_value', '-999');

ncwrite(filename, 'lat', lat);
ncwrite(filename, 'lon', lon);
ncwrite(filename, 'municipal_ids', municipal_ids);
ncwrite(filename, 'vehicles', vehicles);
ncwrite(filename, 'vehicles_per_capita', vehicles_per_capita);
ncwrite(filename, 'vehicle_weight_mean', vehicle_weight_mean);
ncwrite(filename, 'electrification_rate', electrification_rate);
ncwrite(filename, 'hybrid_rate', hybrid_rate);
ncwrite(filename, 'fossil_rate', fossil_rate);
ncwrite(filename, 'life_cycle_emissions_per_km',life_cycle_emissions_per_km);
ncwrite(filename, 'life_cycle_emissions', life_cycle_emissions);
ncwrite(filename, 'life_cycle_emissions_per_capita', life_cycle_emissions_per_capita);
ncwrite(filename, 'annual_life_cycle_emissions_per_capita', annual_life_cycle_emissions_per_capita);
end

