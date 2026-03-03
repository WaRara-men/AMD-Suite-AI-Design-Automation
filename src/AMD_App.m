% ==========================================
% Algo-Mech Designer (AMD) Suite - App v23.2
% USER-FRIENDLY EDITION: Fixed 3rd Parameters & Compact Voice
% ==========================================

function AMD_App()
    src_dir = fileparts(mfilename('fullpath')); project_root = fileparts(src_dir);
    data_path = fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv');
    output_dir = fullfile(project_root, 'out'); addpath(src_dir);

    bg_color = [0.05 0.05 0.08]; panel_bg = [0.1 0.1 0.15]; txt_color = [0.98 0.98 0.98];
    fig = uifigure('Name', 'AMD Suite v23.2 - Professional Robot Center', 'Position', [100 100 1300 750], 'Color', bg_color);
    current_lang = 'JP';

    uilabel(fig, 'Text', '💎 AMD SUITE v23.2: PROFESSIONAL ENGINEERING CENTER', 'FontSize', 22, 'FontWeight', 'bold', 'Position', [20 705 700 35], 'FontColor', [0.3 0.8 1.0]);

    tg = uitabgroup(fig, 'Position', [20 120 350 570]);
    tab_arm = uitab(tg, 'Title', '🦾 Arm', 'Tag', 'Arm'); tab_lift = uitab(tg, 'Title', '🏗️ Lift', 'Tag', 'Lift');
    tab_mobile = uitab(tg, 'Title', '🏎️ Mobile', 'Tag', 'Mobile'); tab_power = uitab(tg, 'Title', '🔋 Power', 'Tag', 'Power'); tab_bolt = uitab(tg, 'Title', '🔩 Bolt', 'Tag', 'Bolt');

    ctrls = struct();
    function s = build_pnl(tab, title, desc, s_labels, s_guides, s_limits, s_defaults)
        p = uipanel(tab, 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color, 'Position', [0 0 350 540], 'Title', title);
        uilabel(p, 'Text', desc, 'Position', [10 495 330 22], 'FontColor', [0.6 0.9 0.6], 'FontAngle', 'italic');
        s = []; y = [410, 310, 210, 110];
        for i = 1:4
            uilabel(p, 'Text', s_labels{i}, 'Position', [10 y(i)+5, 250, 22], 'FontColor', 'w', 'FontWeight', 'bold');
            uilabel(p, 'Text', s_guides{i}, 'Position', [20 y(i)-15, 300, 15], 'FontColor', [0.7 0.7 0.7], 'FontSize', 9);
            sl = uislider(p, 'Limits', s_limits(i,:), 'Value', s_defaults(i), 'Position', [30 y(i)-30, 280, 3], 'FontColor', 'w');
            s = [s, sl];
        end
    end

    ctrls.Arm = build_pnl(tab_arm, 'Arm Analysis', 'アームの旋回トルクと自重を計算', {'Payload [kg]', 'Length [mm]', 'Radius [mm]', 'Budget [JPY]'}, {'→ 荷物の重さ', '→ 腕の長さ', '→ 腕の太さ(自重に影響)', '→ 予算上限'}, [0.1 10; 50 1000; 2 50; 1000 50000], [2, 300, 10, 15000]);
    % 🌟 FIXED: Efficiency added
    ctrls.Lift = build_pnl(tab_lift, 'Lift Analysis', '垂直リフトの巻上テンション解析', {'Payload [kg]', 'Pulley Rad [mm]', 'Efficiency [%]', 'Budget [JPY]'}, {'→ 吊り上げる重さ', '→ 滑車の半径', '→ 滑車の伝達効率(通常80-90)', '→ 予算上限'}, [0.1 50; 10 100; 10 100; 1000 50000], [5, 30, 90, 15000]);
    ctrls.Mobile = build_pnl(tab_mobile, 'Mobile Analysis', '傾斜面における走行駆動力解析', {'Weight [kg]', 'Wheel Rad [mm]', 'Incline [deg]', 'Budget [JPY]'}, {'→ ロボット総重量', '→ タイヤの半径', '→ 登る坂の角度', '→ 予算上限'}, [1 100; 20 200; 0 45; 1000 50000], [20, 50, 15, 15000]);
    ctrls.Power = build_pnl(tab_power, 'Power Analysis', 'バッテリー消費電力シミュレーション', {'Current [A]', 'Time [h]', 'Voltage [V]', 'Budget [JPY]'}, {'→ 平均消費電流', '→ 稼働させたい時間', '→ システム電圧', '→ 予算上限'}, [0.1 20; 0.5 24; 5 24; 1000 50000], [2, 3, 11.1, 15000]);
    % 🌟 FIXED: Bolt Safety added
    ctrls.Bolt = build_pnl(tab_bolt, 'Bolt Analysis', 'ボルト結合部の破断強度シミュレーション', {'Load [kg]', 'Bolt Count [本]', 'Safety Factor', 'Budget [JPY]'}, {'→ 結合部の荷重', '→ ネジの本数', '→ ネジ専用の安全率(通常2.0-5.0)', '→ 予算上限'}, [10 1000; 1 16; 1.0 10.0; 100 5000], [200, 4, 2.5, 1000]);

    % Analysis & 3D (PROTECTED)
    p_ana = uipanel(fig, 'Title', 'AI Result', 'Position', [385 120 340 570], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    lbl_status = uilabel(p_ana, 'Text', 'Best: ---', 'FontSize', 16, 'FontWeight', 'bold', 'Position', [20 510 300 40], 'FontColor', [0.2 0.8 1.0]);
    ax_bar = uiaxes(p_ana, 'Position', [20 20 300 450], 'Color', bg_color, 'XColor', 'w', 'YColor', 'w');
    p_3d = uipanel(fig, 'Title', 'Live 3D View', 'Position', [740 120 480 570], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    ax_3d = uiaxes(p_3d, 'Position', [10 10 460 530], 'Color', [0 0 0], 'XColor', 'none', 'YColor', 'none');
    view(ax_3d, 3); axis(ax_3d, 'equal'); grid(ax_3d, 'on');

    btn_run = uibutton(fig, 'push', 'Text', '🚀 SELECT OPTIMAL PART & GENERATE CERTIFICATE', 'FontSize', 16, 'FontWeight', 'bold', ...
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
        % 🌟 COMPACT VOICE
        try NET.addAssembly('System.Speech'); speak = System.Speech.Synthesis.SpeechSynthesizer; 
            speak.Speak(sprintf('解析完了。最適解は%sです。詳細は証明書をご覧ください。', char(comp.PartName))); catch, end
    end

    fnames = fieldnames(ctrls);
    for idx = 1:length(fnames), for s = ctrls.(fnames{idx}), addlistener(s, 'ValueChanged', @sync); end; end
    addlistener(tg, 'SelectionChanged', @sync);
    sync(); 
end
