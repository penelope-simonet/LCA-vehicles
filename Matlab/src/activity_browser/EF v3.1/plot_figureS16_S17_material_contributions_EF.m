% plot_figureS16_S17_material_contributions_EF.m

clear; clc;

base_path = 'C:\Users\penel\OneDrive\Bureau\Devoirs\2526 ENTPE_2\Stage MSP\work\activity browser\output activity Browser\EF 3.1';

vehicles = {
    'BEV Medium',  fullfile(base_path, 'BEV Medium');
    'BEV XL',      fullfile(base_path, 'BEV XL');
    'ICEV Medium', fullfile(base_path, 'ICEV Medium');
    'ICEV XL',     fullfile(base_path, 'ICEV XL');
};
n_veh = size(vehicles, 1);

output_pdf = fullfile(base_path, 'figureS16_S17_material_contributions_EF.pdf');

%mains categories
main_raw = {
    'ef_EF-contributions_EF-v31-acidification-accumulated-exceedance-AE_mol-H-Eq.csv', ...
        'Acidification', 'mol H^+-eq';
    'ef_EF-contributions_EF-v31-climate-change-global-warming-potential-GWP100_kg-CO2-Eq.csv', ...
        'Climate change', 'kg CO_2-eq';
    'ef_EF-contributions_EF-v31-ecotoxicity-freshwater-comparative-toxic-unit-for-ecosystems-CTUe_CTUe.csv', ...
        'Ecotoxicity: freshwater', 'CTUe';
    'ef_EF-contributions_EF-v31-energy-resources-non-renewable-abiotic-depletion-potential-ADP-fossil-fuels_MJ-net-calorific-value.csv', ...
        'Energy resources: non-renewable', 'MJ';
    'ef_EF-contributions_EF-v31-eutrophication-freshwater-fraction-of-nutrients-reaching-freshwater-end-compartment-P_kg-P-Eq.csv', ...
        'Eutrophication: freshwater', 'kg P-eq';
    'ef_EF-contributions_EF-v31-eutrophication-marine-fraction-of-nutrients-reaching-marine-end-compartment-N_kg-N-Eq.csv', ...
        'Eutrophication: marine', 'kg N-eq';
    'ef_EF-contributions_EF-v31-eutrophication-terrestrial-accumulated-exceedance-AE_mol-N-Eq.csv', ...
        'Eutrophication: terrestrial', 'mol N-eq';
    'ef_EF-contributions_EF-v31-human-toxicity-carcinogenic-comparative-toxic-unit-for-human-CTUh_CTUh.csv', ...
        'Human toxicity: carcinogenic', 'CTUh';
    'ef_EF-contributions_EF-v31-human-toxicity-non-carcinogenic-comparative-toxic-unit-for-human-CTUh_CTUh.csv', ...
        'Human toxicity: non-carcinogenic', 'CTUh';
    'ef_EF-contributions_EF-v31-ionising-radiation-human-health-human-exposure-efficiency-relative-to-u235_kBq-U235-Eq.csv', ...
        'Ionising radiation', 'kBq U235-eq';
    'ef_EF-contributions_EF-v31-land-use-soil-quality-index_dimensionless.csv', ...
        'Land use', 'Pt';
    'ef_EF-contributions_EF-v31-material-resources-metalsminerals-abiotic-depletion-potential-ADP-elements-ultimate-reserves_kg-Sb-Eq.csv', ...
        'Material resources: metals/minerals', 'kg Sb-eq';
    'ef_EF-contributions_EF-v31-ozone-depletion-ozone-depletion-potential-ODP_kg-CFC-11-Eq.csv', ...
        'Ozone depletion', 'kg CFC-11-eq';
    'ef_EF-contributions_EF-v31-particulate-matter-formation-impact-on-human-health_disease-incidence.csv', ...
        'Particulate matter formation', 'disease incidence';
    'ef_EF-contributions_EF-v31-photochemical-oxidant-formation-human-health-tropospheric-ozone-concentration-increase_kg-NMVOC-Eq.csv', ...
        'Photochemical oxidant formation: human health', 'kg NMVOC-eq';
    'ef_EF-contributions_EF-v31-water-use-user-deprivation-potential-deprivation-weighted-water-consumption_m3-world-eq-deprived.csv', ...
        'Water use', 'm^3 world eq deprived';
};
n_main = size(main_raw, 1);

