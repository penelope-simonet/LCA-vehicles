function  create_high_resolution_netcdf_Norway()
%CREATE_HIGH_RESOLUTION_NETCDF_NORWAY Summary of this function goes here
%   Detailed explanation goes here

filename = 'high_res_2arcsec_Norway.nc';

lon_bnds = [0 35];
lat_bnds = [57 72];

lon_step = 2/3600;

lon_1arcsec = [-180+lon_step/2:lon_step:180-lon_step/2];
lat_1arcsec = [90-lon_step/2:-lon_step:-90+lon_step/2];


[~,idx_lat1] = min(abs(lat_1arcsec-lat_bnds(2)));
[~,idx_lat2] = min(abs(lat_1arcsec-lat_bnds(1)));
[~,idx_lon1] = min(abs(lon_1arcsec-lon_bnds(1)));
[~,idx_lon2] = min(abs(lon_1arcsec-lon_bnds(2)));

lon = lon_1arcsec(idx_lon1:idx_lon2);
lat = lat_1arcsec(idx_lat1:idx_lat2);

test_grid = zeros(length(lon), length(lat));

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

nccreate(filename, 'grid_2arcsec_NOR', 'Dimensions', {'lon' length(lon) 'lat' length(lat)}, 'DeflateLevel', 4);
ncwriteatt(filename, 'grid_2arcsec_NOR', 'standard_name', 'grid_2arcsec_NOR');
ncwriteatt(filename, 'grid_2arcsec_NOR', 'long_name', 'grid_2arcsec_NOR');
ncwriteatt(filename, 'grid_2arcsec_NOR', 'units', '-');
ncwriteatt(filename, 'grid_2arcsec_NOR', 'missing_value', '-999');


ncwrite(filename, 'lat', lat);
ncwrite(filename, 'lon', lon);
ncwrite(filename, 'grid_2arcsec_NOR', test_grid);

end

