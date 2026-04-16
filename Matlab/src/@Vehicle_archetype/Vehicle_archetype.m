classdef Vehicle_archetype
    %VEHICLE_ARCHETYPE Summary of this class goes here
    %   Detailed explanation goes here

    properties
        id
        id_archetype
        powertrain
        size
        weight_kg_bnds
        powertrain_Rousseau_string
        is_hybrid

        year_state
        year_cars_produced = [2000:1:2050]

        number_of_cars_from_year = 0;

        number_of_cars_from_year_mun_sub5k = 0;
        number_of_cars_from_year_mun_5k_10k = 0;
        number_of_cars_from_year_mun_10k_20k = 0;
        number_of_cars_from_year_mun_20k_50k = 0;
        number_of_cars_from_year_mun_50k_plus = 0;
        number_of_cars_from_year_Trondheim = 0;
        number_of_cars_from_year_Bergen = 0;
        number_of_cars_from_year_Oslo = 0;
        number_of_cars_from_year_unknown = 0;



        Midpoint_impacts_SSP2_NPi
        Endpoint_impacts_SSP2_NPi

        Midpoint_impacts_SSP2_PkBudg1150
        Endpoint_impacts_SSP2_PkBudg1150

        Midpoint_impacts_SSP2_PkBudg500
        Endpoint_impacts_SSP2_PkBudg500



        functional_unit = 'impact per vehicle kilometer';





    end

    methods

        function obj = preallocate_impact_vecs(obj)
            for i = 1:length(obj.Midpoint_impacts_SSP2_NPi)
                obj.Midpoint_impacts_SSP2_NPi(i).time = zeros(1,length(obj.number_of_cars_from_year));
                obj.Midpoint_impacts_SSP2_NPi(i).value = zeros(1,length(obj.number_of_cars_from_year));

                obj.Midpoint_impacts_SSP2_NPi(i).value_glider = zeros(1,length(obj.number_of_cars_from_year));
                obj.Midpoint_impacts_SSP2_NPi(i).value_powertrain = zeros(1,length(obj.number_of_cars_from_year));
                obj.Midpoint_impacts_SSP2_NPi(i).value_energy_storage = zeros(1,length(obj.number_of_cars_from_year));
                obj.Midpoint_impacts_SSP2_NPi(i).value_energy_chain = zeros(1,length(obj.number_of_cars_from_year));
                obj.Midpoint_impacts_SSP2_NPi(i).value_maintenance = zeros(1,length(obj.number_of_cars_from_year));
                obj.Midpoint_impacts_SSP2_NPi(i).value_EoL = zeros(1,length(obj.number_of_cars_from_year));
                obj.Midpoint_impacts_SSP2_NPi(i).value_road = zeros(1,length(obj.number_of_cars_from_year));
                obj.Midpoint_impacts_SSP2_NPi(i).value_direct_non_exhaust = zeros(1,length(obj.number_of_cars_from_year));
                obj.Midpoint_impacts_SSP2_NPi(i).value_direct_exhaust = zeros(1,length(obj.number_of_cars_from_year));
            end
            for i = 1:length(obj.Endpoint_impacts_SSP2_NPi)
                obj.Endpoint_impacts_SSP2_NPi(i).time = zeros(1,length(obj.number_of_cars_from_year));
                obj.Endpoint_impacts_SSP2_NPi(i).value = zeros(1,length(obj.number_of_cars_from_year));

                obj.Endpoint_impacts_SSP2_NPi(i).value_glider = zeros(1,length(obj.number_of_cars_from_year));
                obj.Endpoint_impacts_SSP2_NPi(i).value_powertrain = zeros(1,length(obj.number_of_cars_from_year));
                obj.Endpoint_impacts_SSP2_NPi(i).value_energy_storage = zeros(1,length(obj.number_of_cars_from_year));
                obj.Endpoint_impacts_SSP2_NPi(i).value_energy_chain = zeros(1,length(obj.number_of_cars_from_year));
                obj.Endpoint_impacts_SSP2_NPi(i).value_maintenance = zeros(1,length(obj.number_of_cars_from_year));
                obj.Endpoint_impacts_SSP2_NPi(i).value_EoL = zeros(1,length(obj.number_of_cars_from_year));
                obj.Endpoint_impacts_SSP2_NPi(i).value_road = zeros(1,length(obj.number_of_cars_from_year));
                obj.Endpoint_impacts_SSP2_NPi(i).value_direct_non_exhaust = zeros(1,length(obj.number_of_cars_from_year));
                obj.Endpoint_impacts_SSP2_NPi(i).value_direct_exhaust = zeros(1,length(obj.number_of_cars_from_year));
            end

            % _PkBudg1150
            for i = 1:length(obj.Midpoint_impacts_SSP2_PkBudg1150)
                obj.Midpoint_impacts_SSP2_PkBudg1150(i).time = zeros(1,length(obj.number_of_cars_from_year));
                obj.Midpoint_impacts_SSP2_PkBudg1150(i).value = zeros(1,length(obj.number_of_cars_from_year));

                obj.Midpoint_impacts_SSP2_PkBudg1150(i).value_glider = zeros(1,length(obj.number_of_cars_from_year));
                obj.Midpoint_impacts_SSP2_PkBudg1150(i).value_powertrain = zeros(1,length(obj.number_of_cars_from_year));
                obj.Midpoint_impacts_SSP2_PkBudg1150(i).value_energy_storage = zeros(1,length(obj.number_of_cars_from_year));
                obj.Midpoint_impacts_SSP2_PkBudg1150(i).value_energy_chain = zeros(1,length(obj.number_of_cars_from_year));
                obj.Midpoint_impacts_SSP2_PkBudg1150(i).value_maintenance = zeros(1,length(obj.number_of_cars_from_year));
                obj.Midpoint_impacts_SSP2_PkBudg1150(i).value_EoL = zeros(1,length(obj.number_of_cars_from_year));
                obj.Midpoint_impacts_SSP2_PkBudg1150(i).value_road = zeros(1,length(obj.number_of_cars_from_year));
                obj.Midpoint_impacts_SSP2_PkBudg1150(i).value_direct_non_exhaust = zeros(1,length(obj.number_of_cars_from_year));
                obj.Midpoint_impacts_SSP2_PkBudg1150(i).value_direct_exhaust = zeros(1,length(obj.number_of_cars_from_year));
            end
            for i = 1:length(obj.Endpoint_impacts_SSP2_PkBudg1150)
                obj.Endpoint_impacts_SSP2_PkBudg1150(i).time = zeros(1,length(obj.number_of_cars_from_year));
                obj.Endpoint_impacts_SSP2_PkBudg1150(i).value = zeros(1,length(obj.number_of_cars_from_year));

                obj.Endpoint_impacts_SSP2_PkBudg1150(i).value_glider = zeros(1,length(obj.number_of_cars_from_year));
                obj.Endpoint_impacts_SSP2_PkBudg1150(i).value_powertrain = zeros(1,length(obj.number_of_cars_from_year));
                obj.Endpoint_impacts_SSP2_PkBudg1150(i).value_energy_storage = zeros(1,length(obj.number_of_cars_from_year));
                obj.Endpoint_impacts_SSP2_PkBudg1150(i).value_energy_chain = zeros(1,length(obj.number_of_cars_from_year));
                obj.Endpoint_impacts_SSP2_PkBudg1150(i).value_maintenance = zeros(1,length(obj.number_of_cars_from_year));
                obj.Endpoint_impacts_SSP2_PkBudg1150(i).value_EoL = zeros(1,length(obj.number_of_cars_from_year));
                obj.Endpoint_impacts_SSP2_PkBudg1150(i).value_road = zeros(1,length(obj.number_of_cars_from_year));
                obj.Endpoint_impacts_SSP2_PkBudg1150(i).value_direct_non_exhaust = zeros(1,length(obj.number_of_cars_from_year));
                obj.Endpoint_impacts_SSP2_PkBudg1150(i).value_direct_exhaust = zeros(1,length(obj.number_of_cars_from_year));
            end
            % _PkBudg500
            for i = 1:length(obj.Midpoint_impacts_SSP2_PkBudg500)
                obj.Midpoint_impacts_SSP2_PkBudg500(i).time = zeros(1,length(obj.number_of_cars_from_year));
                obj.Midpoint_impacts_SSP2_PkBudg500(i).value = zeros(1,length(obj.number_of_cars_from_year));

                obj.Midpoint_impacts_SSP2_PkBudg500(i).value_glider = zeros(1,length(obj.number_of_cars_from_year));
                obj.Midpoint_impacts_SSP2_PkBudg500(i).value_powertrain = zeros(1,length(obj.number_of_cars_from_year));
                obj.Midpoint_impacts_SSP2_PkBudg500(i).value_energy_storage = zeros(1,length(obj.number_of_cars_from_year));
                obj.Midpoint_impacts_SSP2_PkBudg500(i).value_energy_chain = zeros(1,length(obj.number_of_cars_from_year));
                obj.Midpoint_impacts_SSP2_PkBudg500(i).value_maintenance = zeros(1,length(obj.number_of_cars_from_year));
                obj.Midpoint_impacts_SSP2_PkBudg500(i).value_EoL = zeros(1,length(obj.number_of_cars_from_year));
                obj.Midpoint_impacts_SSP2_PkBudg500(i).value_road = zeros(1,length(obj.number_of_cars_from_year));
                obj.Midpoint_impacts_SSP2_PkBudg500(i).value_direct_non_exhaust = zeros(1,length(obj.number_of_cars_from_year));
                obj.Midpoint_impacts_SSP2_PkBudg500(i).value_direct_exhaust = zeros(1,length(obj.number_of_cars_from_year));
            end
            for i = 1:length(obj.Endpoint_impacts_SSP2_PkBudg500)
                obj.Endpoint_impacts_SSP2_PkBudg500(i).time = zeros(1,length(obj.number_of_cars_from_year));
                obj.Endpoint_impacts_SSP2_PkBudg500(i).value = zeros(1,length(obj.number_of_cars_from_year));

                obj.Endpoint_impacts_SSP2_PkBudg500(i).value_glider = zeros(1,length(obj.number_of_cars_from_year));
                obj.Endpoint_impacts_SSP2_PkBudg500(i).value_powertrain = zeros(1,length(obj.number_of_cars_from_year));
                obj.Endpoint_impacts_SSP2_PkBudg500(i).value_energy_storage = zeros(1,length(obj.number_of_cars_from_year));
                obj.Endpoint_impacts_SSP2_PkBudg500(i).value_energy_chain = zeros(1,length(obj.number_of_cars_from_year));
                obj.Endpoint_impacts_SSP2_PkBudg500(i).value_maintenance = zeros(1,length(obj.number_of_cars_from_year));
                obj.Endpoint_impacts_SSP2_PkBudg500(i).value_EoL = zeros(1,length(obj.number_of_cars_from_year));
                obj.Endpoint_impacts_SSP2_PkBudg500(i).value_road = zeros(1,length(obj.number_of_cars_from_year));
                obj.Endpoint_impacts_SSP2_PkBudg500(i).value_direct_non_exhaust = zeros(1,length(obj.number_of_cars_from_year));
                obj.Endpoint_impacts_SSP2_PkBudg500(i).value_direct_exhaust = zeros(1,length(obj.number_of_cars_from_year));
            end
        end

        function obj = backfill_from_first_value(obj, tol)
            % Carry the FIRST future non-zero backward for every contributor field,
            % for ALL midpoint & endpoint categories of this vehicle. Recomputes .value.
            if nargin < 2, tol = 0; end
            flds = {'value_glider','value_powertrain','value_energy_storage', ...
                'value_energy_chain','value_maintenance','value_EoL', ...
                'value_road','value_direct_non_exhaust','value_direct_exhaust'};

            % Midpoints
            for k = 1:numel(obj.Midpoint_impacts_SSP2_NPi)
                obj.Midpoint_impacts_SSP2_NPi(k) = ...
                    Vehicle_archetype.futureFillImpact(obj.Midpoint_impacts_SSP2_NPi(k), flds, tol);
            end
            % Endpoints
            for k = 1:numel(obj.Endpoint_impacts_SSP2_NPi)
                obj.Endpoint_impacts_SSP2_NPi(k) = ...
                    Vehicle_archetype.futureFillImpact(obj.Endpoint_impacts_SSP2_NPi(k), flds, tol);
            end
        end

        function imp = futureFillImpact(imp, flds, tol)
            if nargin<3, tol = 0; end
            nT = numel(imp.time);
            for f = 1:numel(flds)
                arr = imp.(flds{f});
                if isempty(arr), arr = zeros(1,nT); else, arr = arr(:).'; end
                arr(abs(arr) <= tol) = NaN;             % treat tiny values as missing
                arr = fillmissing(arr, 'next');         % pull from future
                arr(isnan(arr)) = 0;                    % all-missing stays 0
                imp.(flds{f}) = arr;
            end
            % total = sum of contributors
            imp.value = zeros(1,nT);
            for f = 1:numel(flds), imp.value = imp.value + imp.(flds{f}); end
        end

        function impT = backfillImpact(impT, impD, flds, tol, leadingOnly)
            if nargin<4, tol = 0; end
            if nargin<5, leadingOnly = false; end
            nT = numel(impT.time);

            % Build contributors matrix for target
            C = zeros(numel(flds), nT);
            for f = 1:numel(flds)
                v = impT.(flds{f}); if isempty(v), v = zeros(1,nT); else, v = v(:).'; end
                if numel(v) < nT, v(end+1:nT) = 0; end
                C(f,:) = v;
            end

            % Missing where ALL contributors are ~0
            missing = ~any(abs(C) > tol, 1);

            % Leading-only option
            if leadingOnly
                firstNZ = find(~missing, 1, 'first');  % first time any contributor is nonzero
                lead = false(1, nT);
                if ~isempty(firstNZ) && firstNZ > 1, lead(1:firstNZ-1) = true; else, lead(:) = true; end
                missing = missing & lead;
            end

            if any(missing)
                % Copy from donor 1:1 in time (axes already asserted equal)
                for f = 1:numel(flds)
                    src = impD.(flds{f}); if isempty(src), src = zeros(1,nT); else, src = src(:).'; end
                    tgt = C(f,:);
                    tgt(missing) = src(missing);
                    impT.(flds{f}) = tgt;
                    C(f,:) = tgt;
                end
            end

            % keep total consistent
            impT.value = sum(C, 1);
        end

        function obj = backfill_with_loops(obj)
            flds = {'value_glider','value_powertrain','value_energy_storage', ...
                'value_energy_chain','value_maintenance','value_EoL', ...
                'value_road','value_direct_non_exhaust','value_direct_exhaust'};

            tol = 1e-30;

            % Midpoints
            for k = 1:numel(obj.Midpoint_impacts_SSP2_NPi)

                first_contributor_with_data = -999;
                found = 0;

                for l = 1:length(obj.Midpoint_impacts_SSP2_NPi(k).time)
                    for f = 1:numel(flds)
                        if obj.Midpoint_impacts_SSP2_NPi(k).(flds{f})(l) > tol
                            first_contributor_with_data = l;
                            found = 1;
                            break
                        end
                    end

                    if found == 1
                        break
                    end

                end

                if  first_contributor_with_data > 0
                    for l = 1:(first_contributor_with_data-1)
                        for f = 1:numel(flds)
                            obj.Midpoint_impacts_SSP2_NPi(k).(flds{f})(l) = obj.Midpoint_impacts_SSP2_NPi(k).(flds{f})(first_contributor_with_data);
                        end
                    end

                end
            end % for k

            % Endpoints
            for k = 1:numel(obj.Endpoint_impacts_SSP2_NPi)

                first_contributor_with_data = -999;
                found = 0;

                for l = 1:length(obj.Endpoint_impacts_SSP2_NPi(k).time)
                    for f = 1:numel(flds)
                        if obj.Endpoint_impacts_SSP2_NPi(k).(flds{f})(l) > tol
                            first_contributor_with_data = l;
                            found = 1;
                            break
                        end
                    end
                    if found == 1
                        break
                    end
                end

                if  first_contributor_with_data > 0
                    for l = 1:(first_contributor_with_data-1)
                        for f = 1:numel(flds)
                            obj.Endpoint_impacts_SSP2_NPi(k).(flds{f})(l) = obj.Endpoint_impacts_SSP2_NPi(k).(flds{f})(first_contributor_with_data);
                        end
                    end

                end
            end % for k
        end % function backfill with loops

        function obj = backfill_vectorized(obj)

            flds = {'value_glider','value_powertrain','value_energy_storage', ...
                'value_energy_chain','value_maintenance','value_EoL', ...
                'value_road','value_direct_non_exhaust','value_direct_exhaust'};

            tol = 1e-30;


            get_first_idx = @(S) find( any(cell2mat(cellfun( ...
                @(nm) S.(nm)(:) > tol, flds, 'UniformOutput', false)) ,2), 1, 'first');

            for k = 1:numel(obj.Midpoint_impacts_SSP2_NPi)
                idx = get_first_idx(obj.Midpoint_impacts_SSP2_NPi(k));
                if ~isempty(idx) && idx > 1
                    for f = 1:numel(flds)
                        obj.Midpoint_impacts_SSP2_NPi(k).(flds{f})(1:idx-1) = ...
                            obj.Midpoint_impacts_SSP2_NPi(k).(flds{f})(idx);
                    end
                end
            end

            for k = 1:numel(obj.Endpoint_impacts_SSP2_NPi)
                idx = get_first_idx(obj.Endpoint_impacts_SSP2_NPi(k));
                if ~isempty(idx) && idx > 1
                    for f = 1:numel(flds)
                        obj.Endpoint_impacts_SSP2_NPi(k).(flds{f})(1:idx-1) = ...
                            obj.Endpoint_impacts_SSP2_NPi(k).(flds{f})(idx);
                    end
                end
            end


        end

    end

end



