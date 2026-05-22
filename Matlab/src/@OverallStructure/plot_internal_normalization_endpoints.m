function plot_internal_normalization_endpoints(obj)

endpoint_ids_to_plot = [24 25 26];
endpoint_names = {'Total: ecosystem quality', 'Total: human health', 'Total: natural resources'};
units = {'species year vkm^{-1}', 'DALY vkm^{-1}', 'USD2013 vkm^{-1}'};

years = [obj.State.year];

data_raw = zeros(length(endpoint_ids_to_plot),  length(years));

plot_matrix = zeros(length(endpoint_ids_to_plot),  length(years));

for i = 1:length(obj.State)
    for j = 1:length(endpoint_ids_to_plot)
        data_raw(j,i) = obj.State(i).Endpoint_impacts(endpoint_ids_to_plot(j)).value;
    end
end

for i = 1:length(years)
    for j = 1:length(endpoint_ids_to_plot)
        plot_matrix(j,i) = data_raw(j,i)/data_raw(j,1);
    end
end


figure
plot(years,plot_matrix(1,:), 'LineWidth', 2.5);
hold on
plot(years,plot_matrix(2,:), 'LineWidth', 2.5);
plot(years,plot_matrix(3,:), 'LineWidth', 2.5);

legend(endpoint_names)

xlabel('Year')
ylabel('Internal normalization')

title('Endpoint impacts per vkm')

ylim([0.5 1.5])

filename = 'Output/endpoints_internal_normalization_vehicle_stock.pdf';
print('-vector','-dpdf', '-r1000', filename)
save('Output/endpoints_internal_normalization_vehicle_stock.mat', 'plot_matrix', 'years', 'endpoint_names' );

%% NEW CARS

data_raw_new_cars = zeros(length(endpoint_ids_to_plot),  length(years));

plot_matrix = zeros(length(endpoint_ids_to_plot),  length(years));

for i = 1:length(obj.State)
    for j = 1:length(endpoint_ids_to_plot)
        data_raw_new_cars(j,i) = obj.State(i).Endpoint_impacts_new_cars(endpoint_ids_to_plot(j)).value;
    end
end

for i = 1:length(years)
    for j = 1:length(endpoint_ids_to_plot)
        plot_matrix(j,i) = data_raw_new_cars(j,i)/data_raw_new_cars(j,1);
    end
end


figure
plot(years,plot_matrix(1,:), 'LineWidth', 2.5);
hold on
plot(years,plot_matrix(2,:), 'LineWidth', 2.5);
plot(years,plot_matrix(3,:), 'LineWidth', 2.5);

legend(endpoint_names)

xlabel('Year')
ylabel('Internal normalization')

title('Endpoint impacts per vkm')

ylim([0.5 1.5])

filename = 'Output/endpoints_internal_normalization_new_vehicles.pdf';
print('-vector','-dpdf', '-r1000', filename)
save('Output/endpoints_internal_normalization_new_vehicles.mat', 'plot_matrix', 'years', 'endpoint_names' );



%% NEXT

flds = {'value_glider','value_powertrain','value_energy_storage', ...
    'value_maintenance','value_EoL', ...
    'value_road','value_energy_chain','value_direct_non_exhaust','value_direct_exhaust'};

endpoint_names_out = {'ecosystem_quality', 'human_health', 'natural_resources'};

ylimmax = [1.5e-9 1e-6 0.04];

legend_array = {'Glider', 'Powertrain', 'Energy storage', 'Maintenance', 'EoL', 'Road', 'Energy chain', 'Direct non-exhaust', 'Direct exhaust'};
flds = flip(flds);
legend_array = flip(legend_array);

data_raw_components = zeros(length(endpoint_ids_to_plot), length(flds), length(years));
data_raw_components_new_cars = zeros(length(endpoint_ids_to_plot), length(flds), length(years));

for i = 1:length(obj.State)
    for j = 1:length(endpoint_ids_to_plot)
        for k = 1:length(flds)
            data_raw_components(j,i,k) = obj.State(i).Endpoint_impacts(endpoint_ids_to_plot(j)).(flds{k});
            data_raw_components_new_cars(j,i,k) = obj.State(i).Endpoint_impacts_new_cars(endpoint_ids_to_plot(j)).(flds{k});
        end
    end
