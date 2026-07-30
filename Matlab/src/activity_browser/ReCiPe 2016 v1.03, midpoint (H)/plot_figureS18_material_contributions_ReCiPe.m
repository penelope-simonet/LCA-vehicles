% plot_figureS18_material_contributions_ReCiPe.m

clear; clc;

base_path = 'C:\Users\penel\OneDrive\Bureau\Devoirs\2526 ENTPE_2\Stage MSP\work\activity browser\output activity Browser\ReCiPe 2016 v1.03, midpoint (H)';

vehicles = {
    'BEV Medium',  fullfile(base_path, 'BEV Medium');
    'BEV XL',      fullfile(base_path, 'BEV XL');
    'ICEV Medium', fullfile(base_path, 'ICEV Medium');
    'ICEV XL',     fullfile(base_path, 'ICEV XL');
};
n_veh = size(vehicles, 1);

output_pdf = fullfile(base_path, 'figureS18_material_contributions_ReCiPe.pdf');
output_pdf_portrait = fullfile(base_path, 'figureS18_material_contributions_ReCiPe_portrait.pdf');

indicators_raw = {
    'GWP1000',     'kg-CO2-Eq',    'climate change',                                        'kg CO_2-eq';
    'SOP',         'kg-Cu-Eq',     'material resources: metals/minerals',                    'kg Cu-eq';
    'FEP',         'kg-P-Eq',      'eutrophication: freshwater',                             'kg P-eq';
    'MEP',         'kg-N-Eq',      'eutrophication: marine',                                 'kg N-eq';
    'TAP',         'kg-SO2-Eq',    'acidification: terrestrial',                             'kg SO_2-eq';
    'FETP',        'kg-14-DCB-Eq', 'ecotoxicity: freshwater',                                'kg 1,4-DCB-eq';
    'METP',        'kg-14-DCB-Eq', 'ecotoxicity: marine',                                    'kg 1,4-DCB-eq';
    'TETP',        'kg-14-DCB-Eq', 'ecotoxicity: terrestrial',                               'kg 1,4-DCB-eq';
    'HTPc',        'kg-14-DCB-Eq', 'human toxicity: carcinogenic',                           'kg 1,4-DCB-eq';
    'HTPnc',       'kg-14-DCB-Eq', 'human toxicity: non-carcinogenic',                       'kg 1,4-DCB-eq';
    'IRP',         'kg-Co-60-Eq',  'ionising radiation',                                     'kg Co-60-eq';
    'LOP',         'm2a-crop-Eq',  'land use',                                               'm^2a crop-eq';
    'ODPinfinite', 'kg-CFC-11-Eq', 'ozone depletion',                                        'kg CFC-11-eq';
    'PMFP',        'kg-PM25-Eq',   'particulate matter formation',                           'kg PM_{2.5}-eq';
    'HOFP',        'kg-NOx-Eq',    'photochemical oxidant formation: human health',          'kg NO_x-eq';
    'EOFP',        'kg-NOx-Eq',    'photochemical oxidant formation: terrestrial ecosystems','kg NO_x-eq';
    'WCP',         'cubic-meter',  'water use',                                              'm^3';
    'FFP',         'kg-oil-Eq',    'energy resources depletion: non-renewable',              'kg oil-eq';
};
n_ind = size(indicators_raw, 1);

indicators = indicators_raw;
for i = 1:n_ind
    letter = char('a' + i - 1);
    indicators{i,3} = sprintf('(%s) %s', letter, indicators_raw{i,3});
end

mat_colors = containers.Map(...
    {'cast iron','steel','aluminium','polyethylene','zinc','copper','lithium','manganese','nickel','phosphorus','other'}, ...
    {'#5F5E5A',  '#378ADD','#1D9E75','#BA7517',     '#D4537E','#E24B4A','#7F77DD','#0F6E56','#D85A30','#639922','#B4B2A9'});

mat_labels = {'cast iron','steel','aluminium','polyethylene','zinc','copper','lithium','manganese','nickel','phosphorus','other'};

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

%% pdf
W = 29.7; H = 21.0;
lm = 1.2; rm = 1.0; tm = 1.5; bm = 1.2;
hgap = 1.4; vgap = 2.2;

plot_w = (W - lm - rm - 2*hgap) / 3;
plot_h = (H - tm - bm - vgap) / 2;

x_pos = [lm, lm+plot_w+hgap, lm+2*(plot_w+hgap)];
y_pos = [bm+plot_h+vgap, bm]; 

veh_colors = {'#185FA5','#0C447C','#3B6D11','#27500A'};
veh_labels = {'BEV Med.','BEV XL','ICEV Med.','ICEV XL'};

% pdf portrait
all_indicator_data = struct('label', {}, 'unit_disp', {}, 'data', {}, 'mats', {});

first_page = true;
fig = [];

