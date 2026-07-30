function plot_figure2_norm_2000_EF(obj)
% Use : OS.plot_figure2_norm_2000_EF()

years_to_plot  = [2000, 2010, 2023];
year_labels    = {'2000', '2010', '2023'};
n_years        = length(years_to_plot);

flds = {'value_glider','value_powertrain','value_energy_storage', ...
        'value_maintenance','value_EoL', ...
        'value_road','value_energy_chain','value_direct_non_exhaust','value_direct_exhaust'};
contributor_labels = {'Glider','Powertrain','Energy storage', ...
                      'Maintenance','EoL','Road','Energy chain','Direct non-exhaust','Direct exhaust'};
n_flds = length(flds);

colors = [
    0.6353    0.0784    0.1843;
    0.8510    0.3255    0.0980;
    1.0000    0.4118    0.1608;
    0.9294    0.6941    0.1255;
    0.3922    0.8314    0.0745;
    0.0157    0.7686    0.5176;
    0.0745    0.6235    1.0000;
    0    0.4471    0.7412;
    0     0     0;
];

midpoint_categories = get_midpoint_categories();
ef_start = 24;
ef_end   = length(midpoint_categories);
n_cats_EF = ef_end - ef_start + 1;
cat_names_all = {midpoint_categories(ef_start:ef_end).name};
cat_names_all = strrep(cat_names_all, ' EF', '');

ef_cats_to_exclude = [3, 4, 5];
cats_to_plot = setdiff(1:n_cats_EF, ef_cats_to_exclude);
n_cats_plot  = length(cats_to_plot);
cat_names    = cat_names_all(cats_to_plot);

years_all = [obj.State.year];
year_indices = zeros(1, n_years);
for y = 1:n_years
    year_indices(y) = find(years_all == years_to_plot(y));
end

% datas
data = zeros(n_cats_plot, n_years, n_flds);
for y = 1:n_years
    state = obj.State(year_indices(y));
    for c = 1:n_cats_plot
        cat_idx = ef_start + cats_to_plot(c) - 1;
        for f = 1:n_flds
            data(c, y, f) = state.Midpoint_impacts_new_cars(cat_idx).(flds{f});
        end
    end
end

% Normalise by 2000
data_norm = zeros(size(data));
for c = 1:n_cats_plot
    total_2000 = sum(squeeze(data(c, 1, :)));
    if total_2000 ~= 0
        data_norm(c, :, :) = data(c, :, :) / total_2000;
    end
end

bar_height  = 0.12;
bar_spacing = 0.20;
group_gap   = 0.30;

y_positions = zeros(n_cats_plot, n_years);
for c = 1:n_cats_plot
    base = (c-1) * (n_years * bar_spacing + group_gap);
    for y = 1:n_years
        y_positions(c, y) = base + (y-1) * bar_spacing;
    end
end

fig = figure('Visible', 'off', 'Units', 'centimeters', 'Position', [2 2 18 21]);
set(fig, 'Color', 'white');
ax = axes('Parent', fig, 'Position', [0.38 0.10 0.56 0.85]);
hold(ax, 'on');

for c = 1:n_cats_plot
    for y = 1:n_years
        x_start = 0;
        for f = 1:n_flds
            val = data_norm(c, y, f);
            if abs(val) > 1e-12
                x_rect = [x_start, x_start+val, x_start+val, x_start];
                y_rect = [y_positions(c,y)-bar_height/2, ...
                          y_positions(c,y)-bar_height/2, ...
                          y_positions(c,y)+bar_height/2, ...
                          y_positions(c,y)+bar_height/2];
                patch(ax, x_rect, y_rect, colors(f,:), 'EdgeColor', 'none');
                x_start = x_start + val;
            end
        end
    end
end


