function plot_figureS2_S3_norm_2000_ReCiPe_midpoints(obj)
 
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

% Categories to exclude from main plot
cats_to_exclude_main = [3, 20, 21, 22, 23];
cats_human_noise     = [23];
 
years_all = [obj.State.year];
year_indices = zeros(1, n_years);
for y = 1:n_years
    year_indices(y) = find(years_all == years_to_plot(y));
end
 
data = zeros(n_cats_recipe, n_years, n_flds);
for y = 1:n_years
    state = obj.State(year_indices(y));
    for c = 1:n_cats_recipe
        for f = 1:n_flds
            data(c, y, f) = state.Midpoint_impacts_new_cars(c).(flds{f});
        end
    end
end
 
data_norm = zeros(size(data));
for c = 1:n_cats_recipe
    total_2000 = sum(squeeze(data(c, 1, :)));
    if total_2000 ~= 0
        data_norm(c, :, :) = data(c, :, :) / total_2000;
    end
end

cats_main = setdiff(1:n_cats_recipe, cats_to_exclude_main);

%% PDF
base_path  = fileparts(fileparts(fileparts(mfilename('fullpath'))));
output_dir = fullfile(base_path, 'Output');
if ~exist(output_dir, 'dir'), mkdir(output_dir); end

output_pdf       = fullfile(output_dir, 'figureS2_norm_2000_ReCiPe_midpoints.pdf');
output_pdf_noise = fullfile(output_dir, 'figureS3_norm_2000_ReCiPe_human_noise.pdf');

make_and_save(cats_main, ...
    'Midpoint impacts ReCiPe2016 : Norwegian new cars (2000, 2010, 2023)', ...
    18.0, 21.0, output_pdf, ...
    data_norm, n_years, n_flds, year_labels, cat_names, colors, contributor_labels, flds);

% Second PDF: identical to the main plot (same categories, same order),
% with the human noise category.
cats_main_plus_noise = [cats_main, cats_human_noise];

make_and_save(cats_main_plus_noise, ...
    'Midpoint impacts ReCiPe2016 : Norwegian new cars (2000, 2010, 2023) — incl. human noise', ...
    18.0, 21.0, output_pdf_noise, ...
    data_norm, n_years, n_flds, year_labels, cat_names, colors, contributor_labels, flds);

%% Excel
source_dir = fullfile(output_dir, 'Source_data');
if ~exist(source_dir, 'dir'), mkdir(source_dir); end
output_xlsx = fullfile(source_dir, 'plot_figureS2_S3_norm_2000_ReCiPe_midpoints.xlsx');
if exist(output_xlsx, 'file'), delete(output_xlsx); end
header = [{'Category'}, contributor_labels];
for y = 1:n_years
    data_out = [cat_names', num2cell(squeeze(data_norm(:, y, :)))];
    writecell([header; data_out], output_xlsx, 'Sheet', year_labels{y});
end
fprintf('Excel saved: %s\n', output_xlsx);

end


function make_and_save(cat_indices, fig_title, fig_w_cm, fig_h_cm, output_pdf, ...
    data_norm, n_years, n_flds, year_labels, cat_names, colors, contributor_labels, flds)

n_c = length(cat_indices);
bar_height  = 0.12;
bar_spacing = 0.20;
group_gap   = 0.30;

y_pos = zeros(n_c, n_years);
for ci = 1:n_c
    base = (ci-1) * (n_years * bar_spacing + group_gap);
    for y = 1:n_years
        y_pos(ci, y) = base + (y-1) * bar_spacing;
    end
end

fig = figure('Visible', 'off', 'Units', 'centimeters', 'Position', [2 2 fig_w_cm fig_h_cm]);
set(fig, 'Color', 'white');
ax = axes('Parent', fig, 'Position', [0.38 0.10 0.56 0.85]);
hold(ax, 'on');

for ci = 1:n_c
    c = cat_indices(ci);
    for y = 1:n_years
        x_start = 0;
        for f = 1:n_flds
            val = data_norm(c, y, f);
            if abs(val) > 1e-12
                x_rect = [x_start, x_start+val, x_start+val, x_start];
                y_rect = [y_pos(ci,y)-bar_height/2, y_pos(ci,y)-bar_height/2, ...
                          y_pos(ci,y)+bar_height/2, y_pos(ci,y)+bar_height/2];
                patch(ax, x_rect, y_rect, colors(f,:), 'EdgeColor', 'none');
                x_start = x_start + val;
            end
        end
    end
end


for ci = 1:n_c
    c = cat_indices(ci);
    for y = 2:n_years
        total_norm = sum(squeeze(data_norm(c, y, :)));
        pct_change = (total_norm - 1) * 100;
        if pct_change >= 0
            pct_str = sprintf('+%.0f%%', pct_change);
        else
            pct_str = sprintf('%.0f%%', pct_change);
        end
        text(ax, total_norm + 0.02, y_pos(ci,y), pct_str, ...
            'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle', ...
            'FontSize', 5.5, 'Color', [0.2 0.2 0.2]);
    end
end

for ci = 1:n_c-1
    sep_y = (y_pos(ci, n_years) + y_pos(ci+1, 1)) / 2;
    plot(ax, [0 3], [sep_y sep_y], '-', 'Color', [0.88 0.88 0.88], 'LineWidth', 0.5);
end


cat_label_y = mean(y_pos, 2);
for ci = 1:n_c
    c = cat_indices(ci);
    name = cat_names{c};
    if length(name) > 25
        space_idx = strfind(name, ' ');
        mid = length(name) / 2;
        [~, best] = min(abs(space_idx - mid));
        cut = space_idx(best);
        name = {name(1:cut-1), name(cut+1:end)};
    end
    text(ax, -0.4, cat_label_y(ci), name, ...
        'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle', ...
        'FontSize', 6.5, 'FontWeight', 'bold');
end

for ci = 1:n_c
    for y = 1:n_years
        text(ax, -0.1, y_pos(ci,y), year_labels{y}, ...
            'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle', ...
            'FontSize', 6, 'Color', [0.45 0.45 0.45]);
    end
end

xline(ax, 1, '--', 'Color', [0.3 0.3 0.3], 'LineWidth', 1.0);

set(ax, 'YTick', [], 'YDir', 'reverse', 'FontSize', 8);
xlabel(ax, 'Normalized impact (relative to year 2000)', 'FontSize', 8);

max_val = max(arrayfun(@(ci) max(sum(squeeze(data_norm(cat_indices(ci),:,:)), 2)), 1:n_c));
xlim(ax, [-0.015 max_val * 1.15]);
ylim(ax, [y_pos(1,1) - bar_spacing, y_pos(end,end) + bar_spacing]);
grid(ax, 'off');
box(ax, 'off');

h = zeros(1, n_flds);
for f = 1:n_flds
    h(f) = patch(ax, NaN, NaN, colors(f,:), 'EdgeColor', 'none');
end
legend(ax, h, contributor_labels, ...
    'Location', 'southoutside', 'Orientation', 'horizontal', ...
    'FontSize', 7, 'Box', 'off', 'NumColumns', 5);

set(fig, 'PaperUnits', 'centimeters', 'PaperSize', [fig_w_cm fig_h_cm]);
drawnow;
exportgraphics(fig, output_pdf, 'ContentType', 'vector');
close(fig);
fprintf('PDF saved: %s\n', output_pdf);

end