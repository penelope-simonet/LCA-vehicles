function plot_figure3_norm_carrying_capacities_EF_EPC(obj)

% Source for PBs: Sala et al. (2020), Table 3
% Use : OS.plot_figure3_norm_carrying_capacities_EF_EPC()

pop_norway = 4889252;
NormFactors = get_normalization_factors_EF();
PB_norway = NormFactors.PB_per_capita * pop_norway;

vkm_per_year = 12000;
years = [obj.State.year];
n_years = length(years);

ef_start = 24;
ef_end   = 42;
n_cats_EF = ef_end - ef_start + 1;
ef_cats_to_exclude = [3, 4, 5];

midpoint_categories = get_midpoint_categories();
cat_names_raw = {midpoint_categories(ef_start:ef_end).name};
cat_names = strrep(cat_names_raw, ' EF', '');

share = zeros(n_cats_EF, n_years);

for i = 1:n_years
    state = obj.State(i);
    n_cars_total = 0;
    for at = 1:numel(state.VehicleArchetype)
        n_cars_total = n_cars_total + sum(state.VehicleArchetype(at).number_of_cars_from_year);
    end

    for c = 1:n_cats_EF
        cat_idx = ef_start + c - 1;
        impact_fleet = state.Midpoint_impacts(cat_idx).value * vkm_per_year * n_cars_total;
        pb = PB_norway(cat_idx);
        if pb > 0
            share(c, i) = impact_fleet / pb;
        else
            share(c, i) = NaN;
        end
    end
end

fig = figure('Visible', 'off', 'Units', 'centimeters', 'Position', [0 0 40 18]);
ax = axes('Parent', fig, 'Position', [0.10 0.08 0.64 0.88]);
hold(ax, 'on');

rouge        = [0.85 0.10 0.10];
jaune        = [0.80 0.68 0.00];
bleu_fonce   = [0.08 0.20 0.55];
bleu_clair   = [0.7 0.85 1];
bleu_cyan    = [0.3 0.7  1];
vert         = [0.10 0.60 0.20];
vert_clair   = [0.50 1.00 0.00];
orange       = [0.95 0.50 0.05];
violet       = [0.55 0.10 0.75];
violet_clair = [0.70 0.50 1.00];
marron       = [0.50 0.25 0.00];
gris         = [0.50 0.50 0.50];
noir         = [0.00 0.00 0.00];

cat_colors_EF = zeros(19, 3);
cat_lines_EF  = cell(19, 1);
cat_markers_EF = cell(19, 1);

cat_colors_EF(1,:)  = bleu_clair;   cat_lines_EF{1}  = '-';  cat_markers_EF{1}  = 'none';
cat_colors_EF(2,:)  = bleu_fonce;   cat_lines_EF{2}  = '-';  cat_markers_EF{2}  = 'none';
cat_colors_EF(3,:)  = bleu_fonce;   cat_lines_EF{3}  = '--'; cat_markers_EF{3}  = 'none';
cat_colors_EF(4,:)  = bleu_fonce;   cat_lines_EF{4}  = '-';  cat_markers_EF{4}  = 'o';
cat_colors_EF(5,:)  = bleu_fonce;   cat_lines_EF{5}  = '-';  cat_markers_EF{5}  = '^';
cat_colors_EF(6,:)  = rouge;        cat_lines_EF{6}  = '-';  cat_markers_EF{6}  = 'none';
cat_colors_EF(7,:)  = violet;       cat_lines_EF{7}  = '-';  cat_markers_EF{7}  = 'none';
cat_colors_EF(8,:)  = vert;         cat_lines_EF{8}  = '-';  cat_markers_EF{8}  = 'none';
cat_colors_EF(9,:)  = vert;         cat_lines_EF{9}  = '--'; cat_markers_EF{9}  = 'none';
cat_colors_EF(10,:) = vert;         cat_lines_EF{10} = '-';  cat_markers_EF{10} = 'o';
cat_colors_EF(11,:) = jaune;        cat_lines_EF{11} = '-';  cat_markers_EF{11} = 'none';
cat_colors_EF(12,:) = jaune;        cat_lines_EF{12} = '--'; cat_markers_EF{12} = 'none';
cat_colors_EF(13,:) = marron;       cat_lines_EF{13} = '-';  cat_markers_EF{13} = 'none';
cat_colors_EF(14,:) = gris;         cat_lines_EF{14} = '-';  cat_markers_EF{14} = 'none';
cat_colors_EF(15,:) = violet_clair; cat_lines_EF{15} = '-';  cat_markers_EF{15} = 'none';
cat_colors_EF(16,:) = noir;         cat_lines_EF{16} = '-';  cat_markers_EF{16} = 'none';
cat_colors_EF(17,:) = vert_clair;   cat_lines_EF{17} = '-';  cat_markers_EF{17} = 'none';
cat_colors_EF(18,:) = orange;       cat_lines_EF{18} = '-';  cat_markers_EF{18} = 'none';
cat_colors_EF(19,:) = bleu_cyan;    cat_lines_EF{19} = '-';  cat_markers_EF{19} = 'none';

