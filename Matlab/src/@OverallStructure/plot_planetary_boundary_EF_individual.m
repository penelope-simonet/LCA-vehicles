function plot_planetary_boundary_EF_individual(obj)

% Planetary boundaries for EF v3.1 individual midpoint categories
% Source: Sala et al. (2020), Table 3; Horup et al. (2025) for land use
% Per capita allocation (egalitarian)

NormFactors  = get_normalization_factors_EF();
pop_norway   = 5400000;
vkm_per_year = 12000;
lifetime_km  = 200000;

years   = [obj.State.year];
n_years = length(years);

midpoint_categories = get_midpoint_categories();
ef_start = 24;
ef_end   = length(midpoint_categories);
ef_cats_to_exclude = [3, 4, 5];
n_cats_EF = ef_end - ef_start + 1;

base_path  = fileparts(fileparts(fileparts(mfilename('fullpath'))));
output_dir = fullfile(base_path, 'Output');
if ~exist(output_dir, 'dir'), mkdir(output_dir); end
output_pdf = fullfile(output_dir, 'planetary_boundary_EF_individual.pdf');
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

for ci = 1:n_cats_EF
    if ismember(ci, ef_cats_to_exclude), continue; end
    cat_idx  = ef_start + ci - 1;
    cat_name = strrep(midpoint_categories(cat_idx).name, ' EF', '');
    cat_unit = midpoint_categories(cat_idx).unit;
    PB_global = NormFactors.PB_global(cat_idx);

    if PB_global <= 0
        continue
    end

    PB_norway = PB_global * (pop_norway / NormFactors.pop_ref);

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

    total = embodied + operational + infra;

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

    plot(ax, [years(1) years(end)], [1 1], '--', 'LineWidth', 1.0, 'Color', [1 0 0 0.6]);
    text(ax, years(end)+0.5, 1, 'Planetary boundary (Norway share)', ...
        'FontSize', 7, 'Color', 'r', 'VerticalAlignment', 'middle', ...
        'HorizontalAlignment', 'left');

    legend(ax, {'Infrastructure (road)', 'Operational', 'Embodied', 'Total'}, ...
        'Location', 'northwest', 'FontSize', 8, 'Box', 'off');

    xlabel(ax, 'Year', 'FontSize', 9);
    ylabel(ax, 'Share of Norwegian planetary boundary', 'FontSize', 9);
    title(ax, {sprintf('EF v3.1 : %s', cat_name), ...
        sprintf('(%s) — per capita allocation, Sala et al. 2020', cat_unit)}, ...
        'FontSize', 9, 'FontWeight', 'bold');

    text(ax, years(1), max(total)*1.02, sprintf('PB Norway = %.2e %s/yr', PB_norway, cat_unit), ...
        'FontSize', 7, 'Color', [0.6 0 0], 'VerticalAlignment', 'bottom');

    grid(ax, 'on');
    box(ax, 'off');
    set(ax, 'FontSize', 8);

    page = page + 1;
    export_page(fig, output_pdf, page);
    fprintf('Page %d — %s\n', page, cat_name);
end

%% Export source data to Excel
output_xlsx = fullfile(output_dir, 'source_data_planetary_boundary_EF_individual.xlsx');
if exist(output_xlsx, 'file'), delete(output_xlsx); end

header = [{'Year'}, {'Embodied'}, {'Operational'}, {'Infrastructure'}, {'Total'}, {'PB_norway'}];

for ci = 1:n_cats_EF
    if ismember(ci, ef_cats_to_exclude), continue; end
    cat_idx  = ef_start + ci - 1;
    PB_global = NormFactors.PB_global(cat_idx);
    if PB_global <= 0, continue; end

    PB_norway_cat = PB_global * (pop_norway / NormFactors.pop_ref);
    cat_name_clean = strrep(strrep(midpoint_categories(cat_idx).name, ' EF', ''), ':', '-');
    cat_name_clean = strrep(cat_name_clean, '/', '-');

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
        emb_sheet(i) = (state.Midpoint_impacts(cat_idx).value_glider + ...
                        state.Midpoint_impacts(cat_idx).value_powertrain + ...
                        state.Midpoint_impacts(cat_idx).value_energy_storage) * lifetime_km * n_new_cars / PB_norway_cat;
        ops_sheet(i) = (state.Midpoint_impacts(cat_idx).value_direct_exhaust + ...
                        state.Midpoint_impacts(cat_idx).value_energy_chain + ...
                        state.Midpoint_impacts(cat_idx).value_direct_non_exhaust) * n_cars_total * vkm_per_year / PB_norway_cat;
        inf_sheet(i) = state.Midpoint_impacts(cat_idx).value_road * n_cars_total * vkm_per_year / PB_norway_cat;
    end

    data_out = [num2cell(years'), num2cell(emb_sheet), num2cell(ops_sheet), ...
                num2cell(inf_sheet), num2cell(emb_sheet + ops_sheet + inf_sheet), ...
                num2cell(repmat(PB_norway_cat, n_years, 1))];
    writecell([header; data_out], output_xlsx, 'Sheet', cat_name_clean(1:min(end,31)));
end

fprintf('Excel saved: %s\n', output_xlsx);

fprintf('\nDone! PDF: %s\n', output_pdf);

end