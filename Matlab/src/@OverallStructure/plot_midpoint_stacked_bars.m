function plot_midpoints_stacked_bars(obj)
 
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
n_cats_recipe = 23;
cat_names = {midpoint_categories(1:n_cats_recipe).name};
 
years_all = [obj.State.year];
year_indices = zeros(1, n_years);
for y = 1:n_years
    year_indices(y) = find(years_all == years_to_plot(y));
end
 
% collect datas
data = zeros(n_cats_recipe, n_years, n_flds);
for y = 1:n_years
    state = obj.State(year_indices(y));
    for c = 1:n_cats_recipe
        for f = 1:n_flds
            data(c, y, f) = state.Midpoint_impacts_new_cars(c).(flds{f});
        end
    end
end
 
% Normalise by 2000
data_norm = zeros(size(data));
for c = 1:n_cats_recipe
    total_2000 = sum(squeeze(data(c, 1, :)));
    if total_2000 ~= 0
        data_norm(c, :, :) = data(c, :, :) / total_2000;
    end
end
 
% size
bar_height  = 0.12;   
bar_spacing = 0.20;   
group_gap   = 0.30;   
 
y_positions = zeros(n_cats_recipe, n_years);
for c = 1:n_cats_recipe
    base = (c-1) * (n_years * bar_spacing + group_gap);
    for y = 1:n_years
        y_positions(c, y) = base + (y-1) * bar_spacing;
    end
end
 
fig = figure('Visible', 'off', 'Units', 'centimeters', 'Position', [2 2 42 28]);
ax = axes('Parent', fig, 'Position', [0.32 0.08 0.64 0.88]);
hold(ax, 'on');
 
for c = 1:n_cats_recipe
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
 
% percentage
for c = 1:n_cats_recipe
    for y = 2:n_years  % 2010, 2023
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

% separator lines between categories
for c = 1:n_cats_recipe-1
    sep_y = (y_positions(c, n_years) + y_positions(c+1, 1)) / 2;
    plot(ax, [0 3], [sep_y sep_y], '-', 'Color', [0.88 0.88 0.88], 'LineWidth', 0.5);
end
 
% labels
cat_label_y = mean(y_positions, 2);
for c = 1:n_cats_recipe
    text(ax, -0.3, cat_label_y(c), cat_names{c}, ...
        'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'middle', ...
        'FontSize', 7, 'FontWeight', 'bold');
end
 
for c = 1:n_cats_recipe
    for y = 1:n_years
        text(ax, -0.1, y_positions(c,y), year_labels{y}, ...
            'HorizontalAlignment', 'right', ...
            'VerticalAlignment', 'middle', ...
            'FontSize', 6, 'Color', [0.45 0.45 0.45]);
    end
end
 
% line x=1
xline(ax, 1, '--', 'Color', [0.3 0.3 0.3], 'LineWidth', 1.0);
 
set(ax, 'YTick', [], 'YDir', 'reverse', 'FontSize', 8);
xlabel(ax, 'Normalized impact (relative to year 2000)', 'FontSize', 9);
title(ax, 'Midpoint impacts ReCiPe2016 : Norwegian new cars (2000, 2010, 2023)', ...
    'FontSize', 10, 'FontWeight', 'bold');
max_val = max(arrayfun(@(c) max(sum(squeeze(data_norm(c,:,:)), 2)), 1:n_cats_recipe));
xlim(ax, [-0.015 max_val * 1.15]);
ylim(ax, [y_positions(1,1) - bar_spacing, y_positions(end,end) + bar_spacing]);
grid(ax, 'off');
box(ax, 'off');
 
% legend
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
output_pdf = fullfile(output_dir, 'comparison_2000_2010_2023_stacked_bars_midpoints_ReCiPe.pdf');

set(fig, 'PaperUnits', 'centimeters');
set(fig, 'PaperSize', [42 28]);

drawnow;  
exportgraphics(fig, output_pdf, 'ContentType', 'vector');

%% Export source data to Excel
base_path  = fileparts(fileparts(fileparts(mfilename('fullpath'))));
output_dir = fullfile(base_path, 'Output');

source_dir = fullfile(output_dir, 'Source_data');
if ~exist(source_dir, 'dir'), mkdir(source_dir); end
output_xlsx = fullfile(source_dir, 'stacked_bars_ReCiPe.xlsx');
if exist(output_xlsx, 'file'), delete(output_xlsx); end

header = [{'Category'}, contributor_labels];
for y = 1:n_years
    data_out = [cat_names', num2cell(squeeze(data_norm(:, y, :)))];
    writecell([header; data_out], output_xlsx, 'Sheet', year_labels{y});
end

fprintf('Excel saved: %s\n', output_xlsx);

fprintf('PDF saved: %s\n', output_pdf);

end