function MidpointArray = get_midpoint_categories()


%%
MidpointArray(1:23) = MidpointCategories;

c=1;
MidpointArray(c).name = 'acidification: terrestrial';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'kg SO2eq/vkm';

c=c+1;
MidpointArray(c).name = 'climate change';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'kg CO2eq/vkm';

c=c+1;
MidpointArray(c).name = 'climate change w bio';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'kg CO2eq/vkm';

c=c+1;
MidpointArray(c).name = 'ecotoxicity: freshwater';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'kg 1,4-DB eq/vkm';

c=c+1;
MidpointArray(c).name = 'ecotoxicity: marine';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'kg 1,4-DB eq/vkm';

c=c+1;
MidpointArray(c).name = 'ecotoxicity: terrestrial';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'kg 1,4-DB eq/vkm';

c=c+1;
MidpointArray(c).name = 'energy resources depletion: non-renewable';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'kg oil eq/vkm';

c=c+1;
MidpointArray(c).name = 'eutrophication: freshwater';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'kg P eq/vkm';

c=c+1;
MidpointArray(c).name = 'eutrophication: marine';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'kg N eq/vkm';

c=c+1;
MidpointArray(c).name = 'human toxicity: carcinogenic';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'kg 1,4-DB eq/vkm';

c=c+1;
MidpointArray(c).name = 'human toxicity: non-carcinogenic';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'kg 1,4-DB eq/vkm';

c=c+1;
MidpointArray(c).name = 'ionising radiation';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'kg U235 eq/vkm';

c=c+1;
MidpointArray(c).name = 'land use';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'm2a/vkm';

c=c+1;
MidpointArray(c).name = 'material resources: metals/minerals';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'kg Fe eq/vkm';

c=c+1;
MidpointArray(c).name = 'ozone depletion';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'kg CFC-11 eq/vkm';

c=c+1;
MidpointArray(c).name = 'particulate matter formation';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'kg PM10 eq/vkm';

c=c+1;
MidpointArray(c).name = 'photochemical oxidant formation: human health';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'kg NMVOC/vkm';

c=c+1;
MidpointArray(c).name = 'photochemical oxidant formation: terrestrial ecosystems';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'kg NMVOC/vkm';

c=c+1;
MidpointArray(c).name = 'water use';
MidpointArray(c).framework = 'Recipe 2016';
MidpointArray(c).unit = 'm3/vkm';

c=c+1;
MidpointArray(c).name = 'energy resources: non-renewable';
MidpointArray(c).framework = '';
MidpointArray(c).unit = 'kg oil eq/vkm';

c=c+1;
MidpointArray(c).name = 'energy resources: renewable';
MidpointArray(c).framework = '';
MidpointArray(c).unit = 'kg oil eq/vkm';

c=c+1;
MidpointArray(c).name = 'total';
MidpointArray(c).framework = '';
MidpointArray(c).unit = 'mixed — not comparable';

c=c+1;
MidpointArray(c).name = 'Human noise impacts';
MidpointArray(c).framework = 'Cucurachi et al.';
MidpointArray(c).unit = 'DALY/vkm';

for i = 1:length(MidpointArray)
    MidpointArray(i).id = i;
end


%%

end