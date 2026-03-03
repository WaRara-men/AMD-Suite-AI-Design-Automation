% ==========================================
% Algo-Mech Designer (AMD) Suite - Logic v16.0
% ==========================================
function [req_val, comp, catalog, b_idx, m_name, m_unit] = AMD_Logic(inputs, mode, project_root)
    g = 9.81;
    switch mode
        case 'Arm'
            catalog = readtable(fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv'));
            load = inputs(1); len = inputs(2); rad = inputs(3); budget = inputs(4);
            arm_mass = (pi * rad^2 * len) * 0.0000027;
            req_val = (load + arm_mass/2) * g * (len/1000) * 1.5;
            m_name = 'Torque'; m_unit = 'Nm'; vals = catalog.Torque_Nm;
        case 'Lift'
            catalog = readtable(fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv'));
            load = inputs(1); p_rad = inputs(2); budget = inputs(4);
            req_val = (load * g) * (p_rad/1000) * 1.5;
            m_name = 'Torque'; m_unit = 'Nm'; vals = catalog.Torque_Nm;
        case 'Mobile'
            catalog = readtable(fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv'));
            weight = inputs(1); w_rad = inputs(2); inc = inputs(3); budget = inputs(4);
            req_val = (weight * g * sin(inc*pi/180) + 0.1*weight*g*cos(inc*pi/180)) * (w_rad/1000) * 1.5;
            m_name = 'Torque'; m_unit = 'Nm'; vals = catalog.Torque_Nm;
        case 'Power'
            catalog = readtable(fullfile(project_root, 'data', 'Battery_Catalog.csv'));
            curr = inputs(1); hrs = inputs(2); volt = inputs(3); budget = inputs(4);
            req_val = curr * hrs * 1000 * 1.2; 
            m_name = 'Capacity'; m_unit = 'mAh'; vals = catalog.Capacity_mAh;
        case 'Bolt'
            catalog = readtable(fullfile(project_root, 'data', 'Bolt_Catalog.csv'));
            load = inputs(1); num = inputs(2); budget = inputs(4);
            req_val = (load * g * 2.0) / num;
            m_name = 'Shear Force'; m_unit = 'N'; vals = catalog.MaxShear_N;
    end
    feasible = find(vals >= req_val & catalog.Price_JPY <= budget);
    if isempty(feasible), [~, b_idx] = min(catalog.Price_JPY); else, [~, s_idx] = min(catalog.Weight_kg(feasible)); b_idx = feasible(s_idx); end
    comp = catalog(b_idx, :);
end
