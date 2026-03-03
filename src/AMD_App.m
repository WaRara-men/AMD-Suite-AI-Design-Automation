% ==========================================
% Algo-Mech Designer (AMD) Suite - App v23.1
% USER-FRIENDLY EDITION: Explanatory UI Labels
% ==========================================

function AMD_App()
    src_dir = fileparts(mfilename('fullpath')); project_root = fileparts(src_dir);
    data_path = fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv');
    output_dir = fullfile(project_root, 'out'); addpath(src_dir);

    bg_color = [0.05 0.05 0.08]; panel_bg = [0.1 0.1 0.15]; txt_color = [0.98 0.98 0.98];
    fig = uifigure('Name', 'AMD Suite v23.1 - User-Centric Robotics Suite', 'Position', [100 100 1300 750], 'Color', bg_color);
    current_lang = 'JP';

    % --- Header ---
    uilabel(fig, 'Text', '💎 AMD SUITE v23.1: GUIDED DESIGN CENTER', 'FontSize', 22, 'FontWeight', 'bold', 'Position', [20 705 600 35], 'FontColor', [0.3 0.8 1.0]);

    % --- 🌟 Tab Group ---
    tg = uitabgroup(fig, 'Position', [20 120 350 570]);
    tab_arm = uitab(tg, 'Title', '🦾 Arm', 'Tag', 'Arm'); tab_lift = uitab(tg, 'Title', '🏗️ Lift', 'Tag', 'Lift');
    tab_mobile = uitab(tg, 'Title', '🏎️ Mobile', 'Tag', 'Mobile'); tab_power = uitab(tg, 'Title', '🔋 Power', 'Tag', 'Power'); tab_bolt = uitab(tg, 'Title', '🔩 Bolt', 'Tag', 'Bolt');

    % Slider Storage
    ctrls = struct();

    % 🎯 IMPROVED Panel Builder with Sub-Descriptions
    function s = build_guided_pnl(tab, title, desc, s_labels, s_guides, s_limits, s_defaults)
        p = uipanel(tab, 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color, 'Position', [0 0 350 540], 'Title', title);
        uilabel(p, 'Text', desc, 'Position', [10 495 330 22], 'FontColor', [0.6 0.9 0.6], 'FontAngle', 'italic');
        s = []; y = [410, 310, 210, 110];
        for i = 1:4
            % Label
            uilabel(p, 'Text', s_labels{i}, 'Position', [10 y(i)+5, 250, 22], 'FontColor', 'w', 'FontWeight', 'bold');
            % Guide/Explanation (NEW!)
            uilabel(p, 'Text', s_guides{i}, 'Position', [20 y(i)-15, 300, 15], 'FontColor', [0.7 0.7 0.7], 'FontSize', 9);
            % Slider
            sl = uislider(p, 'Limits', s_limits(i,:), 'Value', s_defaults(i), 'Position', [30 y(i)-30, 280, 3], 'FontColor', 'w');
            s = [s, sl];
        end
    end

    ctrls.Arm = build_guided_pnl(tab_arm, 'Arm', 'アームトルク計算', ...
        {'Payload [kg]', 'Length [mm]', 'Radius [mm]', 'Budget [JPY]'}, ...
        {'→ 荷物の重さ(重力負荷)', '→ 支点から荷物までの距離', '→ アームの太さ(自重計算用)', '→ お財布の限界'}, ...
        [0.1 10; 50 1000; 2 50; 1000 50000], [2, 300, 10, 15000]);

    ctrls.Lift = build_guided_pnl(tab_lift, 'Lift', '昇降機計算', ...
        {'Payload [kg]', 'Pulley Rad [mm]', '---', 'Budget [JPY]'}, ...
        {'→ 垂直に引き上げる荷物の重さ', '→ 巻上プーリーの半径', '→ (予約済み)', '→ 予算上限'}, ...
        [0.1 50; 10 100; 0 1; 1000 50000], [5, 30, 0, 15000]);

    ctrls.Mobile = build_guided_pnl(tab_mobile, 'Mobile', '走行駆動力計算', ...
        {'Weight [kg]', 'Wheel Rad [mm]', 'Incline [deg]', 'Budget [JPY]'}, ...
        {'→ ロボット全体の総重量', '→ タイヤの半径', '→ 登る坂の角度', '→ 予算上限'}, ...
        [1 100; 20 200; 0 45; 1000 50000], [20, 50, 15, 15000]);

    ctrls.Power = build_guided_pnl(tab_power, 'Power', 'バッテリー選定', ...
        {'Current [A]', 'Time [h]', 'Voltage [V]', 'Budget [JPY]'}, ...
        {'→ 平均的な消費電流', '→ 稼働させたい時間', '→ システムの動作電圧', '→ 予算上限'}, ...
        [0.1 20; 0.5 24; 5 24; 1000 50000], [2, 3, 11.1, 15000]);

    ctrls.Bolt = build_guided_pnl(tab_bolt, 'Bolt', 'ネジ強度計算', ...
        {'Shear Load [kg]', 'Bolt Count [本]', '---', 'Budget [JPY]'}, ...
        {'→ ネジにかかる総荷重', '→ 荷重を分担するネジの本数', '→ (予約済み)', '→ 予算上限'}, ...
        [10 1000; 1 16; 0 1; 100 5000], [200, 4, 0, 1000]);

    % Results & 3D
    p_ana = uipanel(fig, 'Title', 'AI Result Dashboard', 'Position', [385 120 340 570], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    lbl_status = uilabel(p_ana, 'Text', 'Best: ---', 'FontSize', 16, 'FontWeight', 'bold', 'Position', [20 510 300 40], 'FontColor', [0.2 0.8 1.0]);
    ax_bar = uiaxes(p_ana, 'Position', [20 20 300 450], 'Color', bg_color, 'XColor', 'w', 'YColor', 'w');

    p_3d = uipanel(fig, 'Title', 'Live 3D View', 'Position', [740 120 480 570], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    ax_3d = uiaxes(p_3d, 'Position', [10 10 460 530], 'Color', [0 0 0], 'XColor', 'none', 'YColor', 'none');

    btn_run = uibutton(fig, 'push', 'Text', '🚀 GENERATE GUIDED OFFICIAL CERTIFICATE', 'FontSize', 16, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.1 0.6 0.3], 'FontColor', 'white', 'Position', [100 25 1100 80]);

    function sync(~, ~)
        try
            mode = tg.SelectedTab.Tag; c = ctrls.(mode);
            inputs = [c(1).Value, c(2).Value, c(3).Value, c(4).Value];
            [req_v, comp, catalog, b_idx, m_name, m_unit, desc_jp] = AMD_Logic(inputs, mode, project_root);
            lbl_status.Text = ['👑 Selected: ', char(comp.PartName)];
            AMD_Visuals(ax_bar, ax_3d, catalog, b_idx, mode, inputs, m_name, m_unit);
        catch, end
    end

    btn_run.ButtonPushedFcn = @(btn, event) run_full();
    function run_full()
        mode = tg.SelectedTab.Tag; c = ctrls.(mode);
        inputs = [c(1).Value, c(2).Value, c(3).Value, c(4).Value];
        [req_v, comp, catalog, b_idx, m_name, m_unit, desc_jp] = AMD_Logic(inputs, mode, project_root);
        AMD_Report(inputs(1), inputs(2), inputs(3), inputs(4), 1.5, mode, comp, req_v, m_name, m_unit, desc_jp, catalog, b_idx, output_dir, ax_3d);
        AMD_Voice(mode, comp.PartName, req_v, m_unit);
    end

    fnames = fieldnames(ctrls);
    for idx = 1:length(fnames), for s = ctrls.(fnames{idx}), addlistener(s, 'ValueChanged', @sync); end; end
    addlistener(tg, 'SelectionChanged', @sync);
    sync(); 
end
