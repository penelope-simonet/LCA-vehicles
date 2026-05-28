function plot_planetary_boundary_EF_individual(obj)

% Planetary boundaries for EF v3.1 individual midpoint categories
% Source: Sala et al. (2020), Table 3; Horup et al. (2025) for land use
% Per capita allocation (egalitarian)
% Layout: 4 categories per page (2x2 grid), shared legend on right side

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
            exportgraphics(fig, pdf, 'Append', false, 'ContentType', 'vector', 'BackgroundColor', 'white');
        else
            exportgraphics(fig, pdf, 'Append', true, 'ContentType', 'vector', 'BackgroundColor', 'white');
        end
        close(fig);
    end

% Precompute all categories to plot
cats_data = struct();
n_valid = 0;

for ci = 1:n_cats_EF
    if ismember(ci, ef_cats_to_exclude), continue; end
    cat_idx  = ef_start + ci - 1;
    PB_global = NormFactors.PB_global(cat_idx);
    if PB_global <= 0, continue; end

    PB_norway = PB_global * (pop_norway / NormFactors.pop_ref);
    cat_name  = strrep(midpoint_categories(cat_idx).name, ' EF', '');
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

    n_valid = n_valid + 1;
    cats_data(n_valid).cat_name   = cat_name;
    cats_data(n_valid).cat_unit   = cat_unit;
    cats_data(n_valid).PB_norway  = PB_norway;
    cats_data(n_valid).embodied   = embodied;
    cats_data(n_valid).operational= operational;
    cats_data(n_valid).infra      = infra;
    cats_data(n_valid).total      = embodied + operational + infra;
end

% Plot 4 per page
cats_per_page = 4;
n_pages = ceil(n_valid / cats_per_page);

for pg = 1:n_pages
    fig = figure('Visible', 'off', 'Units', 'centimeters', 'Position', [2 2 38 24]);
    set(fig, 'Color', 'white');

    idx_start = (pg-1)*cats_per_page + 1;
    idx_end   = min(pg*cats_per_page, n_valid);
    n_on_page = idx_end - idx_start + 1;

    for k = 1:n_on_page
        d = cats_data(idx_start + k - 1);

        % 2x2 grid, leave right 20% for legend
        row = ceil(k/2);
        col = mod(k-1, 2) + 1;

        left   = 0.06 + (col-1) * 0.40;
        bottom = 0.58 - (row-1) * 0.50;
        width  = 0.35;
        height = 0.38;

        ax = axes('Parent', fig, 'Position', [left bottom width height]); 
        hold(ax, 'on');

        area(ax, years, d.embodied + d.operational + d.infra, ...
            'FaceColor', [0.47 0.67 0.19], 'EdgeColor', 'none', 'FaceAlpha', 0.7);
        area(ax, years, d.embodied + d.operational, ...
            'FaceColor', [0.85 0.33 0.10], 'EdgeColor', 'none', 'FaceAlpha', 0.7);
        area(ax, years, d.embodied, ...
            'FaceColor', [0.20 0.45 0.70], 'EdgeColor', 'none', 'FaceAlpha', 0.7);
        plot(ax, years, d.total, '-k', 'LineWidth', 1.2);

        plot(ax, [years(1) years(end)], [1 1], '--', 'LineWidth', 1.0, 'Color', [1 0 0 0.7]);

        ylim(ax, [0 2]);
        xlim(ax, [years(1) years(end)]);
        grid(ax, 'on');
        box(ax, 'off');
        set(ax, 'FontSize', 7);

        title(ax, sprintf('%s\n(%s)', d.cat_name, d.cat_unit), ...
            'FontSize', 7.5, 'FontWeight', 'bold', 'Interpreter', 'none');
        xlabel(ax, 'Year', 'FontSize', 7);
        ylabel(ax, 'Share of PB (Norway)', 'FontSize', 7);

        % FIX 1 : un seul label rouge sur la ligne rouge, plus de texte bordeaux
        pb_label = sprintf('Planetary boundary = %.2e %s/yr', d.PB_norway, d.cat_unit);
        text(ax, years(1) + 0.3, 1.04, pb_label, ...
            'FontSize', 5.5, 'Color', 'r', 'Interpreter', 'none', ...
            'VerticalAlignment', 'bottom');
    end

      % Légende via annotation invisible
    ax_tmp = axes('Parent', fig, 'Position', [0.83 0.30 0.14 0.35], ...
        'Visible', 'off', 'Color', 'none', 'XColor', 'none', 'YColor', 'none');
    hold(ax_tmp, 'on');
    h1 = fill(ax_tmp, NaN, NaN, [0.20 0.45 0.70], 'EdgeColor', 'none', 'FaceAlpha', 0.7);
    h2 = fill(ax_tmp, NaN, NaN, [0.85 0.33 0.10], 'EdgeColor', 'none', 'FaceAlpha', 0.7);
    h3 = fill(ax_tmp, NaN, NaN, [0.47 0.67 0.19], 'EdgeColor', 'none', 'FaceAlpha', 0.7);
    h4 = plot(ax_tmp, NaN, NaN, '-k',  'LineWidth', 1.2);
    h5 = plot(ax_tmp, NaN, NaN, '--r', 'LineWidth', 1.0);
    leg = legend(ax_tmp, [h1 h2 h3 h4 h5], ...
        {'Embodied', 'Operational', 'Infrastructure', 'Total', 'Planetary boundary'}, ...
        'Location', 'best', 'FontSize', 7.5, 'Box', 'on', 'Color', 'white', 'EdgeColor', [0.5 0.5 0.5]);

    % FIX 3 : titre de page déplacé au-dessus de la légende (pas en haut de figure)
    annotation(fig, 'textbox', [0.815 0.67 0.17 0.10], ...
        'String', {'EF v3.1 midpoint impacts', 'vs planetary boundaries', '(per capita, Sala et al. 2020)'}, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
        'FontSize', 7, 'FontWeight', 'bold', 'EdgeColor', 'none', ...
        'BackgroundColor', 'none', 'Interpreter', 'none');

    page = page + 1;
    export_page(fig, output_pdf, page);
    fprintf('Page %d : categories %d to %d\n', page, idx_start, idx_end);
end

%% Export source data to Excel
base_path  = fileparts(fileparts(fileparts(mfilename('fullpath'))));
output_dir = fullfile(base_path, 'Output');

source_dir = fullfile(output_dir, 'Source_data');
if ~exist(source_dir, 'dir'), mkdir(source_dir); end
output_xlsx = fullfile(source_dir, 'planetary_boundary_EF_individual.xlsx');
if exist(output_xlsx, 'file'), delete(output_xlsx); end

header = [{'Year'}, {'Embodied'}, {'Operational'}, {'Infrastructure'}, {'Total'}, {'PB_norway'}];

for k = 1:n_valid
    d = cats_data(k);
    cat_name_clean = strrep(strrep(d.cat_name, ':', '-'), '/', '-');
    cat_name_clean = cat_name_clean(1:min(end,31));
    data_out = [num2cell(years'), num2cell(d.embodied'), num2cell(d.operational'), ...
                num2cell(d.infra'), num2cell(d.total'), ...
                num2cell(repmat(d.PB_norway, n_years, 1))];
    writecell([header; data_out], output_xlsx, 'Sheet', cat_name_clean);
end

fprintf('Excel saved: %s\n', output_xlsx);
fprintf('\nDone! PDF: %s\n', output_pdf);

end