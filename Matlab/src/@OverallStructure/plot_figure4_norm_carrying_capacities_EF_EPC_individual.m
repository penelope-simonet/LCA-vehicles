function plot_figure4_norm_carrying_capacities_EF_EPC_individual(obj)

% 8 selected EF v3.1 indicators (ranked by exceedance)
% Allocation: EPC (Sala et al. 2020), global carrying capacity allocated
% to Norway via Norway/World population ratio.

% Use : OS.plot_figure4_norm_carrying_capacities_EF_EPC_individual()

NormFactors  = get_normalization_factors_EF();
pop_norway   = 4889252;
vkm_per_year = 12000;
lifetime_km  = 200000;

years   = [obj.State.year];
n_years = length(years);

midpoint_categories = get_midpoint_categories();

selected = [25, 40, 38, 29, 30, 31, 41, 34];
display_names = {
    'Climate change';
    'Particulate matter formation';
    'Material resources: metals/minerals';
    'Ecotoxicity: freshwater';
    'Energy resources: non-renewable';
    'Eutrophication: freshwater';
    'Photochemical oxidant formation: human health';
    'Human toxicity: carcinogenic'};

n_cats = numel(selected);
cats_data = struct();

for k = 1:n_cats
    cat_idx   = selected(k);
    PB_global = NormFactors.PB_global(cat_idx);
    PB_norway = PB_global * (pop_norway / NormFactors.pop_ref);
    cat_unit  = midpoint_categories(cat_idx).unit;

    embodied    = zeros(1, n_years);
    operational = zeros(1, n_years);
    infra       = zeros(1, n_years);

    for i = 1:n_years
        state = obj.State(i);

        n_cars_total = 0;
        for at = 1:numel(state.VehicleArchetype)
            n_cars_total = n_cars_total + sum(state.VehicleArchetype(at).number_of_cars_from_year);
        end

        n_new_cars = 0;
        for at = 1:numel(state.VehicleArchetype)
            year_idx = find(state.VehicleArchetype(at).year_cars_produced == state.year, 1);
            if ~isempty(year_idx)
                n_new_cars = n_new_cars + state.VehicleArchetype(at).number_of_cars_from_year(year_idx);
            end
        end

        emb = (state.Midpoint_impacts(cat_idx).value_glider + ...
               state.Midpoint_impacts(cat_idx).value_powertrain + ...
               state.Midpoint_impacts(cat_idx).value_energy_storage) * lifetime_km * n_new_cars;

        ops = (state.Midpoint_impacts(cat_idx).value_direct_exhaust + ...
               state.Midpoint_impacts(cat_idx).value_energy_chain + ...
               state.Midpoint_impacts(cat_idx).value_direct_non_exhaust) * n_cars_total * vkm_per_year;

        inf_val = state.Midpoint_impacts(cat_idx).value_road * n_cars_total * vkm_per_year;

        embodied(i)    = emb     / PB_norway;
        operational(i) = ops     / PB_norway;
        infra(i)       = inf_val / PB_norway;
    end

    cats_data(k).name        = display_names{k};
    cats_data(k).unit        = cat_unit;
    cats_data(k).PB_norway   = PB_norway;
    cats_data(k).embodied    = embodied;
    cats_data(k).operational = operational;
    cats_data(k).infra       = infra;
    cats_data(k).total       = embodied + operational + infra;
    cats_data(k).max_share   = max(cats_data(k).total);
end

%% --- Output paths ---
base_path  = fileparts(fileparts(fileparts(mfilename('fullpath'))));
output_dir = fullfile(base_path, 'Output');
if ~exist(output_dir, 'dir'), mkdir(output_dir); end
output_pdf = fullfile(output_dir, 'figure4_norm_carrying_capacities_EF_EPC_individual.pdf');
if exist(output_pdf, 'file'), delete(output_pdf); end

y_upper = max(2, ceil(max([cats_data.max_share]) * 1.1));
make_page(cats_data, years, 1, y_upper, output_pdf, false);

fprintf('PDF saved: %s\n', output_pdf);

%% excel
source_dir = fullfile(output_dir, 'Source_data');
if ~exist(source_dir, 'dir'), mkdir(source_dir); end
output_xlsx = fullfile(source_dir, 'plot_figure4_norm_carrying_capacities_EF_EPC_individual.xlsx');
if exist(output_xlsx, 'file'), delete(output_xlsx); end

