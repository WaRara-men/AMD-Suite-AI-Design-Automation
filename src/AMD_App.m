% ==========================================
% Algo-Mech Designer (AMD) Suite - App v17.0
% THE OMNIPOTENT ARCHITECT: Fixed & Synchronized
% ==========================================

function AMD_App()
    src_dir = fileparts(mfilename('fullpath')); project_root = fileparts(src_dir);
    data_dir = fullfile(project_root, 'data');
    output_dir = fullfile(project_root, 'out'); addpath(src_dir);

    bg_color = [0.05 0.05 0.08]; panel_bg = [0.1 0.1 0.15]; txt_color = [0.98 0.98 0.98];
    fig = uifigure('Name', 'AMD Suite v17.0 - OMNIPOTENT ARCHITECT', 'Position', [50 50 1350 750], 'Color', bg_color);
    current_lang = 'JP';

    % --- Header ---
    uilabel(fig, 'Text', '💎 AMD SUITE: OMNIPOTENT DESIGN CENTER', 'FontSize', 22, 'FontWeight', 'bold', 'Position', [20 705 600 35], 'FontColor', [0.3 0.8 1.0]);
    btn_git = uibutton(fig, 'push', 'Text', '🌐 SYNC TO GITHUB', 'Position', [1150 710 150 30], 'BackgroundColor', [0.2 0.2 0.2], 'FontColor', 'w');

    % --- 🌟 5-TAB GROUP ---
    tg = uitabgroup(fig, 'Position', [20 120 400 570]);
    tab_arm = uitab(tg, 'Title', '🦾 Arm'); tab_lift = uitab(tg, 'Title', '🏗️ Lift');
    tab_mobile = uitab(tg, 'Title', '🏎️ Mobile'); tab_power = uitab(tg, 'Title', '🔋 Power'); tab_bolt = uitab(tg, 'Title', '🔩 Bolt');

    % --- UI Component Storage ---
    ctrls = struct();

    % Helper to build tab panels
    function [p, s] = build_pnl(tab, title, desc, s_labels, s_hints, s_limits, s_defaults)
        p = uipanel(tab, 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color, 'Position', [0 0 400 540], 'Title', title);
        uilabel(p, 'Text', desc, 'Position', [10 495 380 22], 'FontColor', [0.6 0.9 0.6], 'FontAngle', 'italic');
        s = []; y = [410, 310, 210, 110];
        for i = 1:4
            uilabel(p, 'Text', s_labels{i}, 'Position', [10 y(i), 250, 22], 'FontColor', 'w', 'FontWeight', 'bold');
            uilabel(p, 'Text', s_hints{i}, 'Position', [20 y(i)-15, 300, 15], 'FontColor', [0.7 0.7 0.7], 'FontSize', 10);
            sl = uislider(p, 'Limits', s_limits(i,:), 'Value', s_defaults(i), 'Position', [30 y(i)-30, 300, 3], 'FontColor', 'w');
            s = [s, sl];
        end
    end

    % 1. Arm
    [~, ctrls.Arm] = build_pnl(tab_arm, 'Robot Arm', '旋回トルクと自重を計算', ...
        {'1. Payload [kg]', '2. Length [mm]', '3. Radius [mm]', '4. Budget [JPY]'}, ...
        {'→ 重さを指定', '→ アーム長を指定', '→ 棒の太さを指定', '→ 予算上限'}, ...
        [0.1 10; 50 1000; 2 50; 1000 50000], [2, 300, 10, 15000]);

    % 2. Lift
    [~, ctrls.Lift] = build_pnl(tab_lift, 'Lifting Stage', '垂直昇降の力を計算', ...
        {'1. Payload [kg]', '2. Pulley Rad [mm]', '3. (N/A)', '4. Budget [JPY]'}, ...
        {'→ 吊り上げる重さ', '→ 滑車の半径', '→ 予備', '→ 予算上限'}, ...
        [0.1 50; 10 100; 0 1; 1000 50000], [5, 30, 0, 15000]);

    % 3. Mobile
    [~, ctrls.Mobile] = build_pnl(tab_mobile, 'Mobile Base', '走行駆動力と斜面摩擦', ...
        {'1. Weight [kg]', '2. Wheel Rad [mm]', '3. Incline [deg]', '4. Budget [JPY]'}, ...
        {'→ 車体重量', '→ タイヤの半径', '→ 登る坂の角度', '→ 予算上限'}, ...
        [1 100; 20 200; 0 45; 1000 50000], [20, 50, 15, 15000]);

    % 4. Power
    [~, ctrls.Power] = build_pnl(tab_power, 'Power System', '消費電力からバッテリーを選定', ...
        {'1. Current [A]', '2. Time [h]', '3. Voltage [V]', '4. Budget [JPY]'}, ...
        {'→ 平均消費電流', '→ 稼働時間', '→ システム電圧', '→ 予算上限'}, ...
        [0.1 20; 0.5 24; 5 24; 1000 50000], [2, 3, 11.1, 15000]);

    % 5. Bolt
    [~, ctrls.Bolt] = build_pnl(tab_bolt, 'Bolt & Joint', 'せん断荷重からネジを選定', ...
        {'1. Load [kg]', '2. Count', '3. (N/A)', '4. Budget [JPY]'}, ...
        {'→ 結合部の総荷重', '→ ネジの本数', '→ 予備', '→ 予算上限'}, ...
        [10 1000; 1 16; 0 1; 100 5000], [200, 4, 0, 1000]);

    % Analysis & 3D (PROTECTED)
    pnl_ana = uipanel(fig, 'Title', 'AI Result Dashboard', 'Position', [435 120 380 570], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    lbl_status = uilabel(pnl_ana, 'Text', 'Selected: ---', 'FontSize', 16, 'FontWeight', 'bold', 'Position', [20 510 340 40], 'FontColor', [0.2 0.8 1.0]);
    ax_bar = uiaxes(pnl_ana, 'Position', [20 20 340 450], 'Color', bg_color, 'XColor', 'w', 'YColor', 'w');

    pnl_3d = uipanel(fig, 'Title', 'Live 3D Preview', 'Position', [830 120 480 570], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    ax_3d = uiaxes(pnl_3d, 'Position', [10 10 460 530], 'Color', [0 0 0], 'XColor', 'none', 'YColor', 'none');

    btn_run = uibutton(fig, 'push', 'Text', '🚀 GENERATE OMNIPOTENT CERTIFICATE', 'FontSize', 16, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.1 0.6 0.3], 'FontColor', 'white', 'Position', [100 25 1100 80]);

    % --- 🎯 Master Sync Logic ---
    function update_ui(~, ~)
        try
            mode = tg.SelectedTab.Title(5:end);
            c = ctrls.(mode);
            inputs = [c(1).Value, c(2).Value, c(3).Value, c(4).Value];
            
            [req_v, comp, catalog, b_idx, m_name, m_unit] = AMD_Logic(inputs, mode, project_root);
            lbl_status.Text = ['👑 Winner: ', char(comp.PartName)];
            
            % Update Visuals
            AMD_Visuals(ax_bar, ax_3d, catalog, b_idx, mode, inputs, m_name, m_unit);
        catch, end
    end

    btn_run.ButtonPushedFcn = @(btn, event) run_full();
    function run_full()
        mode = tg.SelectedTab.Title(5:end); c = ctrls.(mode);
        inputs = [c(1).Value, c(2).Value, c(3).Value, c(4).Value];
        [req_v, comp, catalog, b_idx, m_name, m_unit] = AMD_Logic(inputs, mode, project_root);
        
        if strcmp(mode, 'Arm'), arm_m = (pi * inputs(3)^2 * inputs(2)) * 0.0000027; else, arm_m = 0; end
        
        AMD_Report(mode, comp, req_v, m_name, m_unit, catalog, b_idx, output_dir);
        AMD_Voice(mode, comp.PartName);
    end

    btn_git.ButtonPushedFcn = @(btn, event) system(sprintf('cd "%s" && git add . && git commit -m "Final v17.0" && git push', project_root));

    % Listeners
    fnames = fieldnames(ctrls);
    for j=1:length(fnames), for s=ctrls.(fnames{j}), addlistener(s, 'ValueChanged', @update_ui); end; end
    addlistener(tg, 'SelectionChanged', @update_ui);
    update_ui();
end
