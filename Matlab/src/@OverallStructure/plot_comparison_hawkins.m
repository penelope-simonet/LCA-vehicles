function plot_comparison_hawkins(obj)

%% =========================================================
%  plot_comparison_hawkins.m
%  Comparison of Carculator (Norwegian fleet, 2013) vs
%  Hawkins et al. (2013) — Table S1-1
%  Per vkm basis, g X/km
%% =========================================================

%% --- Hawkins et al. (2013) Table S1-1 ---
% EV Li-NCM European electricity mix (most comparable to Norwegian BEV)
% Units: g X/km
hawkins_EV = struct();
hawkins_EV.climate_change                    = 196.79;
hawkins_EV.terrestrial_acidification         = 0.94;
hawkins_EV.freshwater_eutrophication         = 0.21;
hawkins_EV.marine_eutrophication             = 0.21;
hawkins_EV.particulate_matter               = 0.35;
hawkins_EV.photochem_oxidant                = 0.47;
hawkins_EV.human_toxicity                   = 262.19;  % carcinogenic + non-carcinogenic combined
hawkins_EV.freshwater_ecotoxicity           = 4.11;
hawkins_EV.terrestrial_ecotoxicity          = 0.08;
hawkins_EV.metal_depletion                  = 90.37;
hawkins_EV.fossil_depletion                 = 57.47;
hawkins_EV.ionising_radiation               = 103.67;  % g U235eq/km

% ICEV Gasoline (for reference)
hawkins_ICEV = struct();
hawkins_ICEV.climate_change                 = 258.32;
hawkins_ICEV.terrestrial_acidification      = 0.89;
hawkins_ICEV.freshwater_eutrophication      = 0.05;
hawkins_ICEV.marine_eutrophication          = 0.08;
hawkins_ICEV.particulate_matter            = 0.29;
hawkins_ICEV.photochem_oxidant             = 0.61;
hawkins_ICEV.human_toxicity                = 74.09;
hawkins_ICEV.freshwater_ecotoxicity        = 1.51;
hawkins_ICEV.terrestrial_ecotoxicity       = 0.08;
hawkins_ICEV.metal_depletion               = 30.16;
hawkins_ICEV.fossil_depletion              = 90.40;
hawkins_ICEV.ionising_radiation            = 21.72;

%% --- Carculator values (Norwegian new cars 2013, g X/km) ---
% From OS.State(idx_2013).Midpoint_impacts_new_cars
years_all = [obj.State.year];
idx_2013 = find(years_all == 2013);

midpoint_categories = get_midpoint_categories();

carc = struct();
carc.climate_change              = obj.State(idx_2013).Midpoint_impacts_new_cars(2).value  * 1000;
carc.terrestrial_acidification   = obj.State(idx_2013).Midpoint_impacts_new_cars(1).value  * 1000;
carc.freshwater_eutrophication   = obj.State(idx_2013).Midpoint_impacts_new_cars(8).value  * 1000;
carc.marine_eutrophication       = obj.State(idx_2013).Midpoint_impacts_new_cars(9).value  * 1000;
carc.particulate_matter          = obj.State(idx_2013).Midpoint_impacts_new_cars(16).value * 1000;
carc.photochem_oxidant           = obj.State(idx_2013).Midpoint_impacts_new_cars(17).value * 1000;
carc.human_toxicity_carc         = obj.State(idx_2013).Midpoint_impacts_new_cars(10).value * 1000;
carc.human_toxicity_ncarc        = obj.State(idx_2013).Midpoint_impacts_new_cars(11).value * 1000;
carc.freshwater_ecotoxicity      = obj.State(idx_2013).Midpoint_impacts_new_cars(4).value  * 1000;
carc.terrestrial_ecotoxicity     = obj.State(idx_2013).Midpoint_impacts_new_cars(6).value  * 1000;
carc.metal_resources             = obj.State(idx_2013).Midpoint_impacts_new_cars(14).value * 1000;
carc.fossil_resources            = obj.State(idx_2013).Midpoint_impacts_new_cars(7).value  * 1000;
carc.ionising_radiation          = obj.State(idx_2013).Midpoint_impacts_new_cars(12).value * 1000;

