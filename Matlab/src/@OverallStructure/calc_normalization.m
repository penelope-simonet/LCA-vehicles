function obj = calc_normalization(obj)

% Calculation 1 : Share of the Norwegian vehicle stock in the European and global impact
% Calculation 2 : Share of new cars per vehicle-kilometre
% Calculation 3 : Share of the average car in the fleet per vehicle-kilometre
% Calculation 4 : Absolute flows: embodied vs operational (23 categories)
%
% Calculation unit for the entire fleet: X kg/year
% Calculation unit per car: X kg/year (based on 12,000 vehicle-kilometres)

vkm_per_year = 12000;
lifetime_km = 200000;

NormFactors = get_normalization_factors_ReCiPe();
n_cats = 23;

for i = 1:numel(obj.State)

    state = obj.State(i);

    % Total number of cars (for operational)
    n_cars_total = 0;
    for at = 1:numel(state.VehicleArchetype)
        n_cars_total = n_cars_total + sum(state.VehicleArchetype(at).number_of_cars_from_year);
    end
    
    % New cars this year only (for embodied)
    n_new_cars_this_year = 0;
    for at = 1:numel(state.VehicleArchetype)
        year_idx = find(state.VehicleArchetype(at).year_cars_produced == state.year, 1);
        if ~isempty(year_idx)
            n_new_cars_this_year = n_new_cars_this_year + state.VehicleArchetype(at).number_of_cars_from_year(year_idx);
        end
    end

    for cat = 1:n_cats

        norm_E = NormFactors.midpoint_Europe(cat);
        norm_W = NormFactors.midpoint_World(cat);

        impact_avg_vkm = state.Midpoint_impacts(cat).value;
        impact_new_vkm = state.Midpoint_impacts_new_cars(cat).value;

        %% Calculation 1 : vehicle stock
        impact_fleet = impact_avg_vkm * vkm_per_year * n_cars_total;
        if ~isnan(norm_E) && norm_E > 0
            obj.State(i).Normalization.fleet_share_Europe(cat) = impact_fleet / norm_E;
        else
            obj.State(i).Normalization.fleet_share_Europe(cat) = NaN;
        end
        if ~isnan(norm_W) && norm_W > 0
            obj.State(i).Normalization.fleet_share_World(cat) = impact_fleet / norm_W;
        else
            obj.State(i).Normalization.fleet_share_World(cat) = NaN;
        end

        %% Calculation 2 : new cars
        impact_new = impact_new_vkm * vkm_per_year;
        if ~isnan(norm_E) && norm_E > 0
            obj.State(i).Normalization.new_cars_share_Europe(cat) = impact_new / norm_E;
        else
            obj.State(i).Normalization.new_cars_share_Europe(cat) = NaN;
        end
        if ~isnan(norm_W) && norm_W > 0
            obj.State(i).Normalization.new_cars_share_World(cat) = impact_new / norm_W;
        else
            obj.State(i).Normalization.new_cars_share_World(cat) = NaN;
        end

        %% Calculation 3 : average car
        impact_avg = impact_avg_vkm * vkm_per_year;
        if ~isnan(norm_E) && norm_E > 0
            obj.State(i).Normalization.avg_car_share_Europe(cat) = impact_avg / norm_E;
        else
            obj.State(i).Normalization.avg_car_share_Europe(cat) = NaN;
        end
        if ~isnan(norm_W) && norm_W > 0
            obj.State(i).Normalization.avg_car_share_World(cat) = impact_avg / norm_W;
        else
            obj.State(i).Normalization.avg_car_share_World(cat) = NaN;
        end

        %% Calculation 4 : embodied vs operational 
        % Embodied    = glider + powertrain + energy_storage
        % Operational = direct_exhaust uniquement

        % Vehicle stock (kg X/an)
        embodied_fleet = ( ...
            state.Midpoint_impacts(cat).value_glider + ...
            state.Midpoint_impacts(cat).value_powertrain + ...
            state.Midpoint_impacts(cat).value_energy_storage) * lifetime_km * vkm_per_year * n_cars_total;

        operational_fleet = (state.Midpoint_impacts(cat).value_direct_exhaust + ...
                     state.Midpoint_impacts(cat).value_energy_chain + ...
                     state.Midpoint_impacts(cat).value_direct_non_exhaust) * n_cars_total * vkm_per_year;

        obj.State(i).Normalization.embodied_fleet(cat)    = embodied_fleet;
        obj.State(i).Normalization.operational_fleet(cat) = operational_fleet;
        obj.State(i).Normalization.total_fleet(cat)       = embodied_fleet + operational_fleet;

        % New cars : X kg/year (based on 12,000 vehicle-kilometres)
        embodied_new = ( ...
            state.Midpoint_impacts_new_cars(cat).value_glider + ...
            state.Midpoint_impacts_new_cars(cat).value_powertrain + ...
            state.Midpoint_impacts_new_cars(cat).value_energy_storage) * vkm_per_year;

        operational_new = (state.Midpoint_impacts_new_cars(cat).value_direct_exhaust + ...
                   state.Midpoint_impacts_new_cars(cat).value_energy_chain + ...
                   state.Midpoint_impacts_new_cars(cat).value_direct_non_exhaust) * vkm_per_year;

        obj.State(i).Normalization.embodied_new_cars(cat)    = embodied_new;
        obj.State(i).Normalization.operational_new_cars(cat) = operational_new;
        obj.State(i).Normalization.total_new_cars(cat)       = embodied_new + operational_new;

        % Average car : X kg/year (based on 12,000 vehicle-kilometres)
        embodied_avg = ( ...
            state.Midpoint_impacts(cat).value_glider + ...
            state.Midpoint_impacts(cat).value_powertrain + ...
            state.Midpoint_impacts(cat).value_energy_storage) * vkm_per_year;

       operational_avg = (state.Midpoint_impacts(cat).value_direct_exhaust + ...
                   state.Midpoint_impacts(cat).value_energy_chain + ...
                   state.Midpoint_impacts(cat).value_direct_non_exhaust) * vkm_per_year;

        obj.State(i).Normalization.embodied_avg_car(cat)    = embodied_avg;
        obj.State(i).Normalization.operational_avg_car(cat) = operational_avg;
        obj.State(i).Normalization.total_avg_car(cat)       = embodied_avg + operational_avg;

    end % for cat

    obj.State(i).Normalization.n_cars_total = n_cars_total;
    obj.State(i).Normalization.year         = state.year;

    fprintf('Year %d done — cars: %.0f\n', state.year, n_cars_total);

end % for i

fprintf('\ncalc_normalization done!\n');

end