% ==========================================
% Algo-Mech Designer (AMD) Suite - App v8.7
% THE ABSOLUTE GOD-MODE: Dashboard Restoration
% ==========================================

function AMD_App()
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    data_path = fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv');
    output_dir = fullfile(project_root, 'out');
    addpath(src_dir);

    bg_color = [0.05 0.05 0.08]; panel_bg = [0.1 0.1 0.15]; txt_color = [0.95 0.95 0.95];
    fig = uifigure('Name', 'AMD Suite v8.7 - The Ultimate Dashboard', 'Position', [100 100 1150 650], 'Color', bg_color);
    current_lang = 'JP';

    % Language Switch
    btn_lang = uibutton(fig, 'push', 'Text', '🌐 Switch to English', 'Position', [1000 610 130 30], 'BackgroundColor', [0.2 0.2 0.2], 'FontColor', 'w');

    % Settings (RESTORED ALL 3)
    pnl_settings = uipanel(fig, 'Title', 'Robot Specifications', 'Position', [20 120 300 480], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    
    uilabel(pnl_settings, 'Text', '1. Payload / 荷物重量 [kg]:', 'Position', [10 410 250 22], 'FontColor', txt_color, 'FontWeight', 'bold');
    sld_load = uislider(pnl_settings, 'Limits', [0.1 10.0], 'Value', 2.0, 'Position', [20 380 250 3], 'FontColor', txt_color);
    
    uilabel(pnl_settings, 'Text', '2. Arm Length / アーム長 [mm]:', 'Position', [10 310 250 22], 'FontColor', txt_color, 'FontWeight', 'bold');
    sld_len = uislider(pnl_settings, 'Limits', [50 1000], 'Value', 300, 'Position', [20 280 250 3], 'FontColor', txt_color);

    lbl_budget_title = uilabel(pnl_settings, 'Text', '3. Budget Limit / 予算上限 [JPY]:', 'Position', [10 210 250 22], 'FontColor', txt_color, 'FontWeight', 'bold');
    sld_budget = uislider(pnl_settings, 'Limits', [1000 50000], 'Value', 10000, 'Position', [20 180 250 3], 'FontColor', txt_color);

    % Analytics (RESTORED CHART)
    pnl_ana = uipanel(fig, 'Title', 'AI Selection', 'Position', [330 120 340 480], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    lbl_status = uilabel(pnl_ana, 'Text', 'Best: ---', 'FontSize', 16, 'FontWeight', 'bold', 'Position', [20 420 300 40], 'FontColor', [0.2 0.8 1.0]);
    lbl_details = uilabel(pnl_ana, 'Text', 'Calculating...', 'FontSize', 12, 'Position', [20 380 300 30], 'FontColor', txt_color);
    ax_bar = uiaxes(pnl_ana, 'Position', [20 20 300 340], 'Color', bg_color, 'XColor', txt_color, 'YColor', txt_color);

    % 3D (RESTORED PREVIEW)
    pnl_3d = uipanel(fig, 'Title', 'Live 3D Preview', 'Position', [680 120 450 480], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    ax_3d = uiaxes(pnl_3d, 'Position', [10 10 430 430], 'Color', [0 0 0], 'XColor', 'none', 'YColor', 'none');
    view(ax_3d, 3); axis(ax_3d, 'equal'); grid(ax_3d, 'on');

    btn_run = uibutton(fig, 'push', 'Text', '🚀 SELECT MOTOR & GENERATE PDF', 'FontSize', 16, 'FontWeight', 'bold', 'BackgroundColor', [0.1 0.4 0.6], 'FontColor', 'white', 'Position', [100 30 950 70]);

    function update_ui(~, ~)
        try
            catalog = readtable(data_path);
            req_t = (sld_load.Value * 9.8) * (sld_len.Value / 1000) * 1.5;
            feasible = find(catalog.Torque_Nm >= req_t & catalog.Price_JPY <= sld_budget.Value);
            if isempty(feasible), [~, b_idx] = min(catalog.Price_JPY); else, [~, sub_idx] = min(catalog.Weight_kg(feasible)); b_idx = feasible(sub_idx); end
            motor = catalog(b_idx, :);
            
            % 🌟 FIXED: Human-readable integer labels (No more 'e' notation!)
            lbl_status.Text = ['👑 Selected: ', char(motor.PartName)];
            lbl_details.Text = sprintf('Req. Torque: %.2f N-m | Budget: %d JPY', req_t, round(sld_budget.Value));
            
            bar(ax_bar, catalog.Torque_Nm, 'FaceColor', [0.3 0.3 0.3]); hold(ax_bar, 'on');
            bar(ax_bar, b_idx, motor.Torque_Nm, 'FaceColor', [1.0 0.6 0.2]); hold(ax_bar, 'off');
            set(ax_bar, 'XTickLabel', catalog.PartName);
            
            % Draw 3D Arm
            cla(ax_3d); [X, Y, Z] = cylinder([5 5], 20); Z = Z * sld_len.Value;
            surf(ax_3d, Z, X, Y, 'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'none');
            view(ax_3d, 3); axis(ax_3d, 'equal'); camlight(ax_3d); material(ax_3d, 'shiny');
        catch, end
    end

    btn_run.ButtonPushedFcn = @(btn, event) AMD_Main_Brain(sld_load.Value, sld_len.Value, sld_budget.Value, 1.5, current_lang);
    addlistener(sld_load, 'ValueChanged', @update_ui);
    addlistener(sld_len, 'ValueChanged', @update_ui);
    addlistener(sld_budget, 'ValueChanged', @update_ui);
    update_ui();
end
