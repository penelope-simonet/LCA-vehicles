function obj = get_pop_projections_municipal(obj,filename)


[~,~,raw] = xlsread(filename);

first_row = 4;
n_years = 29;

time = [raw{first_row:first_row+n_years-1,4}];

municipal_ids = [obj.MunicipalArray.id];

base_col = 5;
low_col = 6;
high_col = 7;


mSize = size(raw);

while first_row < 41299
idx1_men_0_17 = first_row;
idx2_men_0_17 = idx1_men_0_17+n_years-1;

idx1_men_above_18 = idx2_men_0_17+1;
idx2_men_above_18 = idx1_men_above_18+n_years-1;

idx1_women_0_17 = idx2_men_above_18+1;
idx2_women_0_17 = idx1_women_0_17+n_years-1;

idx1_women_above_18 = idx2_women_0_17+1;
idx2_women_above_18 = idx1_women_above_18+n_years-1;

% Find right muncipality
string_this = raw{first_row,1};
id_this = str2num(string_this(1:4));

idx_mun = find(municipal_ids == id_this);

obj.MunicipalArray(idx_mun).population_projection_men_0_17 = [raw{idx1_men_0_17:idx2_men_0_17,base_col}];
obj.MunicipalArray(idx_mun).population_projection_men_above_18 = [raw{idx1_men_above_18:idx2_men_above_18,base_col}];
obj.MunicipalArray(idx_mun).population_projection_women_0_17 = [raw{idx1_women_0_17:idx2_women_0_17,base_col}];
obj.MunicipalArray(idx_mun).population_projection_women_above_18 = [raw{idx1_women_above_18:idx2_women_above_18,base_col}];

obj.MunicipalArray(idx_mun).population_projection_tot_0_17 = obj.MunicipalArray(idx_mun).population_projection_men_0_17 + obj.MunicipalArray(idx_mun).population_projection_women_0_17;
obj.MunicipalArray(idx_mun).population_projection_tot_above_18 = obj.MunicipalArray(idx_mun).population_projection_men_above_18 + obj.MunicipalArray(idx_mun).population_projection_women_above_18;
obj.MunicipalArray(idx_mun).population_projection_tot = obj.MunicipalArray(idx_mun).population_projection_tot_0_17 + obj.MunicipalArray(idx_mun).population_projection_tot_above_18;

%Low
obj.MunicipalArray(idx_mun).population_projection_men_0_17_low = [raw{idx1_men_0_17:idx2_men_0_17,low_col}];
obj.MunicipalArray(idx_mun).population_projection_men_above_18_low = [raw{idx1_men_above_18:idx2_men_above_18,low_col}];
obj.MunicipalArray(idx_mun).population_projection_women_0_17_low = [raw{idx1_women_0_17:idx2_women_0_17,low_col}];
obj.MunicipalArray(idx_mun).population_projection_women_above_18_low = [raw{idx1_women_above_18:idx2_women_above_18,low_col}];

obj.MunicipalArray(idx_mun).population_projection_tot_0_17_low = obj.MunicipalArray(idx_mun).population_projection_men_0_17_low + obj.MunicipalArray(idx_mun).population_projection_women_0_17_low;
obj.MunicipalArray(idx_mun).population_projection_tot_above_18_low = obj.MunicipalArray(idx_mun).population_projection_men_above_18_low + obj.MunicipalArray(idx_mun).population_projection_women_above_18_low;
obj.MunicipalArray(idx_mun).population_projection_tot_low = obj.MunicipalArray(idx_mun).population_projection_tot_0_17_low + obj.MunicipalArray(idx_mun).population_projection_tot_above_18_low;

%High
obj.MunicipalArray(idx_mun).population_projection_men_0_17_high = [raw{idx1_men_0_17:idx2_men_0_17,high_col}];
obj.MunicipalArray(idx_mun).population_projection_men_above_18_high = [raw{idx1_men_above_18:idx2_men_above_18,high_col}];
obj.MunicipalArray(idx_mun).population_projection_women_0_17_high = [raw{idx1_women_0_17:idx2_women_0_17,high_col}];
obj.MunicipalArray(idx_mun).population_projection_women_above_18_high = [raw{idx1_women_above_18:idx2_women_above_18,high_col}];

obj.MunicipalArray(idx_mun).population_projection_tot_0_17_high  = obj.MunicipalArray(idx_mun).population_projection_men_0_17_high + obj.MunicipalArray(idx_mun).population_projection_women_0_17_high;
obj.MunicipalArray(idx_mun).population_projection_tot_above_18_high  = obj.MunicipalArray(idx_mun).population_projection_men_above_18_high + obj.MunicipalArray(idx_mun).population_projection_women_above_18_high;
obj.MunicipalArray(idx_mun).population_projection_tot_high  = obj.MunicipalArray(idx_mun).population_projection_tot_0_17_high + obj.MunicipalArray(idx_mun).population_projection_tot_above_18_high;





first_row = idx2_women_above_18+1;



end

