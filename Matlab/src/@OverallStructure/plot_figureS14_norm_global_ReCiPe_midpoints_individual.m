function plot_figureS14_norm_global_ReCiPe_midpoints_individual(obj)

% Normalization of ReCiPe midpoint impacts against global impact reference
% Source: get_normalization_factors_ReCiPe (ReCiPe 2016 v1.1 Hierarchist)
% Per capita allocation (egalitarian): Norway pop / world pop 2010

% Use : OS.plot_figureS14_norm_global_ReCiPe_midpoints_individual()

NormFactors  = get_normalization_factors_ReCiPe();
pop_2010     = 6895889018;
pop_norway   = 5400000;
vkm_per_year = 12000;
lifetime_km  = 200000;

cats_to_exclude = [3, 20, 21, 22, 23];

years   = [obj.State.year];
n_years = length(years);

midpoint_categories = get_midpoint_categories();

base_path  = fileparts(fileparts(fileparts(mfilename('fullpath'))));
output_dir = fullfile(base_path, 'Output');
if ~exist(output_dir, 'dir'), mkdir(output_dir); end
output_pdf = fullfile(output_dir, 'figureS14_norm_global_ReCiPe_midpoints_individual.pdf');
if exist(output_pdf, 'file'), delete(output_pdf); end

output_pdf_portrait = fullfile(output_dir, 'plot_figureS14_norm_global_ReCiPe_midpoints_individual_portrait.pdf');
if exist(output_pdf_portrait, 'file'), delete(output_pdf_portrait); end

page = 0;

    function export_page(fig, pdf, pg, use_print)
        if nargin < 4
            use_print = false;
        end
        if use_print
            set(fig, 'PaperPositionMode', 'manual');
            [pdf_dir, pdf_name, pdf_ext] = fileparts(pdf);
            page_pdf = fullfile(pdf_dir, sprintf('%s_page%d%s', pdf_name, pg, pdf_ext));
            print(fig, page_pdf, '-dpdf', '-painters');
        else
            if pg == 1
                exportgraphics(fig, pdf, 'Append', false, 'ContentType', 'vector', 'BackgroundColor', 'white');
            else
                exportgraphics(fig, pdf, 'Append', true,  'ContentType', 'vector', 'BackgroundColor', 'white');
            end
        end
        close(fig);
    end

% categories
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