marker_step = max(1, floor(n_years / 8));

for c = 1:n_cats_EF
    if ismember(c, ef_cats_to_exclude), continue; end
    v = share(c, :);
    if ~all(isnan(v)) && any(v > 0)
        if strcmp(cat_markers_EF{c}, 'none')
            plot(ax, years, v, cat_lines_EF{c}, 'Color', cat_colors_EF(c,:), 'LineWidth', 1.8);
        else
            plot(ax, years, v, cat_lines_EF{c}, 'Color', cat_colors_EF(c,:), ...
                'LineWidth', 1.8, 'Marker', cat_markers_EF{c}, ...
                'MarkerFaceColor', cat_colors_EF(c,:), 'MarkerEdgeColor', cat_colors_EF(c,:), ...
                'MarkerSize', 4, 'MarkerIndices', 1:marker_step:n_years);
        end
    end
end

plot(ax, [years(1) years(end)], [1 1], '--', 'LineWidth', 3.0, 'Color', [1 0 0 0.6]);
text(ax, years(end)+0.5, 1, sprintf('Carrying\ncapacities,\nEPC'), ...
    'FontSize', 10, 'Color', 'r', 'VerticalAlignment', 'middle', ...
    'HorizontalAlignment', 'left');

set(ax, 'YScale', 'log');
xlabel(ax, 'Year', 'FontSize', 10);
ylabel(ax, 'Share of Norwegian carrying capacities (EPC, log scale)', 'FontSize', 10);
grid(ax, 'on');
box(ax, 'off');
set(ax, 'FontSize', 10);

leg_labels = { ...
    'ecotoxicity: freshwater', ...
    'human toxicity: carcinogenic', ...
    'human toxicity: non-carcinogenic', ...
    'climate change', ...
    'acidification', ...
    'eutrophication: freshwater', ...
    'eutrophication: terrestrial', ...
    'eutrophication: marine', ...
    'particulate matter formation', ...
    'photochemical oxidant formation: human health', ...
    'material resources: metals/minerals', ...
    'energy resources: non-renewable', ...
    'ionising radiation: human health', ...
    'land use', ...
    'ozone depletion', ...
    'water use'};

h_leg = gobjects(16,1);
h_leg(1)  = plot(ax, NaN, NaN, '-',  'Color', rouge,        'LineWidth', 2);
h_leg(2)  = plot(ax, NaN, NaN, '-',  'Color', jaune,        'LineWidth', 2);
h_leg(3)  = plot(ax, NaN, NaN, '--', 'Color', jaune,        'LineWidth', 2);
h_leg(4)  = plot(ax, NaN, NaN, '-',  'Color', bleu_fonce,   'LineWidth', 2);
h_leg(5)  = plot(ax, NaN, NaN, '-',  'Color', bleu_clair,   'LineWidth', 2);
h_leg(6)  = plot(ax, NaN, NaN, '-',  'Color', vert,         'LineWidth', 2);
h_leg(7)  = plot(ax, NaN, NaN, '-o', 'Color', vert,         'LineWidth', 2, 'MarkerFaceColor', vert, 'MarkerEdgeColor', vert, 'MarkerSize', 4);
h_leg(8)  = plot(ax, NaN, NaN, '--', 'Color', vert,         'LineWidth', 2);
h_leg(9)  = plot(ax, NaN, NaN, '-',  'Color', vert_clair,   'LineWidth', 2);
h_leg(10) = plot(ax, NaN, NaN, '-',  'Color', orange,       'LineWidth', 2);
h_leg(11) = plot(ax, NaN, NaN, '-',  'Color', violet_clair, 'LineWidth', 2);
h_leg(12) = plot(ax, NaN, NaN, '-',  'Color', violet,       'LineWidth', 2);
h_leg(13) = plot(ax, NaN, NaN, '-',  'Color', marron,       'LineWidth', 2);
h_leg(14) = plot(ax, NaN, NaN, '-',  'Color', gris,         'LineWidth', 2);
h_leg(15) = plot(ax, NaN, NaN, '-',  'Color', noir,         'LineWidth', 2);
h_leg(16) = plot(ax, NaN, NaN, '-',  'Color', bleu_cyan,   'LineWidth', 2);

legend(ax, h_leg, leg_labels, 'Location', 'eastoutside', 'FontSize', 10, 'Box', 'off');

base_path  = fileparts(fileparts(fileparts(mfilename('fullpath'))));
output_dir = fullfile(base_path, 'Output');
if ~exist(output_dir, 'dir'), mkdir(output_dir); end
output_pdf = fullfile(output_dir, 'figure3_norm_carrying_capacities_EF_EPC.pdf');

set(fig, 'PaperUnits', 'centimeters');
set(fig, 'PaperSize', [40 18]);

drawnow;
exportgraphics(fig, output_pdf, 'ContentType', 'vector');


%% excel
base_path  = fileparts(fileparts(fileparts(mfilename('fullpath'))));
output_dir = fullfile(base_path, 'Output');

