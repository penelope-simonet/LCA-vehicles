function plot_spider_new_cars(obj)

cat_names_to_plot = { ...
    'climate change', ...
    'eutrophication: freshwater', ...
    'eutrophication: marine', ...
    'acidification: terrestrial', ...
    'energy resources depletion: non-renewable', ...
    'water use', ...
    'energy resources: renewable'};

cat_labels = { ...
    'Climate change', ...
    'Freshwater eutrophication', ...
    'Marine eutrophication', ...
    'Terrestrial acidification', ...
    'Energy depletion (non-ren.)', ...
    'Water use', ...
    'Energy resources (ren.)'};

years_to_plot = [2000, 2010, 2023];
colors = {[0.85 0.33 0.10], [0.93 0.69 0.13], [0.18 0.55 0.34]};

midpoint_categories = get_midpoint_categories();
all_names = {midpoint_categories.name};

cat_ids = zeros(1, length(cat_names_to_plot));
for c = 1:length(cat_names_to_plot)
    idx = find(strcmp(all_names, cat_names_to_plot{c}));
    if isempty(idx)
        error('Catégorie non trouvée : %s', cat_names_to_plot{c});
    end
    cat_ids(c) = idx;
end

years_all = [obj.State.year];
year_indices = zeros(1, length(years_to_plot));
for y = 1:length(years_to_plot)
    idx = find(years_all == years_to_plot(y));
    year_indices(y) = idx;
end

n_cats  = length(cat_ids);
n_years = length(years_to_plot);
data    = zeros(n_years, n_cats);

for y = 1:n_years
    state = obj.State(year_indices(y));
    for c = 1:n_cats
        data(y, c) = state.Midpoint_impacts_new_cars(cat_ids(c)).value;
    end
end

data_norm = zeros(size(data));
for c = 1:n_cats
    max_val = max(abs(data(:, c)));
    if max_val > 0
        data_norm(:, c) = data(:, c) / max_val;
    end
end

n_axes = n_cats;
angles = linspace(0, 2*pi, n_axes + 1);
angles = angles(1:end-1);

figure('Units', 'normalized', 'Position', [0.05 0.05 0.80 0.88]);

% Axes bien centré avec marges généreuses
ax = axes('Position', [0.18 0.18 0.64 0.62]);
hold(ax, 'on');
axis(ax, 'equal');
axis(ax, 'off');

R = 1;

% --- Cercles de référence ---
n_circles = 4;
for r = 1:n_circles
    r_val = R * r / n_circles;
    theta = linspace(0, 2*pi, 300);
    plot(ax, r_val*cos(theta), r_val*sin(theta), '-', ...
        'Color', [0.82 0.82 0.82], 'LineWidth', 0.6);
    % label sur l'axe de gauche pour éviter collision avec le haut
    text(ax, -0.03, r_val, ...
        sprintf('%.0f%%', 100*r/n_circles), ...
        'FontSize', 9, 'Color', [0.55 0.55 0.55], 'HorizontalAlignment', 'right');
end

% --- Axes radiaux ---
for c = 1:n_axes
    plot(ax, [0, R*cos(angles(c))], [0, R*sin(angles(c))], '-', ...
        'Color', [0.65 0.65 0.65], 'LineWidth', 1.0);
end

% --- Labels des axes avec offsets manuels ---
label_offset = 1.22;
for c = 1:n_axes
    x_lbl = label_offset * cos(angles(c));
    y_lbl = label_offset * sin(angles(c));

    if cos(angles(c)) > 0.15
        halign = 'left';
    elseif cos(angles(c)) < -0.15
        halign = 'right';
    else
        halign = 'center';
    end

    % Offsets verticaux manuels par label pour éviter tous les chevauchements
    y_extra = 0;
    x_extra = 0;
    if strcmp(cat_labels{c}, 'Freshwater eutrophication')
        y_extra =  0.13;   % monter au-dessus du titre
        x_extra = -0.005;
    elseif strcmp(cat_labels{c}, 'Marine eutrophication')
        y_extra =  -0.1;
        x_extra =  0.05;
    elseif strcmp(cat_labels{c}, 'Water use')
        y_extra = 0.1;   % descendre sous la légende
    end

    text(ax, x_lbl + x_extra, y_lbl + y_extra, cat_labels{c}, ...
        'FontSize', 11, 'FontWeight', 'bold', ...
        'HorizontalAlignment', halign, ...
        'VerticalAlignment', 'middle', ...
        'Color', [0.15 0.15 0.15]);
end

% --- Polygones ---
for y = 1:n_years
    vals   = data_norm(y, :);
    x_poly = [vals .* cos(angles), vals(1)*cos(angles(1))];
    y_poly = [vals .* sin(angles), vals(1)*sin(angles(1))];

    fill(ax, x_poly, y_poly, colors{y}, 'FaceAlpha', 0.15, 'EdgeColor', 'none');
    plot(ax, x_poly, y_poly, '-o', ...
        'Color', colors{y}, 'LineWidth', 2.5, ...
        'MarkerFaceColor', colors{y}, 'MarkerSize', 7);
end

% --- Légende en bas ---
h = zeros(1, n_years);
for y = 1:n_years
    h(y) = plot(ax, NaN, NaN, '-o', ...
        'Color', colors{y}, 'LineWidth', 2.5, ...
        'MarkerFaceColor', colors{y}, 'MarkerSize', 7);
end
legend(ax, h, ...
    {sprintf('New cars %d', years_to_plot(1)), ...
     sprintf('New cars %d', years_to_plot(2)), ...
     sprintf('New cars %d', years_to_plot(3))}, ...
    'Location', 'southoutside', ...
    'Orientation', 'horizontal', ...
    'FontSize', 11, 'Box', 'off');

% --- Titre avec espace suffisant au-dessus ---
title(ax, 'Midpoint impacts — Norwegian new cars (normalized)', ...
    'FontSize', 13, 'FontWeight', 'bold', 'Units', 'normalized', ...
    'Position', [0.5, 1.12, 0]);

end