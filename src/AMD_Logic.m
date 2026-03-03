% ==========================================
% Algo-Mech Designer (AMD) Suite - Logic v21.0
% FULL PHYSICS Integration for 5 Modes
% ==========================================

function [req_val, comp, catalog, b_idx, m_name, m_unit, desc_jp] = AMD_Logic(inputs, mode, project_root)
    g = 9.81;
    switch mode
        case 'Arm'
            catalog = readtable(fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv'));
            load = inputs(1); len = inputs(2); rad = inputs(3); budget = inputs(4);
            arm_mass = (pi * rad^2 * len) * 0.0000027;
            req_val = (load + arm_mass/2) * g * (len/1000) * 1.5;
            m_name = 'Torque'; m_unit = 'Nm'; vals = catalog.Torque_Nm;
            desc_jp = sprintf('ロボットアームの旋回（自重%.2fkg考慮）', arm_mass);
        case 'Lift'
            catalog = readtable(fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv'));
            load = inputs(1); p_rad = inputs(2); budget = inputs(4);
            req_val = (load * g) * (p_rad/1000) * 1.5;
            m_name = 'Torque'; m_unit = 'Nm'; vals = catalog.Torque_Nm;
            desc_jp = '垂直昇降機の巻上負荷';
        case 'Mobile'
            catalog = readtable(fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv'));
            weight = inputs(1); w_rad = inputs(2); inc = inputs(3); budget = inputs(4);
            req_val = (weight * g * sin(inc*pi/180) + 0.15*weight*g*cos(inc*pi/180)) * (w_rad/1000) * 1.5;
            m_name = 'Torque'; m_unit = 'Nm'; vals = catalog.Torque_Nm;
            desc_jp = sprintf('%d度の坂を登る走行駆動力', round(inc));
        case 'Power'
            catalog = readtable(fullfile(project_root, 'data', 'Battery_Catalog.csv'));
            curr = inputs(1); hrs = inputs(2); volt = inputs(3); budget = inputs(4);
            req_val = curr * hrs * 1000 * 1.2; % Required mAh
            m_name = 'Capacity'; m_unit = 'mAh'; vals = catalog.Capacity_mAh;
            desc_jp = sprintf('%.1fAで%.1f時間稼働するための電源', curr, hrs);
        case 'Bolt'
            catalog = readtable(fullfile(project_root, 'data', 'Bolt_Catalog.csv'));
            load = inputs(1); num = inputs(2); budget = inputs(4);
            req_val = (load * g * 2.5) / num; % Safety 2.5 for bolts
            m_name = 'Shear Force'; m_unit = 'N'; vals = catalog.MaxShear_N;
            desc_jp = sprintf('%d本のネジによる荷重分散', round(num));
    end

    feasible = find(vals >= req_val & catalog.Price_JPY <= budget);
    if isempty(feasible), [~, b_idx] = min(catalog.Price_JPY); else, [~, s_idx] = min(catalog.Weight_kg(feasible)); b_idx = feasible(s_idx); end
    comp = catalog(b_idx, :);
end