%% --- Build comparison table ---
% Categories that can be matched between the two datasets
cat_labels = {
    'Climate change (g CO2eq/km)', ...
    'Terrestrial acidification (g SO2eq/km)', ...
    'Freshwater eutrophication (g P/km)', ...
    'Marine eutrophication (g N/km)', ...
    'Particulate matter (g PM/km)', ...
    'Photochem. oxidant formation (g NMVOC/km)', ...
    'Human toxicity — carcinogenic (g 1,4-DB/km)', ...
    'Human toxicity — non-carcinogenic (g 1,4-DB/km)', ...
    'Freshwater ecotoxicity (g 1,4-DB/km)', ...
    'Terrestrial ecotoxicity (g 1,4-DB/km) ⚠', ...
    'Metal resources (g Fe-eq/km)', ...
    'Fossil resources (g oil-eq/km)', ...
    'Ionising radiation (g U235eq/km)'
};

vals_carculator = [
    carc.climate_change
    carc.terrestrial_acidification
    carc.freshwater_eutrophication
    carc.marine_eutrophication
    carc.particulate_matter
    carc.photochem_oxidant
    carc.human_toxicity_carc
    carc.human_toxicity_ncarc
    carc.freshwater_ecotoxicity
    carc.terrestrial_ecotoxicity
    carc.metal_resources
    carc.fossil_resources
    carc.ionising_radiation
];

vals_hawkins_EV = [
    hawkins_EV.climate_change
    hawkins_EV.terrestrial_acidification
    hawkins_EV.freshwater_eutrophication
    hawkins_EV.marine_eutrophication
    hawkins_EV.particulate_matter
    hawkins_EV.photochem_oxidant
    NaN   % carcinogenic only not available separately in Hawkins
    NaN   % non-carcinogenic only not available separately in Hawkins
    hawkins_EV.freshwater_ecotoxicity
    hawkins_EV.terrestrial_ecotoxicity
    hawkins_EV.metal_depletion
    hawkins_EV.fossil_depletion
    hawkins_EV.ionising_radiation
];

vals_hawkins_ICEV = [
    hawkins_ICEV.climate_change
    hawkins_ICEV.terrestrial_acidification
    hawkins_ICEV.freshwater_eutrophication
    hawkins_ICEV.marine_eutrophication
    hawkins_ICEV.particulate_matter
    hawkins_ICEV.photochem_oxidant
    NaN
    NaN
    hawkins_ICEV.freshwater_ecotoxicity
    hawkins_ICEV.terrestrial_ecotoxicity
    hawkins_ICEV.metal_depletion
    hawkins_ICEV.fossil_depletion
    hawkins_ICEV.ionising_radiation
];

n_cats = length(cat_labels);

%% --- Figure ---
fig = figure('Units','normalized','Position',[0.02 0.02 0.70 0.92]);

ax = axes('Parent', fig, 'Position', [0.45 0.06 0.50 0.90]);
hold on;

y = n_cats:-1:1;  % reverse order for readability

% Normalize each row so that the max of the three values = 1
% BUT keep terrestrial ecotoxicity on its own scale to show the anomaly
vals_norm_carc  = zeros(n_cats,1);
vals_norm_hawk  = zeros(n_cats,1);
vals_norm_icev  = zeros(n_cats,1);

for i = 1:n_cats
    vals_all = [vals_carculator(i), vals_hawkins_EV(i), vals_hawkins_ICEV(i)];
    max_val  = max(vals_all(~isnan(vals_all)));
    if max_val > 0
        vals_norm_carc(i) = vals_carculator(i)    / max_val;
        if ~isnan(vals_hawkins_EV(i)),   vals_norm_hawk(i) = vals_hawkins_EV(i)   / max_val; end
        if ~isnan(vals_hawkins_ICEV(i)), vals_norm_icev(i) = vals_hawkins_ICEV(i) / max_val; end
    end
