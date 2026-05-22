function plot_normalization(obj)

midpoint_categories = get_midpoint_categories();
n_cats = 23;
cat_names = {midpoint_categories.name};

units_fleet = { ...
    'kg SO2eq/yr', ...
    'kg CO2eq/yr', ...
    'kg CO2eq/yr', ...
    'kg 1,4-DCB/yr', ...
    'kg 1,4-DCB/yr', ...
    'kg 1,4-DCB/yr', ...
    'oil-eq/yr', ...
    'kg P/yr', ...
    'kg N/yr', ...
    'kg 1,4-DCB/yr', ...
    'kg 1,4-DCB/yr', ...
    'kBq Co-60 eq/yr', ...
    'm2a/yr', ...
    'kg Cu-eq/yr', ...
    'kg CFC-11 eq/yr', ...
    'kg PM2.5eq/yr', ...
    'kg NOx eq/yr', ...
    'kg NOx eq/yr', ...
    'm3/yr', ...
    'oil-eq/yr', ...
    'oil-eq/yr', ...
    'mixed/yr', ...
    'DALY/yr'};

units_vkm = { ...
    'kg SO2eq/yr (12000 vkm)', ...
    'kg CO2eq/yr (12000 vkm)', ...
    'kg CO2eq/yr (12000 vkm)', ...
    'kg 1,4-DCB/yr (12000 vkm)', ...
    'kg 1,4-DCB/yr (12000 vkm)', ...
    'kg 1,4-DCB/yr (12000 vkm)', ...
    'oil-eq/yr (12000 vkm)', ...
    'kg P/yr (12000 vkm)', ...
    'kg N/yr (12000 vkm)', ...
    'kg 1,4-DCB/yr (12000 vkm)', ...
    'kg 1,4-DCB/yr (12000 vkm)', ...
    'kBq Co-60 eq/yr (12000 vkm)', ...
    'm2a/yr (12000 vkm)', ...
    'kg Cu-eq/yr (12000 vkm)', ...
    'kg CFC-11 eq/yr (12000 vkm)', ...
    'kg PM2.5eq/yr (12000 vkm)', ...
    'kg NOx eq/yr (12000 vkm)', ...
    'kg NOx eq/yr (12000 vkm)', ...
    'm3/yr (12000 vkm)', ...
    'oil-eq/yr (12000 vkm)', ...
    'oil-eq/yr (12000 vkm)', ...
    'mixed/yr (12000 vkm)', ...
    'DALY/yr (12000 vkm)'};

years = [obj.State.year];
n_years = length(years);

fleet_Europe      = zeros(n_cats, n_years);
fleet_World       = zeros(n_cats, n_years);
new_Europe        = zeros(n_cats, n_years);
new_World         = zeros(n_cats, n_years);
avg_Europe        = zeros(n_cats, n_years);
avg_World         = zeros(n_cats, n_years);
embodied_fleet    = zeros(n_cats, n_years);
operational_fleet = zeros(n_cats, n_years);
embodied_new      = zeros(n_cats, n_years);
operational_new   = zeros(n_cats, n_years);
embodied_avg      = zeros(n_cats, n_years);
operational_avg   = zeros(n_cats, n_years);

for i = 1:n_years
    for cat = 1:n_cats
        fleet_Europe(cat,i)      = obj.State(i).Normalization.fleet_share_Europe(cat);
        fleet_World(cat,i)       = obj.State(i).Normalization.fleet_share_World(cat);
        new_Europe(cat,i)        = obj.State(i).Normalization.new_cars_share_Europe(cat);
        new_World(cat,i)         = obj.State(i).Normalization.new_cars_share_World(cat);
        avg_Europe(cat,i)        = obj.State(i).Normalization.avg_car_share_Europe(cat);
        avg_World(cat,i)         = obj.State(i).Normalization.avg_car_share_World(cat);
        embodied_fleet(cat,i)    = obj.State(i).Normalization.embodied_fleet(cat);
        operational_fleet(cat,i) = obj.State(i).Normalization.operational_fleet(cat);
        embodied_new(cat,i)      = obj.State(i).Normalization.embodied_new_cars(cat);
        operational_new(cat,i)   = obj.State(i).Normalization.operational_new_cars(cat);
        embodied_avg(cat,i)      = obj.State(i).Normalization.embodied_avg_car(cat);
        operational_avg(cat,i)   = obj.State(i).Normalization.operational_avg_car(cat);
    end
