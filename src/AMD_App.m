% ==========================================
% Algo-Mech Designer (AMD) Suite - App v16.0
% THE ETERNAL ARCHITECT: Final Feature-Complete UI
% ==========================================

function AMD_App()
    src_dir = fileparts(mfilename('fullpath')); project_root = fileparts(src_dir);
    data_path = fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv');
    output_dir = fullfile(project_root, 'out'); addpath(src_dir);

    bg_color = [0.05 0.05 0.08]; panel_bg = [0.1 0.1 0.15]; 
    txt_color = [0.98 0.98 0.98]; % BRIGHT WHITE
    hint_color = [0.7 0.7 0.7];   % VISIBLE GRAY

    fig = uifigure('Name', 'AMD Suite v16.0 - THE ETERNAL ARCHITECT', 'Position', [50 50 1300 750], 'Color', bg_color);
    current_lang = 'JP';

    % --- Top Bar ---
    uilabel(fig, 'Text', '💎 AMD SUITE v16.0: ULTIMATE ROBOTICS DESIGN CENTER', 'FontSize', 22, 'FontWeight', 'bold', 'Position', [20 705 600 35], 'FontColor', [0.3 0.8 1.0]);
    btn_git = uibutton(fig, 'push', 'Text', '🌐 SYNC TO GITHUB', 'Position', [1100 710 150 30], 'BackgroundColor', [0.2 0.2 0.2], 'FontColor', 'w');

    % --- Tab Group ---
    tg = uitabgroup(fig, 'Position', [20 120 400 570]);
    tab_arm = uitab(tg, 'Title', '🦾 Arm'); tab_lift = uitab(tg, 'Title', '🏗️ Lift');
    tab_mobile = uitab(tg, 'Title', '🏎️ Mobile'); tab_power = uitab(tg, 'Title', '🔋 Power'); tab_bolt = uitab(tg, 'Title', '🔩 Bolt');

    % --- Panel Builder with GUARANTEED Descriptions ---
    function [p, slds] = create_pnl(tab, title, desc, sld_labels, sld_hints, sld_limits, sld_values)
        p = uipanel(tab, 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color, 'Position', [0 0 400 540], 'Title', title);
        uilabel(p, 'Text', desc, 'Position', [10 490 380 22], 'FontColor', [0.6 0.9 0.6], 'FontAngle', 'italic');
        
        slds = [];
        y_pos = [410, 310, 210, 110];
        for i = 1:4
            % Label (White)
            uilabel(p, 'Text', sld_labels{i}, 'Position', [10 y_pos(i), 250, 22], 'FontColor', 'w', 'FontWeight', 'bold');
            % Hint (Gray)
            uilabel(p, 'Text', sld_hints{i}, 'Position', [20 y_pos(i)-15, 300, 15], 'FontColor', hint_color, 'FontSize', 10);
            % Slider
            s = uislider(p, 'Limits', sld_limits(i,:), 'Value', sld_values(i), 'Position', [30 y_pos(i)-30, 300, 3], 'FontColor', 'w');
            slds = [slds, s];
        end
    end

    % 1. Arm
    [p_arm, s_arm] = create_pnl(tab_arm, 'Robot Arm', 'アームの旋回トルクと自重を計算', ...
        {'1. Payload [kg]', '2. Length [mm]', '3. Radius [mm]', '4. Budget [JPY]'}, ...
        {'→ 持ち上げたい荷物の重さ', '→ アームの回転半径', '→ 棒の太さ(自重に影響)', '→ 予算上限'}, ...
        [0.1 10; 50 1000; 2 50; 1000 50000], [2, 300, 10, 15000]);

    % 2. Lift
    [p_lift, s_lift] = create_pnl(tab_lift, 'Lifting Stage', '垂直昇降の巻上トルクを計算', ...
        {'1. Payload [kg]', '2. Pulley Rad [mm]', '3. (Reserved)', '4. Budget [JPY]'}, ...
        {'→ 垂直に持ち上げる荷物の重さ', '→ 巻上プーリーの半径', '→ 予備パラメータ', '→ 予算上限'}, ...
        [0.1 50; 10 100; 0 1; 1000 50000], [5, 30, 0, 15000]);

    % 3. Mobile
    [p_mob, s_mob] = create_pnl(tab_mobile, 'Mobile Base', '走行駆動力と斜面摩擦を計算', ...
        {'1. Weight [kg]', '2. Wheel Rad [mm]', '3. Incline [deg]', '4. Budget [JPY]'}, ...
        {'→ ロボット全体の総重量', '→ 駆動輪の半径', '→ 登坂する坂の角度', '→ 予算上限'}, ...
        [1 100; 20 200; 0 45; 1000 50000], [20, 50, 15, 15000]);

    % 4. Power
    [p_pow, s_pow] = create_pnl(tab_power, 'Power System', '消費電力からバッテリーを選定', ...
        {'1. Current [A]', '2. Time [h]', '3. Voltage [V]', '4. Budget [JPY]'}, ...
        {'→ 平均消費電流', '→ 必要な稼働時間', '→ システム電圧', '→ 予算上限'}, ...
        [0.1 20; 0.5 24; 5 24; 1000 50000], [2, 3, 11.1, 15000]);

    % 5. Bolt
    [p_bolt, s_bolt] = create_pnl(tab_bolt, 'Bolt & Joint', 'せん断荷重からネジを選定', ...
        {'1. Load [kg]', '2. Count', '3. (Reserved)', '4. Budget [JPY]'}, ...
        {'→ 結合部にかかる総重量', '→ 使用するネジの本数', '→ 予備パラメータ', '→ 予算上限'}, ...
        [10 1000; 1 16; 0 1; 100 5000], [200, 4, 0, 1000]);

    ctrls = struct('Arm', s_arm, 'Lift', s_lift, 'Mobile', s_mob, 'Power', s_pow, 'Bolt', s_bolt);

    % --- Analysis & 3D ---
    p_ana = uipanel(fig, 'Title', 'AI Analysis', 'Position', [435 120 340 570], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    lbl_status = uilabel(p_ana, 'Text', 'Best: ---', 'FontSize', 16, 'FontWeight', 'bold', 'Position', [20 510 300 40], 'FontColor', [0.2 0.8 1.0]);
    lbl_details = uilabel(p_ana, 'Text', 'Waiting...', 'FontSize', 11, 'Position', [20 480 300 30], 'FontColor', [0.7 0.7 0.7]);
    ax_bar = uiaxes(p_ana, 'Position', [20 20 300 450], 'Color', bg_color, 'XColor', 'w', 'YColor', 'w');

    p_3d = uipanel(fig, 'Title', 'Live 3D View', 'Position', [790 120 480 570], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    ax_3d = uiaxes(p_3d, 'Position', [10 10 460 530], 'Color', [0 0 0], 'XColor', 'none', 'YColor', 'none');

    btn_run = uibutton(fig, 'push', 'Text', '🚀 GENERATE OMNIPOTENT CERTIFICATE', 'FontSize', 16, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.1 0.6 0.3], 'FontColor', 'white', 'Position', [100 25 1100 80]);

    % --- Master Sync Engine ---
    function update_ui(~, ~)
        try
            mode = tg.SelectedTab.Title(5:end);
            c = ctrls.(mode);
            inputs = [c(1).Value, c(2).Value, c(3).Value, c(4).Value];
            
            [req_v, comp, catalog, b_idx, m_name, m_unit] = AMD_Logic(inputs, mode, project_root);
            
            lbl_status.Text = ['👑 Selected: ', char(comp.PartName)];
            lbl_details.Text = sprintf('Req. %s: %.2f %s | Budget: %d JPY', m_name, req_v, m_unit, round(inputs(4)));
            
            % Update Visuals
            AMD_Visuals(ax_bar, ax_3d, catalog, b_idx, mode, inputs, m_name, m_unit);
        catch, end
    end

    btn_run.ButtonPushedFcn = @(btn, event) run_full();
    function run_full()
        mode = tg.SelectedTab.Title(5:end); c = ctrls.(mode);
        inputs = [c(1).Value, c(2).Value, c(3).Value, c(4).Value];
        [req_v, comp, catalog, b_idx, m_name, m_unit] = AMD_Logic(inputs, mode, project_root);
        
        % Logic for Arm weight
        if strcmp(mode, 'Arm'), arm_m = (pi * inputs(3)^2 * inputs(2)) * 0.0000027; else, arm_m = 0; end
        
        % Final Restoration Calls
        AMD_Report(inputs(1), inputs(2), inputs(3), inputs(4), 1.5, mode, comp, arm_m, req_v, catalog, b_idx, output_dir);
        AMD_Voice(mode, comp.PartName);
    end

    btn_git.ButtonPushedFcn = @(btn, event) system(sprintf('cd "%s" && git add . && git commit -m "Final Gold v16.0" && git push', project_root));

    % Listeners
    f = fieldnames(ctrls);
    for idx = 1:length(f), for s = ctrls.(f{idx}), addlistener(s, 'ValueChanged', @update_ui); end; end
    addlistener(tg, 'SelectionChanged', @update_ui);
    update_ui();
end
