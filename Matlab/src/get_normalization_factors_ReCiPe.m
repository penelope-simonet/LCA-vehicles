function NormFactors = get_normalization_factors_ReCiPe()

%  Stores the ReCiPe 2008 v1.11 standardisation values
%  Perspective : Hierarchist (H)
%  regions : Europe et World
%  base year : 2000
%  units : kg X per year

%% Europe Hierarchist 
NormFactors.Europe.climate_change                           = 5.21e12;  % kg CO2eq/yr
NormFactors.Europe.ozone_depletion                          = 1.02e7;   % kg CFC-11eq/yr
NormFactors.Europe.terrestrial_acidification                = 1.60e10;  % kg SO2eq/yr
NormFactors.Europe.freshwater_eutrophication                = 1.93e8;   % kg P eq/yr
NormFactors.Europe.marine_eutrophication                    = 4.70e9;   % kg N eq/yr
NormFactors.Europe.human_toxicity                           = 2.92e11;  % kg 1,4-DB eq/yr
NormFactors.Europe.photochemical_oxidant_formation          = 2.64e10;  % kg NMVOC/yr
NormFactors.Europe.particulate_matter_formation             = 6.93e9;   % kg PM10eq/yr
NormFactors.Europe.terrestrial_ecotoxicity                  = 3.83e9;   % kg 1,4-DB eq/yr
NormFactors.Europe.freshwater_ecotoxicity                   = 5.11e9;   % kg 1,4-DB eq/yr
NormFactors.Europe.marine_ecotoxicity                       = 4.06e9;   % kg 1,4-DB eq/yr
NormFactors.Europe.ionising_radiation                       = 2.91e12;  % kg U235eq/yr
NormFactors.Europe.agricultural_land_occupation             = 2.10e12;  % m2a/yr
NormFactors.Europe.urban_land_occupation                    = 1.89e11;  % m2a/yr
NormFactors.Europe.natural_land_transformation              = 7.50e7;   % m2/yr
NormFactors.Europe.water_depletion                          = 0;        % m3/yr (no data ReCiPe)
NormFactors.Europe.metal_depletion                          = 3.32e11;  % kg Fe eq/yr
NormFactors.Europe.fossil_depletion                         = 7.23e11;  % kg oil eq/yr

%% World Hierarchist
NormFactors.World.climate_change                            = 4.19e13;  % kg CO2eq/yr
NormFactors.World.ozone_depletion                           = 2.29e8;   % kg CFC-11eq/yr
NormFactors.World.terrestrial_acidification                 = 2.32e11;  % kg SO2eq/yr
NormFactors.World.freshwater_eutrophication                 = 1.76e9;   % kg P eq/yr
NormFactors.World.marine_eutrophication                     = 4.46e10;  % kg N eq/yr
NormFactors.World.human_toxicity                            = 1.98e12;  % kg 1,4-DB eq/yr
NormFactors.World.photochemical_oxidant_formation           = 3.45e11;  % kg NMVOC/yr
NormFactors.World.particulate_matter_formation              = 8.55e10;  % kg PM10eq/yr
NormFactors.World.terrestrial_ecotoxicity                   = 3.61e10;  % kg 1,4-DB eq/yr
NormFactors.World.freshwater_ecotoxicity                    = 2.62e10;  % kg 1,4-DB eq/yr
NormFactors.World.marine_ecotoxicity                        = 1.50e10;  % kg 1,4-DB eq/yr
NormFactors.World.ionising_radiation                        = 8.01e12;  % kg U235eq/yr
NormFactors.World.agricultural_land_occupation              = 3.30e13;  % m2a/yr
NormFactors.World.urban_land_occupation                     = 4.71e12;  % m2a/yr
NormFactors.World.natural_land_transformation               = 7.31e10;  % m2/yr
NormFactors.World.water_depletion                           = 0;        % m3/yr (no ReCiPe data)
NormFactors.World.metal_depletion                           = 2.71e12;  % kg Fe eq/yr
NormFactors.World.fossil_depletion                          = 7.84e12;  % kg oil eq/yr

%% Mapping to the IDs from get_midpoint_categories.m

% id 1  : acidification: terrestrial
NormFactors.midpoint_Europe(1)  = NormFactors.Europe.terrestrial_acidification;
NormFactors.midpoint_World(1)   = NormFactors.World.terrestrial_acidification;

% id 2  : climate change
NormFactors.midpoint_Europe(2)  = NormFactors.Europe.climate_change;
NormFactors.midpoint_World(2)   = NormFactors.World.climate_change;

% id 3  : climate change w bio
NormFactors.midpoint_Europe(3)  = NormFactors.Europe.climate_change;
NormFactors.midpoint_World(3)   = NormFactors.World.climate_change;

