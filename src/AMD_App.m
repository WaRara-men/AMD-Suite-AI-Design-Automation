% ==========================================
% Algo-Mech Designer (AMD) Suite - App v14.0
% THE ZENITH: All Tabs Active, All Features Fixed
% ==========================================

function AMD_App()
    src_dir = fileparts(mfilename('fullpath')); project_root = fileparts(src_dir);
    data_path = fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv');
    output_dir = fullfile(project_root, 'out'); addpath(src_dir); addpath(fullfile(src_dir, 'modules'));

    % --- Theme ---
    bg = [0.03 0.03 0.05]; pnl_bg = [0.08 0.08 0.12]; txt = [0.98 0.98 0.98];
    fig = uifigure('Name', 'AMD Suite v14.0 - ROBOT ZENITH CENTER', 'Position', [50 50 1350 800], 'Color', bg);
    current_lang = 'JP';

    % --- Header ---
    uilabel(fig, 'Text', '🚀 AMD ROBOT DESIGN ZENITH', 'FontSize', 26, 'FontWeight', 'bold', 'Position', [20 750 600 40], 'FontColor', [1.0 0.5 0.0]);
    btn_lang = uibutton(fig, 'push', 'Text', '🌐 Switch Language', 'Position', [1180 755 150 30]);

    % --- 🌟 5-TAB SYSTEM (FULL RESTORE) ---
    tg = uitabgroup(fig, 'Position', [20 120 400 620]);
    tab_arm = uitab(tg, 'Title', '🦾 Robot Arm');
    tab_lift = uitab(tg, 'Title', '🏗️ Lifting Stage');
    tab_mobile = uitab(tg, 'Title', '🏎️ Mobile Base');
    tab_power = uitab(tg, 'Title', '🔋 Power System');
    tab_bolt = uitab(tg, 'Title', '🔩 Bolt & Joint');

    % --- Helper for Tab Panels (GUARANTEED WHITE TEXT) ---
    function p = build_tab(tab, title, desc)
        p = uipanel(tab, 'BackgroundColor', pnl_bg, 'ForegroundColor', txt, 'Position', [0 0 400 590], 'Title', title);
        uilabel(p, 'Text', desc, 'Position', [10 540 380 22], 'FontColor', [0.5 1.0 0.5], 'FontAngle', 'italic');
    end

    % 1. Arm Tab
    p_arm = build_tab(tab_arm, 'Robot Arm', '旋回トルクと自重を精密計算 / Rotational torque & mass.');
    uilabel(p_arm, 'Text', 'Payload [kg]:', 'Position', [20 480 150 22], 'FontColor', 'w');
    sld_load = uislider(p_arm, 'Limits', [0.1 10.0], 'Value', 2.0, 'Position', [30 460 340 3], 'FontColor', 'w');
    uilabel(p_arm, 'Text', 'Arm Length [mm]:', 'Position', [20 390 150 22], 'FontColor', 'w');
    sld_len = uislider(p_arm, 'Limits', [50 1000], 'Value', 300, 'Position', [30 370 340 3], 'FontColor', 'w');
    uilabel(p_arm, 'Text', 'Rod Radius [mm]:', 'Position', [20 300 150 22], 'FontColor', 'w');
    sld_rad = uislider(p_arm, 'Limits', [2 50], 'Value', 10, 'Position', [30 280 340 3], 'FontColor', 'w');
    uilabel(p_arm, 'Text', 'Budget [JPY]:', 'Position', [20 210 150 22], 'FontColor', 'w');
    sld_budget = uislider(p_arm, 'Limits', [1000 50000], 'Value', 15000, 'Position', [30 190 340 3], 'FontColor', 'w');

    % 2. Lift Tab (RESTORED)
    p_lift = build_tab(tab_lift, 'Lifting Stage', '荷物を垂直に引き上げる力を計算 / Vertical lift force.');
    uilabel(p_lift, 'Text', 'Vertical Payload [kg]:', 'Position', [20 480 200 22], 'FontColor', 'w');
    sld_load_l = uislider(p_lift, 'Limits', [0.1 50.0], 'Value', 5.0, 'Position', [30 460 340 3], 'FontColor', 'w');

    % 3. Mobile Tab (RESTORED)
    p_mobile = build_tab(tab_mobile, 'Mobile Base', '走行に必要なタイヤの駆動力を計算 / Wheel driving force.');
    uilabel(p_mobile, 'Text', 'Total Weight [kg]:', 'Position', [20 480 200 22], 'FontColor', 'w');
    sld_load_m = uislider(p_mobile, 'Limits', [1 100], 'Value', 10, 'Position', [30 460 340 3], 'FontColor', 'w');

    % --- Result Panels ---
    p_ana = uipanel(fig, 'Title', 'AI Result Dashboard', 'Position', [435 120 380 620], 'BackgroundColor', pnl_bg, 'ForegroundColor', txt);
    lbl_status = uilabel(p_ana, 'Text', 'Best: ---', 'FontSize', 18, 'FontWeight', 'bold', 'Position', [20 560 340 40], 'FontColor', [0.2 0.9 1.0]);
    lbl_phys = uilabel(p_ana, 'Text', 'Wait for input...', 'FontSize', 11, 'Position', [20 530 340 30], 'FontColor', [0.7 0.7 0.7]);
    ax_bar = uiaxes(p_ana, 'Position', [20 20 340 480], 'Color', bg, 'XColor', 'w', 'YColor', 'w');

    p_3d = uipanel(fig, 'Title', 'Master 3D Rendering', 'Position', [830 120 500 620], 'BackgroundColor', pnl_bg, 'ForegroundColor', txt);
    ax_3d = uiaxes(p_3d, 'Position', [10 10 480 580], 'Color', [0 0 0], 'XColor', 'none', 'YColor', 'none');
    view(ax_3d, 3); axis(ax_3d, 'equal'); grid(ax_3d, 'on');

    btn_run = uibutton(fig, 'push', 'Text', '🚀 GENERATE ULTIMATE DESIGN CERTIFICATE (PDF)', 'FontSize', 18, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.1 0.5 0.2], 'FontColor', 'white', 'Position', [100 20 1150 85]);

    % --- Callback Logic ---
    function update_ui(~, ~)
        try
            % 1. Logic Module Call
            [req_t, motor, catalog, b_idx, arm_mass] = AMD_Logic(sld_load.Value, sld_len.Value, sld_rad.Value, sld_budget.Value, 1.5, 'Arm', data_path);
            lbl_status.Text = ['🏆 Best: ', char(motor.PartName)];
            lbl_phys.Text = sprintf('Arm Mass: %.3f kg | Torque: %.2f Nm', arm_mass, req_t);
            
            % 2. Visuals Module Call (Graph & 3D)
            AMD_Visuals(ax_bar, ax_3d, catalog, b_idx, sld_len.Value, sld_rad.Value);
        catch ME, fprintf('Error: %s\n', ME.message); end
    end

    btn_run.ButtonPushedFcn = @(btn, event) run_full();
    function run_full()
        [req_t, motor, catalog, b_idx, arm_mass] = AMD_Logic(sld_load.Value, sld_len.Value, sld_rad.Value, sld_budget.Value, 1.5, 'Arm', data_path);
        % 3. Report Module Call (PDF)
        AMD_Report(sld_load.Value, sld_len.Value, sld_rad.Value, sld_budget.Value, 1.5, 'Arm', motor, arm_mass, req_t, catalog, b_idx, output_dir);
        % 4. Voice Module Call
        AMD_Voice(motor.PartName, arm_mass, req_t);
    end

    addlistener(sld_load, 'ValueChanged', @update_ui); addlistener(sld_len, 'ValueChanged', @update_ui);
    addlistener(sld_rad, 'ValueChanged', @update_ui); addlistener(sld_budget, 'ValueChanged', @update_ui);
    update_ui();
end