%% other categories (details)
detail_raw = {
    'ef_EF-contributions_EF-v31-climate-change-biogenic-global-warming-potential-GWP100_kg-CO2-Eq.csv', ...
        'Climate change: biogenic', 'kg CO_2-eq';
    'ef_EF-contributions_EF-v31-climate-change-fossil-global-warming-potential-GWP100_kg-CO2-Eq.csv', ...
        'Climate change: fossil', 'kg CO_2-eq';
    'ef_EF-contributions_EF-v31-climate-change-land-use-and-land-use-change-global-warming-potential-GWP100_kg-CO2-Eq.csv', ...
        'Climate change: land use', 'kg CO_2-eq';
    'ef_EF-contributions_EF-v31-ecotoxicity-freshwater-inorganics-comparative-toxic-unit-for-ecosystems-CTUe_CTUe.csv', ...
        'Ecotoxicity freshwater: inorganics', 'CTUe';
    'ef_EF-contributions_EF-v31-ecotoxicity-freshwater-organics-comparative-toxic-unit-for-ecosystems-CTUe_CTUe.csv', ...
        'Ecotoxicity freshwater: organics', 'CTUe';
    'ef_EF-contributions_EF-v31-human-toxicity-carcinogenic-inorganics-comparative-toxic-unit-for-human-CTUh_CTUh.csv', ...
        'Human toxicity carc.: inorganics', 'CTUh';
    'ef_EF-contributions_EF-v31-human-toxicity-carcinogenic-organics-comparative-toxic-unit-for-human-CTUh_CTUh.csv', ...
        'Human toxicity carc.: organics', 'CTUh';
    'ef_EF-contributions_EF-v31-human-toxicity-non-carcinogenic-inorganics-comparative-toxic-unit-for-human-CTUh_CTUh.csv', ...
        'Human toxicity non-carc.: inorganics', 'CTUh';
    'ef_EF-contributions_EF-v31-human-toxicity-non-carcinogenic-organics-comparative-toxic-unit-for-human-CTUh_CTUh.csv', ...
        'Human toxicity non-carc.: organics', 'CTUh';
};
n_detail = size(detail_raw, 1);

mat_colors = containers.Map(...
    {'cast iron','steel','aluminium','polyethylene','zinc','copper','lithium','manganese','nickel','phosphorus','other'}, ...
    {'#5F5E5A',  '#378ADD','#1D9E75','#BA7517',     '#D4537E','#E24B4A','#7F77DD','#0F6E56','#D85A30','#639922','#B4B2A9'});

mat_labels = {'cast iron','steel','aluminium','polyethylene','zinc','copper','lithium','manganese','nickel','phosphorus','other'};

veh_labels = {'BEV Med.','BEV XL','ICEV Med.','ICEV XL'};

%% pdf
Wp = 21.0; Hp = 29.7;

n_cols_p = 2;
n_rows_p = 5;
lm_p = 1.3; rm_p = 0.4; tm_p = 0.6; bm_p = 0.6;
hgap_p = 2.4; vgap_p = 1.6;

plot_w_p = (Wp - lm_p - rm_p - (n_cols_p-1)*hgap_p) / n_cols_p;
plot_h_p = (Hp - tm_p - bm_p - (n_rows_p-1)*vgap_p) / n_rows_p;

x_pos_p = zeros(1, n_cols_p);
for c = 1:n_cols_p
    x_pos_p(c) = lm_p + (c-1)*(plot_w_p + hgap_p);
end
y_pos_p = zeros(1, n_rows_p);
for r = 1:n_rows_p
    y_pos_p(r) = Hp - tm_p - r*plot_h_p - (r-1)*vgap_p;
end

slot_positions_p = zeros(n_cols_p*n_rows_p, 4);
for r = 1:n_rows_p
    for c = 1:n_cols_p
        idx = (r-1)*n_cols_p + c;
        slot_positions_p(idx,:) = [x_pos_p(c), y_pos_p(r), plot_w_p, plot_h_p];
    end
end

%% page 1 and page 2 : main categories
main_page1 = main_raw(1:8, :);
main_page2 = main_raw(9:16, :);

build_ef_page(output_pdf, main_page1, 1, ...
    vehicles, 'principaux', mat_colors, mat_labels, slot_positions_p, ...
    Wp, Hp, veh_labels, n_veh, false);

build_ef_page(output_pdf, main_page2, 9, ...
    vehicles, 'principaux', mat_colors, mat_labels, slot_positions_p, ...
    Wp, Hp, veh_labels, n_veh, true);

%% page 3 : other categories (details)
build_ef_page(output_pdf, detail_raw, 1, ...
    vehicles, 'details', mat_colors, mat_labels, slot_positions_p, ...
    Wp, Hp, veh_labels, n_veh, true);

