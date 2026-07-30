function NormFactors = get_normalization_factors_EF_UE()
% Hybrid allocation: for the EF categories where Lund et al. (2025) /
% Bjørn & Hauschild (2015) provide a EUROPEAN-scale carrying capacity
% (compatible unit with Sala et al. 2020), Norway's share is computed
% against the EUROPEAN population instead of the world population. For
% all other categories, the global Sala et al. (2020) carrying capacity
% and world population are used, unchanged (same as get_normalization_factors_EF.m).
%
% Source: Lund, Schjerbeck & Bjørn (2025), Building and Environment,
% DOI: 10.1016/j.buildenv.2025.112985 ("40 buildings case" table),
% itself built on Bjørn & Hauschild (2015), Int. J. LCA 20(7), 1005-1018.
%
% Categories switched to the EUROPEAN-POPULATION allocation (4): acidification,
% eutrophication (freshwater/marine/terrestrial). These are the only ones
% marked with the "a" superscript (European-scale carrying capacity) in
% Lund et al.'s Table 1.
%
% Material resources: metals/minerals uses a DIFFERENT NUMERIC VALUE from
% Sala et al. (1.07E+08 vs 2.19E+08 kg Sb-eq), but this is NOT a European-
% scale value — Lund et al. do not mark it with "a". The difference comes
% from a different global-scale method (Vargas-Gonzalez et al. 2019,
% reduction factor 4.08) rather than Sala et al.'s method (Bringezu 2015).
% It is therefore allocated via WORLD population, like any other global
% carrying capacity — corrected after Pénélope's verification of the
% original Lund et al. table (2026-07-08).
%
% Photochemical oxidant formation: human health IS marked "a" (European),
% consistent with its earlier treatment.
%
% IMPORTANT — categories NOT switched to the European scale:
%   - Ecotoxicity: freshwater (id 29): kept on Sala et al. (2020) / global
%     basis (not European), per correction from Pénélope.
%   - Land use (id 37): REMOVED FROM THE STUDY ENTIRELY (dropped from the
%     16-category lists in the plotting scripts). Lund et al. report "kg C
%     deficit", INCOMPATIBLE with the "Pt" unit used throughout this
%     codebase (Horup et al. 2025), and no European-scale carrying capacity
%     in a compatible unit could be found.
%   - Energy resources: non-renewable (id 30): not covered by Lund et al.
%     at all. Kept on the Sala et al. (2020) / global basis.
%   - Climate change, ozone depletion, water use, particulate matter,
%     ionising radiation, human toxicity (carc/non-carc): Lund et al.
%     report the SAME values as Sala et al. (2020) (i.e. already global,
%     not regionalised) — kept on the global basis, no change needed.
%
% CORRECTED — "Eutrophication: marine" (id 32): The table in Lund et al.
% (2025) / JRC142099 shows 2.29E+02 kg N eq, which is an 8-order-of-
% magnitude transcription error (E+02 instead of E+10). Verified against
% Bjørn & Hauschild (2015), Table 1, who report a per-capita European
% normalisation reference (NR_Europe) of 31 kg N eq/person/year for marine
% eutrophication (unchanged by Lund et al., per their SM text). Multiplying
% by the European population (740,000,000, 2010) gives the total European
% carrying capacity: 31 x 740,000,000 = 2.294E+10 kg N eq, used here.
% Cross-check: applying the same method to freshwater eutrophication
% (NR_Europe = 0.46 kg P eq/pers/yr x 740M = 3.40E+08) matches the table's
% 3.50E+08 kg P eq to within rounding, confirming the method and isolating
% the error to this one category.

pop_norway = 4889252;      % Norway, 2010 (World Bank, SP.POP.TOTL)
pop_europe = 740000000;    % Continental Europe, 2010 (UNDESA 2012, via Bjørn & Hauschild 2015)
pop_world  = 6916183482;   % World, 2010 (UNDESA 2012, via Bjørn & Hauschild 2015)

% --- Global PB values (Sala et al. 2020, Table 3, except land use) ---
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

% --- European-scale PB values (Lund et al. 2025 "40 buildings" table) ---
% Same units as their global Sala et al. (2020) counterparts above.
% NOTE: ecotoxicity freshwater is NOT switched to the European scale
% (kept on Sala et al. 2020 / global, per correction from Pénélope).
% NOTE: land use is REMOVED from this study entirely (see plotting scripts).
PB_EU.acidification             = 6.59e+10;  % mol H+ eq
PB_EU.eutrophication_freshwater = 3.50e+08;  % kg P eq
PB_EU.eutrophication_marine     = 2.294e+10; % kg N eq  -- CORRECTED, see note below
PB_EU.eutrophication_terrestrial= 4.27e+11;  % molc N eq
PB_EU.material_resources        = 1.07e+08;  % kg Sb eq
PB_EU.photochem_oxidant         = 4.35e+10;  % kg NMVOC eq

% id 24  : acidification EF                              -> European scale
% id 25  : climate change EF                              -> global scale
% id 26  : climate change: biogenic EF                    -> global scale
% id 27  : climate change: fossil EF                      -> global scale
% id 28  : climate change: land use and land use change EF-> global scale
% id 29  : ecotoxicity: freshwater EF                      -> European scale
% id 30  : energy resources: non-renewable EF              -> global scale (not covered by Lund)
% id 31  : eutrophication: freshwater EF                   -> European scale
% id 32  : eutrophication: marine EF                       -> European scale (CAUTION)
% id 33  : eutrophication: terrestrial EF                  -> European scale
% id 34  : human toxicity: carcinogenic EF                 -> global scale
% id 35  : human toxicity: non-carcinogenic EF             -> global scale
% id 36  : ionising radiation: human health EF             -> global scale
% id 37  : land use EF                                     -> global scale (unit incompatible)
% id 38  : material resources: metals/minerals EF          -> global scale (different global method, not European)
% id 39  : ozone depletion EF                              -> global scale
% id 40  : particulate matter formation EF                 -> global scale
% id 41  : photochemical oxidant formation: human health EF-> European scale
% id 42  : water use EF                                    -> global scale

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

% ids using the European-POPULATION allocation (only categories marked "a"
% in Lund et al.'s Table 1: acidification, eutrophication x3)
eu_ids = [24, 31, 32, 33, 41];

% Default: global scale, Norway/world population ratio
NormFactors.PB_norway_UE = NormFactors.PB_global * (pop_norway / pop_world);

% Override the 4 European-scale categories with European-scale carrying
% capacity + Norway/Europe population ratio
NormFactors.PB_norway_UE(24) = PB_EU.acidification              * (pop_norway / pop_europe);
NormFactors.PB_norway_UE(31) = PB_EU.eutrophication_freshwater   * (pop_norway / pop_europe);
NormFactors.PB_norway_UE(32) = PB_EU.eutrophication_marine       * (pop_norway / pop_europe);
NormFactors.PB_norway_UE(33) = PB_EU.eutrophication_terrestrial  * (pop_norway / pop_europe);
NormFactors.PB_norway_UE(41) = PB_EU.photochem_oxidant           * (pop_norway / pop_europe);

% Material resources: different global-scale value from Lund et al.
% (Vargas-Gonzalez et al. 2019 method), allocated via WORLD population
% (not European) since it is not a regionalised carrying capacity.
NormFactors.PB_norway_UE(38) = PB_EU.material_resources          * (pop_norway / pop_world);

NormFactors.pop_norway = pop_norway;
NormFactors.pop_europe = pop_europe;
NormFactors.pop_world  = pop_world;
NormFactors.eu_ids     = eu_ids;

end