end

base_path  = fileparts(fileparts(fileparts(mfilename('fullpath'))));
output_dir = fullfile(base_path, 'Output');
if ~exist(output_dir, 'dir'), mkdir(output_dir); end
output_pdf = fullfile(output_dir, 'normalization_midpoints.pdf');
if exist(output_pdf, 'file'), delete(output_pdf); end

cats_to_exclude = [20, 21, 22, 23, 24:42];
page = 0;

rouge      = [0.85 0.10 0.10];
jaune      = [0.80 0.68 0.00];
bleu_fonce = [0.08 0.20 0.55];
vert       = [0.10 0.60 0.20];
orange     = [0.95 0.50 0.05];
violet     = [0.55 0.10 0.75];
gris       = [0.50 0.50 0.50];

cat_colors  = zeros(n_cats, 3);
cat_lines   = cell(n_cats, 1);
cat_markers = cell(n_cats, 1);
for k = 1:n_cats
    cat_colors(k,:) = [0.7 0.7 0.7];
    cat_lines{k}    = '-';
    cat_markers{k}  = 'none';
end

cat_colors(4,:)  = rouge;       cat_lines{4}  = '-';  cat_markers{4}  = 'none';
cat_colors(5,:)  = rouge;       cat_lines{5}  = '--'; cat_markers{5}  = 'none';
cat_colors(6,:)  = rouge;       cat_lines{6}  = '-';  cat_markers{6}  = 'o';
cat_colors(10,:) = jaune;       cat_lines{10} = '-';  cat_markers{10} = 'none';
cat_colors(11,:) = jaune;       cat_lines{11} = '--'; cat_markers{11} = 'none';
cat_colors(2,:)  = bleu_fonce;  cat_lines{2}  = '-';  cat_markers{2}  = 'none';
cat_colors(3,:)  = bleu_fonce;  cat_lines{3}  = '--'; cat_markers{3}  = 'none';
cat_colors(1,:)  = [0.7 0.85 1]; cat_lines{1}  = '-';  cat_markers{1}  = 'none';
cat_colors(8,:)  = vert;        cat_lines{8}  = '-';  cat_markers{8}  = 'none';
cat_colors(9,:)  = vert;        cat_lines{9}  = '--'; cat_markers{9}  = 'none';
cat_colors(16,:) = [0.5 1 0];   cat_lines{16} = '-';  cat_markers{16} = 'none';
cat_colors(17,:) = orange;      cat_lines{17} = '-';  cat_markers{17} = 'none';
cat_colors(18,:) = orange;      cat_lines{18} = '--'; cat_markers{18} = 'none';
cat_colors(14,:) = violet;      cat_lines{14} = '-';  cat_markers{14} = 'none';
cat_colors(12,:) = [0.5 0 0];   cat_lines{12} = '-';  cat_markers{12} = 'none';
cat_colors(13,:) = gris;        cat_lines{13} = '-';  cat_markers{13} = 'none';
cat_colors(15,:) = [0 0 0];     cat_lines{15} = '-';  cat_markers{15} = 'none';
cat_colors(19,:) = [0.3 0.7 1]; cat_lines{19} = '-';  cat_markers{19} = 'none';
cat_colors(7, :) = [0.7 0.5 1]; cat_lines{7} = '-';  cat_markers{7} = 'none';