for i = 1:n_ind
    code     = indicators{i,1};
    unit_f   = indicators{i,2};
    label    = indicators{i,3};
    unit_disp= indicators{i,4};

    
    page_idx = ceil(i/6);
    pos_idx  = mod(i-1,6);
    col_idx  = mod(pos_idx,3)+1;
    row_idx  = floor(pos_idx/3)+1;

  
    if mod(i-1,6) == 0
        if ~isempty(fig)
            exportgraphics(fig, output_pdf,'ContentType','vector','Append',true);
            close(fig);
        end
        fig = figure('Units','centimeters','Position',[1 1 W H], ...
                     'PaperUnits','centimeters','PaperSize',[W H], ...
                     'PaperPosition',[0 0 W H],'Visible','off', ...
                     'Color','w');
    end

    
    all_scores = cell(n_veh,1);
    for v = 1:n_veh
        fname = sprintf('lca_EF-contributions_ReCiPe-2016-v103-midpoint-H-%s_%s.csv', code, unit_f);
        fpath = fullfile(vehicles{v,2}, fname);
        all_scores{v} = read_scores(fpath);
    end

    
    all_mats = {};
    for v = 1:n_veh
        if ~isempty(all_scores{v})
            all_mats = union(all_mats, keys(all_scores{v}));
        end
    end

  
    n_mat = numel(all_mats);
    data  = zeros(n_mat, n_veh);
    for m = 1:n_mat
        for v = 1:n_veh
            if ~isempty(all_scores{v}) && isKey(all_scores{v}, all_mats{m})
                data(m,v) = all_scores{v}(all_mats{m});
            end
        end
    end

    
    all_indicator_data(i).label     = label;
    all_indicator_data(i).unit_disp = unit_disp;
    all_indicator_data(i).data      = data;
    all_indicator_data(i).mats      = all_mats;

    
    ax = axes(fig,'Units','centimeters', ...
        'Position',[x_pos(col_idx), y_pos(row_idx), plot_w, plot_h]); 

    
    bottom = zeros(1, n_veh);
    for m = 1:n_mat
        mat = all_mats{m};
        if isKey(mat_colors, mat)
            col = mat_colors(mat);
        else
            col = '#B4B2A9';
        end
        rgb = sscanf(col(2:end),'%2x%2x%2x',[1 3])/255;
        bar_h = bar(ax, 1:n_veh, data(m,:), 'stacked', ...
            'FaceColor', rgb, 'EdgeColor', 'none', 'BarWidth', 0.6);
        if m == 1
            hold(ax,'on');
        end
        
        for v = 1:n_veh
            if data(m,v) > 0
                rectangle(ax,'Position',[v-0.3, bottom(v), 0.6, data(m,v)], ...
                    'FaceColor', rgb, 'EdgeColor','none');
                bottom(v) = bottom(v) + data(m,v);
            end
        end
        delete(bar_h);
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
    max_total = max(bottom);
    if max_total > 100
        ax.YAxis.Exponent = floor(log10(max_total));
    end

    
end


if ~isempty(fig)
    if first_page
        exportgraphics(fig, output_pdf,'ContentType','vector','Append',false);
    else
        exportgraphics(fig, output_pdf,'ContentType','vector','Append',true);
    end
    close(fig);
end


fig_leg = figure('Units','centimeters','Position',[1 1 W H], ...
                 'PaperUnits','centimeters','PaperSize',[W H], ...
                 'PaperPosition',[0 0 W H],'Visible','off','Color','w');

ax_leg = axes(fig_leg,'Position',[0 0 1 1],'Visible','off');
hold(ax_leg,'on');

y_start = 0.85;
annotation(fig_leg,'textbox',[0.05 0.90 0.9 0.08],'String','Légende — Matériaux', ...
    'FontSize',14,'FontWeight','bold','HorizontalAlignment','center','EdgeColor','none');

for m = 1:numel(mat_labels)
    col = mat_colors(mat_labels{m});
    rgb = sscanf(col(2:end),'%2x%2x%2x',[1 3])/255;
    y = y_start - (m-1)*0.07;
    annotation(fig_leg,'rectangle',[0.1 y 0.05 0.04],'FaceColor',rgb,'EdgeColor','none');
    annotation(fig_leg,'textbox',[0.17 y-0.005 0.7 0.05],'String',mat_labels{m}, ...
        'FontSize',11,'EdgeColor','none','VerticalAlignment','middle');
end

exportgraphics(fig_leg, output_pdf,'ContentType','vector','Append',true);
close(fig_leg);

fprintf('\n✓ PDF généré : %s\n', output_pdf);


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

cats_per_page_p = 9;
n_pages_p = ceil(n_ind / cats_per_page_p);
fig_p = [];
first_page_p = true;