end

for i = 1:length(endpoint_ids_to_plot)

    plotMatrix = zeros(length(flds),length(years));
    plotMatrix_new_cars = zeros(length(flds),length(years));

    for j = 1:length(flds)
        for k = 1:length(years)
            plotMatrix(j,k) = data_raw_components(i,k,j);
            plotMatrix_new_cars(j,k) = data_raw_components_new_cars(i,k,j);
        end
    end

    

    figure
    clrs = turbo(9);
    colororder(clrs);
    bar(years, plotMatrix, 'Stacked');
    ylabel(units{i});
    xlabel('Year');
    title([endpoint_names{i}]);

    %legend(legend_array, 'Location', 'eastoutside')

    ylim([0 ylimmax(i)])

    filename = ['Output/endpoints_' endpoint_names_out{i} '_vehicle_stock.pdf'];
    
    if exist(filename, 'file')
        delete(filename)
    end

    print('-vector','-dpdf', '-r1000', filename)
    save(['Output/endpoints_' endpoint_names_out{i} '_vehicle_stock.mat'], 'plotMatrix', 'years', 'flds');

    
    figure
    clrs = turbo(9);
    colororder(clrs);
    bar(years, plotMatrix_new_cars, 'Stacked');
    ylabel(units{i});
    xlabel('Year');
    title(['New cars - ' endpoint_names_out{i}]);

    %legend(legend_array, 'Location', 'eastoutside')

    ylim([0 ylimmax(i)])
    

    filename = ['Output/endpoints_' endpoint_names_out{i} '_new_vehicles.pdf'];

    if exist(filename, 'file')
        delete(filename)
    end

    print('-vector','-dpdf', '-r1000', filename)
    save(['Output/endpoints_' endpoint_names_out{i} '_new_vehicles.mat'], 'plotMatrix', 'years', 'flds');

end

%% Export source data to Excel
output_xlsx = 'Output/source_data_internal_normalization_endpoints.xlsx';
if exist(output_xlsx, 'file'), delete(output_xlsx); end

header_norm = {'Year', 'Ecosystem_quality', 'Human_health', 'Natural_resources'};

% Vehicle stock — normalized
data_out = [num2cell(years'), num2cell(data_raw(1,:)'/data_raw(1,1)), ...
            num2cell(data_raw(2,:)'/data_raw(2,1)), num2cell(data_raw(3,:)'/data_raw(3,1))];
writecell([header_norm; data_out], output_xlsx, 'Sheet', 'norm_vehicle_stock');

% New cars — normalized
data_out = [num2cell(years'), num2cell(data_raw_new_cars(1,:)'/data_raw_new_cars(1,1)), ...
            num2cell(data_raw_new_cars(2,:)'/data_raw_new_cars(2,1)), num2cell(data_raw_new_cars(3,:)'/data_raw_new_cars(3,1))];
writecell([header_norm; data_out], output_xlsx, 'Sheet', 'norm_new_cars');

header_comp = [{'Year'}, legend_array];
for i = 1:length(endpoint_ids_to_plot)
    plotMatrix_exp = zeros(length(years), length(flds));
    plotMatrix_nc_exp = zeros(length(years), length(flds));
    for j = 1:length(flds)
        for k = 1:length(years)
            plotMatrix_exp(k,j)    = data_raw_components(i,k,j);
            plotMatrix_nc_exp(k,j) = data_raw_components_new_cars(i,k,j);
        end
    end
    writecell([header_comp; [num2cell(years'), num2cell(plotMatrix_exp)]], ...
        output_xlsx, 'Sheet', [endpoint_names_out{i} '_stock']);
    writecell([header_comp; [num2cell(years'), num2cell(plotMatrix_nc_exp)]], ...
        output_xlsx, 'Sheet', [endpoint_names_out{i} '_new_cars']);
end

fprintf('Excel saved: %s\n', output_xlsx);


end

