function NormFactors = get_normalization_factors_ReCiPe()

%  normalization values from ReCiPe 2016 v1.1
%  Hierarchist (H)

pop_2010 = 6895889018;   % mondial population 2010

%% Values per capita (Hierarchist World)
pc.climate_change                       = 7990.407652952963;       % kg CO2eq
pc.ozone_depletion                      = 6.0010004962240043e-2;   % kg CFC11eq
pc.ionising_radiation                   = 479.91735010391716;      % kBq Co-60
pc.particulate_matter                   = 25.569594920658865;      % kg PM2.5eq
pc.photochem_oxidant_human              = 20.567456694737732;      % kg NOx eq
pc.photochem_oxidant_terrestrial        = 17.749328221367179;      % kg NOx eq
pc.human_toxicity_carcinogenic          = 10.298306455189207;      % kg 1,4-DCB
pc.human_toxicity_noncarcinogenic       = 31251.842257731121;      % kg 1,4-DCB
pc.water_consumption                    = 266.63926110882778;      % m3
pc.terrestrial_acidification            = 40.980514742338137;      % kg SO2eq
pc.terrestrial_ecotoxicity              = 15200.310658799526;      % kg 1,4-DCB
pc.freshwater_eutrophication            = 0.64988836189570243;     % kg P
pc.freshwater_ecotoxicity               = 25.174703491092206;      % kg 1,4-DCB
pc.marine_eutrophication                = 4.6177855678795483;      % kg N
pc.marine_ecotoxicity                   = 43.442842025376152;      % kg 1,4-DCB
pc.land_use                             = 6167.4822789500304;      % m2a
pc.mineral_resources                    = 120051.20954550793;      % kg Cu-eq
pc.fossil_resources                     = 569.90476351079815 + ...
                                          0.40197862708700571 + ...
                                          381.51426061712181  + ...
                                          31.456422722840287; % oil-eq

%% midpoints total values (per capita × population)
NormFactors.Europe.climate_change                  = pc.climate_change                 * pop_2010;
NormFactors.Europe.ozone_depletion                 = pc.ozone_depletion                * pop_2010;
NormFactors.Europe.ionising_radiation              = pc.ionising_radiation             * pop_2010;
NormFactors.Europe.particulate_matter              = pc.particulate_matter             * pop_2010;
NormFactors.Europe.photochem_oxidant_human         = pc.photochem_oxidant_human        * pop_2010;
NormFactors.Europe.photochem_oxidant_terrestrial   = pc.photochem_oxidant_terrestrial  * pop_2010;
NormFactors.Europe.human_toxicity_carcinogenic     = pc.human_toxicity_carcinogenic    * pop_2010;
NormFactors.Europe.human_toxicity_noncarcinogenic  = pc.human_toxicity_noncarcinogenic * pop_2010;
NormFactors.Europe.water_consumption               = pc.water_consumption              * pop_2010;
NormFactors.Europe.terrestrial_acidification       = pc.terrestrial_acidification      * pop_2010;
NormFactors.Europe.terrestrial_ecotoxicity         = pc.terrestrial_ecotoxicity        * pop_2010;
NormFactors.Europe.freshwater_eutrophication       = pc.freshwater_eutrophication      * pop_2010;
NormFactors.Europe.freshwater_ecotoxicity          = pc.freshwater_ecotoxicity         * pop_2010;
NormFactors.Europe.marine_eutrophication           = pc.marine_eutrophication          * pop_2010;
NormFactors.Europe.marine_ecotoxicity              = pc.marine_ecotoxicity             * pop_2010;
NormFactors.Europe.land_use                        = pc.land_use                       * pop_2010;
NormFactors.Europe.mineral_resources               = pc.mineral_resources              * pop_2010;
NormFactors.Europe.fossil_resources                = pc.fossil_resources               * pop_2010;

% World = Europe (same value in ReCiPe 2016)
NormFactors.World = NormFactors.Europe;

%% endpoints
pc_end.ecosystem_quality = 8.188138758371857e-4;   % species.yr/person (terrestrial tox, as reference)
pc_end.human_health      = 7.415098301940347e-3;   % DALY/person (GW human health)
pc_end.natural_resources = 291.35213967771415;     % USD2013/person (fossil)

NormFactors.Europe.endpoint_ecosystem_quality = pc_end.ecosystem_quality * pop_2010;
NormFactors.Europe.endpoint_human_health      = pc_end.human_health      * pop_2010;
NormFactors.Europe.endpoint_natural_resources = pc_end.natural_resources * pop_2010;

NormFactors.World.endpoint_ecosystem_quality  = NormFactors.Europe.endpoint_ecosystem_quality;
NormFactors.World.endpoint_human_health       = NormFactors.Europe.endpoint_human_health;
NormFactors.World.endpoint_natural_resources  = NormFactors.Europe.endpoint_natural_resources;

