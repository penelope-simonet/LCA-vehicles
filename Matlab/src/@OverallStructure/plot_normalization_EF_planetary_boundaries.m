function plot_normalization_EF_planetary_boundaries(obj)

% Source for PBs: Sala et al. (2020), Table 3

pop_norway = 5400000;
NormFactors = get_normalization_factors_EF();
PB_norway = NormFactors.PB_per_capita * pop_norway;

vkm_per_year = 12000;
years = [obj.State.year];
n_years = length(years);

ef_start = 24;
ef_end   = 42;
n_cats_EF = ef_end - ef_start + 1;

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
ax = axes('Parent', fig, 'Position', [0.32 0.08 0.64 0.88]);
hold(ax, 'on');



rouge        = [0.85 0.10 0.10];
jaune        = [0.80 0.68 0.00];
bleu_fonce   = [0.08 0.20 0.55];
bleu_clair   = [0.7 0.85 1];
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

% c=1  acidification → bleu clair -
cat_colors_EF(1,:)  = bleu_clair;   cat_lines_EF{1}  = '-';  cat_markers_EF{1}  = 'none';
% c=2  climate change → bleu foncé -
cat_colors_EF(2,:)  = bleu_fonce;   cat_lines_EF{2}  = '-';  cat_markers_EF{2}  = 'none';
% c=3  climate change: biogenic → bleu foncé --
cat_colors_EF(3,:)  = bleu_fonce;   cat_lines_EF{3}  = '--'; cat_markers_EF{3}  = 'none';
% c=4  climate change: fossil → bleu foncé - avec ronds
cat_colors_EF(4,:)  = bleu_fonce;   cat_lines_EF{4}  = '-';  cat_markers_EF{4}  = 'o';
% c=5  climate change: land use → bleu foncé - avec triangles
cat_colors_EF(5,:)  = bleu_fonce;   cat_lines_EF{5}  = '-';  cat_markers_EF{5}  = '^';
% c=6  ecotoxicity: freshwater → rouge -
cat_colors_EF(6,:)  = rouge;        cat_lines_EF{6}  = '-';  cat_markers_EF{6}  = 'none';
% c=7  energy resources: non-renewable → violet -
cat_colors_EF(7,:)  = violet;       cat_lines_EF{7}  = '-';  cat_markers_EF{7}  = 'none';
% c=8  eutrophication: freshwater → vert -
cat_colors_EF(8,:)  = vert;         cat_lines_EF{8}  = '-';  cat_markers_EF{8}  = 'none';
% c=9  eutrophication: marine → vert --
cat_colors_EF(9,:)  = vert;         cat_lines_EF{9}  = '--'; cat_markers_EF{9}  = 'none';
% c=10 eutrophication: terrestrial → vert - avec ronds rouges
cat_colors_EF(10,:) = vert;         cat_lines_EF{10} = '-';  cat_markers_EF{10} = 'o';
% c=11 human toxicity: carcinogenic → jaune -
cat_colors_EF(11,:) = jaune;        cat_lines_EF{11} = '-';  cat_markers_EF{11} = 'none';
% c=12 human toxicity: non-carcinogenic → jaune --
cat_colors_EF(12,:) = jaune;        cat_lines_EF{12} = '--'; cat_markers_EF{12} = 'none';
% c=13 ionising radiation → marron -
cat_colors_EF(13,:) = marron;       cat_lines_EF{13} = '-';  cat_markers_EF{13} = 'none';
% c=14 land use → gris -
cat_colors_EF(14,:) = gris;         cat_lines_EF{14} = '-';  cat_markers_EF{14} = 'none';
% c=15 material resources → violet clair -
cat_colors_EF(15,:) = violet_clair; cat_lines_EF{15} = '-';  cat_markers_EF{15} = 'none';
% c=16 ozone depletion → noir -
cat_colors_EF(16,:) = noir;         cat_lines_EF{16} = '-';  cat_markers_EF{16} = 'none';
% c=17 particulate matter → vert clair -
cat_colors_EF(17,:) = vert_clair;   cat_lines_EF{17} = '-';  cat_markers_EF{17} = 'none';
% c=18 photochem: human health → orange -
cat_colors_EF(18,:) = orange;       cat_lines_EF{18} = '-';  cat_markers_EF{18} = 'none';
% c=19 water use → bleu clair -
cat_colors_EF(19,:) = bleu_clair;   cat_lines_EF{19} = '-';  cat_markers_EF{19} = 'none';
years_plot = years;

