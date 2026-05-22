function plot_planetary_boundary_ecosystem(obj)

% Planetary boundary for biosphere integrity (Eegholm et al., 2025)
% Based on Doka (2016): 10% BII loss x 0.6 PDF/BII x 1,950,000 species = 117,000 species.yr/yr (global)
PB_global = 117000; % species.yr/yr

% Per capita allocation (egalitarian)
pop_world_2010   = 6895889018;
pop_norway       = 5400000;
PB_norway = PB_global * (pop_norway / pop_world_2010); % species.yr/yr allocated to Norway

years    = [obj.State.year];
n_years  = length(years);

embodied    = zeros(1, n_years);
operational = zeros(1, n_years);
infra_share = zeros(1, n_years);

for i = 1:n_years
    state = obj.State(i);
    n_cars = state.Normalization.n_cars_total;
    vkm    = 12000;

    emb = (state.Endpoint_impacts(24).value_glider + ...
           state.Endpoint_impacts(24).value_powertrain + ...
           state.Endpoint_impacts(24).value_energy_storage) * n_cars * vkm;

    ops = (state.Endpoint_impacts(24).value_direct_exhaust + ...
           state.Endpoint_impacts(24).value_energy_chain + ...
           state.Endpoint_impacts(24).value_direct_non_exhaust) * n_cars * vkm;

    infra = state.Endpoint_impacts(24).value_road * n_cars * vkm;

    embodied(i)    = emb / PB_norway;
    operational(i) = ops / PB_norway;
    infra_share(i) = infra / PB_norway;
end

total = embodied + operational + infra_share;

fig = figure('Visible', 'off', 'Units', 'centimeters', 'Position', [2 2 30 16]);
ax = axes(fig);
hold(ax, 'on');

area(ax, years, embodied + operational + infra_share, ...
    'FaceColor', [0.47 0.67 0.19], 'EdgeColor', 'none', 'FaceAlpha', 0.7);
area(ax, years, embodied + operational, ...
    'FaceColor', [0.85 0.33 0.10], 'EdgeColor', 'none', 'FaceAlpha', 0.7);
area(ax, years, embodied, ...
    'FaceColor', [0.20 0.45 0.70], 'EdgeColor', 'none', 'FaceAlpha', 0.7);

plot(ax, years, embodied + operational + infra_share, '-k', 'LineWidth', 1.5);

yline(ax, 1, '--r', 'LineWidth', 2, 'Label', 'Planetary boundary (Norway share)', ...
    'LabelHorizontalAlignment', 'left', 'FontSize', 8);

legend(ax, {'Infrastructure', 'Operational', 'Embodied', 'Total'}, ...
    'Location', 'northwest', 'FontSize', 8, 'Box', 'off');

xlabel(ax, 'Year', 'FontSize', 9);
ylabel(ax, 'Share of Norwegian planetary boundary for biosphere integrity', 'FontSize', 9);
title(ax, {'Norwegian fleet : Ecosystem quality impact', ...
    'relative to planetary boundary (per capita allocation)'}, ...
    'FontSize', 10, 'FontWeight', 'bold');

grid(ax, 'on');
box(ax, 'off');
set(ax, 'FontSize', 8);

% Annotation
text(ax, years(1), 1.02, sprintf('PB Norway = %.2f species.yr/yr', PB_norway), ...
    'FontSize', 7, 'Color', [0.6 0 0], 'VerticalAlignment', 'bottom');

base_path  = fileparts(fileparts(fileparts(mfilename('fullpath'))));
output_dir = fullfile(base_path, 'Output');
if ~exist(output_dir, 'dir'), mkdir(output_dir); end
output_pdf = fullfile(output_dir, 'planetary_boundary_ecosystem_quality.pdf');

drawnow;
exportgraphics(fig, output_pdf, 'ContentType', 'vector');
%% Export source data to Excel
output_xlsx = fullfile(output_dir, 'source_data_planetary_boundary_ecosystem_quality.xlsx');
if exist(output_xlsx, 'file'), delete(output_xlsx); end

header = [{'Year'}, {'Embodied'}, {'Operational'}, {'Infrastructure'}, {'Total'}, {'PB_norway_species_yr'}];
data_out = [num2cell(years'), num2cell(embodied'), num2cell(operational'), ...
            num2cell(infra_share'), num2cell(total'), ...
            num2cell(repmat(PB_norway, n_years, 1))];
writecell([header; data_out], output_xlsx, 'Sheet', 'ecosystem_quality');

fprintf('Excel saved: %s\n', output_xlsx);
fprintf('PDF saved: %s\n', output_pdf);

end