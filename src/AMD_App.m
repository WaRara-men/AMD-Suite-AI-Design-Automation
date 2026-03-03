% ==========================================
% Algo-Mech Designer (AMD) Suite - App v11.0
% ULTIMATE 5-TAB ROBOTICS DASHBOARD
% ==========================================

function AMD_App()
    src_dir = fileparts(mfilename('fullpath')); project_root = fileparts(src_dir);
    data_path = fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv');
    output_dir = fullfile(project_root, 'out'); addpath(src_dir);

    bg_color = [0.05 0.05 0.08]; panel_bg = [0.1 0.1 0.15]; txt_color = [0.95 0.95 0.95];
    fig = uifigure('Name', 'AMD Suite v11.0 - Ultimate Robotics Platform', 'Position', [100 100 1300 750], 'Color', bg_color);
    current_lang = 'JP';

    % --- Header & Language ---
    uilabel(fig, 'Text', '💎 AMD SUITE: ULTIMATE ROBOT DESIGN CENTER', 'FontSize', 22, 'FontWeight', 'bold', 'Position', [20 710 600 35], 'FontColor', [0.3 0.8 1.0]);
    btn_lang = uibutton(fig, 'push', 'Text', '🌐 Switch Language', 'Position', [1100 715 150 30], 'BackgroundColor', [0.2 0.2 0.2], 'FontColor', 'w');

    % --- 🌟 5-TAB GROUP ---
    tg = uitabgroup(fig, 'Position', [20 120 400 580]);
    tab_arm = uitab(tg, 'Title', '🦾 Arm');
    tab_lift = uitab(tg, 'Title', '🏗️ Lift');
    tab_mobile = uitab(tg, 'Title', '🏎️ Mobile');
    tab_power = uitab(tg, 'Title', '🔋 Power');
    tab_bolt = uitab(tg, 'Title', '🔩 Bolt');

    % --- Tab Content (Descriptions Added) ---
    function setup_tab(tab, title, desc)
        p = uipanel(tab, 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color, 'Position', [0 0 400 550], 'Title', title);
        uilabel(p, 'Text', desc, 'Position', [10 500 380 22], 'FontColor', [0.6 0.9 0.6], 'FontAngle', 'italic');
    end

    setup_tab(tab_arm, 'Robot Arm', '旋回するアームのトルクと自重を計算します / Rotational torque & arm weight.');
    setup_tab(tab_lift, 'Lifting Stage', '荷物を垂直に引き上げる力を計算します / Vertical lifting force & tension.');
    setup_tab(tab_mobile, 'Mobile Base', 'タイヤの駆動力と摩擦を計算します / Wheel driving force & friction.');
    setup_tab(tab_power, 'Power System', 'バッテリー持続時間と電流を計算します / Battery life & power consumption.');
    setup_tab(tab_bolt, 'Bolt & Joint', '結合部の強度とネジの本数を計算します / Bolt shear strength & safety.');

    % [Arm Controls - RESTORED & PROTECTED]
    pnl_controls = uipanel(tab_arm, 'Position', [10 10 380 480], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    uilabel(pnl_controls, 'Text', 'Payload [kg]:', 'Position', [10 420 100 22], 'FontColor', 'w');
    sld_load = uislider(pnl_controls, 'Limits', [0.1 10], 'Value', 2, 'Position', [20 400 340 3]);
    uilabel(pnl_controls, 'Text', 'Arm Length [mm]:', 'Position', [10 330 100 22], 'FontColor', 'w');
    sld_len = uislider(pnl_controls, 'Limits', [50 1000], 'Value', 300, 'Position', [20 310 340 3]);
    uilabel(pnl_controls, 'Text', 'Rod Radius [mm]:', 'Position', [10 240 100 22], 'FontColor', 'w');
    sld_rad = uislider(pnl_controls, 'Limits', [2 50], 'Value', 10, 'Position', [20 220 340 3]);
    uilabel(pnl_controls, 'Text', 'Budget [JPY]:', 'Position', [10 150 100 22], 'FontColor', 'w');
    sld_budget = uislider(pnl_controls, 'Limits', [1000 50000], 'Value', 15000, 'Position', [20 130 340 3]);

    % --- Analytics & 3D (RESTORED & PROTECTED) ---
    pnl_ana = uipanel(fig, 'Title', 'AI Result', 'Position', [435 120 340 580], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    lbl_status = uilabel(pnl_ana, 'Text', 'Best: ---', 'FontSize', 16, 'FontWeight', 'bold', 'Position', [20 520 300 40], 'FontColor', [0.2 0.8 1.0]);
    ax_bar = uiaxes(pnl_ana, 'Position', [20 20 300 450], 'Color', bg_color, 'XColor', txt_color, 'YColor', txt_color);

    pnl_3d = uipanel(fig, 'Title', '3D Preview', 'Position', [790 120 480 580], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    ax_3d = uiaxes(pnl_3d, 'Position', [10 10 460 540], 'Color', [0 0 0], 'XColor', 'none', 'YColor', 'none');
    view(ax_3d, 3); axis(ax_3d, 'equal'); grid(ax_3d, 'on');

    btn_run = uibutton(fig, 'push', 'Text', '🚀 SELECT MOTOR & GENERATE OFFICIAL CERTIFICATE', 'FontSize', 16, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.1 0.6 0.3], 'FontColor', 'white', 'Position', [100 25 1100 80]);

    % --- Master Logic ---
    function update_ui(~, ~)
        try
            catalog = readtable(data_path);
            arm_mass = (pi * sld_rad.Value^2 * sld_len.Value) * 0.0000027; 
            req_t = (sld_load.Value + arm_mass/2) * 9.81 * (sld_len.Value / 1000) * 1.5;
            feasible = find(catalog.Torque_Nm >= req_t & catalog.Price_JPY <= sld_budget.Value);
            if isempty(feasible), [~, b_idx] = min(catalog.Price_JPY); else, [~, s_idx] = min(catalog.Weight_kg(feasible)); b_idx = feasible(sub_idx); end
            motor = catalog(b_idx, :);
            lbl_status.Text = ['👑 Winner: ', char(motor.PartName)];
            bar(ax_bar, catalog.Torque_Nm, 'FaceColor', [0.2 0.3 0.4]); hold(ax_bar, 'on'); bar(ax_bar, b_idx, motor.Torque_Nm, 'FaceColor', [1.0 0.6 0.2]); hold(ax_bar, 'off');
            cla(ax_3d); [X, Y, Z] = cylinder([sld_rad.Value sld_rad.Value], 20); Z = Z * sld_len.Value;
            surf(ax_3d, Z, X, Y, 'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'none'); view(ax_3d, 3); axis(ax_3d, 'tight'); axis(ax_3d, 'equal'); camlight(ax_3d); material(ax_3d, 'shiny');
        catch, end
    end

    btn_run.ButtonPushedFcn = @(btn, event) AMD_Main_Brain(sld_load.Value, sld_len.Value, sld_rad.Value, sld_budget.Value, 1.5, current_lang, 'Arm');
    addlistener(sld_load, 'ValueChanged', @update_ui); addlistener(sld_len, 'ValueChanged', @update_ui);
    addlistener(sld_rad, 'ValueChanged', @update_ui); addlistener(sld_budget, 'ValueChanged', @update_ui);
    update_ui();
end
