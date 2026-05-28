function plot_normalization_ReCiPe_individual(obj)

% Normalization of ReCiPe midpoint impacts against global impact reference
% Source: get_normalization_factors_ReCiPe (ReCiPe 2016 v1.1 Hierarchist)
% Per capita allocation (egalitarian): Norway pop / world pop 2010
% Layout: 4 categories per page (2x2 grid), shared legend + title on right side

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
            exportgraphics(fig, pdf, 'Append', false, 'ContentType', 'vector', 'BackgroundColor', 'white');
        else
            exportgraphics(fig, pdf, 'Append', true,  'ContentType', 'vector', 'BackgroundColor', 'white');
        end
        close(fig);
    end

% Precompute all valid categories
cats_data = struct();
n_valid = 0;

for cat = 1:23
    if ismember(cat, cats_to_exclude), continue; end

    norm_W = NormFactors.midpoint_World(cat);
    if isnan(norm_W) || norm_W <= 0, continue; end

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
    if all(total == 0), continue; end

    n_valid = n_valid + 1;
    cats_data(n_valid).cat_name    = cat_name;
    cats_data(n_valid).cat_unit    = cat_unit;
    cats_data(n_valid).norm_norway = norm_norway;
    cats_data(n_valid).embodied    = embodied;
    cats_data(n_valid).operational = operational;
    cats_data(n_valid).infra       = infra;
    cats_data(n_valid).total       = total;
end

% Plot 4 per page
cats_per_page = 4;
n_pages = ceil(n_valid / cats_per_page);

ax_positions = [
    0.06  0.55  0.35  0.38;
    0.45  0.55  0.35  0.38;
    0.06  0.08  0.35  0.38;
    0.45  0.08  0.35  0.38;
];

for pg = 1:n_pages
    idx_start = (pg-1)*cats_per_page + 1;
    idx_end   = min(pg*cats_per_page, n_valid);
    n_on_page = idx_end - idx_start + 1;

    fig = figure('Visible', 'off', 'Units', 'centimeters', 'Position', [2 2 38 24]);
    set(fig, 'Color', 'white');

    for k = 1:n_on_page
        d  = cats_data(idx_start + k - 1);
        ax = axes('Parent', fig, 'Position', ax_positions(k,:)); 
        hold(ax, 'on');

        % Calcul du facteur d'échelle pour que le max soit entre 0.2 et 2
        max_total = max(d.total);
        if max_total <= 0
            scale = 1;
        else
            scale = 1;
            while max_total * scale > 2,   scale = scale / 10; end
            while max_total * scale < 0.2, scale = scale * 10; end
        end

        area(ax, years, (d.embodied + d.operational + d.infra) * scale, ...
            'FaceColor', [0.47 0.67 0.19], 'EdgeColor', 'none', 'FaceAlpha', 0.7);
        area(ax, years, (d.embodied + d.operational) * scale, ...
            'FaceColor', [0.85 0.33 0.10], 'EdgeColor', 'none', 'FaceAlpha', 0.7);
        area(ax, years, d.embodied * scale, ...
            'FaceColor', [0.20 0.45 0.70], 'EdgeColor', 'none', 'FaceAlpha', 0.7);
        
        plot(ax, years, d.total * scale, '-k', 'LineWidth', 1.2);
        
        val_2000 = d.total(1) * scale;
        plot(ax, [years(1) years(end)], [val_2000 val_2000], '--', ...
            'LineWidth', 1.0, 'Color', [0.3 0.3 0.3 0.6]);
        
        ref_label = sprintf('Global ref. = %.2e %s/yr', d.norm_norway, d.cat_unit);
        text(ax, years(1) + 0.3, 1.97, ref_label, ...
            'FontSize', 5.5, 'Color', [0.2 0.2 0.6], 'Interpreter', 'none', ...
            'VerticalAlignment', 'top');
        
        ylim(ax, [0 2]);
        xlim(ax, [years(1) years(end)]);
        grid(ax, 'on');
        box(ax, 'off');
        set(ax, 'FontSize', 7);

        title(ax, sprintf('%s\n(%s)', d.cat_name, d.cat_unit), ...
            'FontSize', 7.5, 'FontWeight', 'bold', 'Interpreter', 'none');
        xlabel(ax, 'Year', 'FontSize', 7);
        if scale == 1
            ylabel(ax, 'Share of global impact reference (Norway)', 'FontSize', 7);
        else
            ylabel(ax, sprintf('Share of global impact reference (Norway) ×%.0e', 1/scale), 'FontSize', 7);
        end
    end

    % Shared legend — transparent axes background
    ax_tmp = axes('Parent', fig, 'Position', [0.83 0.30 0.14 0.35], ...
        'Visible', 'off', 'Color', 'none', 'XColor', 'none', 'YColor', 'none');
    hold(ax_tmp, 'on');
    h1 = fill(ax_tmp, NaN, NaN, [0.20 0.45 0.70], 'EdgeColor', 'none', 'FaceAlpha', 0.7);
    h2 = fill(ax_tmp, NaN, NaN, [0.85 0.33 0.10], 'EdgeColor', 'none', 'FaceAlpha', 0.7);
    h3 = fill(ax_tmp, NaN, NaN, [0.47 0.67 0.19], 'EdgeColor', 'none', 'FaceAlpha', 0.7);
    h4 = plot(ax_tmp, NaN, NaN, '-k',  'LineWidth', 1.2);
    h5 = plot(ax_tmp, NaN, NaN, '--', 'LineWidth', 1.0, 'Color', [0.3 0.3 0.3]);
    legend(ax_tmp, [h1 h2 h3 h4 h5], ...
        {'Embodied', 'Operational', 'Infrastructure', 'Total', 'Year 2000 level'}, ...
        'Location', 'best', 'FontSize', 7.5, 'Box', 'on', 'Color', 'white', ...
        'EdgeColor', [0.5 0.5 0.5]);

    % Title above legend
    annotation(fig, 'textbox', [0.815 0.67 0.17 0.10], ...
        'String', {'ReCiPe 2016 midpoint impacts', 'normalised vs global reference', '(per capita, Norway)'}, ...
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
output_xlsx = fullfile(source_dir, 'normalization_ReCiPe_individual.xlsx');

if exist(output_xlsx, 'file'), delete(output_xlsx); end

header = {'Year', 'Embodied', 'Operational', 'Infrastructure', 'Total'};

for k = 1:n_valid
    d = cats_data(k);
    cat_name_clean = strrep(strrep(d.cat_name, ':', '-'), '/', '-');
    cat_name_clean = cat_name_clean(1:min(end,31));
    data_out = [num2cell(years'), num2cell(d.embodied'), num2cell(d.operational'), ...
                num2cell(d.infra'), num2cell(d.total')];
    writecell([header; data_out], output_xlsx, 'Sheet', cat_name_clean);
end

fprintf('Excel saved: %s\n', output_xlsx);
fprintf('\nDone! PDF: %s\n', output_pdf);

end