for c = 1:n_cats_plot
    for y = 2:n_years
        total_norm = sum(squeeze(data_norm(c, y, :)));
        pct_change = (total_norm - 1) * 100;
        x_end = total_norm;
        if pct_change >= 0
            pct_str = sprintf('+%.0f%%', pct_change);
        else
            pct_str = sprintf('%.0f%%', pct_change);
        end
        text(ax, x_end + 0.02, y_positions(c,y), pct_str, ...
            'HorizontalAlignment', 'left', ...
            'VerticalAlignment', 'middle', ...
            'FontSize', 5.5, 'Color', [0.2 0.2 0.2]);
    end
end

for c = 1:n_cats_plot-1
    sep_y = (y_positions(c, n_years) + y_positions(c+1, 1)) / 2;
    plot(ax, [0 3], [sep_y sep_y], '-', 'Color', [0.88 0.88 0.88], 'LineWidth', 0.5);
end

cat_label_y = mean(y_positions, 2);
for c = 1:n_cats_plot
    name = cat_names{c};
    if length(name) > 25
        space_idx = strfind(name, ' ');
        mid = length(name) / 2;
        [~, best] = min(abs(space_idx - mid));
        cut = space_idx(best);
        name = {name(1:cut-1), name(cut+1:end)};
    end
    text(ax, -0.4, cat_label_y(c), name, ...
        'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'middle', ...
        'FontSize', 6.5, 'FontWeight', 'bold');
end

for c = 1:n_cats_plot
    for y = 1:n_years
        text(ax, -0.1, y_positions(c,y), year_labels{y}, ...
            'HorizontalAlignment', 'right', ...
            'VerticalAlignment', 'middle', ...
            'FontSize', 6, 'Color', [0.45 0.45 0.45]);
    end
end

xline(ax, 1, '--', 'Color', [0.3 0.3 0.3], 'LineWidth', 1.0);

set(ax, 'YTick', [], 'YDir', 'reverse', 'FontSize', 8);
xlabel(ax, 'Normalized impact (relative to year 2000)', 'FontSize', 8);
max_val = max(arrayfun(@(c) max(sum(squeeze(data_norm(c,:,:)), 2)), 1:n_cats_plot));
xlim(ax, [-0.015 max_val * 1.15]);
ylim(ax, [y_positions(1,1) - bar_spacing, y_positions(end,end) + bar_spacing]);
grid(ax, 'off');
box(ax, 'off');

h = zeros(1, n_flds);
for f = 1:n_flds
    h(f) = patch(ax, NaN, NaN, colors(f,:), 'EdgeColor', 'none');
end
legend(ax, h, contributor_labels, ...
    'Location', 'southoutside', ...
    'Orientation', 'horizontal', ...
    'FontSize', 7, 'Box', 'off', ...
    'NumColumns', 5);

% PDF
base_path  = fileparts(fileparts(fileparts(mfilename('fullpath'))));
output_dir = fullfile(base_path, 'Output');
if ~exist(output_dir, 'dir'), mkdir(output_dir); end
output_pdf = fullfile(output_dir, 'figure2_norm_2000_EF.pdf');

set(fig, 'PaperUnits', 'centimeters');
set(fig, 'PaperSize', [18 21]);

drawnow;
exportgraphics(fig, output_pdf, 'ContentType', 'vector');

%% Excel
base_path  = fileparts(fileparts(fileparts(mfilename('fullpath'))));
output_dir = fullfile(base_path, 'Output');

source_dir = fullfile(output_dir, 'Source_data');
if ~exist(source_dir, 'dir'), mkdir(source_dir); end
output_xlsx = fullfile(source_dir, 'figure2_norm_2000_EF.xlsx');
if exist(output_xlsx, 'file'), delete(output_xlsx); end

header = [{'Category'}, contributor_labels];
for y = 1:n_years
    data_out = [cat_names', num2cell(squeeze(data_norm(:, y, :)))];
    writecell([header; data_out], output_xlsx, 'Sheet', year_labels{y});
end

fprintf('Excel saved: %s\n', output_xlsx);

fprintf('PDF saved: %s\n', output_pdf);

end