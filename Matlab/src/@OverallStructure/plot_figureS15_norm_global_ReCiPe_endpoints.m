function plot_figureS15_norm_global_ReCiPe_endpoints(obj)

% Use : OS.plot_figureS15_norm_global_ReCiPe_endpoints()

years      = [obj.State.year];
n_years    = length(years);
vkm_per_year = 12000;

NormFactors = get_normalization_factors_ReCiPe();

% IDs of 3 endpoints categories
ids = [24, 25, 26];
cat_names = {'Total: ecosystem quality (species.yr)', ...
             'Total: human health (DALY)', ...
             'Total: natural resources (USD)'};
units = {'species.yr/yr', 'DALY/yr', 'USD/yr'};
colors = {[0.18 0.55 0.34], [0.20 0.45 0.70], [0.93 0.69 0.13]};

n_cats = length(ids);

%% collect data
fleet_World  = zeros(n_cats, n_years);
new_World    = zeros(n_cats, n_years);
avg_World    = zeros(n_cats, n_years);
embodied_fleet    = zeros(n_cats, n_years);
operational_fleet = zeros(n_cats, n_years);
embodied_new      = zeros(n_cats, n_years);
operational_new   = zeros(n_cats, n_years);
embodied_avg      = zeros(n_cats, n_years);
operational_avg   = zeros(n_cats, n_years);

for i = 1:n_years
    state = obj.State(i);

    n_cars_total = 0;
    for at = 1:numel(state.VehicleArchetype)
        n_cars_total = n_cars_total + sum(state.VehicleArchetype(at).number_of_cars_from_year);
    end

    for c = 1:n_cats
        cat_id  = ids(c);
        norm_W  = NormFactors.endpoint_World(cat_id);

        impact_avg_vkm = state.Endpoint_impacts(cat_id).value;
        impact_new_vkm = state.Endpoint_impacts_new_cars(cat_id).value;

        % Calculation 1 : fleet
        impact_fleet = impact_avg_vkm * vkm_per_year * n_cars_total;
        if norm_W > 0
            fleet_World(c,i) = impact_fleet / norm_W;
        end

        % Calculation 2 : new cars
        impact_new = impact_new_vkm * vkm_per_year;
        if norm_W > 0
            new_World(c,i) = impact_new / norm_W;
        end

        % Calculation 3 : average car
        impact_avg = impact_avg_vkm * vkm_per_year;
        if norm_W > 0
            avg_World(c,i) = impact_avg / norm_W;
        end

        % Calculation 4 : embodied vs operational
        % Fleet
        embodied_fleet(c,i) = ( ...
            state.Endpoint_impacts(cat_id).value_glider + ...
            state.Endpoint_impacts(cat_id).value_powertrain + ...
            state.Endpoint_impacts(cat_id).value_energy_storage) * vkm_per_year * n_cars_total;
        operational_fleet(c,i) = ...
            state.Endpoint_impacts(cat_id).value_direct_exhaust * vkm_per_year * n_cars_total;

        % New cars
        embodied_new(c,i) = ( ...
            state.Endpoint_impacts_new_cars(cat_id).value_glider + ...
            state.Endpoint_impacts_new_cars(cat_id).value_powertrain + ...
            state.Endpoint_impacts_new_cars(cat_id).value_energy_storage) * vkm_per_year;
        operational_new(c,i) = ...
            state.Endpoint_impacts_new_cars(cat_id).value_direct_exhaust * vkm_per_year;

        % Average car
        embodied_avg(c,i) = ( ...
            state.Endpoint_impacts(cat_id).value_glider + ...
            state.Endpoint_impacts(cat_id).value_powertrain + ...
            state.Endpoint_impacts(cat_id).value_energy_storage) * vkm_per_year;
        operational_avg(c,i) = ...
            state.Endpoint_impacts(cat_id).value_direct_exhaust * vkm_per_year;
    end
end

%% pdf
base_path  = fileparts(fileparts(fileparts(mfilename('fullpath'))));
output_dir = fullfile(base_path, 'Output');
if ~exist(output_dir, 'dir'), mkdir(output_dir); end
output_pdf = fullfile(output_dir, 'figureS15_norm_global_ReCiPe_endpoints.pdf');
if exist(output_pdf, 'file'), delete(output_pdf); end

page = 0;
    function export_page(fig, pdf, pg)
        if pg == 1
            exportgraphics(fig, pdf, 'Append', false, 'ContentType','vector');
        else
            exportgraphics(fig, pdf, 'Append', true,  'ContentType','vector');
        end
        close(fig);
    end

%% page 1 : calculations 1, 2, 3
fig = figure('Visible','off','Units','centimeters','Position',[0 0 40 30]);

subplot(3,1,1);
hold on;
for c = 1:n_cats
    v = fleet_World(c,:);
    if v(1) ~= 0
        v_norm = v / v(1);
    else
        v_norm = v;
    end
    plot(years, v_norm, '-o', 'Color', colors{c}, 'LineWidth',2, ...
        'MarkerFaceColor', colors{c}, 'MarkerSize',4);
end
ylabel('Internal normalization (relative to 2000)', 'FontSize', 10);
title('Calculation 1 : Norwegian fleet share of World total endpoint impact per year', 'FontSize', 16, 'FontWeight', 'bold');
legend(cat_names, 'Location','northwest', 'FontSize',10, 'Box','off');
grid on; box off;
set(gca, 'FontSize', 12);

