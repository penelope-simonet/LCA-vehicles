function plot_figureS1_new_cars_powertrain_and_weight(obj)

% Two stacked-area charts for newly registered cars, by year:
%   (1) powertrain composition (grouped as in Rousseau et al., 2025)
%   (2) curb weight category composition
%
% Data source: VehicleArchetype.number_of_cars_from_year, matched to
% VehicleArchetype.year_cars_produced == state.year (new registrations
% only), summed across all VehicleArchetype entries for that year.

% Use : OS.plot_figureS1_new_cars_powertrain_and_weight()

years   = [obj.State.year];
n_years = length(years);

get_new_cars = @(archetype, yr) local_get_new_cars(archetype, yr);

%% Powertrain grouping (as in Rousseau et al., 2025)
% Mapping from the 9 detailed powertrain codes to 5 display groups.
% FCEV (hydrogen) is ignored as marginal.
powertrain_group_map = struct( ...
    'BEV',    'Electric', ...
    'ICEV_g', 'Gasoline', ...
    'ICEV_d', 'Diesel', ...
    'HEV_p',  'Gasoline hybrid', ...
    'PHEV_p', 'Gasoline hybrid', ...
    'HEV_d',  'Diesel hybrid', ...
    'PHEV_d', 'Diesel hybrid');

powertrain_groups = {'Gasoline', 'Diesel', 'Gasoline hybrid', 'Diesel hybrid', 'Electric'};
n_pg = length(powertrain_groups);

powertrain_colors = [
    0.80 0.65 0.10;   % Gasoline      (mustard/gold)
    0.55 0.35 0.05;   % Diesel        (brown)
    0.65 0.85 1.00;   % Gasoline hybrid (light blue)
    0.00 0.10 0.60;   % Diesel hybrid (dark blue)
    0.10 0.55 0.15;   % Electric      (green)
];

%% Weight category grouping (as in Rousseau et al., 2025, Figure 1b)
weight_bins = [400 900 1250 1500 1750 2000 inf];
weight_labels_orig = {'400-900 kg', '900-1250 kg', '1250-1500 kg', ...
                       '1500-1750 kg', '1750-2000 kg', '> 2000 kg'};
weight_colors_orig = [
    0.10 0.30 0.85;   % 400-900 kg     (blue)
    0.55 0.85 0.20;   % 900-1250 kg    (light green)
    0.95 0.85 0.10;   % 1250-1500 kg   (yellow)
    0.95 0.60 0.20;   % 1500-1750 kg   (orange)
    0.85 0.30 0.10;   % 1750-2000 kg   (dark orange)
    0.75 0.10 0.10;   % > 2000 kg      (red)
];

weight_labels = fliplr(weight_labels_orig);
weight_colors = flipud(weight_colors_orig);
n_wg = length(weight_labels);

%% data
data_powertrain = zeros(n_years, n_pg);
data_weight     = zeros(n_years, n_wg);

for i = 1:n_years
    state = obj.State(i);
    yr    = state.year;

    for at = 1:numel(state.VehicleArchetype)
        archetype = state.VehicleArchetype(at);
        n_new = get_new_cars(archetype, yr);
        if n_new <= 0
            continue;
        end

        pt_code = strrep(archetype.powertrain, '-', '_');  
        if isfield(powertrain_group_map, pt_code)
            group_name = powertrain_group_map.(pt_code);
            pg_idx = find(strcmp(powertrain_groups, group_name), 1);
            if ~isempty(pg_idx)
                data_powertrain(i, pg_idx) = data_powertrain(i, pg_idx) + n_new;
            end
        end
      

      
        w_mid = mean(archetype.weight_kg_bnds);
        wg_idx_orig = find(w_mid > weight_bins(1:end-1) & w_mid <= weight_bins(2:end), 1);
        if isempty(wg_idx_orig)
            wg_idx_orig = 1; 
        end
        wg_idx = n_wg - wg_idx_orig + 1;
        data_weight(i, wg_idx) = data_weight(i, wg_idx) + n_new;
    end
end

data_powertrain = data_powertrain / 1000;
data_weight     = data_weight / 1000;

%% Figure
fig = figure('Visible', 'off', 'Units', 'centimeters', 'Position', [2 2 36 16]);
set(fig, 'Color', 'white');

%% Panel 1: Powertrain 
ax1 = axes('Parent', fig, 'Position', [0.07 0.12 0.40 0.78]);
hold(ax1, 'on');
area(ax1, years, data_powertrain, 'EdgeColor', 'none');
colororder(ax1, powertrain_colors);
set(ax1, 'FontSize', 12);
xlabel(ax1, 'Year', 'FontSize', 12);
ylabel(ax1, 'Thousands of cars', 'FontSize', 12);
title(ax1, 'a', 'FontSize', 14, 'FontWeight', 'bold');
legend(ax1, powertrain_groups, 'Location', 'northwest', 'FontSize', 12, 'Box', 'off');
xlim(ax1, [years(1) years(end)]);
box(ax1, 'off');

%% Panel 2: Weight category
ax2 = axes('Parent', fig, 'Position', [0.57 0.12 0.40 0.78]);
hold(ax2, 'on');
area(ax2, years, data_weight, 'EdgeColor', 'none');
colororder(ax2, weight_colors);
set(ax2, 'FontSize', 12);
xlabel(ax2, 'Year', 'FontSize', 12);
ylabel(ax2, 'Thousands of cars', 'FontSize', 12);
title(ax2, 'b', 'FontSize', 14, 'FontWeight', 'bold');
legend(ax2, weight_labels, 'Location', 'northwest', 'FontSize', 12, 'Box', 'off');
xlim(ax2, [years(1) years(end)]);
box(ax2, 'off');

%% pdf
base_path  = fileparts(fileparts(fileparts(mfilename('fullpath'))));
output_dir = fullfile(base_path, 'Output');
if ~exist(output_dir, 'dir'), mkdir(output_dir); end
output_pdf = fullfile(output_dir, 'figureS1_new_cars_powertrain_and_weight.pdf');

drawnow;
exportgraphics(fig, output_pdf, 'ContentType', 'vector', 'BackgroundColor', 'white');
close(fig);
fprintf('PDF saved: %s\n', output_pdf);

%% excel
source_dir = fullfile(output_dir, 'Source_data');
if ~exist(source_dir, 'dir'), mkdir(source_dir); end
output_xlsx = fullfile(source_dir, 'figureS1_new_cars_powertrain_and_weight.xlsx');
if exist(output_xlsx, 'file'), delete(output_xlsx); end

header_pt = [{'Year'}, powertrain_groups];
writecell([header_pt; num2cell([years', data_powertrain])], output_xlsx, 'Sheet', 'powertrain');

header_w = [{'Year'}, weight_labels];
writecell([header_w; num2cell([years', data_weight])], output_xlsx, 'Sheet', 'weight_category');

fprintf('Excel saved: %s\n', output_xlsx);

end

function n_new = local_get_new_cars(archetype, yr)
    idx = find(archetype.year_cars_produced == yr, 1);
    if isempty(idx)
        n_new = 0;
    else
        n_new = archetype.number_of_cars_from_year(idx);
    end
end