% id 4  : ecotoxicity: freshwater
NormFactors.midpoint_Europe(4)  = NormFactors.Europe.freshwater_ecotoxicity;
NormFactors.midpoint_World(4)   = NormFactors.World.freshwater_ecotoxicity;

% id 5  : ecotoxicity: marine
NormFactors.midpoint_Europe(5)  = NormFactors.Europe.marine_ecotoxicity;
NormFactors.midpoint_World(5)   = NormFactors.World.marine_ecotoxicity;

% id 6  : ecotoxicity: terrestrial
NormFactors.midpoint_Europe(6)  = NormFactors.Europe.terrestrial_ecotoxicity;
NormFactors.midpoint_World(6)   = NormFactors.World.terrestrial_ecotoxicity;

% id 7  : energy resources depletion: non-renewable (=fossil depletion)
NormFactors.midpoint_Europe(7)  = NormFactors.Europe.fossil_depletion;
NormFactors.midpoint_World(7)   = NormFactors.World.fossil_depletion;

% id 8  : eutrophication: freshwater
NormFactors.midpoint_Europe(8)  = NormFactors.Europe.freshwater_eutrophication;
NormFactors.midpoint_World(8)   = NormFactors.World.freshwater_eutrophication;

% id 9  : eutrophication: marine
NormFactors.midpoint_Europe(9)  = NormFactors.Europe.marine_eutrophication;
NormFactors.midpoint_World(9)   = NormFactors.World.marine_eutrophication;

% id 10 : human toxicity: carcinogenic (=human toxicity)
NormFactors.midpoint_Europe(10) = NormFactors.Europe.human_toxicity;
NormFactors.midpoint_World(10)  = NormFactors.World.human_toxicity;

% id 11 : human toxicity: non-carcinogenic (=human toxicity)
NormFactors.midpoint_Europe(11) = NormFactors.Europe.human_toxicity;
NormFactors.midpoint_World(11)  = NormFactors.World.human_toxicity;

% id 12 : ionising radiation
NormFactors.midpoint_Europe(12) = NormFactors.Europe.ionising_radiation;
NormFactors.midpoint_World(12)  = NormFactors.World.ionising_radiation;

% id 13 : land use (agricultural + urban)
NormFactors.midpoint_Europe(13) = NormFactors.Europe.agricultural_land_occupation + ...
                                   NormFactors.Europe.urban_land_occupation;
NormFactors.midpoint_World(13)  = NormFactors.World.agricultural_land_occupation + ...
                                   NormFactors.World.urban_land_occupation;

% id 14 : material resources : metals/minerals (=metal depletion)
NormFactors.midpoint_Europe(14) = NormFactors.Europe.metal_depletion;
NormFactors.midpoint_World(14)  = NormFactors.World.metal_depletion;

% id 15 : ozone depletion
NormFactors.midpoint_Europe(15) = NormFactors.Europe.ozone_depletion;
NormFactors.midpoint_World(15)  = NormFactors.World.ozone_depletion;

% id 16 : particulate matter formation
NormFactors.midpoint_Europe(16) = NormFactors.Europe.particulate_matter_formation;
NormFactors.midpoint_World(16)  = NormFactors.World.particulate_matter_formation;

% id 17 : photochemical oxidant formation : human health
NormFactors.midpoint_Europe(17) = NormFactors.Europe.photochemical_oxidant_formation;
NormFactors.midpoint_World(17)  = NormFactors.World.photochemical_oxidant_formation;

% id 18 : photochemical oxidant formation : terrestrial ecosystems
NormFactors.midpoint_Europe(18) = NormFactors.Europe.photochemical_oxidant_formation;
NormFactors.midpoint_World(18)  = NormFactors.World.photochemical_oxidant_formation;

% id 19 : water use (water depletion : no ReCiPe data)
NormFactors.midpoint_Europe(19) = NormFactors.Europe.water_depletion;   % = 0
NormFactors.midpoint_World(19)  = NormFactors.World.water_depletion;    % = 0

% id 20 : energy resources: non-renewable (fossil depletion)
NormFactors.midpoint_Europe(20) = NormFactors.Europe.fossil_depletion;
NormFactors.midpoint_World(20)  = NormFactors.World.fossil_depletion;

% id 21 : energy resources: renewable (no direct match in ReCiPe)
NormFactors.midpoint_Europe(21) = NaN;  
NormFactors.midpoint_World(21)  = NaN;

% id 22 : total (sum of categories with different units : cannot be normalised)
NormFactors.midpoint_Europe(22) = NaN;
NormFactors.midpoint_World(22)  = NaN;

% id 23 : Human noise impacts (no ReCiPe data)
NormFactors.midpoint_Europe(23) = NaN;
NormFactors.midpoint_World(23)  = NaN;

end