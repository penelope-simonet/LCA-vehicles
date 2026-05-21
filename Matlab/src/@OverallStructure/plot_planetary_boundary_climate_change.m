function plot_planetary_boundary_climate_change(obj)

% Planetary boundary for climate change (Sala et al. 2020, Table 3)
% PB global = 6.81e12 kg CO2eq/yr
% Source: Bjorn and Hauschild (2015), Rockstrom et al. (2009)

PB_global = 6.81e12; % kg CO2eq/yr

% Per capita allocation (egalitarian)
pop_ref    = 6916183482;
pop_norway = 5400000;
PB_norway  = PB_global * (pop_norway / pop_ref);

vkm_per_year = 12000;
years    = [obj.State.year];
n_years  = length(years);

embodied    = zeros(1, n_years);
operational = zeros(1, n_years);
infra       = zeros(1, n_years);

for i = 1:n_years
    state = obj.State(i);
    n_cars = 0;
    for at = 1:numel(state.VehicleArchetype)
        n_cars = n_cars + sum(state.VehicleArchetype(at).number_of_cars_from_year);
    end

    emb = (state.Midpoint_impacts(2).value_glider + ...
           state.Midpoint_impacts(2).value_powertrain + ...
           state.Midpoint_impacts(2).value_energy_storage) * n_cars * vkm_per_year;

    ops = (state.Midpoint_impacts(2).value_direct_exhaust + ...
           state.Midpoint_impacts(2).value_energy_chain + ...
           state.Midpoint_impacts(2).value_direct_non_exhaust) * n_cars * vkm_per_year;

    inf_val = state.Midpoint_impacts(2).value_road * n_cars * vkm_per_year;

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

yline(ax, 1, '--r', 'LineWidth', 2, 'Label', 'Planetary boundary (Norway share)', ...
    'LabelHorizontalAlignment', 'left', 'FontSize', 8);

legend(ax, {'Infrastructure (road)', 'Operational', 'Embodied', 'Total'}, ...
    'Location', 'northwest', 'FontSize', 8, 'Box', 'off');

xlabel(ax, 'Year', 'FontSize', 9);
ylabel(ax, 'Share of Norwegian planetary boundary for climate change', 'FontSize', 9);
title(ax, {'Norwegian fleet : Climate change impact', ...
    'relative to planetary boundary (per capita allocation, Sala et al. 2020)'}, ...
    'FontSize', 10, 'FontWeight', 'bold');

grid(ax, 'on');
box(ax, 'off');
set(ax, 'FontSize', 8);

text(ax, years(1), 1.02, sprintf('PB Norway = %.2e kg CO2eq/yr', PB_norway), ...
    'FontSize', 7, 'Color', [0.6 0 0], 'VerticalAlignment', 'bottom');

base_path  = fileparts(fileparts(fileparts(mfilename('fullpath'))));
output_dir = fullfile(base_path, 'Output');
if ~exist(output_dir, 'dir'), mkdir(output_dir); end
output_pdf = fullfile(output_dir, 'planetary_boundary_climate_change.pdf');

drawnow;
exportgraphics(fig, output_pdf, 'ContentType', 'vector');
fprintf('PDF saved: %s\n', output_pdf);

end