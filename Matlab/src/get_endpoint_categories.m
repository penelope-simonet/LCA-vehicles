function EndpointArray = get_endpoint_categories()

%%
EndpointArray(1:18) = EndpointCategories;

%% Ecosystem damage

c=1;
EndpointArray(c).name = 'acidification: terrestrial';
EndpointArray(c).framework = 'Recipe 2016';
EndpointArray(c).unit = 'species.yr';
EndpointArray(c).id = c;

c=c+1;
EndpointArray(c).name = 'climate change: freshwater ecosystems';
EndpointArray(c).framework = 'Recipe 2016';
EndpointArray(c).unit = 'species.yr';
EndpointArray(c).id = c;


c=c+1;
EndpointArray(c).name = 'climate change: terrestrial ecosystems';
EndpointArray(c).framework = 'Recipe 2016';
EndpointArray(c).unit = 'species.yr';
EndpointArray(c).id = c;



c=c+1;
EndpointArray(c).name = 'ecotoxicity: freshwater';
EndpointArray(c).framework = 'Recipe 2016';
EndpointArray(c).unit = 'species.yr';
EndpointArray(c).id = c;


c=c+1;
EndpointArray(c).name = 'ecotoxicity: marine';
EndpointArray(c).framework = 'Recipe 2016';
EndpointArray(c).unit = 'species.yr';
EndpointArray(c).id = c;


c=c+1;
EndpointArray(c).name = 'ecotoxicity: terrestrial';
EndpointArray(c).framework = 'Recipe 2016';
EndpointArray(c).unit = '';
EndpointArray(c).id = c;


c=c+1;
EndpointArray(c).name = 'eutrophication: freshwater';
EndpointArray(c).framework = 'Recipe 2016';
EndpointArray(c).unit = 'species.yr';
EndpointArray(c).id = c;


c=c+1;
EndpointArray(c).name = 'eutrophication: marine';
EndpointArray(c).framework = 'Recipe 2016';
EndpointArray(c).unit = 'species.yr';
EndpointArray(c).id = c;


c=c+1;
EndpointArray(c).name = 'land use';
EndpointArray(c).framework = 'Recipe 2016';
EndpointArray(c).unit = 'species.yr';
EndpointArray(c).id = c;

c=c+1;
EndpointArray(c).name = 'photochemical oxidant formation: terrestrial ecosystems';
EndpointArray(c).framework = 'Recipe 2016';
EndpointArray(c).unit = 'species.yr';
EndpointArray(c).id = c;

c=c+1;
EndpointArray(c).name = 'water use: aquatic ecosystems';
EndpointArray(c).framework = 'Recipe 2016';
EndpointArray(c).unit = 'species.yr';
EndpointArray(c).id = c;

c=c+1;
EndpointArray(c).name = 'water use: terrestrial ecosystems';
EndpointArray(c).framework = 'Recipe 2016';
EndpointArray(c).unit = 'species.yr';
EndpointArray(c).id = c;


%% Human health

c=c+1;
EndpointArray(c).name = 'climate change: human health';
EndpointArray(c).framework = 'Recipe 2016';
EndpointArray(c).unit = 'DALY';
EndpointArray(c).id = c;


c=c+1;
EndpointArray(c).name = 'human toxicity: carcinogenic';
EndpointArray(c).framework = 'Recipe 2016';
EndpointArray(c).unit = 'DALY';
EndpointArray(c).id = c;


c=c+1;
EndpointArray(c).name = 'human toxicity: non-carcinogenic';
EndpointArray(c).framework = 'Recipe 2016';
EndpointArray(c).unit = 'DALY';
EndpointArray(c).id = c;


c=c+1;
EndpointArray(c).name = 'ionising radiation';
EndpointArray(c).framework = 'Recipe 2016';
EndpointArray(c).unit = 'DALY';
EndpointArray(c).id = c;



c=c+1;
EndpointArray(c).name = 'ozone depletion';
EndpointArray(c).framework = 'Recipe 2016';
EndpointArray(c).unit = 'DALY';
EndpointArray(c).id = c;


c=c+1;
EndpointArray(c).name = 'particulate matter formation';
EndpointArray(c).framework = 'Recipe 2016';
EndpointArray(c).unit = 'DALY';
EndpointArray(c).id = c;



c=c+1;
EndpointArray(c).name = 'photochemical oxidant formation: human health';
EndpointArray(c).framework = 'Recipe 2016';
EndpointArray(c).unit = 'DALY';
EndpointArray(c).id = c;


c=c+1;
EndpointArray(c).name = 'water use: human health';
EndpointArray(c).framework = 'Recipe 2016';
EndpointArray(c).unit = 'DALY';
EndpointArray(c).id = c;




%% RESOURCES
c=c+1;
EndpointArray(c).name = 'material resources: metals/minerals';
EndpointArray(c).framework = 'Recipe 2016';
EndpointArray(c).unit = 'USD 2013';
EndpointArray(c).id = c;



c=c+1;
EndpointArray(c).name = 'energy resources: non-renewable, fossil ';
EndpointArray(c).framework = '';
EndpointArray(c).unit = 'USD 2013';
EndpointArray(c).id = c;


c=c+1;
EndpointArray(c).name = 'energy resources: renewable';
EndpointArray(c).framework = '';
EndpointArray(c).unit = '';
EndpointArray(c).id = c;


%% TOTAL ENDPOINT IMPACTS



c=c+1;
EndpointArray(c).name = 'total: ecosystem quality';
EndpointArray(c).framework = 'Recipe 2016';
EndpointArray(c).unit = 'species.yr';
EndpointArray(c).id = c;


c=c+1;
EndpointArray(c).name = 'total: human health';
EndpointArray(c).framework = 'Recipe 2016';
EndpointArray(c).unit = 'DALY';
EndpointArray(c).id = c;


c=c+1;
EndpointArray(c).name = 'total: natural resources';
EndpointArray(c).framework = 'Recipe 2016';
EndpointArray(c).unit = 'USD 2013';
EndpointArray(c).id = c;


%% NOISE (Cucurachi et al.)
c=c+1;
EndpointArray(c).name = 'Human noise impacts';
EndpointArray(c).framework = 'Recipe 2016';
EndpointArray(c).unit = 'DALY';
EndpointArray(c).id = c;


%%

end



