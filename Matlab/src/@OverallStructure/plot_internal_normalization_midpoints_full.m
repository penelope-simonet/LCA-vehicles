function plot_internal_normalization_midpoints_full(obj)
 
% Get midpoint category names and ids
midpoint_categories = get_midpoint_categories();
n_cats = length(midpoint_categories);
 
years = [obj.State.year];
 
flds = {'value_glider','value_powertrain','value_energy_storage', ...
    'value_maintenance','value_EoL', ...
    'value_road','value_energy_chain','value_direct_non_exhaust','value_direct_exhaust'};
 
legend_array = {'Glider', 'Powertrain', 'Energy storage', 'Maintenance', 'EoL', 'Road', 'Energy chain', 'Direct non-exhaust', 'Direct exhaust'};
flds = flip(flds);
legend_array = flip(legend_array);
 
% Output PDF
output_pdf = 'Output/midpoints_all_categories.pdf';
if exist(output_pdf, 'file'), delete(output_pdf); end
 
%% Loop over all midpoint categories
for cat = 1:n_cats
 
    cat_name = midpoint_categories(cat).name;
    cat_unit = midpoint_categories(cat).unit;
    cat_id   = midpoint_categories(cat).id;
 
    fprintf('Plotting midpoint category %d/%d: %s\n', cat, n_cats, cat_name);
 
    %% collect data
    data_raw          = zeros(1, length(years));
    data_raw_new_cars = zeros(1, length(years));
 
    for i = 1:length(obj.State)
        data_raw(i)          = obj.State(i).Midpoint_impacts(cat_id).value;
        data_raw_new_cars(i) = obj.State(i).Midpoint_impacts_new_cars(cat_id).value;
    end
 
    % Internal normalization
    if data_raw(1) ~= 0
        plot_matrix = data_raw / data_raw(1);
    else
        plot_matrix = data_raw;
    end
 
    if data_raw_new_cars(1) ~= 0
        plot_matrix_new_cars = data_raw_new_cars / data_raw_new_cars(1);
    else
        plot_matrix_new_cars = data_raw_new_cars;
    end
 
    %% stacked bar data
    data_components          = zeros(length(flds), length(years));
    data_components_new_cars = zeros(length(flds), length(years));
 
    for i = 1:length(obj.State)
        for k = 1:length(flds)
            data_components(k, i)          = obj.State(i).Midpoint_impacts(cat_id).(flds{k});
            data_components_new_cars(k, i) = obj.State(i).Midpoint_impacts_new_cars(cat_id).(flds{k});
        end
    end
 
    %% figure
    fig = figure('Visible', 'off');
    set(fig, 'Units', 'centimeters', 'Position', [0 0 42 20]);
 
    sgtitle(['Midpoint: ' cat_name], 'FontSize', 14, 'FontWeight', 'bold');
 
    % subplot 1 : internal normalization, vehicle stock
    subplot(2, 2, 1)
    plot(years, plot_matrix, 'LineWidth', 2.5, 'Color', [0.18 0.45 0.70]);
    xlabel('Year')
    ylabel('Internal normalization')
    title('Vehicle stock : internal normalization')
    ylim([0 2])
    grid on
 
    % subplot 2 : internal normalization, new cars
    subplot(2, 2, 2)
    plot(years, plot_matrix_new_cars, 'LineWidth', 2.5, 'Color', [0.85 0.33 0.10]);
    xlabel('Year')
    ylabel('Internal normalization')
    title('New cars : internal normalization')
    ylim([0 2])
    grid on
 
    % subplot 3 : stacked bars, vehicule stock
    subplot(2, 2, 3)
    clrs = turbo(9);
    colororder(clrs);
    bar(years, data_components', 'Stacked');
    ylabel(cat_unit)
    xlabel('Year')
    title('Vehicle stock : by contributor')
    legend(legend_array, 'Location', 'eastoutside', 'FontSize', 6)
    grid on
 
    % subplot 4 : stacked bars, new cars
    subplot(2, 2, 4)
    clrs = turbo(9);
    colororder(clrs);
    bar(years, data_components_new_cars', 'Stacked');
    ylabel(cat_unit)
    xlabel('Year')
    title('New cars : by contributor')
    legend(legend_array, 'Location', 'eastoutside', 'FontSize', 6)
    grid on
 
    %% append to PDF with exportgraphics 
    exportgraphics(fig, output_pdf, 'Append', true, 'ContentType', 'vector');
 
    close(fig)
 
end % for cat
 
%% Export source data to Excel
output_xlsx = 'Output/source_data_internal_normalization_midpoints.xlsx';
if exist(output_xlsx, 'file'), delete(output_xlsx); end

for cat = 1:n_cats
    cat_name_clean = strrep(midpoint_categories(cat).name, ':', '-');
    cat_name_clean = strrep(cat_name_clean, '/', '-');
    cat_id = midpoint_categories(cat).id;

    data_raw_exp          = zeros(length(years), 1);
    data_raw_new_cars_exp = zeros(length(years), 1);
    norm_exp              = zeros(length(years), 1);
    norm_new_cars_exp     = zeros(length(years), 1);
    components_exp        = zeros(length(years), length(flds));
    components_nc_exp     = zeros(length(years), length(flds));

    for i = 1:length(obj.State)
        data_raw_exp(i)          = obj.State(i).Midpoint_impacts(cat_id).value;
        data_raw_new_cars_exp(i) = obj.State(i).Midpoint_impacts_new_cars(cat_id).value;
        for k = 1:length(flds)
            components_exp(i,k)    = obj.State(i).Midpoint_impacts(cat_id).(flds{k});
            components_nc_exp(i,k) = obj.State(i).Midpoint_impacts_new_cars(cat_id).(flds{k});
        end
    end

    if data_raw_exp(1) ~= 0
        norm_exp = data_raw_exp / data_raw_exp(1);
    end
    if data_raw_new_cars_exp(1) ~= 0
        norm_new_cars_exp = data_raw_new_cars_exp / data_raw_new_cars_exp(1);
    end

    header_norm = {'Year', 'Raw_vehicle_stock', 'Norm_vehicle_stock', 'Raw_new_cars', 'Norm_new_cars'};
    data_norm_out = [num2cell(years'), num2cell(data_raw_exp), num2cell(norm_exp), ...
                     num2cell(data_raw_new_cars_exp), num2cell(norm_new_cars_exp)];
    writecell([header_norm; data_norm_out], output_xlsx, 'Sheet', cat_name_clean(1:min(end,31)));
end

fprintf('Excel saved: %s\n', output_xlsx);

fprintf('Done! All midpoint plots saved in: %s\n', output_pdf);
 
end