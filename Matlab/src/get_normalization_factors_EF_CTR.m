function NormFactors = get_normalization_factors_EF_CTR()
% Same global planetary boundaries as get_normalization_factors_EF(), but
% allocated to Norway using the "Capacity to Reduce" (CTR / "Ability to
% Pay") principle instead of Equal Per Capita (EPC).
%
% Source: Bjørn, Paulillo, Sanye Mengual, De Laurentiis, Vea, Hauschild,
% Sala (2025). Guidance for applying absolute environmental sustainability
% assessment on activities at different scales (BETA version). JRC142099.
%
% AF_CTR,S = (Pop_S / GDPcap_S) / Sum_S(Pop_S / GDPcap_S)
%
% Computed for reference year 2010 (consistent with the EPC allocation
% used elsewhere in this codebase), from World Bank data:
%   - Population, total (SP.POP.TOTL)
%   - GDP per capita, PPP, current international $ (NY.GDP.PCAP.PP.CD)
%   - 200 countries with both indicators available in 2010
%   - Norway: pop = 4,889,252 ; GDP/cap PPP = $58,213.13
%   - Sum_S(Pop_S/GDPcap_S) over 200 countries = 1,317,120.63
% See fiche_recap_allocation_CTR.md for the full derivation.

AF_CTR_norway = 6.377e-5;

% PB global values (Sala et al. (2020), Table 3, except land use)
PB.acidification             = 1.00e+12;  % mol H+ eq
PB.climate_change            = 6.81e+12;  % kg CO2 eq
PB.ecotoxicity_freshwater    = 1.31e+14;  % CTUe
PB.energy_resources          = 2.24e+14;  % MJ
PB.eutrophication_freshwater = 5.81e+09;  % kg P eq
PB.eutrophication_marine     = 2.01e+11;  % kg N eq
PB.eutrophication_terrestrial= 6.13e+12;  % mol N eq
PB.human_toxicity_carc       = 9.62e+05;  % CTUh
PB.human_toxicity_noncarc    = 4.10e+06;  % CTUh
PB.ionising_radiation        = 5.27e+14;  % kBq U235 eq
PB.land_use                  = 5.21e+15;  % Pt (Horup et al. 2025, Table 1)
PB.material_resources        = 2.19e+08;  % kg Sb eq
PB.ozone_depletion           = 5.39e+08;  % kg CFC-11 eq
PB.particulate_matter        = 5.16e+05;  % disease incidence
PB.photochem_oxidant         = 4.07e+11;  % kg NMVOC eq
PB.water_use                 = 1.82e+14;  % m3 world eq

% id 24  : acidification EF
% id 25  : climate change EF
% id 26  : climate change: biogenic EF
% id 27  : climate change: fossil EF
% id 28  : climate change: land use and land use change EF
% id 29  : ecotoxicity: freshwater EF
% id 30  : energy resources: non-renewable EF
% id 31  : eutrophication: freshwater EF
% id 32  : eutrophication: marine EF
% id 33  : eutrophication: terrestrial EF
% id 34  : human toxicity: carcinogenic EF
% id 35  : human toxicity: non-carcinogenic EF
% id 36  : ionising radiation: human health EF
% id 37  : land use EF
% id 38  : material resources: metals/minerals EF
% id 39  : ozone depletion EF
% id 40  : particulate matter formation EF
% id 41  : photochemical oxidant formation: human health EF
% id 42  : water use EF
NormFactors.PB_global = zeros(1, 42);
NormFactors.PB_global(24) = PB.acidification;
NormFactors.PB_global(25) = PB.climate_change;
NormFactors.PB_global(26) = PB.climate_change;
NormFactors.PB_global(27) = PB.climate_change;
NormFactors.PB_global(28) = PB.climate_change;
NormFactors.PB_global(29) = PB.ecotoxicity_freshwater;
NormFactors.PB_global(30) = PB.energy_resources;
NormFactors.PB_global(31) = PB.eutrophication_freshwater;
NormFactors.PB_global(32) = PB.eutrophication_marine;
NormFactors.PB_global(33) = PB.eutrophication_terrestrial;
NormFactors.PB_global(34) = PB.human_toxicity_carc;
NormFactors.PB_global(35) = PB.human_toxicity_noncarc;
NormFactors.PB_global(36) = PB.ionising_radiation;
NormFactors.PB_global(37) = PB.land_use;
NormFactors.PB_global(38) = PB.material_resources;
NormFactors.PB_global(39) = PB.ozone_depletion;
NormFactors.PB_global(40) = PB.particulate_matter;
NormFactors.PB_global(41) = PB.photochem_oxidant;
NormFactors.PB_global(42) = PB.water_use;

NormFactors.AF_CTR_norway = AF_CTR_norway;
NormFactors.PB_CTR        = NormFactors.PB_global * AF_CTR_norway;

end