marker_step = max(1, floor(n_years / 8));

    function export_page(fig, pdf, pg)
        if pg == 1
            exportgraphics(fig, pdf, 'Append', false, 'ContentType','vector');
        else
            exportgraphics(fig, pdf, 'Append', true,  'ContentType','vector');
        end
        close(fig);
    end

    function plot_normalization_curves(ax, data_matrix, title_str, ylabel_str)
        hold(ax, 'on');
        for cat = 1:n_cats
            if ismember(cat, cats_to_exclude), continue; end
            v = data_matrix(cat,:);
            if ~all(isnan(v)) && any(v > 0)
                if strcmp(cat_markers{cat}, 'none')
                    plot(ax, years, v, ...
                        'Color', cat_colors(cat,:), ...
                        'LineStyle', cat_lines{cat}, ...
                        'LineWidth', 1.8);
                else
                    plot(ax, years, v, ...
                        'Color', cat_colors(cat,:), ...
                        'LineStyle', cat_lines{cat}, ...
                        'Marker', cat_markers{cat}, ...
                        'LineWidth', 1.8, ...
                        'MarkerSize', 4, ...
                        'MarkerIndices', 1:marker_step:n_years, ...
                        'MarkerFaceColor', cat_colors(cat,:));
                end
            end
        end
        set(ax, 'YScale', 'log');
        xlabel(ax, 'Year');
        ylabel(ax, ylabel_str);
        title(ax, title_str);
        grid(ax, 'on');
        box(ax, 'off');

        h_leg = gobjects(18,1);
        h_leg(1)  = plot(ax, NaN, NaN, '-',   'Color', rouge,      'LineWidth', 2);
        h_leg(2)  = plot(ax, NaN, NaN, '--',  'Color', rouge,      'LineWidth', 2);
        h_leg(3)  = plot(ax, NaN, NaN, '-o',  'Color', rouge,      'LineWidth', 2, 'MarkerFaceColor', rouge,      'MarkerSize', 4);
        h_leg(4)  = plot(ax, NaN, NaN, '-',   'Color', jaune,      'LineWidth', 2);
        h_leg(5)  = plot(ax, NaN, NaN, '--',  'Color', jaune,      'LineWidth', 2);
        h_leg(6)  = plot(ax, NaN, NaN, '-',   'Color', bleu_fonce, 'LineWidth', 2);
        h_leg(7)  = plot(ax, NaN, NaN, '--',  'Color', bleu_fonce, 'LineWidth', 2);
        h_leg(8)  = plot(ax, NaN, NaN, '-',   'Color', [0.7 0.85 1],'LineWidth', 2);
        h_leg(9)  = plot(ax, NaN, NaN, '-',   'Color', vert,       'LineWidth', 2);
        h_leg(10) = plot(ax, NaN, NaN, '--',  'Color', vert,       'LineWidth', 2);
        h_leg(11) = plot(ax, NaN, NaN, '-',   'Color', [0.5 1 0],     'LineWidth', 2);
        h_leg(12) = plot(ax, NaN, NaN, '-',  'Color', orange,     'LineWidth', 2);
        h_leg(13) = plot(ax, NaN, NaN, '--',  'Color', orange,     'LineWidth', 2);
        h_leg(14) = plot(ax, NaN, NaN, '-', 'Color', [0.7 0.5 1], 'LineWidth', 2);
        h_leg(15) = plot(ax, NaN, NaN, '-',   'Color', violet,     'LineWidth', 2);
        h_leg(16) = plot(ax, NaN, NaN, '-',   'Color', [0.5 0 0],       'LineWidth', 2);
        h_leg(17) = plot(ax, NaN, NaN, '-',  'Color', gris,       'LineWidth', 2);
        h_leg(18) = plot(ax, NaN, NaN, '-',  'Color', [0 0 0],       'LineWidth', 2);
        h_leg(19) = plot(ax, NaN, NaN, '-', 'Color', [0.3 0.7 1], 'LineWidth', 2);
       

        leg_labels = { ...
        'ecotoxicity: freshwater', 'ecotoxicity: marine', 'ecotoxicity: terrestrial', ...
        'human toxicity: carcinogenic', 'human toxicity: non-carcinogenic', ...
        'climate change', 'climate change w bio', ...
        'acidification: terrestrial', 'eutrophication: freshwater', 'eutrophication: marine', ...
        'particulate matter formation', 'photochemical oxidant formation: human health', 'photochemical oxidant formation: terrestrial ecosystems', ...
        'material resources: metals/minerals', 'energy resources depletion: non-renewable' ...
        'ionising radiation', 'land use', 'ozone depletion', 'water use'};
        legend(ax, h_leg(1:19), leg_labels, ...
            'Location', 'eastoutside', 'FontSize', 6.5, 'Box', 'off');
    end