subplot(3,1,2);
hold on;
for c = 1:n_cats
    v = new_World(c,:);
    if v(1) ~= 0, v_norm = v / v(1); else, v_norm = v; end
    plot(years, v_norm, '-o', 'Color', colors{c}, 'LineWidth',2, ...
        'MarkerFaceColor', colors{c}, 'MarkerSize',4);
end
ylabel('Internal normalization (relative to 2000)', 'FontSize', 10);
title('Calculation 2 : New cars share of World total endpoint impact per vkm', 'FontSize', 16, 'FontWeight', 'bold');
legend(cat_names, 'Location','northwest', 'FontSize',10, 'Box','off');
grid on; box off;
set(gca, 'FontSize', 12);

subplot(3,1,3);
hold on;
for c = 1:n_cats
    v = avg_World(c,:);
    if v(1) ~= 0, v_norm = v / v(1); else, v_norm = v; end
    plot(years, v_norm, '-o', 'Color', colors{c}, 'LineWidth',2, ...
        'MarkerFaceColor', colors{c}, 'MarkerSize',4);
end
xlabel('Year', 'FontSize', 12);
ylabel('Internal normalization (relative to 2000)', 'FontSize', 10);
title('Calculation 3 : Average car share of World total endpoint impact per vkm', 'FontSize', 16, 'FontWeight', 'bold');
legend(cat_names, 'Location','northwest', 'FontSize',10, 'Box','off');
grid on; box off;
set(gca, 'FontSize', 12);

page = page + 1; export_page(fig, output_pdf, page);

%%  page 2+, calculation 4
for c = 1:n_cats

    fig = figure('Visible','off','Units','centimeters','Position',[0 0 42 16]);

    emb_fl = embodied_fleet(c,:);
    ops_fl = operational_fleet(c,:);
    emb_nw = embodied_new(c,:);
    ops_nw = operational_new(c,:);
    emb_av = embodied_avg(c,:);
    ops_av = operational_avg(c,:);

    % Fleet : time series
    subplot(1,2,1);
    plot(years, emb_fl, '-o','Color',[0.20 0.45 0.70],'LineWidth',2,'MarkerFaceColor',[0.20 0.45 0.70],'MarkerSize',3);
    hold on;
    plot(years, ops_fl, '-o','Color',[0.85 0.33 0.10],'LineWidth',2,'MarkerFaceColor',[0.85 0.33 0.10],'MarkerSize',3);
    plot(years, emb_fl+ops_fl, '--k','LineWidth',1.2);
    legend({'Embodied','Operational','Total'},'Location','best','FontSize',11,'Box','off');
    xlabel('Year', 'FontSize', 11); ylabel(units{c}, 'FontSize', 11);
    title(['Fleet : time series : ' cat_names{c}],'FontSize',14,'FontWeight','bold');
    grid on; box off;
    set(gca, 'FontSize', 11);

    % Fleet : stacked bars
    subplot(1,2,2);
    bar(years, [emb_fl', ops_fl'], 'stacked');
    colororder([[0.20 0.45 0.70];[0.85 0.33 0.10]]);
    legend({'Embodied','Operational'},'Location','best','FontSize',11,'Box','off');
    xlabel('Year', 'FontSize', 11); ylabel(units{c}, 'FontSize', 11);
    title(['Fleet : stacked bars : ' cat_names{c}],'FontSize',14,'FontWeight','bold');
    grid on; box off;
    set(gca, 'FontSize', 11);

    page = page + 1;
    export_page(fig, output_pdf, page);
    fprintf('Page %d : %s\n', page, cat_names{c});

end

%% excel
source_dir = fullfile(output_dir, 'Source_data');
if ~exist(source_dir, 'dir'), mkdir(source_dir); end
output_xlsx = fullfile(source_dir, 'figureS15_norm_global_ReCiPe_endpoints.xlsx');
if exist(output_xlsx, 'file'), delete(output_xlsx); end

% Sheet 1 : internal normalization (calculations 1, 2, 3), raw values before normalization to year 2000
header_calc = [{'Category'}, num2cell(years)];

data_fleet = [cat_names', num2cell(fleet_World)];
data_new   = [cat_names', num2cell(new_World)];
data_avg   = [cat_names', num2cell(avg_World)];

writecell([header_calc; data_fleet], output_xlsx, 'Sheet', 'calc1_fleet_share_World');
writecell([header_calc; data_new],   output_xlsx, 'Sheet', 'calc2_newcars_share_World');
writecell([header_calc; data_avg],   output_xlsx, 'Sheet', 'calc3_avgcar_share_World');

% Sheet per category : calculation 4, embodied vs operational (fleet, new cars, average car)
header_c4 = {'Year', 'Embodied_fleet', 'Operational_fleet', ...
             'Embodied_new', 'Operational_new', ...
             'Embodied_avg', 'Operational_avg'};

for c = 1:n_cats
    data_out = [num2cell(years'), num2cell(embodied_fleet(c,:)'), num2cell(operational_fleet(c,:)'), ...
                num2cell(embodied_new(c,:)'), num2cell(operational_new(c,:)'), ...
                num2cell(embodied_avg(c,:)'), num2cell(operational_avg(c,:)')];
    sheet_name = matlab.lang.makeValidName(cat_names{c});
    if length(sheet_name) > 31
        sheet_name = sheet_name(1:31);
    end
    writecell([header_c4; data_out], output_xlsx, 'Sheet', sheet_name);
end

fprintf('Excel saved: %s\n', output_xlsx);

fprintf('\nDone! PDF: %s\n', output_pdf);

end