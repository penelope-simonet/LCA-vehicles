function MidpointArray = get_midpoint_categories()


%%
MidpointArray(1:42) = MidpointCategories;

c=1;
MidpointArray(c).name = 'acidification: terrestrial';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'kg SO2eq';

c=c+1;
MidpointArray(c).name = 'climate change';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'kg CO2eq';

c=c+1;
MidpointArray(c).name = 'climate change w bio';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'kg CO2eq';


c=c+1;
MidpointArray(c).name = 'ecotoxicity: freshwater';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'kg 1,4-DCB';

c=c+1;
MidpointArray(c).name = 'ecotoxicity: marine';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'kg 1,4-DCB';

c=c+1;
MidpointArray(c).name = 'ecotoxicity: terrestrial';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'kg 1,4-DCB';

c=c+1;
MidpointArray(c).name = 'energy resources depletion: non-renewable';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'oil-eq';

c=c+1;
MidpointArray(c).name = 'eutrophication: freshwater';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'kg P';

c=c+1;
MidpointArray(c).name = 'eutrophication: marine';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'kg N';

c=c+1;
MidpointArray(c).name = 'human toxicity: carcinogenic';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'kg 1,4-DCB';

c=c+1;
MidpointArray(c).name = 'human toxicity: non-carcinogenic';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'kg 1,4-DCB';

c=c+1;
MidpointArray(c).name = 'ionising radiation';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'kBq Co-60';

c=c+1;
MidpointArray(c).name = 'land use';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'm2a';

c=c+1;
MidpointArray(c).name = 'material resources: metals/minerals';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'kg Cu-eq';


c=c+1;
MidpointArray(c).name = 'ozone depletion';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'kg CFC11eq';

c=c+1;
MidpointArray(c).name = 'particulate matter formation';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'kg PM2.5eq';


c=c+1;
MidpointArray(c).name = 'photochemical oxidant formation: human health';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'kg NOx eq';

c=c+1;
MidpointArray(c).name = 'photochemical oxidant formation: terrestrial ecosystems';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'kg NOx eq';

c=c+1;
MidpointArray(c).name = 'water use';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'm3';

c=c+1;
MidpointArray(c).name = 'energy resources: non-renewable';
MidpointArray(c).framework = '';
MidpointArray(c).unit = '';

c=c+1;
MidpointArray(c).name = 'energy resources: renewable';
MidpointArray(c).framework = '';
MidpointArray(c).unit = '';

c=c+1;
MidpointArray(c).name = 'total';
MidpointArray(c).framework = '';
MidpointArray(c).unit = '';

c=c+1;  
MidpointArray(c).name = 'Human noise impacts';
MidpointArray(c).framework = 'Cucurachi et al.';
MidpointArray(c).unit = '';

% EF v3.1 categories (
c=c+1;
MidpointArray(c).name = 'acidification EF'; 
MidpointArray(c).framework = 'EF v3.1'; 
MidpointArray(c).unit = 'mol H+-Eq';

c=c+1; 
MidpointArray(c).name = 'climate change EF'; 
MidpointArray(c).framework = 'EF v3.1'; 
MidpointArray(c).unit = 'kg CO2-Eq';

c=c+1; 
MidpointArray(c).name = 'climate change: biogenic EF'; 
MidpointArray(c).framework = 'EF v3.1';
MidpointArray(c).unit = 'kg CO2-Eq';

c=c+1; 
MidpointArray(c).name = 'climate change: fossil EF';
MidpointArray(c).framework = 'EF v3.1'; 
MidpointArray(c).unit = 'kg CO2-Eq';

c=c+1;
MidpointArray(c).name = 'climate change: land use and land use change EF'; 
MidpointArray(c).framework = 'EF v3.1'; 
MidpointArray(c).unit = 'kg CO2-Eq';

c=c+1; 
MidpointArray(c).name = 'ecotoxicity: freshwater EF'; 
MidpointArray(c).framework = 'EF v3.1'; 
MidpointArray(c).unit = 'CTUe';

c=c+1; 
MidpointArray(c).name = 'energy resources: non-renewable EF'; 
MidpointArray(c).framework = 'EF v3.1'; 
MidpointArray(c).unit = 'MJ';

c=c+1; 
MidpointArray(c).name = 'eutrophication: freshwater EF'; 
MidpointArray(c).framework = 'EF v3.1'; 
MidpointArray(c).unit = 'kg P-Eq';

c=c+1;
MidpointArray(c).name = 'eutrophication: marine EF'; 
MidpointArray(c).framework = 'EF v3.1'; 
MidpointArray(c).unit = 'kg N-Eq';

c=c+1; 
MidpointArray(c).name = 'eutrophication: terrestrial EF'; 
MidpointArray(c).framework = 'EF v3.1'; 
MidpointArray(c).unit = 'mol N-Eq';

c=c+1;
MidpointArray(c).name = 'human toxicity: carcinogenic EF'; 
MidpointArray(c).framework = 'EF v3.1'; 
MidpointArray(c).unit = 'CTUh';

c=c+1;
MidpointArray(c).name = 'human toxicity: non-carcinogenic EF'; 
MidpointArray(c).framework = 'EF v3.1'; 
MidpointArray(c).unit = 'CTUh';

c=c+1; 
MidpointArray(c).name = 'ionising radiation: human health EF'; 
MidpointArray(c).framework = 'EF v3.1'; 
MidpointArray(c).unit = 'kBq U235-Eq';

c=c+1; 
MidpointArray(c).name = 'land use EF'; 
MidpointArray(c).framework = 'EF v3.1'; 
MidpointArray(c).unit = 'Pt';

c=c+1; 
MidpointArray(c).name = 'material resources: metals/minerals EF';
MidpointArray(c).framework = 'EF v3.1'; 
MidpointArray(c).unit = 'kg Sb-Eq';

c=c+1; 
MidpointArray(c).name = 'ozone depletion EF'; 
MidpointArray(c).framework = 'EF v3.1'; 
MidpointArray(c).unit = 'kg CFC-11-Eq';

c=c+1; 
MidpointArray(c).name = 'particulate matter formation EF'; 
MidpointArray(c).framework = 'EF v3.1'; 
MidpointArray(c).unit = 'disease incidence';

c=c+1; 
MidpointArray(c).name = 'photochemical oxidant formation: human health EF'; 
MidpointArray(c).framework = 'EF v3.1'; 
MidpointArray(c).unit = 'kg NMVOC-Eq';

c=c+1;
MidpointArray(c).name = 'water use EF'; 
MidpointArray(c).framework = 'EF v3.1'; 
MidpointArray(c).unit = 'm3 world Eq';

for i = 1:length(MidpointArray)
    MidpointArray(i).id = i;
end


%%

end