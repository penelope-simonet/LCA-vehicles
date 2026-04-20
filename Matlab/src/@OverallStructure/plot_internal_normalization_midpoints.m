function plot_internal_normalization_midpoints(obj)
 
midpoint_id_to_plot = 22;  % 'total'
midpoint_name = 'Total midpoint impact';
unit = 'midpoint unit vkm^{-1}';
 
years = [obj.State.year];
 
%% --- VEHICLE STOCK ---
 
data_raw = zeros(1, length(years));
 
for i = 1:length(obj.State)
    data_raw(i) = obj.State(i).Midpoint_impacts(midpoint_id_to_plot).value;
end
 
% Internal normalization: divide by value in year 2000
plot_matrix = data_raw / data_raw(1);
 
figure
plot(years, plot_matrix, 'LineWidth', 2.5);
legend({midpoint_name})
xlabel('Year')
ylabel('Internal normalization')
title('Midpoint total impact per vkm — vehicle stock')
ylim([0.5 1.5])
 
filename = 'Output/midpoints_internal_normalization_vehicle_stock.pdf';
print('-vector', '-dpdf', '-r1000', filename)
save('Output/midpoints_internal_normalization_vehicle_stock.mat', 'plot_matrix', 'years', 'midpoint_name');
 
 
%% --- NEW CARS ---
 
data_raw_new_cars = zeros(1, length(years));
 
for i = 1:length(obj.State)
    data_raw_new_cars(i) = obj.State(i).Midpoint_impacts_new_cars(midpoint_id_to_plot).value;
end
 
% Internal normalization
plot_matrix_new_cars = data_raw_new_cars / data_raw_new_cars(1);
 
figure
plot(years, plot_matrix_new_cars, 'LineWidth', 2.5);
legend({midpoint_name})
xlabel('Year')
ylabel('Internal normalization')
title('Midpoint total impact per vkm — new cars')
ylim([0.5 1.5])
 
filename = 'Output/midpoints_internal_normalization_new_vehicles.pdf';
print('-vector', '-dpdf', '-r1000', filename)
save('Output/midpoints_internal_normalization_new_vehicles.mat', 'plot_matrix_new_cars', 'years', 'midpoint_name');
 
 
%% --- BARRES EMPILEES PAR CONTRIBUTEUR ---
 
flds = {'value_glider','value_powertrain','value_energy_storage', ...
    'value_maintenance','value_EoL', ...
    'value_road','value_energy_chain','value_direct_non_exhaust','value_direct_exhaust'};
 
legend_array = {'Glider', 'Powertrain', 'Energy storage', 'Maintenance', 'EoL', 'Road', 'Energy chain', 'Direct non-exhaust', 'Direct exhaust'};
 
% Inverser pour que les couleurs correspondent à l'ordre d'empilement
flds = flip(flds);
legend_array = flip(legend_array);
 
data_components        = zeros(length(flds), length(years));
data_components_new_cars = zeros(length(flds), length(years));
 
for i = 1:length(obj.State)
    for k = 1:length(flds)
        data_components(k, i)        = obj.State(i).Midpoint_impacts(midpoint_id_to_plot).(flds{k});
        data_components_new_cars(k, i) = obj.State(i).Midpoint_impacts_new_cars(midpoint_id_to_plot).(flds{k});
    end
end
 
% -- Parc entier --
figure
clrs = turbo(9);
colororder(clrs);
bar(years, data_components', 'Stacked');
ylabel(unit);
xlabel('Year');
title(['Midpoint total — vehicle stock']);
legend(legend_array, 'Location', 'eastoutside')
 
filename = 'Output/midpoints_total_vehicle_stock.pdf';
if exist(filename, 'file'), delete(filename); end
print('-vector', '-dpdf', '-r1000', filename)
save('Output/midpoints_total_vehicle_stock.mat', 'data_components', 'years', 'flds');
 
% -- Nouvelles voitures --
figure
clrs = turbo(9);
colororder(clrs);
bar(years, data_components_new_cars', 'Stacked');
ylabel(unit);
xlabel('Year');
title(['New cars - midpoint total']);
legend(legend_array, 'Location', 'eastoutside')
 
filename = 'Output/midpoints_total_new_vehicles.pdf';
if exist(filename, 'file'), delete(filename); end
print('-vector', '-dpdf', '-r1000', filename)
save('Output/midpoints_total_new_vehicles.mat', 'data_components_new_cars', 'years', 'flds');
 
end