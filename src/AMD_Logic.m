% ==========================================
% Algo-Mech Designer (AMD) Suite - Logic v12.0
% Centralized Engineering Calculations
% ==========================================

function [req_t, motor, arm_mass] = AMD_Logic(payload, length, radius, budget, safety, mode, data_path)
    g = 9.81; 
    density_al = 0.0000027; % kg/mm^3
    catalog = readtable(data_path);
    
    switch mode
        case 'Arm'
            arm_mass = (pi * radius^2 * length) * density_al;
            req_t = (payload + arm_mass/2) * g * (length/1000) * safety;
        case 'Lift'
            arm_mass = 0;
            req_t = (payload * g) * (radius / 1000) * safety;
        case 'Mobile'
            arm_mass = 0;
            req_t = (payload * g * 0.15) * (radius / 1000) * safety; % 0.15 friction
        case 'Power'
            arm_mass = 0; req_t = payload; % Dummy for now
        case 'Bolt'
            arm_mass = 0; req_t = payload * g * safety; % Shear force
        otherwise
            arm_mass = 0; req_t = 0;
    end

    % Selection Logic
    feasible = find(catalog.Torque_Nm >= req_t & catalog.Price_JPY <= budget);
    if isempty(feasible), [~, b_idx] = min(catalog.Price_JPY); else, [~, s_idx] = min(catalog.Weight_kg(feasible)); b_idx = feasible(s_idx); end
    motor = catalog(b_idx, :);
end
