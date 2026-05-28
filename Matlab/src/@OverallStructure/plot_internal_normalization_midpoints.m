function plot_internal_normalization_midpoints(obj)
 
% Get midpoint category names and ids
midpoint_categories = get_midpoint_categories();
n_cats = length(midpoint_categories);
 
years = [obj.State.year];

base_path = fileparts(fileparts(fileparts(mfilename('fullpath'))));
output_dir = fullfile(base_path, 'Output');
pdf_stock_dir   = fullfile(output_dir, 'internal_norm_midpoints', 'PDF_stock');
pdf_new_dir     = fullfile(output_dir, 'internal_norm_midpoints', 'PDF_new_cars');
pdf_bars_stock  = fullfile(output_dir, 'internal_norm_midpoints', 'PDF_bars_stock');
pdf_bars_new    = fullfile(output_dir, 'internal_norm_midpoints', 'PDF_bars_new_cars');
mat_dir         = fullfile(output_dir, 'internal_norm_midpoints', 'MAT');
for d = {pdf_stock_dir, pdf_new_dir, pdf_bars_stock, pdf_bars_new, mat_dir}
    if ~exist(d{1}, 'dir'), mkdir(d{1}); end
end
 
flds = {'value_glider','value_powertrain','value_energy_storage', ...
    'value_maintenance','value_EoL', ...
    'value_road','value_energy_chain','value_direct_non_exhaust','value_direct_exhaust'};
 
legend_array = {'Glider', 'Powertrain', 'Energy storage', 'Maintenance', 'EoL', 'Road', 'Energy chain', 'Direct non-exhaust', 'Direct exhaust'};
flds = flip(flds);
legend_array = flip(legend_array);
 
%% Loop over all midpoint categories
for cat = 1:n_cats
 
    cat_name = midpoint_categories(cat).name;
    cat_unit = midpoint_categories(cat).unit;
    cat_id   = midpoint_categories(cat).id;
 
        cat_name_safe = strrep(cat_name, ':', '-');
    cat_name_safe = strrep(cat_name_safe, ' ', '_');
    cat_name_safe = strrep(cat_name_safe, '/', '_');
 
    fprintf('Plotting midpoint category %d/%d: %s\n', cat, n_cats, cat_name);
 
    %% collect data
    data_raw          = zeros(1, length(years));
    data_raw_new_cars = zeros(1, length(years));
 
    for i = 1:length(obj.State)
        data_raw(i)          = obj.State(i).Midpoint_impacts(cat_id).value;
        data_raw_new_cars(i) = obj.State(i).Midpoint_impacts_new_cars(cat_id).value;
    end
 
    %% internal normalization : vehicle stock 
    if data_raw(1) ~= 0
        plot_matrix = data_raw / data_raw(1);
    else
        plot_matrix = data_raw;
    end
 
    figure('Visible', 'off')
    plot(years, plot_matrix, 'LineWidth', 2.5);
    xlabel('Year')
    ylabel('Internal normalization')
    title(['Midpoint: ' cat_name ' : vehicle stock'])
    ylim([0 2])
 
    filename = fullfile(pdf_stock_dir, ['midpoints_' cat_name_safe '_internal_norm_vehicle_stock.pdf']);
    if exist(filename, 'file'), delete(filename); end
    print('-vector', '-dpdf', '-r1000', filename)
    save(fullfile(mat_dir, ['midpoints_' cat_name_safe '_internal_norm_vehicle_stock.mat']), 'plot_matrix', 'years', 'cat_name');
 
    %% internal normalization : new cars 
    if data_raw_new_cars(1) ~= 0
        plot_matrix_new_cars = data_raw_new_cars / data_raw_new_cars(1);
    else
        plot_matrix_new_cars = data_raw_new_cars;
    end
 
    figure('Visible', 'off')
    plot(years, plot_matrix_new_cars, 'LineWidth', 2.5);
    xlabel('Year')
    ylabel('Internal normalization')
    title(['Midpoint: ' cat_name ' : new cars'])
    ylim([0 2])
 
   
    filename = fullfile(pdf_new_dir, ['midpoints_' cat_name_safe '_internal_norm_new_vehicles.pdf']);
    if exist(filename, 'file'), delete(filename); end
    print('-vector', '-dpdf', '-r1000', filename)
    save(fullfile(mat_dir, ['midpoints_' cat_name_safe '_internal_norm_new_vehicles.mat']), 'plot_matrix_new_cars', 'years', 'cat_name');
 
    %% stacked bars : vehicle stock
    data_components          = zeros(length(flds), length(years));
    data_components_new_cars = zeros(length(flds), length(years));
 
    for i = 1:length(obj.State)
        for k = 1:length(flds)
            data_components(k, i)          = obj.State(i).Midpoint_impacts(cat_id).(flds{k});
            data_components_new_cars(k, i) = obj.State(i).Midpoint_impacts_new_cars(cat_id).(flds{k});
        end
    end
 
    figure('Visible', 'off')
    clrs = turbo(9);
    colororder(clrs);
    bar(years, data_components', 'Stacked');
    ylabel(cat_unit);
    xlabel('Year');
    title(['Midpoint: ' cat_name ' : vehicle stock']);
    legend(legend_array, 'Location', 'eastoutside')
 
    filename = fullfile(pdf_bars_stock, ['midpoints_' cat_name_safe '_vehicle_stock.pdf']);
    if exist(filename, 'file'), delete(filename); end
    print('-vector', '-dpdf', '-r1000', filename)
    save(fullfile(mat_dir, ['midpoints_' cat_name_safe '_vehicle_stock.mat']), 'data_components', 'years', 'flds');
 
    %% stacked bars : new cars
    figure('Visible', 'off')
    clrs = turbo(9);
    colororder(clrs);
    bar(years, data_components_new_cars', 'Stacked');
    ylabel(cat_unit);
    xlabel('Year');
    title(['New cars : midpoint: ' cat_name]);
    legend(legend_array, 'Location', 'eastoutside')
 
    filename = fullfile(pdf_bars_new, ['midpoints_' cat_name_safe '_new_vehicles.pdf']);
    if exist(filename, 'file'), delete(filename); end
    print('-vector', '-dpdf', '-r1000', filename)
    save(fullfile(mat_dir, ['midpoints_' cat_name_safe '_new_vehicles.mat']), 'data_components_new_cars', 'years', 'flds');
 
    close all

    % Export source data to Excel
    source_dir = fullfile(output_dir, 'Source_data');
    if ~exist(source_dir, 'dir'), mkdir(source_dir); end
    output_xlsx = fullfile(source_dir, 'internal_normalization_midpoints.xlsx');
    
    cat_name_clean = strrep(strrep(strrep(strrep(cat_name_safe, ':', ''), '?', ''), '*', ''), '[', '');
    cat_name_clean = cat_name_clean(1:min(end,25));
    
    header_norm = {'Year', 'Normalized_stock', 'Normalized_new_cars'};
    data_out = [num2cell(years'), num2cell(plot_matrix'), num2cell(plot_matrix_new_cars')];
    writecell([header_norm; data_out], output_xlsx, 'Sheet', ['norm_' cat_name_clean]);
    
    header_comp = [{'Year'}, legend_array];
    data_out = [num2cell(years'), num2cell(data_components')];
    writecell([header_comp; data_out], output_xlsx, 'Sheet', ['stock_' cat_name_clean]);
    data_out = [num2cell(years'), num2cell(data_components_new_cars')];
    writecell([header_comp; data_out], output_xlsx, 'Sheet', ['new_' cat_name_clean]);
 
end % for cat
 
fprintf('Done! All midpoint plots saved in Output/\n');
 
end