%% mapping midpoints to IDs get_midpoint_categories ---
% id 1  — acidification: terrestrial
NormFactors.midpoint_Europe(1)  = NormFactors.Europe.terrestrial_acidification;
NormFactors.midpoint_World(1)   = NormFactors.World.terrestrial_acidification;
% id 2  — climate change
NormFactors.midpoint_Europe(2)  = NormFactors.Europe.climate_change;
NormFactors.midpoint_World(2)   = NormFactors.World.climate_change;
% id 3  — climate change w bio
NormFactors.midpoint_Europe(3)  = NormFactors.Europe.climate_change;
NormFactors.midpoint_World(3)   = NormFactors.World.climate_change;
% id 4  — ecotoxicity: freshwater
NormFactors.midpoint_Europe(4)  = NormFactors.Europe.freshwater_ecotoxicity;
NormFactors.midpoint_World(4)   = NormFactors.World.freshwater_ecotoxicity;
% id 5  — ecotoxicity: marine
NormFactors.midpoint_Europe(5)  = NormFactors.Europe.marine_ecotoxicity;
NormFactors.midpoint_World(5)   = NormFactors.World.marine_ecotoxicity;
% id 6  — ecotoxicity: terrestrial
NormFactors.midpoint_Europe(6)  = NormFactors.Europe.terrestrial_ecotoxicity;
NormFactors.midpoint_World(6)   = NormFactors.World.terrestrial_ecotoxicity;
% id 7  — energy resources depletion: non-renewable
NormFactors.midpoint_Europe(7)  = NormFactors.Europe.fossil_resources;
NormFactors.midpoint_World(7)   = NormFactors.World.fossil_resources;
% id 8  — eutrophication: freshwater
NormFactors.midpoint_Europe(8)  = NormFactors.Europe.freshwater_eutrophication;
NormFactors.midpoint_World(8)   = NormFactors.World.freshwater_eutrophication;
% id 9  — eutrophication: marine
NormFactors.midpoint_Europe(9)  = NormFactors.Europe.marine_eutrophication;
NormFactors.midpoint_World(9)   = NormFactors.World.marine_eutrophication;
% id 10 — human toxicity: carcinogenic
NormFactors.midpoint_Europe(10) = NormFactors.Europe.human_toxicity_carcinogenic;
NormFactors.midpoint_World(10)  = NormFactors.World.human_toxicity_carcinogenic;
% id 11 — human toxicity: non-carcinogenic
NormFactors.midpoint_Europe(11) = NormFactors.Europe.human_toxicity_noncarcinogenic;
NormFactors.midpoint_World(11)  = NormFactors.World.human_toxicity_noncarcinogenic;
% id 12 — ionising radiation
NormFactors.midpoint_Europe(12) = NormFactors.Europe.ionising_radiation;
NormFactors.midpoint_World(12)  = NormFactors.World.ionising_radiation;
% id 13 — land use
NormFactors.midpoint_Europe(13) = NormFactors.Europe.land_use;
NormFactors.midpoint_World(13)  = NormFactors.World.land_use;
% id 14 — material resources: metals/minerals
NormFactors.midpoint_Europe(14) = NormFactors.Europe.mineral_resources;
NormFactors.midpoint_World(14)  = NormFactors.World.mineral_resources;
% id 15 — ozone depletion
NormFactors.midpoint_Europe(15) = NormFactors.Europe.ozone_depletion;
NormFactors.midpoint_World(15)  = NormFactors.World.ozone_depletion;
% id 16 — particulate matter formation
NormFactors.midpoint_Europe(16) = NormFactors.Europe.particulate_matter;
NormFactors.midpoint_World(16)  = NormFactors.World.particulate_matter;
% id 17 — photochemical oxidant formation: human health
NormFactors.midpoint_Europe(17) = NormFactors.Europe.photochem_oxidant_human;
NormFactors.midpoint_World(17)  = NormFactors.World.photochem_oxidant_human;
% id 18 — photochemical oxidant formation: terrestrial ecosystems
NormFactors.midpoint_Europe(18) = NormFactors.Europe.photochem_oxidant_terrestrial;
NormFactors.midpoint_World(18)  = NormFactors.World.photochem_oxidant_terrestrial;
% id 19 — water use
NormFactors.midpoint_Europe(19) = NormFactors.Europe.water_consumption;
NormFactors.midpoint_World(19)  = NormFactors.World.water_consumption;
% id 20 — energy resources: non-renewable
NormFactors.midpoint_Europe(20) = NormFactors.Europe.fossil_resources;
NormFactors.midpoint_World(20)  = NormFactors.World.fossil_resources;
% id 21 — energy resources: renewable (pas dans ReCiPe)
NormFactors.midpoint_Europe(21) = NaN;
NormFactors.midpoint_World(21)  = NaN;
% id 22 — total (non normalisable)
NormFactors.midpoint_Europe(22) = NaN;
NormFactors.midpoint_World(22)  = NaN;
% id 23 — Human noise impacts (pas dans ReCiPe)
NormFactors.midpoint_Europe(23) = NaN;
NormFactors.midpoint_World(23)  = NaN;

%% mapping endpoints to IDs get_endpoint_categories 
% Ecosystem quality (ids 1-12 + 24)
for id = [1:12, 24]
    NormFactors.endpoint_Europe(id) = NormFactors.Europe.endpoint_ecosystem_quality;
    NormFactors.endpoint_World(id)  = NormFactors.World.endpoint_ecosystem_quality;
end
% Human health (ids 13-20 + 25)
for id = [13:20, 25]
    NormFactors.endpoint_Europe(id) = NormFactors.Europe.endpoint_human_health;
    NormFactors.endpoint_World(id)  = NormFactors.World.endpoint_human_health;
end
% Natural resources (ids 21-23 + 26)
for id = [21:23, 26]
    NormFactors.endpoint_Europe(id) = NormFactors.Europe.endpoint_natural_resources;
    NormFactors.endpoint_World(id)  = NormFactors.World.endpoint_natural_resources;
end
% Human noise impacts (id 27) — DALY comme human health
NormFactors.endpoint_Europe(27) = NormFactors.Europe.endpoint_human_health;
NormFactors.endpoint_World(27)  = NormFactors.World.endpoint_human_health;

end