for pg = 1:n_pages_p
    idx_start = (pg-1)*cats_per_page_p + 1;
    idx_end   = min(pg*cats_per_page_p, n_ind);
    n_on_page = idx_end - idx_start + 1;

    fig_p = figure('Units','centimeters','Position',[1 1 Wp Hp], ...
                   'PaperUnits','centimeters','PaperSize',[Wp Hp], ...
                   'PaperPosition',[0 0 Wp Hp],'Visible','off', ...
                   'Color','w');

    for k = 1:n_on_page
        ind_idx = idx_start + k - 1;
        d = all_indicator_data(ind_idx);

        ax = axes(fig_p,'Units','centimeters', ...
            'Position', slot_positions_p(k,:)); 

        n_mat_k = size(d.data, 1);
        bottom = zeros(1, n_veh);
        hold(ax,'on');
        for m = 1:n_mat_k
            mat = d.mats{m};
            if isKey(mat_colors, mat)
                col = mat_colors(mat);
            else
                col = '#B4B2A9';
            end
            rgb = sscanf(col(2:end),'%2x%2x%2x',[1 3])/255;
            for v = 1:n_veh
                if d.data(m,v) > 0
                    rectangle(ax,'Position',[v-0.3, bottom(v), 0.6, d.data(m,v)], ...
                        'FaceColor', rgb, 'EdgeColor','none');
                    bottom(v) = bottom(v) + d.data(m,v);
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
        ylabel(ax, d.unit_disp, 'FontSize', 9);
        title(ax, d.label, 'FontSize', 9, 'FontWeight', 'bold');
        grid(ax,'on'); ax.GridAlpha = 0.15; ax.YGrid = 'on'; ax.XGrid = 'off';
        max_total = max(bottom);
        if max_total > 100
            ax.YAxis.Exponent = floor(log10(max_total));
        end
    end

   
    ax_leg_p = axes(fig_p,'Units','centimeters', ...
        'Position', slot_positions_p(10,:), 'Visible','off');
    hold(ax_leg_p,'on');

    n_mat_leg   = numel(mat_labels);
    n_col_leg   = 2;
    n_per_col   = ceil(n_mat_leg / n_col_leg);
    y_start_leg = 0.90;
    row_step    = 0.15;
    col_x_axes  = [0.05, 0.55]; 
    col_x_fig_offset = [0.01, slot_positions_p(10,3)/Wp * 0.55]; 

    for m = 1:n_mat_leg
        col_idx = floor((m-1) / n_per_col);   
        row_idx = mod((m-1), n_per_col);      
        y = y_start_leg - row_idx * row_step;

        col = mat_colors(mat_labels{m});
        rgb = sscanf(col(2:end),'%2x%2x%2x',[1 3])/255;
        annotation(fig_p,'rectangle', ...
            [slot_positions_p(10,1)/Wp + col_x_fig_offset(col_idx+1), ...
             slot_positions_p(10,2)/Hp + y*slot_positions_p(10,4)/Hp - 0.01, ...
             0.02, 0.02], 'FaceColor', rgb, 'EdgeColor', 'none');
        text(ax_leg_p, col_x_axes(col_idx+1) + 0.07, y, mat_labels{m}, ...
            'FontSize', 8, 'Units', 'normalized', 'VerticalAlignment', 'middle');
    end
    text(ax_leg_p, 0.0, 1.05, 'Materials', ...
        'FontSize', 9, 'FontWeight', 'bold', 'Units', 'normalized');

    if first_page_p
        exportgraphics(fig_p, output_pdf_portrait,'ContentType','vector','Append',false);
        first_page_p = false;
    else
        exportgraphics(fig_p, output_pdf_portrait,'ContentType','vector','Append',true);
    end
    close(fig_p);
    fprintf('Portrait page %d : indicators %d to %d\n', pg, idx_start, idx_end);
end

fprintf('\n✓ PDF portrait généré : %s\n', output_pdf_portrait);

%% Excel export
source_dir = 'C:\Users\penel\OneDrive\Bureau\Devoirs\2526 ENTPE_2\Stage MSP\work\Vehicles\Matlab\src\activity_browser\Source_data';
if ~exist(source_dir, 'dir'), mkdir(source_dir); end
output_xlsx = fullfile(source_dir, 'figureS18_material_contributions_ReCiPe.xlsx');
if exist(output_xlsx, 'file'), delete(output_xlsx); end

for i = 1:n_ind
    d = all_indicator_data(i);

    header = [{'Material'}, veh_labels];
    data_out = [d.mats(:), num2cell(d.data)];

    sheet_name = matlab.lang.makeValidName(d.label);
    if length(sheet_name) > 31
        sheet_name = sheet_name(1:31);
    end
    writecell([{sprintf('Unit: %s', d.unit_disp)}, cell(1, n_veh)], output_xlsx, 'Sheet', sheet_name, 'Range', 'A1');
    writecell([header; data_out], output_xlsx, 'Sheet', sheet_name, 'Range', 'A2');
end

fprintf('Excel saved: %s\n', output_xlsx);