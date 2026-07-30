function plot_figure1_archetypes_over_time(obj)
%PLOT_FIGURE1_ARCHETYPES_OVER_TIME
% 4-panel PDF showing how the vehicle stock's composition by weight
% category (archetype) evolves year by year, from 2000 to 2023, one
% panel per powertrain group.
%
% Source: Carculator, from Rousseau et al. dataset 3 (input/Rousseau_dataset_3.xlsx).
%
% Use: OS.plot_figure1_archetypes_over_time()

%% load data
base_path = fileparts(fileparts(fileparts(mfilename('fullpath'))));
filename  = fullfile(base_path, 'input', 'Rousseau_dataset_3.xlsx');
T_R3 = readtable(filename, Sheet='Sheet1');

T_R3_year            = T_R3{:,1};
T_R3_muni_cat         = T_R3{:,2};
T_R3_fuel             = T_R3{:,3};
T_R3_weight_category  = T_R3{:,5};
T_R3_number_of_cars   = T_R3{:,6};

%% Keep all stock years, excluding the 'Norway' national aggregate row
% 'Norway' is the sum of all other muni_cat categories (incl. 'unknown
% municipalities'); keeping it alongside them would double-count every vehicle.
keep_rows = ~strcmp(T_R3_muni_cat, 'Norway');
stock_year      = T_R3_year(keep_rows);
fuel            = T_R3_fuel(keep_rows);
weight_category = T_R3_weight_category(keep_rows);
number_of_cars  = T_R3_number_of_cars(keep_rows);

%% Powertrain grouping 
% 01 Gasoline
% 02 Diesel
% 05 Electric
% 07 Gasoline hybrid
% 08 Gasoline hybrid (grouped, marginal volume)
panel_groups  = {'Diesel', 'Gasoline', 'Electric', 'Gasoline hybrid'};
panel_letters = {'a', 'b', 'c', 'd'};
n_panels = numel(panel_groups);

fuel_map = containers.Map( ...
    {'01 - Bensin', '02 - Diesel', '05 - Elektrisk', '07 - Bensin hybrid', '08 - Diesel hybrid'}, ...
    {'Gasoline',     'Diesel',      'Electric',       'Gasoline hybrid',    'Gasoline hybrid'});

panel_of_row = cell(size(fuel));
for i = 1:numel(fuel)
    panel_of_row{i} = fuel_map(fuel{i});
end

%% Weight categories
weight_category_order = {'Mini', 'Small', 'Lower medium', 'Medium', 'Large', 'Large SUV'};
weight_labels          = {'400-900 kg', '900-1250 kg', '1250-1500 kg', ...
                           '1500-1750 kg', '1750-2000 kg', '2000-4000 kg'};
n_wg = numel(weight_labels);

weight_colors = [ ...
    0.12 0.47 0.71;   % 400-900 kg     (blue)
    1.00 0.50 0.05;   % 900-1250 kg    (orange)
    0.17 0.63 0.17;   % 1250-1500 kg   (green)
    0.58 0.40 0.74;   % 1500-1750 kg   (purple)
    0.55 0.34 0.29;   % 1750-2000 kg   (brown)
    0.89 0.10 0.11];  % 2000-4000 kg   (red)

years = (2000:2023)';
n_years = numel(years);

%% data matrices
% Summed over all cohorts (first_reg_year) for each stock year.
data_panels = cell(n_panels, 1);
for p = 1:n_panels
    data_panels{p} = zeros(n_years, n_wg);
end

for i = 1:numel(fuel)
    p = find(strcmp(panel_groups, panel_of_row{i}), 1);
    y = find(years == stock_year(i), 1);
    w = find(strcmp(weight_category_order, weight_category{i}), 1);
    if ~isempty(p) && ~isempty(y) && ~isempty(w)
        data_panels{p}(y, w) = data_panels{p}(y, w) + number_of_cars(i);
    end
end

%% Figure
fig = figure('Units', 'centimeters', 'Position', [1 1 36 32], 'Color', 'w', 'Visible', 'off');

col1_x = 0.07; col2_x = 0.55; sp_width = 0.42;
row1_y = 0.575; row2_y = 0.12; sp_height = 0.375;
panel_positions = { ...
    [col1_x, row1_y, sp_width, sp_height], ...  
    [col2_x, row1_y, sp_width, sp_height], ...  
    [col1_x, row2_y, sp_width, sp_height], ...  
    [col2_x, row2_y, sp_width, sp_height]};     

for p = 1:n_panels
    ax = axes(fig, 'Position', panel_positions{p});
    hold(ax, 'on');
    bar(ax, years, data_panels{p}, 'stacked', 'EdgeColor', 'none');
    colororder(ax, weight_colors);
    set(ax, 'FontSize', 14);
    title(ax, sprintf('%s) %s', panel_letters{p}, lower(panel_groups{p})), 'FontSize', 18);
    xlabel(ax, 'Year', 'FontSize', 15);
    ylabel(ax, 'Number of vehicles in the stock', 'FontSize', 15);
    xlim(ax, [1999.5 2023.5]);
    ylim(ax, [0 2e6]);
    box(ax, 'on');
end

%% legend
ax_legend = axes(fig, 'Position', [0.05, 0.01, 0.90, 0.08], 'Visible', 'off');
hold(ax_legend, 'on');
h = gobjects(n_wg, 1);
for w = 1:n_wg
    h(w) = patch(ax_legend, NaN, NaN, weight_colors(w,:), 'EdgeColor', 'none');
end
legend(ax_legend, h, weight_labels, ...
       'Orientation', 'horizontal', ...
       'Location',    'south', ...
       'FontSize',    16, ...
       'Box',         'off', ...
       'NumColumns',  6);

%% PDF
output_dir = fullfile(base_path, 'Output');
if ~exist(output_dir, 'dir'), mkdir(output_dir); end
output_pdf = fullfile(output_dir, 'figure1_archetypes_over_time.pdf');

set(fig, 'PaperUnits', 'centimeters', 'PaperSize', [36 32], ...
         'PaperPosition', [0 0 36 32], 'PaperPositionMode', 'manual');
drawnow;
print(fig, output_pdf, '-dpdf', '-painters');
close(fig);
fprintf('PDF saved: %s\n', output_pdf);

%% Excel
source_dir = fullfile(output_dir, 'Source_data');
if ~exist(source_dir, 'dir'), mkdir(source_dir); end
output_xlsx = fullfile(source_dir, 'figure1_archetypes_over_time.xlsx');
if exist(output_xlsx, 'file'), delete(output_xlsx); end

for p = 1:n_panels
    header     = [{'year'}, weight_labels];
    sheet_name = strrep(panel_groups{p}, ' ', '_');
    writecell([header; num2cell([years, data_panels{p}])], ...
              output_xlsx, 'Sheet', sheet_name);
end
fprintf('Excel saved: %s\n', output_xlsx);

end