for k = 1:n_cats
    d = cats_data(k);
    header = {'Year', 'Operational', 'Embodied', 'Infracucture', 'Total'};
    data_out = [num2cell(years'), num2cell(d.operational'), ...
                num2cell(d.embodied'), num2cell(d.infra'), num2cell(d.total')];
    sheet_name = matlab.lang.makeValidName(d.name);
    if length(sheet_name) > 31
        sheet_name = sheet_name(1:31);
    end
    writecell([header; data_out], output_xlsx, 'Sheet', sheet_name);
end

pb_header = {'Category', 'Unit', 'carrying_capacities_Norway'};
pb_data = cell(n_cats, 3);
for k = 1:n_cats
    pb_data{k,1} = cats_data(k).name;
    pb_data{k,2} = cats_data(k).unit;
    pb_data{k,3} = cats_data(k).PB_norway;
end
writecell([pb_header; pb_data], output_xlsx, 'Sheet', 'carrying_capacities_values');

fprintf('Excel saved: %s\n', output_xlsx);

end


%% local function: build one page
function make_page(page_data, years, rank_offset, y_upper, output_pdf, do_append)

n_cats = numel(page_data);
y_lower = 0;

W = 42.0; H = 29.7;
lm = 0.04; rm = 0.01; tm = 0.04; bm = 0.06;
hgap = 0.06; vgap = 0.10;
cell_w = (1 - lm - rm - 2*hgap) / 3;
cell_h = (1 - tm - bm - 2*vgap) / 3;

positions = zeros(9, 4);
for r = 1:3
    for c = 1:3
        idx = (r-1)*3 + c;
        left   = lm + (c-1)*(cell_w + hgap);
        bottom = 1 - tm - r*(cell_h) - (r-1)*vgap;
        positions(idx,:) = [left, bottom, cell_w, cell_h];
    end
end

fig = figure('Visible', 'off', 'Units', 'centimeters', 'Position', [2 2 W H]);
set(fig, 'Color', 'white');

for k = 1:n_cats
    d    = page_data(k);
    rank = k + rank_offset - 1;
    rank_letter = char('a' + rank - 1);
    ax = axes('Parent', fig, 'Position', positions(k,:));
    hold(ax, 'on');

    area(ax, years, (d.operational + d.embodied + d.infra), ...
        'FaceColor', [0.47 0.67 0.19], 'EdgeColor', 'none', 'FaceAlpha', 0.7);
    area(ax, years, (d.operational + d.embodied), ...
        'FaceColor', [0.20 0.45 0.70], 'EdgeColor', 'none', 'FaceAlpha', 0.7);
    area(ax, years, d.operational, ...
        'FaceColor', [0.85 0.33 0.10], 'EdgeColor', 'none', 'FaceAlpha', 0.7);

    plot(ax, years, d.total, '-k', 'LineWidth', 1.2);
    plot(ax, [years(1) years(end)], [1 1], '--r', 'LineWidth', 2.0);

    ylim(ax, [y_lower y_upper]);
    xlim(ax, [years(1) years(end)]);
    grid(ax, 'on');
    box(ax, 'off');
    set(ax, 'FontSize', 8);
    ylabel(ax, 'Share of PB (Norway, EPC)', 'FontSize', 8);
    xlabel(ax, 'Year', 'FontSize', 12);
    if strcmp(d.name, 'Photochemical oxidant formation: human health')
        title_str = sprintf('%s) %s', rank_letter, d.name);
    else
        title_str = sprintf('%s) %s (%s)', rank_letter, d.name, d.unit);
    end
    title(ax, title_str, 'FontSize', 13, 'FontWeight', 'bold', 'Interpreter', 'none');
   
    pb_label = sprintf('%.2e %s/yr', d.PB_norway, d.unit);
    text(ax, years(1)+0.3, y_upper*0.95, pb_label, ...
        'FontSize', 14, 'Color', 'r', 'Interpreter', 'none', ...
        'VerticalAlignment', 'top');
end

ax_leg = axes('Parent', fig, 'Position', positions(9,:), ...
    'Visible', 'off', 'Color', 'none', 'XColor', 'none', 'YColor', 'none');
hold(ax_leg, 'on');

h_inf = fill(ax_leg, NaN, NaN, [0.47 0.67 0.19], 'EdgeColor', 'none', 'FaceAlpha', 0.7);
h_emb = fill(ax_leg, NaN, NaN, [0.20 0.45 0.70], 'EdgeColor', 'none', 'FaceAlpha', 0.7);
h_ops = fill(ax_leg, NaN, NaN, [0.85 0.33 0.10], 'EdgeColor', 'none', 'FaceAlpha', 0.7);
h_tot = plot(ax_leg, NaN, NaN, '-k',  'LineWidth', 1.2);
h_pb  = plot(ax_leg, NaN, NaN, '--r', 'LineWidth', 2.0);

legend(ax_leg, [h_ops h_emb h_inf h_tot h_pb], ...
    {'Operational', 'Embodied', 'Infrastructure', 'Total', 'Carrying capacity (Norway, EPC)'}, ...
    'Location', 'northwest', 'FontSize', 16, 'Box', 'on', ...
    'Color', 'white', 'EdgeColor', [0.5 0.5 0.5]);

set(fig, 'PaperUnits', 'centimeters', 'PaperSize', [W H]);
drawnow;
exportgraphics(fig, output_pdf, 'ContentType', 'vector', 'BackgroundColor', 'white', 'Append', do_append);
close(fig);

end