% plot
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

        max_total = max(d.total);
        if max_total <= 0
            scale = 1;
        else
            scale = 1;
        end

        plot(ax, years, d.operational * scale, '-', 'Color', [0.85 0.33 0.10], 'LineWidth', 1.5);
        plot(ax, years, d.embodied * scale, '-', 'Color', [0.20 0.45 0.70], 'LineWidth', 1.5);
        plot(ax, years, d.infra * scale, '-', 'Color', [0.47 0.67 0.19], 'LineWidth', 1.5);
        plot(ax, years, d.total * scale, '-k', 'LineWidth', 1.8);

        % Reference line at the global per-capita reference (= 1 on the
        % normalized scale), same style as the planetary boundary line
        % used in the EF plots.
        plot(ax, [years(1) years(end)], [1 1], '--r', 'LineWidth', 2.0);
        ref_label = sprintf('Global ref. (Norway) = %.2e %s/yr', d.norm_norway, d.cat_unit);
        if strcmp(d.cat_name, 'human toxicity: carcinogenic')
            text(ax, years(end), 1e-5, ref_label, ...
                'FontSize', 10, 'Color', 'r', 'Interpreter', 'none', ...
                'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        else
            text(ax, years(end), 50, ref_label, ...
                'FontSize', 10, 'Color', 'r', 'Interpreter', 'none', ...
                'VerticalAlignment', 'top', 'HorizontalAlignment', 'right');
        end
        
        set(ax, 'YScale', 'log');
        ylim(ax, [1e-5 1e2]);
        xlim(ax, [years(1) years(end)]);
        grid(ax, 'on');
        box(ax, 'off');
        set(ax, 'FontSize', 10);

        title(ax, sprintf('%s (%s)', d.cat_name, d.cat_unit), ...
            'FontSize', 13, 'FontWeight', 'bold', 'Interpreter', 'none');
        xlabel(ax, 'Year', 'FontSize', 10);
        ylabel(ax, 'Share of global impact reference (Norway, log scale)', 'FontSize', 10);
    end

    % legend
    ax_tmp = axes('Parent', fig, 'Position', [0.83 0.30 0.14 0.35], ...
    'Visible', 'off', 'Color', 'none', 'XColor', 'none', 'YColor', 'none');
    hold(ax_tmp, 'on');
    h_ops  = plot(ax_tmp, NaN, NaN, '-', 'Color', [0.85 0.33 0.10], 'LineWidth', 1.5);
    h_emb  = plot(ax_tmp, NaN, NaN, '-', 'Color', [0.20 0.45 0.70], 'LineWidth', 1.5);
    h_inf  = plot(ax_tmp, NaN, NaN, '-', 'Color', [0.47 0.67 0.19], 'LineWidth', 1.5);
    h_tot  = plot(ax_tmp, NaN, NaN, '-k',  'LineWidth', 1.8);
    h_ref  = plot(ax_tmp, NaN, NaN, '--r', 'LineWidth', 2.0);
    legend(ax_tmp, [h_ops h_emb h_inf h_tot h_ref], ...
        {'Operational', 'Embodied', 'Infrastructure', 'Total', 'Global ref. (Norway)'}, ...
        'Location', 'best', 'FontSize', 9, 'Box', 'on', 'Color', 'white', ...
        'EdgeColor', [0.5 0.5 0.5]);

    % title
    annotation(fig, 'textbox', [0.815 0.67 0.17 0.10], ...
        'String', {'ReCiPe 2016 midpoint impacts', 'normalised vs global reference', '(per capita, Norway)'}, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
        'FontSize', 8, 'FontWeight', 'bold', 'EdgeColor', 'none', ...
        'BackgroundColor', 'none', 'Interpreter', 'none');

    page = page + 1;
    export_page(fig, output_pdf, page);
    fprintf('Page %d : categories %d to %d\n', page, idx_start, idx_end);
end

%% Second PDF: portrait layout
cats_per_page_portrait = 9;
n_pages_portrait = ceil(n_valid / cats_per_page_portrait);
page_portrait = 0;

n_cols_p = 2;
n_rows_p = 5;
lm_p = 0.10; rm_p = 0.04; tm_p = 0.03; bm_p = 0.04;
hgap_p = 0.14; vgap_p = 0.09;
cell_w_p = (1 - lm_p - rm_p - (n_cols_p-1)*hgap_p) / n_cols_p;
cell_h_p = (1 - tm_p - bm_p - (n_rows_p-1)*vgap_p) / n_rows_p;

ax_positions_portrait = zeros(n_cols_p * n_rows_p, 4);
for r = 1:n_rows_p
    for c = 1:n_cols_p
        idx = (r-1)*n_cols_p + c;
        left   = lm_p + (c-1)*(cell_w_p + hgap_p);
        bottom = 1 - tm_p - r*cell_h_p - (r-1)*vgap_p;
        ax_positions_portrait(idx,:) = [left, bottom, cell_w_p, cell_h_p];
    end
end

for pg = 1:n_pages_portrait
    idx_start = (pg-1)*cats_per_page_portrait + 1;
    idx_end   = min(pg*cats_per_page_portrait, n_valid);
    n_on_page = idx_end - idx_start + 1;

    fig = figure('Visible', 'off', 'Units', 'centimeters', 'Position', [2 2 21 29.7], ...
        'PaperUnits', 'centimeters', 'PaperSize', [21 29.7], 'PaperPosition', [0 0 21 29.7]);
    set(fig, 'Color', 'white');

    for k = 1:n_on_page
        d  = cats_data(idx_start + k - 1);
        ax = axes('Parent', fig, 'Position', ax_positions_portrait(k,:));
        hold(ax, 'on');

        max_total = max(d.total);
        if max_total <= 0
            scale = 1;
        else
            scale = 1;
        end

        plot(ax, years, d.operational * scale, '-', 'Color', [0.85 0.33 0.10], 'LineWidth', 1.2);
        plot(ax, years, d.embodied * scale, '-', 'Color', [0.20 0.45 0.70], 'LineWidth', 1.2);
        plot(ax, years, d.infra * scale, '-', 'Color', [0.47 0.67 0.19], 'LineWidth', 1.2);
        plot(ax, years, d.total * scale, '-k', 'LineWidth', 1.4);

        % Reference line at the global per-capita reference (= 1 on the
        % normalized scale), same style as the planetary boundary line
        % used in the EF plots.
        plot(ax, [years(1) years(end)], [1 1], '--r', 'LineWidth', 1.5);
        ref_label = sprintf('Global ref. (Norway) = %.2e %s/yr', d.norm_norway, d.cat_unit);
        if strcmp(d.cat_name, 'human toxicity: carcinogenic')
            text(ax, years(end), 1e-5, ref_label, ...
                'FontSize', 9, 'Color', 'r', 'Interpreter', 'none', ...
                'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        else
            text(ax, years(end), 50, ref_label, ...
                'FontSize', 9, 'Color', 'r', 'Interpreter', 'none', ...
                'VerticalAlignment', 'top', 'HorizontalAlignment', 'right');
        end

        set(ax, 'YScale', 'log');
        ylim(ax, [1e-5 1e2]);
        set(ax, 'YTick', [1e-5 1e-4 1e-3 1e-2 1e-1 1e0 1e1 1e2]);
        xlim(ax, [years(1) years(end)]);
        grid(ax, 'on');
        box(ax, 'off');
        set(ax, 'FontSize', 9);

        title_name = d.cat_name;
        if length(title_name) > 40
            space_idx = strfind(title_name, ' ');
            if ~isempty(space_idx)
                mid = length(title_name) / 2;
                [~, best] = min(abs(space_idx - mid));
                cut = space_idx(best);
                title_name = [title_name(1:cut-1) newline title_name(cut+1:end)];
            end
        end
        title(ax, sprintf('%s (%s)', title_name, d.cat_unit), ...
            'FontSize', 11, 'FontWeight', 'bold', 'Interpreter', 'none');
        xlabel(ax, 'Year', 'FontSize', 9);
        ylabel(ax, 'Share (log)', 'FontSize', 9);
    end

    % legend 
    ax_leg_p = axes('Parent', fig, 'Position', ax_positions_portrait(10,:), ...
        'Visible', 'off', 'Color', 'none', 'XColor', 'none', 'YColor', 'none');
    hold(ax_leg_p, 'on');
    h_ops_p = plot(ax_leg_p, NaN, NaN, '-', 'Color', [0.85 0.33 0.10], 'LineWidth', 1.2);
    h_emb_p = plot(ax_leg_p, NaN, NaN, '-', 'Color', [0.20 0.45 0.70], 'LineWidth', 1.2);
    h_inf_p = plot(ax_leg_p, NaN, NaN, '-', 'Color', [0.47 0.67 0.19], 'LineWidth', 1.2);
    h_tot_p = plot(ax_leg_p, NaN, NaN, '-k',  'LineWidth', 1.4);
    h_ref_p = plot(ax_leg_p, NaN, NaN, '--r', 'LineWidth', 1.5);
    legend(ax_leg_p, [h_ops_p h_emb_p h_inf_p h_tot_p h_ref_p], ...
        {'Operational', 'Embodied', 'Infrastructure', 'Total', 'Global ref. (Norway)'}, ...
        'Location', 'north', 'FontSize', 10, 'Box', 'on', 'Color', 'white', ...
        'EdgeColor', [0.5 0.5 0.5]);

    page_portrait = page_portrait + 1;
    export_page(fig, output_pdf_portrait, page_portrait, true);
    fprintf('Portrait page %d : categories %d to %d\n', page_portrait, idx_start, idx_end);
end

%% excel
base_path  = fileparts(fileparts(fileparts(mfilename('fullpath'))));
output_dir = fullfile(base_path, 'Output');

source_dir = fullfile(output_dir, 'Source_data');
if ~exist(source_dir, 'dir'), mkdir(source_dir); end
output_xlsx = fullfile(source_dir, 'figureS14_norm_global_ReCiPe_midpoints_individual.xlsx');

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