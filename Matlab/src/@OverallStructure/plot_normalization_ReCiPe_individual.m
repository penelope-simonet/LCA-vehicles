function plot_normalization_ReCiPe_individual(obj)

% Normalization of ReCiPe midpoint impacts against global impact reference
% Source: get_normalization_factors_ReCiPe (ReCiPe 2016 v1.1 Hierarchist)
% Per capita allocation (egalitarian): Norway pop / world pop 2010
% One page per category, stacked areas: Embodied / Operational / Infrastructure

NormFactors  = get_normalization_factors_ReCiPe();
pop_2010     = 6895889018;
pop_norway   = 5400000;
vkm_per_year = 12000;
lifetime_km  = 200000;

cats_to_exclude = [20, 21, 22, 23];

years   = [obj.State.year];
n_years = length(years);

midpoint_categories = get_midpoint_categories();

base_path  = fileparts(fileparts(fileparts(mfilename('fullpath'))));
output_dir = fullfile(base_path, 'Output');
if ~exist(output_dir, 'dir'), mkdir(output_dir); end
output_pdf = fullfile(output_dir, 'normalization_ReCiPe_individual.pdf');
if exist(output_pdf, 'file'), delete(output_pdf); end

page = 0;

    function export_page(fig, pdf, pg)
        if pg == 1
            exportgraphics(fig, pdf, 'Append', false, 'ContentType', 'vector');
        else
            exportgraphics(fig, pdf, 'Append', true,  'ContentType', 'vector');
        end
        close(fig);
    end

for cat = 1:23

    if ismember(cat, cats_to_exclude)
        continue
    end

    norm_W = NormFactors.midpoint_World(cat);
    if isnan(norm_W) || norm_W <= 0
        continue
    end

    norm_norway = norm_W * (pop_norway / pop_2010);

    cat_name = midpoint_categories(cat).name;
    cat_unit = midpoint_categories(cat).unit;

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

        emb = (state.Midpoint_impacts(cat).value_glider + ...
               state.Midpoint_impacts(cat).value_powertrain + ...
               state.Midpoint_impacts(cat).value_energy_storage) * lifetime_km * n_new_cars;

        ops = (state.Midpoint_impacts(cat).value_direct_exhaust + ...
               state.Midpoint_impacts(cat).value_energy_chain + ...
               state.Midpoint_impacts(cat).value_direct_non_exhaust) * n_cars_total * vkm_per_year;

        inf_val = state.Midpoint_impacts(cat).value_road * n_cars_total * vkm_per_year;

        embodied(i)    = emb     / norm_norway;
        operational(i) = ops     / norm_norway;
        infra(i)       = inf_val / norm_norway;
    end

    total = embodied + operational + infra;

    if all(total == 0)
        continue
    end

    fig = figure('Visible', 'off', 'Units', 'centimeters', 'Position', [2 2 30 16]);
    ax = axes(fig);
    hold(ax, 'on');

    area(ax, years, embodied + operational + infra, ...
        'FaceColor', [0.47 0.67 0.19], 'EdgeColor', 'none', 'FaceAlpha', 0.7);
    area(ax, years, embodied + operational, ...
        'FaceColor', [0.85 0.33 0.10], 'EdgeColor', 'none', 'FaceAlpha', 0.7);
    area(ax, years, embodied, ...
        'FaceColor', [0.20 0.45 0.70], 'EdgeColor', 'none', 'FaceAlpha', 0.7);

    plot(ax, years, total, '-k', 'LineWidth', 1.5);

    % Reference line at year 2000 value
    val_2000 = total(1);
    plot(ax, [years(1) years(end)], [val_2000 val_2000], '--', ...
        'LineWidth', 1.0, 'Color', [0.3 0.3 0.3 0.6]);
    text(ax, years(end)+0.5, val_2000, 'Year 2000 level', ...
        'FontSize', 7, 'Color', [0.3 0.3 0.3], 'VerticalAlignment', 'middle', ...
        'HorizontalAlignment', 'left');

    legend(ax, {'Infrastructure (road)', 'Operational', 'Embodied', 'Total'}, ...
        'Location', 'northwest', 'FontSize', 8, 'Box', 'off');

    xlabel(ax, 'Year', 'FontSize', 9);
    ylabel(ax, 'Share of Norwegian global impact reference', 'FontSize', 9);
    title(ax, {sprintf('ReCiPe 2016 : %s', cat_name), ...
        sprintf('(%s) — per capita allocation', cat_unit)}, ...
        'FontSize', 9, 'FontWeight', 'bold');

    text(ax, years(1), max(total)*1.02, ...
        sprintf('Global ref. Norway = %.2e %s/yr', norm_norway, cat_unit), ...
        'FontSize', 7, 'Color', [0.2 0.2 0.6], 'VerticalAlignment', 'bottom');

    grid(ax, 'on');
    box(ax, 'off');
    set(ax, 'FontSize', 8);

    page = page + 1;
    export_page(fig, output_pdf, page);
    fprintf('Page %d — %s\n', page, cat_name);

end

%% Export source data to Excel
output_xlsx = fullfile(output_dir, 'source_data_normalization_ReCiPe_individual.xlsx');
if exist(output_xlsx, 'file'), delete(output_xlsx); end

header = [{'Year'}, {'Embodied'}, {'Operational'}, {'Infrastructure'}, {'Total'}];

for cat = 1:23
    if ismember(cat, cats_to_exclude), continue; end
    norm_W = NormFactors.midpoint_World(cat);
    if isnan(norm_W) || norm_W <= 0, continue; end

    cat_name_clean = strrep(midpoint_categories(cat).name, ':', '-');
    cat_name_clean = strrep(cat_name_clean, '/', '-');

    norm_norway = norm_W * (pop_norway / pop_2010);
    emb_sheet = zeros(n_years, 1);
    ops_sheet = zeros(n_years, 1);
    inf_sheet = zeros(n_years, 1);

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
        emb_sheet(i) = (state.Midpoint_impacts(cat).value_glider + ...
                        state.Midpoint_impacts(cat).value_powertrain + ...
                        state.Midpoint_impacts(cat).value_energy_storage) * lifetime_km * n_new_cars / norm_norway;
        ops_sheet(i) = (state.Midpoint_impacts(cat).value_direct_exhaust + ...
                        state.Midpoint_impacts(cat).value_energy_chain + ...
                        state.Midpoint_impacts(cat).value_direct_non_exhaust) * n_cars_total * vkm_per_year / norm_norway;
        inf_sheet(i) = state.Midpoint_impacts(cat).value_road * n_cars_total * vkm_per_year / norm_norway;
    end

    data_out = [num2cell(years'), num2cell(emb_sheet), num2cell(ops_sheet), ...
                num2cell(inf_sheet), num2cell(emb_sheet + ops_sheet + inf_sheet)];
    writecell([header; data_out], output_xlsx, 'Sheet', cat_name_clean(1:min(end,31)));
end

fprintf('Excel saved: %s\n', output_xlsx);

fprintf('\nDone! PDF: %s\n', output_pdf);

end