end

% Draw bars
bar_h = 0.22;
clr_carc = [0.18 0.55 0.34];   % vert — Carculator
clr_hawk = [0.20 0.45 0.70];   % bleu — Hawkins EV
clr_icev = [0.85 0.33 0.10];   % rouge — Hawkins ICEV

for i = 1:n_cats
    % Carculator
    patch([0 vals_norm_carc(i) vals_norm_carc(i) 0], ...
          [y(i)-bar_h y(i)-bar_h y(i) y(i)], clr_carc, 'EdgeColor','none');
    % Hawkins EV
    if ~isnan(vals_hawkins_EV(i))
        patch([0 vals_norm_hawk(i) vals_norm_hawk(i) 0], ...
              [y(i) y(i) y(i)+bar_h y(i)+bar_h], clr_hawk, 'EdgeColor','none');
    end
    % Hawkins ICEV
    if ~isnan(vals_hawkins_ICEV(i))
        patch([0 vals_norm_icev(i) vals_norm_icev(i) 0], ...
              [y(i)-2*bar_h y(i)-2*bar_h y(i)-bar_h y(i)-bar_h], clr_icev, 'EdgeColor','none');
    end

    % Value labels (raw values, not normalized)
    text(ax, vals_norm_carc(i)+0.01, y(i)-bar_h/2, ...
        sprintf('%.2f', vals_carculator(i)), 'FontSize',7, 'Color', clr_carc, 'VerticalAlignment','middle');
    if ~isnan(vals_hawkins_EV(i))
        text(ax, vals_norm_hawk(i)+0.01, y(i)+bar_h/2, ...
            sprintf('%.2f', vals_hawkins_EV(i)), 'FontSize',7, 'Color', clr_hawk, 'VerticalAlignment','middle');
    end
    if ~isnan(vals_hawkins_ICEV(i))
        text(ax, vals_norm_icev(i)+0.01, y(i)-3*bar_h/2, ...
            sprintf('%.2f', vals_hawkins_ICEV(i)), 'FontSize',7, 'Color', clr_icev, 'VerticalAlignment','middle');
    end
end

% Category labels on the left
set(ax,'YTick',[],'XTick',0:0.25:1,'XTickLabel',{'0','25%','50%','75%','100%'});
for i = 1:n_cats
    text(ax, -0.01, y(i), cat_labels{i}, 'HorizontalAlignment','right', ...
        'FontSize',8, 'FontWeight','bold', 'Color',[0.15 0.15 0.15]);
end

xlabel(ax, 'Normalized value (relative to max across the 3 datasets)', 'FontSize',9);
title(ax, {'Carculator (Norway, 2013) vs Hawkins et al. (2013)', ...
    'Per vkm basis — normalized to max per category'}, ...
    'FontSize',10, 'FontWeight','bold');

xlim(ax, [0 1.25]);
ylim(ax, [0.5 n_cats+0.8]);
grid(ax,'on'); box(ax,'off');

% Legend
h(1) = patch(ax, NaN, NaN, clr_carc, 'EdgeColor','none');
h(2) = patch(ax, NaN, NaN, clr_hawk, 'EdgeColor','none');
h(3) = patch(ax, NaN, NaN, clr_icev, 'EdgeColor','none');
legend(ax, h, {'Carculator — Norwegian fleet 2013 (avg)', ...
               'Hawkins et al. — EV Li-NCM Euro mix', ...
               'Hawkins et al. — ICEV Gasoline'}, ...
    'Location','southeast','FontSize',8,'Box','off');

% Note about terrestrial ecotoxicity
annotation(fig,'textbox',[0.01 0.01 0.98 0.04], ...
    'String','⚠ Terrestrial ecotoxicity: Carculator value (6549 g/km) is ~80,000× larger than Hawkins (0.08 g/km) — likely unit inconsistency in Carculator data.', ...
    'FontSize',8,'Color',[0.7 0.1 0.1],'EdgeColor','none','FitBoxToText','off');

fprintf('Plot done!\n');

end