fprintf('\n✓ PDF généré : %s\n', output_pdf);

%% excel
source_dir = fullfile(base_path, 'Source_data');
if ~exist(source_dir, 'dir'), mkdir(source_dir); end
output_xlsx = fullfile(source_dir, 'figureS16_S17_material_contributions_EF.xlsx');
if exist(output_xlsx, 'file'), delete(output_xlsx); end

all_indicators = [main_raw; detail_raw];
n_all = size(all_indicators, 1);

for k = 1:n_all
    fname_csv = all_indicators{k,1};
    label_raw = all_indicators{k,2};
    unit_disp = all_indicators{k,3};

    all_scores = cell(n_veh,1);
    for v = 1:n_veh
        subfolder_this = 'principaux';
        if k > n_main
            subfolder_this = 'details';
        end
        fpath = fullfile(vehicles{v,2}, subfolder_this, fname_csv);
        all_scores{v} = read_scores(fpath);
    end

    all_mats = {};
    for v = 1:n_veh
        if ~isempty(all_scores{v})
            all_mats = union(all_mats, keys(all_scores{v}));
        end
    end

    n_mat = numel(all_mats);
    data = zeros(n_mat, n_veh);
    for m = 1:n_mat
        for v = 1:n_veh
            if ~isempty(all_scores{v}) && isKey(all_scores{v}, all_mats{m})
                data(m,v) = all_scores{v}(all_mats{m});
            end
        end
    end

    header = [{'Material'}, veh_labels];
    data_out = [all_mats(:), num2cell(data)];

    sheet_name = matlab.lang.makeValidName(label_raw);
    if length(sheet_name) > 31
        sheet_name = sheet_name(1:31);
    end
    writecell([{sprintf('Unit: %s', unit_disp)}, cell(1, n_veh)], output_xlsx, 'Sheet', sheet_name, 'Range', 'A1');
    writecell([header; data_out], output_xlsx, 'Sheet', sheet_name, 'Range', 'A2');
end

fprintf('Excel saved: %s\n', output_xlsx);

%% local functions
function build_ef_page(output_pdf, indicators_page, letter_start, ...
    vehicles, subfolder, mat_colors, mat_labels, slot_positions, Wp, Hp, ...
    veh_labels, n_veh, append_flag_value)

n_ind_page = size(indicators_page, 1);

fig_p = figure('Units','centimeters','Position',[1 1 Wp Hp], ...
               'PaperUnits','centimeters','PaperSize',[Wp Hp], ...
               'PaperPosition',[0 0 Wp Hp],'Visible','off', ...
               'Color','w');

for k = 1:n_ind_page
    fname_csv = indicators_page{k,1};
    label_raw = indicators_page{k,2};
    unit_disp = indicators_page{k,3};
    letter = char('a' + letter_start + k - 2);
    label = sprintf('(%s) %s', letter, label_raw);

   
    all_scores = cell(n_veh,1);
    for v = 1:n_veh
        fpath = fullfile(vehicles{v,2}, subfolder, fname_csv);
        all_scores{v} = read_scores(fpath);
    end

    all_mats = {};
    for v = 1:n_veh
        if ~isempty(all_scores{v})
            all_mats = union(all_mats, keys(all_scores{v}));
        end
    end

    n_mat = numel(all_mats);
    data = zeros(n_mat, n_veh);
    for m = 1:n_mat
        for v = 1:n_veh
            if ~isempty(all_scores{v}) && isKey(all_scores{v}, all_mats{m})
                data(m,v) = all_scores{v}(all_mats{m});
            end
        end
    end

    ax = axes(fig_p,'Units','centimeters', ...
        'Position', slot_positions(k,:)); 

    bottom = zeros(1, n_veh);
    hold(ax,'on');
    for m = 1:n_mat
        mat = all_mats{m};
        if isKey(mat_colors, mat)
            col = mat_colors(mat);
        else
            col = '#B4B2A9';
        end
        rgb = sscanf(col(2:end),'%2x%2x%2x',[1 3])/255;
        for v = 1:n_veh
            if data(m,v) > 0
                rectangle(ax,'Position',[v-0.3, bottom(v), 0.6, data(m,v)], ...
                    'FaceColor', rgb, 'EdgeColor','none');
                bottom(v) = bottom(v) + data(m,v);
            end
        end
    end
    hold(ax,'off');

    ax.XTick = 1:n_veh;
    ax.XTickLabel = veh_labels;
    ax.XTickLabelRotation = 0;
    ax.FontSize = 9;
    ax.TickDir = 'out';
    ax.Box = 'off';
    ax.XLim = [0.5, n_veh+0.5];
    ylabel(ax, unit_disp, 'FontSize', 9);
    title(ax, label, 'FontSize', 9, 'FontWeight', 'bold');
    grid(ax,'on'); ax.GridAlpha = 0.15; ax.YGrid = 'on'; ax.XGrid = 'off';

    max_val = max(bottom);
    if max_val > 100
        ax.YAxis.Exponent = floor(log10(max_val));
    end
