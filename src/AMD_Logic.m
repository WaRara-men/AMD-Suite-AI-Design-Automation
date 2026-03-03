% ==========================================
% Algo-Mech Designer (AMD) Suite - Logic v13.0
% ==========================================
function [req_t, motor, catalog, b_idx, arm_mass] = AMD_Logic(payload, length, radius, budget, safety, mode, data_path)
    g = 9.81; density_al = 0.0000027;
    catalog = readtable(data_path);
    if strcmp(mode, 'Arm')
        arm_mass = (pi * radius^2 * length) * density_al;
        req_t = (payload + arm_mass/2) * g * (length/1000) * safety;
    else
        arm_mass = 0; req_t = (payload * g) * (radius / 1000) * safety;
    end
    feasible = find(catalog.Torque_Nm >= req_t & catalog.Price_JPY <= budget);
    if isempty(feasible), [~, b_idx] = min(catalog.Price_JPY); else, [~, s_idx] = min(catalog.Weight_kg(feasible)); b_idx = feasible(s_idx); end
    motor = catalog(b_idx, :);
end
