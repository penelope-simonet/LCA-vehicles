function plot_normalization(obj)

midpoint_categories = get_midpoint_categories();
n_cats = length(midpoint_categories);
cat_names = {midpoint_categories.name};
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
output_pdf = fullfile(output_dir, 'normalization_all_categories.pdf');
if exist(output_pdf, 'file'), delete(output_pdf); end

colors_cats = turbo(n_cats);
page = 0;

    function export_page(fig, pdf, pg)
        if pg == 1
            exportgraphics(fig, pdf, 'Append', false, 'ContentType','vector');
        else
            exportgraphics(fig, pdf, 'Append', true,  'ContentType','vector');
        end
        close(fig);
    end

%% Page 1 : Fleet share
fig = figure('Visible','off','Units','centimeters','Position',[0 0 40 30]);
subplot(2,1,1);
hold on;
for cat = 1:n_cats
    v = fleet_Europe(cat,:);
    if ~all(isnan(v)) && any(v > 0)
        plot(years, v, '-', 'Color', colors_cats(cat,:), 'LineWidth',1.8);
    end
end
set(gca,'YScale','log');
xlabel('Year'); ylabel('Share of European total impact (log scale)');
title('Norwegian fleet : Share of European total impact per year (all midpoints)');
grid on; box off;
legend(cat_names,'Location','eastoutside','FontSize',6.5,'Box','off');

subplot(2,1,2);
hold on;
for cat = 1:n_cats
    v = fleet_World(cat,:);
    if ~all(isnan(v)) && any(v > 0)
        plot(years, v, '-', 'Color', colors_cats(cat,:), 'LineWidth',1.8);
    end
end
set(gca,'YScale','log');
xlabel('Year'); ylabel('Share of World total impact (log scale)');
title('Norwegian fleet : Share of World total impact per year (all midpoints)');
grid on; box off;
legend(cat_names,'Location','eastoutside','FontSize',6.5,'Box','off');
page = page + 1; export_page(fig, output_pdf, page);

%% Page 2 : New cars
fig = figure('Visible','off','Units','centimeters','Position',[0 0 40 30]);
subplot(2,1,1);
hold on;
for cat = 1:n_cats
    v = new_Europe(cat,:);
    if ~all(isnan(v)) && any(v > 0)
        plot(years, v, '-', 'Color', colors_cats(cat,:), 'LineWidth',1.8);
    end
end
set(gca,'YScale','log');
xlabel('Year'); ylabel('Share of European total impact (log scale)');
title('New cars : Share of European total impact per vkm (all midpoints)');
grid on; box off;
legend(cat_names,'Location','eastoutside','FontSize',6.5,'Box','off');

subplot(2,1,2);
hold on;
for cat = 1:n_cats
    v = new_World(cat,:);
    if ~all(isnan(v)) && any(v > 0)
        plot(years, v, '-', 'Color', colors_cats(cat,:), 'LineWidth',1.8);
    end
end
set(gca,'YScale','log');
xlabel('Year'); ylabel('Share of World total impact (log scale)');
title('New cars : Share of World total impact per vkm (all midpoints)');
grid on; box off;
legend(cat_names,'Location','eastoutside','FontSize',6.5,'Box','off');
page = page + 1; export_page(fig, output_pdf, page);

%% Page 3 : Average car
fig = figure('Visible','off','Units','centimeters','Position',[0 0 40 30]);
subplot(2,1,1);
hold on;
for cat = 1:n_cats
    v = avg_Europe(cat,:);
    if ~all(isnan(v)) && any(v > 0)
        plot(years, v, '-', 'Color', colors_cats(cat,:), 'LineWidth',1.8);
    end
end
set(gca,'YScale','log');
xlabel('Year'); ylabel('Share of European total impact (log scale)');
title('Average car in stock : Share of European total impact per vkm (all midpoints)');
grid on; box off;
legend(cat_names,'Location','eastoutside','FontSize',6.5,'Box','off');

subplot(2,1,2);
hold on;
for cat = 1:n_cats
    v = avg_World(cat,:);
    if ~all(isnan(v)) && any(v > 0)
        plot(years, v, '-', 'Color', colors_cats(cat,:), 'LineWidth',1.8);
    end
end
set(gca,'YScale','log');
xlabel('Year'); ylabel('Share of World total impact (log scale)');
title('Average car in stock : Share of World total impact per vkm (all midpoints)');
grid on; box off;
legend(cat_names,'Location','eastoutside','FontSize',6.5,'Box','off');
page = page + 1; export_page(fig, output_pdf, page);

