% ==========================================
% Algo-Mech Designer (AMD) Suite - Logic v23.5
% FIXED: Variable Binding & Budget Filtering
% ==========================================
function [req_val, comp, catalog, b_idx, m_name, m_unit, desc_jp] = AMD_Logic(inputs, mode, project_root)
    g = 9.81;
    % Extract base inputs for clarity
    % inputs = [param1, param2, param3, budget]
    budget = inputs(4);
    
    switch mode
        case 'Arm'
            catalog = readtable(fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv'));
            load = inputs(1); len = inputs(2); rad = inputs(3);
            arm_m = (pi * rad^2 * len) * 0.0000027;
            req_val = (load + arm_m/2) * g * (len/1000) * 1.5;
            m_name = 'Torque'; m_unit = 'Nm'; vals = catalog.Torque_Nm;
            desc_jp = 'アームの旋回トルク解析（自重考慮）';
        case 'Lift'
            catalog = readtable(fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv'));
            load = inputs(1); p_rad = inputs(2); eff = inputs(3);
            real_load = load / (max(0.1, eff) / 100); 
            req_val = (real_load * g) * (p_rad/1000) * 1.5;
            m_name = 'Required Torque'; m_unit = 'Nm'; vals = catalog.Torque_Nm;
            desc_jp = '垂直リフトの巻上テンション解析';
        case 'Mobile'
            catalog = readtable(fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv'));
            w = inputs(1); r = inputs(2); inc = inputs(3);
            req_val = (w*g*sin(inc*pi/180) + 0.15*w*g*cos(inc*pi/180)) * (r/1000) * 1.5;
            m_name = 'Torque'; m_unit = 'Nm'; vals = catalog.Torque_Nm;
            desc_jp = '傾斜面における走行駆動力解析';
        case 'Power'
            catalog = readtable(fullfile(project_root, 'data', 'Battery_Catalog.csv'));
            cur = inputs(1); t = inputs(2); v = inputs(3);
            req_val = cur * t * 1000 * 1.2;
            m_name = 'Capacity'; m_unit = 'mAh'; vals = catalog.Capacity_mAh;
            desc_jp = 'システム消費電力と稼働時間シミュレーション';
        case 'Bolt'
            catalog = readtable(fullfile(project_root, 'data', 'Bolt_Catalog.csv'));
            l = inputs(1); n = inputs(2); sf = inputs(3);
            req_val = (l * g * max(1.0, sf)) / max(1, n);
            m_name = 'Shear Force'; m_unit = 'N'; vals = catalog.MaxShear_N;
            desc_jp = 'ボルト結合部のせん断・破断強度シミュレーション';
    end

    % 🎯 FIXED: Logic ensures 'budget' variable is correctly matched
    feasible = find(vals >= req_val & catalog.Price_JPY <= budget);
    if isempty(feasible)
        [~, b_idx] = min(catalog.Price_JPY); 
    else
        [~, s_idx] = min(catalog.Weight_kg(feasible)); 
        b_idx = feasible(s_idx); 
    end
    comp = catalog(b_idx, :);
end