source_dir = fullfile(output_dir, 'Source_data');
if ~exist(source_dir, 'dir'), mkdir(source_dir); end
output_xlsx = fullfile(source_dir, 'plot_figure3_norm_carrying_capacities_EF_EPC.xlsx');
if exist(output_xlsx, 'file'), delete(output_xlsx); end

header = [{'Category'}, num2cell(years)];
cat_names_EF = strrep({midpoint_categories(ef_start:ef_end).name}, ' EF', '');

% Sheet 1 : share of planetary boundary 
data_out = cell(n_cats_EF, n_years + 1);
for c = 1:n_cats_EF
    data_out{c, 1} = cat_names_EF{c};
    for i = 1:n_years
        data_out{c, i+1} = share(c, i);
    end
end
writecell([header; data_out], output_xlsx, 'Sheet', 'share_carrying_capacities');

% Sheet 2 : carrying capacities values per Norway
pb_header = {'Category', 'PB_global', 'PB_norway'};
pb_data = cell(n_cats_EF, 3);
for c = 1:n_cats_EF
    cat_idx = ef_start + c - 1;
    pb_data{c,1} = cat_names_EF{c};
    pb_data{c,2} = NormFactors.PB_global(cat_idx);
    pb_data{c,3} = PB_norway(cat_idx);
end
writecell([pb_header; pb_data], output_xlsx, 'Sheet', 'carrying_capacities_values');

fprintf('Excel saved: %s\n', output_xlsx);

fprintf('PDF saved: %s\n', output_pdf);

%% second output: legend sorted by 2023 value 

fig2 = figure('Visible', 'off', 'Units', 'centimeters', 'Position', [0 0 40 18]);
ax2 = axes('Parent', fig2, 'Position', [0.10 0.08 0.64 0.88]);
hold(ax2, 'on');

for c = 1:n_cats_EF
    if ismember(c, ef_cats_to_exclude), continue; end
    v = share(c, :);
    if ~all(isnan(v)) && any(v > 0)
        if strcmp(cat_markers_EF{c}, 'none')
            plot(ax2, years, v, cat_lines_EF{c}, 'Color', cat_colors_EF(c,:), 'LineWidth', 1.8);
        else
            plot(ax2, years, v, cat_lines_EF{c}, 'Color', cat_colors_EF(c,:), ...
                'LineWidth', 1.8, 'Marker', cat_markers_EF{c}, ...
                'MarkerFaceColor', cat_colors_EF(c,:), 'MarkerEdgeColor', cat_colors_EF(c,:), ...
                'MarkerSize', 4, 'MarkerIndices', 1:marker_step:n_years);
        end
    end
end

plot(ax2, [years(1) years(end)], [1 1], '--', 'LineWidth', 3.0, 'Color', [1 0 0 0.6]);
text(ax2, years(end)+0.5, 1, sprintf('Carrying\ncapacities,\nEPC'), ...
    'FontSize', 10, 'Color', 'r', 'VerticalAlignment', 'middle', ...
    'HorizontalAlignment', 'left');

set(ax2, 'YScale', 'log');
xlabel(ax2, 'Year', 'FontSize', 10);
ylabel(ax2, 'Share of Norwegian carrying capacities (EPC, log scale)', 'FontSize', 10);
grid(ax2, 'on');
box(ax2, 'off');
set(ax2, 'FontSize', 10);

% determine legend order
included_c = setdiff(1:n_cats_EF, ef_cats_to_exclude);
final_vals = share(included_c, n_years);
final_vals(isnan(final_vals)) = -Inf;
[~, order_idx] = sort(final_vals, 'descend');
sorted_c = included_c(order_idx);

n_sorted = numel(sorted_c);
h_leg2 = gobjects(n_sorted, 1);
leg_labels_sorted = cell(n_sorted, 1);

for k = 1:n_sorted
    c = sorted_c(k);
    leg_labels_sorted{k} = cat_names{c};
    if strcmp(cat_markers_EF{c}, 'none')
        h_leg2(k) = plot(ax2, NaN, NaN, cat_lines_EF{c}, 'Color', cat_colors_EF(c,:), 'LineWidth', 2);
    else
        h_leg2(k) = plot(ax2, NaN, NaN, cat_lines_EF{c}, 'Color', cat_colors_EF(c,:), ...
            'LineWidth', 2, 'Marker', cat_markers_EF{c}, ...
            'MarkerFaceColor', cat_colors_EF(c,:), 'MarkerEdgeColor', cat_colors_EF(c,:), 'MarkerSize', 4);
    end
end

legend(ax2, h_leg2, leg_labels_sorted, 'Location', 'eastoutside', 'FontSize', 10, 'Box', 'off');

output_pdf2 = fullfile(output_dir, 'plot_figure3_norm_carrying_capacities_EF_EPC_sorted_legend.pdf');
set(fig2, 'PaperUnits', 'centimeters');
set(fig2, 'PaperSize', [40 18]);

drawnow;
exportgraphics(fig2, output_pdf2, 'ContentType', 'vector');
close(fig2);

fprintf('PDF saved: %s\n', output_pdf2);

end