%% one page per categories
for cat = 1:n_cats

    if all(embodied_fleet(cat,:) == 0) && all(operational_fleet(cat,:) == 0)
        continue
    end

    cat_name = cat_names{cat};
    emb_fl = embodied_fleet(cat,:);
    ops_fl = operational_fleet(cat,:);
    emb_nw = embodied_new(cat,:);
    ops_nw = operational_new(cat,:);
    emb_av = embodied_avg(cat,:);
    ops_av = operational_avg(cat,:);

    fig = figure('Visible','off','Units','centimeters','Position',[0 0 42 28]);

    subplot(3,2,1);
    plot(years, emb_fl, '-o','Color',[0.20 0.45 0.70],'LineWidth',2,'MarkerFaceColor',[0.20 0.45 0.70],'MarkerSize',3);
    hold on;
    plot(years, ops_fl, '-o','Color',[0.85 0.33 0.10],'LineWidth',2,'MarkerFaceColor',[0.85 0.33 0.10],'MarkerSize',3);
    plot(years, emb_fl+ops_fl, '--k','LineWidth',1.2);
    legend({'Embodied','Operational','Total'},'Location','best','FontSize',7,'Box','off');
    xlabel('Year'); ylabel('kg X / yr');
    title(['Fleet : time series : ' cat_name],'FontSize',7,'FontWeight','bold');
    grid on; box off;

    subplot(3,2,2);
    bar(years, [emb_fl', ops_fl'], 'stacked');
    colororder([[0.20 0.45 0.70];[0.85 0.33 0.10]]);
    legend({'Embodied','Operational'},'Location','best','FontSize',7,'Box','off');
    xlabel('Year'); ylabel('kg X / yr');
    title(['Fleet : stacked bars : ' cat_name],'FontSize',7,'FontWeight','bold');
    grid on; box off;

    subplot(3,2,3);
    plot(years, emb_nw, '-o','Color',[0.20 0.45 0.70],'LineWidth',2,'MarkerFaceColor',[0.20 0.45 0.70],'MarkerSize',3);
    hold on;
    plot(years, ops_nw, '-o','Color',[0.85 0.33 0.10],'LineWidth',2,'MarkerFaceColor',[0.85 0.33 0.10],'MarkerSize',3);
    plot(years, emb_nw+ops_nw, '--k','LineWidth',1.2);
    legend({'Embodied','Operational','Total'},'Location','best','FontSize',7,'Box','off');
    xlabel('Year'); ylabel('kg X / yr (12000 vkm)');
    title(['New cars : time series : ' cat_name],'FontSize',7,'FontWeight','bold');
    grid on; box off;

    subplot(3,2,4);
    bar(years, [emb_nw', ops_nw'], 'stacked');
    colororder([[0.20 0.45 0.70];[0.85 0.33 0.10]]);
    legend({'Embodied','Operational'},'Location','best','FontSize',7,'Box','off');
    xlabel('Year'); ylabel('kg X / yr (12000 vkm)');
    title(['New cars : stacked bars : ' cat_name],'FontSize',7,'FontWeight','bold');
    grid on; box off;

    subplot(3,2,5);
    plot(years, emb_av, '-o','Color',[0.20 0.45 0.70],'LineWidth',2,'MarkerFaceColor',[0.20 0.45 0.70],'MarkerSize',3);
    hold on;
    plot(years, ops_av, '-o','Color',[0.85 0.33 0.10],'LineWidth',2,'MarkerFaceColor',[0.85 0.33 0.10],'MarkerSize',3);
    plot(years, emb_av+ops_av, '--k','LineWidth',1.2);
    legend({'Embodied','Operational','Total'},'Location','best','FontSize',7,'Box','off');
    xlabel('Year'); ylabel('kg X / yr (12000 vkm)');
    title(['Average car : time series : ' cat_name],'FontSize',7,'FontWeight','bold');
    grid on; box off;

    subplot(3,2,6);
    bar(years, [emb_av', ops_av'], 'stacked');
    colororder([[0.20 0.45 0.70];[0.85 0.33 0.10]]);
    legend({'Embodied','Operational'},'Location','best','FontSize',7,'Box','off');
    xlabel('Year'); ylabel('kg X / yr (12000 vkm)');
    title(['Average car : stacked bars : ' cat_name],'FontSize',7,'FontWeight','bold');
    grid on; box off;

    page = page + 1;
    export_page(fig, output_pdf, page);
    fprintf('Page %d — %s\n', page, cat_name);

end

fprintf('\nDone! PDF: %s\n', output_pdf);

end