%% Page 1 : Fleet share
fig = figure('Visible','off','Units','centimeters','Position',[0 0 40 18]);
ax = axes(fig);
plot_normalization_curves(ax, fleet_World, ...
    'Norwegian fleet : Share of World total impact per year (all midpoints)', ...
    'Share of World total impact (log scale)');
page = page + 1; export_page(fig, output_pdf, page);

%% Page 2 : New cars
fig = figure('Visible','off','Units','centimeters','Position',[0 0 40 18]);
ax = axes(fig);
plot_normalization_curves(ax, new_World, ...
    'New cars : Share of World total impact per vkm (all midpoints)', ...
    'Share of World total impact (log scale)');
page = page + 1; export_page(fig, output_pdf, page);

%% Page 3 : Average car
fig = figure('Visible','off','Units','centimeters','Position',[0 0 40 18]);
ax = axes(fig);
plot_normalization_curves(ax, avg_World, ...
    'Average car in stock : Share of World total impact per vkm (all midpoints)', ...
    'Share of World total impact (log scale)');
page = page + 1; export_page(fig, output_pdf, page);

%% One page per category
for cat = 1:n_cats

    if ismember(cat, cats_to_exclude), continue; end
    if all(embodied_fleet(cat,:) == 0) && all(operational_fleet(cat,:) == 0)
        continue
    end

    cat_name = cat_names{cat};
    emb_fl   = embodied_fleet(cat,:);
    ops_fl   = operational_fleet(cat,:);

    fig = figure('Visible','off','Units','centimeters','Position',[0 0 42 14]);

    subplot(1,2,1);
    plot(years, emb_fl, '-o','Color',[0.20 0.45 0.70],'LineWidth',2,'MarkerFaceColor',[0.20 0.45 0.70],'MarkerSize',3);
    hold on;
    plot(years, ops_fl, '-o','Color',[0.85 0.33 0.10],'LineWidth',2,'MarkerFaceColor',[0.85 0.33 0.10],'MarkerSize',3);
    plot(years, emb_fl+ops_fl, '--k','LineWidth',1.2);
    legend({'Embodied','Operational','Total'},'Location','best','FontSize',7,'Box','off');
    xlabel('Year'); ylabel(units_fleet{cat});
    title(['Fleet : time series : ' cat_name],'FontSize',7,'FontWeight','bold');
    grid on; box off;

    subplot(1,2,2);
    bar(years, [emb_fl', ops_fl'], 'stacked');
    colororder([[0.20 0.45 0.70];[0.85 0.33 0.10]]);
    legend({'Embodied','Operational'},'Location','best','FontSize',7,'Box','off');
    xlabel('Year'); ylabel(units_fleet{cat});
    title(['Fleet : stacked bars : ' cat_name],'FontSize',7,'FontWeight','bold');
    grid on; box off;

    page = page + 1;
    export_page(fig, output_pdf, page);
    fprintf('Page %d : %s\n', page, cat_name);

end

%% Export source data to Excel
output_xlsx = fullfile(output_dir, 'source_data_normalization_midpoints.xlsx');
if exist(output_xlsx, 'file'), delete(output_xlsx); end

cat_names_incl = cat_names(1:n_cats);
header = [{'Category'}, num2cell(years)];

% Sheet 1 : fleet_share_World
data_out = [cat_names_incl', num2cell(fleet_World)];
writecell([header; data_out], output_xlsx, 'Sheet', 'fleet_share_World');

% Sheet 2 : new_cars_share_World
data_out = [cat_names_incl', num2cell(new_World)];
writecell([header; data_out], output_xlsx, 'Sheet', 'new_cars_share_World');

% Sheet 3 : avg_car_share_World
data_out = [cat_names_incl', num2cell(avg_World)];
writecell([header; data_out], output_xlsx, 'Sheet', 'avg_car_share_World');

% Sheet 4 : embodied_fleet
data_out = [cat_names_incl', num2cell(embodied_fleet)];
writecell([header; data_out], output_xlsx, 'Sheet', 'embodied_fleet');

% Sheet 5 : operational_fleet
data_out = [cat_names_incl', num2cell(operational_fleet)];
writecell([header; data_out], output_xlsx, 'Sheet', 'operational_fleet');

fprintf('Excel saved: %s\n', output_xlsx);

fprintf('\nDone! PDF: %s\n', output_pdf);

end