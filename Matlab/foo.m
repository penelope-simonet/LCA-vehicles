addpath(genpath(pwd()));

ncid = netcdf.open('municipal_results.nc');

lon = netcdf.getVar(ncid,1);
lat = netcdf.getVar(ncid,0);
lca_em_gco2eq_per_km = netcdf.getVar(ncid,9);
netcdf.close(ncid);

binary_positive = lca_em_gco2eq_per_km > 0;



median_lca_em = median(lca_em_gco2eq_per_km(binary_positive));

lca_em_diff_from_mean = (lca_em_gco2eq_per_km/median_lca_em)-1;

lca_em_diff_from_mean = lca_em_diff_from_mean*100;

lca_em_diff_from_mean(~binary_positive) = -999;
lca_em_gco2eq_per_km(~binary_positive) = -999;

export =1;
if export == 1

filename = 'output.nc';
if exist(filename, 'file')
delete(filename);
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

nccreate(filename, 'life_cycle_emissions_per_km', 'Dimensions', {'lon' length(lon) 'lat' length(lat)}, 'DeflateLevel', 4);
ncwriteatt(filename, 'life_cycle_emissions_per_km', 'standard_name', 'life_cycle_emissions_per_km');
ncwriteatt(filename, 'life_cycle_emissions_per_km', 'long_name', 'mean_life_cycle_emissions_per_km');
ncwriteatt(filename, 'life_cycle_emissions_per_km', 'units', 'gCO2eq km-1');
ncwriteatt(filename, 'life_cycle_emissions_per_km', 'missing_value', '-999');

nccreate(filename, 'life_cycle_emissions_diff_from_mean', 'Dimensions', {'lon' length(lon) 'lat' length(lat)}, 'DeflateLevel', 4);
ncwriteatt(filename, 'life_cycle_emissions_diff_from_mean', 'standard_name', 'life_cycle_emissions_diff_from_mean');
ncwriteatt(filename, 'life_cycle_emissions_diff_from_mean', 'long_name', 'life_cycle_emissions_diff_from_mean');
ncwriteatt(filename, 'life_cycle_emissions_diff_from_mean', 'units', '%');
ncwriteatt(filename, 'life_cycle_emissions_diff_from_mean', 'missing_value', '-999');

ncwrite(filename, 'lat', lat);
ncwrite(filename, 'lon',lon);
ncwrite(filename, 'life_cycle_emissions_per_km', lca_em_gco2eq_per_km);
ncwrite(filename, 'life_cycle_emissions_diff_from_mean', lca_em_diff_from_mean);

end