end


ax_leg_p = axes(fig_p,'Units','centimeters', ...
    'Position', slot_positions(10,:), 'Visible','off');
hold(ax_leg_p,'on');

n_mat_leg   = numel(mat_labels);
n_col_leg   = 2;
n_per_col   = ceil(n_mat_leg / n_col_leg);
y_start_leg = 0.90;
row_step    = 0.15;
col_x_axes  = [0.05, 0.55];
col_x_fig_offset = [0.01, slot_positions(10,3)/Wp * 0.55];

for m = 1:n_mat_leg
    col_idx = floor((m-1) / n_per_col);
    row_idx = mod((m-1), n_per_col);
    y = y_start_leg - row_idx * row_step;

    col = mat_colors(mat_labels{m});
    rgb = sscanf(col(2:end),'%2x%2x%2x',[1 3])/255;
    annotation(fig_p,'rectangle', ...
        [slot_positions(10,1)/Wp + col_x_fig_offset(col_idx+1), ...
         slot_positions(10,2)/Hp + y*slot_positions(10,4)/Hp - 0.01, ...
         0.02, 0.02], 'FaceColor', rgb, 'EdgeColor', 'none');
    text(ax_leg_p, col_x_axes(col_idx+1) + 0.07, y, mat_labels{m}, ...
        'FontSize', 8, 'Units', 'normalized', 'VerticalAlignment', 'middle');
end
text(ax_leg_p, 0.0, 1.05, 'Materials', ...
    'FontSize', 9, 'FontWeight', 'bold', 'Units', 'normalized');

exportgraphics(fig_p, output_pdf, 'ContentType', 'vector', 'Append', append_flag_value);
close(fig_p);

end


function scores = read_scores(filepath)
    scores = containers.Map();
    if ~isfile(filepath)
        return;
    end
    fid = fopen(filepath, 'r');
    header = fgetl(fid);
    score_line = '';
    while ~feof(fid)
        line = fgetl(fid);
        if contains(line, ',Score,')
            score_line = line;
            break;
        end
    end
    fclose(fid);
    if isempty(score_line)
        return;
    end

    cols = parse_csv_line(header);
    vals = parse_csv_line(score_line);

    for c = 9:numel(cols)
        col = cols{c};
        parts = strsplit(col, ' | ');
        raw = strtrim(parts{1});
        name = simplify_name(raw);
        if c <= numel(vals) && ~isempty(vals{c})
            v = str2double(vals{c});
            if ~isnan(v)
                scores(name) = v;
            end
        end
    end
end

function name = simplify_name(raw)
    raw = lower(strtrim(raw));
    if contains(raw,'cast iron'),        name = 'cast iron';
    elseif contains(raw,'steel') || contains(raw,'low-alloyed'), name = 'steel';
    elseif contains(raw,'aluminium') || contains(raw,'aluminum'), name = 'aluminium';
    elseif contains(raw,'polyethylene') || contains(raw,'plastic'), name = 'polyethylene';
    elseif contains(raw,'zinc'),         name = 'zinc';
    elseif contains(raw,'copper'),       name = 'copper';
    elseif contains(raw,'lithium'),      name = 'lithium';
    elseif contains(raw,'manganese'),    name = 'manganese';
    elseif contains(raw,'nickel'),       name = 'nickel';
    elseif contains(raw,'phospho'),      name = 'phosphorus';
    else,                                name = 'other';
    end
end

function fields = parse_csv_line(line)
    fields = {};
    i = 1;
    n = numel(line);
    while i <= n
        if line(i) == '"'
            j = i+1;
            while j <= n && ~(line(j)=='"' && (j==n || line(j+1)==','))
                j = j+1;
            end
            fields{end+1} = line(i+1:j-1); 
            i = j+2;
        else
            j = i;
            while j <= n && line(j) ~= ','
                j = j+1;
            end
            fields{end+1} = line(i:j-1); 
            i = j+1;
        end
    end
end