for c = 1:n_cats_EF
    v = share(c, :);
    if ~all(isnan(v)) && any(v > 0)
        plot(ax, years_plot, v, cat_lines_EF{c}, 'Color', cat_colors_EF(c,:), 'LineWidth', 1.8);
    end
end

plot(ax, [years(1) years(end)], [1 1], '--', 'LineWidth', 1.0, 'Color', [1 0 0 0.6]);
text(ax, years(end)+0.5, 1, 'Planetary boundary (Norway share)', ...
    'FontSize', 7, 'Color', 'r', 'VerticalAlignment', 'middle', ...
    'HorizontalAlignment', 'left');

set(ax, 'YScale', 'log');
xlabel(ax, 'Year', 'FontSize', 9);
ylabel(ax, 'Share of Norwegian planetary boundary (log scale)', 'FontSize', 9);
title(ax, {'Norwegian fleet : EF v3.1 impacts vs planetary boundaries', ...
    '(per capita allocation, Sala et al. 2020)'}, ...
    'FontSize', 10, 'FontWeight', 'bold');
grid(ax, 'on');
box(ax, 'off');
set(ax, 'FontSize', 8);

leg_labels = { ...
    'ecotoxicity: freshwater', ...
    'human toxicity: carcinogenic', ...
    'human toxicity: non-carcinogenic', ...
    'climate change', ...
    'climate change: biogenic', ...
    'climate change: fossil', ...
    'climate change: land use and land use change', ...
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

h_leg = gobjects(19,1);
h_leg(1)  = plot(ax, NaN, NaN, '-',   'Color', rouge,        'LineWidth', 2);
h_leg(2)  = plot(ax, NaN, NaN, '-',   'Color', jaune,        'LineWidth', 2);
h_leg(3)  = plot(ax, NaN, NaN, '--',  'Color', jaune,        'LineWidth', 2);
h_leg(4)  = plot(ax, NaN, NaN, '-',   'Color', bleu_fonce,   'LineWidth', 2);
h_leg(5)  = plot(ax, NaN, NaN, '--',  'Color', bleu_fonce,   'LineWidth', 2);
h_leg(6)  = plot(ax, NaN, NaN, '-o',  'Color', bleu_fonce,   'LineWidth', 2, 'MarkerFaceColor', bleu_fonce, 'MarkerSize', 4);
h_leg(7)  = plot(ax, NaN, NaN, '-^',  'Color', bleu_fonce,   'LineWidth', 2, 'MarkerFaceColor', bleu_fonce, 'MarkerSize', 4);
h_leg(8)  = plot(ax, NaN, NaN, '-',   'Color', bleu_clair,   'LineWidth', 2);
h_leg(9)  = plot(ax, NaN, NaN, '-',   'Color', vert,         'LineWidth', 2);
h_leg(10) = plot(ax, NaN, NaN, '-o',  'Color', vert,         'LineWidth', 2, 'MarkerFaceColor', vert, 'MarkerEdgeColor', vert, 'MarkerSize', 4);
h_leg(11) = plot(ax, NaN, NaN, '--',  'Color', vert,         'LineWidth', 2);
h_leg(12) = plot(ax, NaN, NaN, '-',   'Color', vert_clair,   'LineWidth', 2);
h_leg(13) = plot(ax, NaN, NaN, '-',   'Color', orange,       'LineWidth', 2);
h_leg(14) = plot(ax, NaN, NaN, '-',   'Color', violet_clair, 'LineWidth', 2);
h_leg(15) = plot(ax, NaN, NaN, '-',   'Color', violet,       'LineWidth', 2);
h_leg(16) = plot(ax, NaN, NaN, '-',   'Color', marron,       'LineWidth', 2);
h_leg(17) = plot(ax, NaN, NaN, '-',   'Color', gris,         'LineWidth', 2);
h_leg(18) = plot(ax, NaN, NaN, '-',   'Color', noir,         'LineWidth', 2);
h_leg(19) = plot(ax, NaN, NaN, '-',   'Color', bleu_clair,   'LineWidth', 2);

legend(ax, h_leg, leg_labels, 'Location', 'eastoutside', 'FontSize', 6.5, 'Box', 'off');
base_path  = fileparts(fileparts(fileparts(mfilename('fullpath'))));
output_dir = fullfile(base_path, 'Output');
if ~exist(output_dir, 'dir'), mkdir(output_dir); end
output_pdf = fullfile(output_dir, 'normalization_EF_planetary_boundaries.pdf');

set(fig, 'PaperUnits', 'centimeters');
set(fig, 'PaperSize', [40 18])

drawnow;
exportgraphics(fig, output_pdf, 'ContentType', 'vector');
fprintf('PDF saved: %s\n', output_pdf);

end