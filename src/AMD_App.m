% ==========================================
% Algo-Mech Designer (AMD) Suite - App v13.0
% IMMORTAL MODULAR CONTROLLER
% ==========================================

function AMD_App()
    src_dir = fileparts(mfilename('fullpath')); project_root = fileparts(src_dir);
    data_path = fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv');
    output_dir = fullfile(project_root, 'out'); addpath(src_dir);

    bg_color = [0.05 0.05 0.08]; panel_bg = [0.1 0.1 0.15]; txt_color = [0.95 0.95 0.95];
    fig = uifigure('Name', 'AMD Suite v13.0 - IMMORTAL ROBOT CENTER', 'Position', [100 100 1250 750], 'Color', bg_color);

    % --- Top Bar ---
    uilabel(fig, 'Text', '💎 AMD SUITE v13.0: ULTIMATE DESIGN CENTER', 'FontSize', 22, 'FontWeight', 'bold', 'Position', [20 705 600 35], 'FontColor', [0.3 0.8 1.0]);
    btn_git = uibutton(fig, 'push', 'Text', '🌐 SYNC TO GITHUB', 'Position', [1050 710 150 30], 'BackgroundColor', [0.2 0.2 0.2], 'FontColor', 'w');

    % --- Tabs ---
    tg = uitabgroup(fig, 'Position', [20 120 350 570]);
    tab_arm = uitab(tg, 'Title', '🦾 Arm'); tab_lift = uitab(tg, 'Title', '🏗️ Lift');

    % --- Settings (WHITE TEXT) ---
    pnl_arm = uipanel(tab_arm, 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color, 'Position', [0 0 350 540], 'Title', 'Specifications');
    
    uilabel(pnl_arm, 'Text', 'Payload [kg]:', 'Position', [20 460 100 22], 'FontColor', 'w');
    sld_load = uislider(pnl_arm, 'Limits', [0.1 10.0], 'Value', 2.0, 'Position', [30 440 300 3], 'FontColor', 'w');
    
    uilabel(pnl_arm, 'Text', 'Length [mm]:', 'Position', [20 370 100 22], 'FontColor', 'w');
    sld_len = uislider(pnl_arm, 'Limits', [50 1000], 'Value', 300, 'Position', [30 350 300 3], 'FontColor', 'w');

    uilabel(pnl_arm, 'Text', 'Radius [mm]:', 'Position', [20 280 100 22], 'FontColor', 'w');
    sld_rad = uislider(pnl_arm, 'Limits', [2 50], 'Value', 10, 'Position', [30 260 300 3], 'FontColor', 'w');

    uilabel(pnl_arm, 'Text', 'Budget [JPY]:', 'Position', [20 190 100 22], 'FontColor', 'w');
    sld_budget = uislider(pnl_arm, 'Limits', [1000 50000], 'Value', 15000, 'Position', [30 170 300 3], 'FontColor', 'w');

    % --- Panels ---
    pnl_ana = uipanel(fig, 'Title', 'Analysis', 'Position', [385 120 340 570], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    lbl_status = uilabel(pnl_ana, 'Text', 'Best: ---', 'FontSize', 16, 'FontWeight', 'bold', 'Position', [20 510 300 40], 'FontColor', [0.2 0.8 1.0]);
    ax_bar = uiaxes(pnl_ana, 'Position', [20 20 300 450], 'Color', bg_color, 'XColor', 'w', 'YColor', 'w');

    pnl_3d = uipanel(fig, 'Title', 'Live 3D', 'Position', [740 120 480 570], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    ax_3d = uiaxes(pnl_3d, 'Position', [10 10 460 530], 'Color', [0 0 0], 'XColor', 'none', 'YColor', 'none');

    btn_run = uibutton(fig, 'push', 'Text', '🚀 GENERATE OFFICIAL CERTIFICATE', 'FontSize', 16, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.1 0.6 0.3], 'FontColor', 'white', 'Position', [100 25 1100 80]);

    % --- Logic Bridge ---
    function update_ui(~, ~)
        try
            mode = tg.SelectedTab.Title(5:end);
            [req_t, motor, catalog, b_idx, arm_mass] = AMD_Logic(sld_load.Value, sld_len.Value, sld_rad.Value, sld_budget.Value, 1.5, mode, data_path);
            lbl_status.Text = ['👑 Winner: ', char(motor.PartName)];
            
            % Call External Visuals
            AMD_Visuals(ax_bar, ax_3d, catalog, b_idx, sld_len.Value, sld_rad.Value);
        catch, end
    end

    btn_run.ButtonPushedFcn = @(btn, event) run_full();
    function run_full()
        mode = tg.SelectedTab.Title(5:end);
        [req_t, motor, catalog, b_idx, arm_mass] = AMD_Logic(sld_load.Value, sld_len.Value, sld_rad.Value, sld_budget.Value, 1.5, mode, data_path);
        
        % Call External Report & Voice
        AMD_Report(sld_load.Value, sld_len.Value, sld_rad.Value, sld_budget.Value, 1.5, mode, motor, arm_mass, req_t, catalog, b_idx, output_dir);
        AMD_Voice(motor.PartName, arm_mass);
    end

    btn_git.ButtonPushedFcn = @(btn, event) system(sprintf('cd "%s" && git add . && git commit -m "Final Immortal v13.0" && git push', project_root));

    addlistener(sld_load, 'ValueChanged', @update_ui); addlistener(sld_len, 'ValueChanged', @update_ui);
    addlistener(sld_rad, 'ValueChanged', @update_ui); addlistener(sld_budget, 'ValueChanged', @update_ui);
    update_ui();
end
