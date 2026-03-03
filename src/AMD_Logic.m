% ==========================================
% Algo-Mech Designer (AMD) Suite - Logic v15.0
% ==========================================
function [req_val, comp, catalog, b_idx, extra_val, metric_name, metric_unit] = AMD_Logic(inputs, mode, project_root)
    g = 9.81;
    switch mode
        case 'Arm'
            catalog = readtable(fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv'));
            load = inputs(1); len = inputs(2); rad = inputs(3); budget = inputs(4); safety = 1.5;
            arm_mass = (pi * rad^2 * len) * 0.0000027;
            req_val = (load + arm_mass/2) * g * (len/1000) * safety;
            feasible = find(catalog.Torque_Nm >= req_val & catalog.Price_JPY <= budget);
            extra_val = arm_mass; metric_name = 'Torque'; metric_unit = 'Nm';
        case 'Lift'
            catalog = readtable(fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv'));
            load = inputs(1); p_rad = inputs(2); budget = inputs(4); safety = 1.5;
            req_val = (load * g) * (p_rad/1000) * safety;
            feasible = find(catalog.Torque_Nm >= req_val & catalog.Price_JPY <= budget);
            extra_val = req_val / (p_rad/1000); % Tension force
            metric_name = 'Torque'; metric_unit = 'Nm';
        case 'Mobile'
            catalog = readtable(fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv'));
            weight = inputs(1); w_rad = inputs(2); incline = inputs(3); budget = inputs(4); safety = 1.5;
            theta = incline * pi / 180;
            mu = 0.1; % Rolling resistance
            force = weight * g * sin(theta) + mu * weight * g * cos(theta);
            req_val = force * (w_rad/1000) * safety;
            feasible = find(catalog.Torque_Nm >= req_val & catalog.Price_JPY <= budget);
            extra_val = force; metric_name = 'Torque'; metric_unit = 'Nm';
        case 'Power'
            catalog = readtable(fullfile(project_root, 'data', 'Battery_Catalog.csv'));
            current = inputs(1); hours = inputs(2); voltage = inputs(3); budget = inputs(4); safety = 1.2;
            req_val = current * hours * 1000 * safety; % mAh
            feasible = find(catalog.Capacity_mAh >= req_val & catalog.Voltage_V >= voltage & catalog.Price_JPY <= budget);
            extra_val = req_val / 1000 * voltage; % Required Wh
            metric_name = 'Capacity'; metric_unit = 'mAh';
        case 'Bolt'
            catalog = readtable(fullfile(project_root, 'data', 'Bolt_Catalog.csv'));
            shear_load = inputs(1); num_bolts = inputs(2); budget = inputs(4); safety = 2.0;
            req_val = (shear_load * g * safety) / num_bolts;
            feasible = find(catalog.MaxShear_N >= req_val & (catalog.Price_JPY .* num_bolts) <= budget);
            extra_val = req_val; % Force per bolt
            metric_name = 'Shear Force'; metric_unit = 'N';
    end

    if isempty(feasible)
        [~, b_idx] = min(catalog.Price_JPY); 
    else
        [~, s_idx] = min(catalog.Weight_kg(feasible)); 
        b_idx = feasible(s_idx); 
    end
    comp = catalog(b_idx, :);
end
