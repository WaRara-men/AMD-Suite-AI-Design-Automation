% ==========================================
% Algo-Mech Designer (AMD) Suite - App v23.5 (UI/UX Enhanced)
% VISUALLY POLISHED & RESPONSIVE EDITION
% ==========================================

function fig = AMD_App()
    % Setup paths and directories
    src_dir = fileparts(mfilename('fullpath')); 
    project_root = fileparts(src_dir);
    output_dir = fullfile(project_root, 'out'); 
    addpath(src_dir);

    % Color Palette (Deep Space Theme)
    bg_color = [0.05 0.05 0.08];
    panel_bg = [0.1 0.1 0.15];
    accent_color = [0.0 0.8 1.0]; % Cyan
    success_color = [0.2 0.8 0.4]; % Emerald
    text_color = [0.98 0.98 0.98];
    dim_text = [0.7 0.7 0.7];

    % Figure Initialization
    fig = uifigure('Name', 'AMD Suite v23.5 - Advanced Robot Design Automation', ...
        'Position', [100 100 1300 800], 'Color', bg_color);
    
    % Main Layout
    g_main = uigridlayout(fig, [3, 1]);
    g_main.RowHeight = {60, '1x', 40};
    g_main.Padding = [20 20 20 10];
    g_main.RowSpacing = 15;

    % --- 1. Header ---
    p_head = uipanel(g_main, 'BackgroundColor', bg_color, 'BorderType', 'none');
    uilabel(p_head, 'Text', '💎 AMD SUITE v23.5', 'FontSize', 28, 'FontWeight', 'bold', ...
        'Position', [0 15 400 40], 'FontColor', accent_color);
    uilabel(p_head, 'Text', 'PROFESSIONAL ENGINEERING CENTER', 'FontSize', 12, ...
        'Position', [45 0 300 20], 'FontColor', dim_text);

    % Language Toggle (Placeholder for real implementation)
    btn_lang = uibutton(p_head, 'push', 'Text', '🌐 EN / JP', 'Position', [1150 15 100 30], ...
        'BackgroundColor', panel_bg, 'FontColor', text_color);

    % --- 2. Body ---
    g_body = uigridlayout(g_main, [1, 3]);
    g_body.ColumnWidth = {380, 360, '1x'};
    g_body.ColumnSpacing = 20;
    g_body.Padding = [0 0 0 0];

    % A. Control Panel
    p_ctrl = uipanel(g_body, 'Title', 'DESIGN PARAMETERS', 'BackgroundColor', panel_bg, ...
        'ForegroundColor', text_color, 'FontWeight', 'bold', 'FontSize', 14);
    g_ctrl = uigridlayout(p_ctrl, [2, 1]);
    g_ctrl.RowHeight = {'1x', 100};
    
    tg = uitabgroup(g_ctrl);
    tg.Layout.Row = 1;
    tg.Layout.Column = 1;
    tab_arm = uitab(tg, 'Title', '🦾 Arm', 'Tag', 'Arm');
    tab_lift = uitab(tg, 'Title', '🏗️ Lift', 'Tag', 'Lift');
    tab_mobile = uitab(tg, 'Title', '🏎️ Mobile', 'Tag', 'Mobile');
    tab_power = uitab(tg, 'Title', '🔋 Power', 'Tag', 'Power');
    tab_bolt = uitab(tg, 'Title', '🔩 Bolt', 'Tag', 'Bolt');

    ctrls = struct();
    function s = build_pnl(tab, title, desc, s_labels, s_guides, s_limits, s_defaults)
        p = uipanel(tab, 'BackgroundColor', panel_bg, 'BorderType', 'none');
        g_sub = uigridlayout(p, [9, 1]);
        g_sub.RowHeight = {25, 20, 35, 20, 35, 20, 35, 20, 35};
        g_sub.RowSpacing = 5;
        
        uilabel(g_sub, 'Text', desc, 'FontColor', [0.6 0.9 0.6], 'FontAngle', 'italic', 'FontSize', 11);
        
        s = [];
        for i = 1:4
            % Label & Info
            uilabel(g_sub, 'Text', s_labels{i}, 'FontColor', 'w', 'FontWeight', 'bold');
            
            % Slider & Numeric Field Group
            g_input = uigridlayout(g_sub, [1, 2]);
            g_input.ColumnWidth = {'1x', 60};
            g_input.Padding = [0 0 0 0];
            
            sl = uislider(g_input, 'Limits', s_limits(i,:), 'Value', s_defaults(i), 'FontColor', 'w');
            nf = uieditfield(g_input, 'numeric', 'Value', s_defaults(i), 'Limits', s_limits(i,:), ...
                'BackgroundColor', [0.15 0.15 0.2], 'FontColor', 'w');
            
            % Sync Slider and Edit Field
            sl.ValueChangedFcn = @(src, event) update_nf(nf, src.Value);
            nf.ValueChangedFcn = @(src, event) update_sl(sl, src.Value);
            
            uilabel(g_sub, 'Text', ['   → ', s_guides{i}], 'FontColor', dim_text, 'FontSize', 9);
            s = [s, sl];
        end
    end

    function update_nf(nf, val), nf.Value = val; sync(); end
    function update_sl(sl, val), sl.Value = val; sync(); end

    ctrls.Arm = build_pnl(tab_arm, 'Arm Analysis', 'アームの旋回トルクと自重を計算', ...
        {'Payload [kg]', 'Length [mm]', 'Radius [mm]', 'Budget [JPY]'}, ...
        {'荷物の重さ', '腕の長さ', '腕の太さ(自重に影響)', '予算上限'}, ...
        [0.1 10; 50 1000; 2 50; 1000 50000], [2, 300, 10, 15000]);
    ctrls.Lift = build_pnl(tab_lift, 'Lift Analysis', '垂直リフトの巻上テンション解析', ...
        {'Payload [kg]', 'Pulley Rad [mm]', 'Efficiency [%]', 'Budget [JPY]'}, ...
        {'吊り上げる重さ', '滑車の半径', '伝達効率(通常80-90)', '予算上限'}, ...
        [0.1 50; 10 100; 10 100; 1000 50000], [5, 30, 90, 15000]);
    ctrls.Mobile = build_pnl(tab_mobile, 'Mobile Analysis', '傾斜面における走行駆動力解析', ...
        {'Weight [kg]', 'Wheel Rad [mm]', 'Incline [deg]', 'Budget [JPY]'}, ...
        {'ロボット総重量', 'タイヤの半径', '登る坂の角度', '予算上限'}, ...
        [1 100; 20 200; 0 45; 1000 50000], [20, 50, 15, 15000]);
    ctrls.Power = build_pnl(tab_power, 'Power Analysis', 'バッテリー消費電力シミュレーション', ...
        {'Current [A]', 'Time [h]', 'Voltage [V]', 'Budget [JPY]'}, ...
        {'平均消費電流', '稼働させたい時間', 'システム電圧', '予算上限'}, ...
        [0.1 20; 0.5 24; 5 24; 1000 50000], [2, 3, 11.1, 15000]);
    ctrls.Bolt = build_pnl(tab_bolt, 'Bolt Analysis', 'ボルト結合部の破断強度シミュレーション', ...
        {'Load [kg]', 'Bolt Count [本]', 'Safety Factor', 'Budget [JPY]'}, ...
        {'結合部の荷重', 'ネジの本数', 'ネジ専用の安全率', '予算上限'}, ...
        [10 1000; 1 16; 1.0 10.0; 100 5000], [200, 4, 2.5, 1000]);

    % Generate Button
    btn_run = uibutton(g_ctrl, 'push', 'Text', '🚀 GENERATE CERTIFICATE', 'FontSize', 16, 'FontWeight', 'bold', ...
        'BackgroundColor', success_color, 'FontColor', 'white');
    btn_run.Layout.Row = 2;

    % B. AI Result Panel
    p_ana = uipanel(g_body, 'Title', 'AI INSIGHTS', 'BackgroundColor', panel_bg, ...
        'ForegroundColor', text_color, 'FontWeight', 'bold', 'FontSize', 14);
    g_ana = uigridlayout(p_ana, [2, 1]);
    g_ana.RowHeight = {180, '1x'};
    
    p_info = uipanel(g_ana, 'BackgroundColor', [0.12 0.12 0.18], 'BorderType', 'none');
    p_info.Layout.Row = 1;
    lbl_part = uilabel(p_info, 'Text', 'Selected: ---', 'FontSize', 16, 'FontWeight', 'bold', ...
        'Position', [15 140 300 30], 'FontColor', accent_color);
    lbl_price = uilabel(p_info, 'Text', 'Price: ---', 'Position', [15 110 300 20], 'FontColor', 'w');
    lbl_spec = uilabel(p_info, 'Text', 'Spec: ---', 'Position', [15 90 300 20], 'FontColor', 'w');
    lbl_weight = uilabel(p_info, 'Text', 'Weight: ---', 'Position', [15 70 300 20], 'FontColor', 'w');
    
    lbl_status_msg = uilabel(p_info, 'Text', 'AI is ready to analyze...', 'FontSize', 11, ...
        'Position', [15 10 300 20], 'FontColor', [0.5 0.5 0.5]);

    ax_bar = uiaxes(g_ana, 'Color', bg_color, 'XColor', 'w', 'YColor', 'w', 'FontSize', 8);
    ax_bar.Layout.Row = 2;
    title(ax_bar, 'Catalog Comparison', 'Color', 'w');

    % C. Live 3D View
    p_3d = uipanel(g_body, 'Title', 'REAL-TIME 3D VIEW', 'BackgroundColor', panel_bg, ...
        'ForegroundColor', text_color, 'FontWeight', 'bold', 'FontSize', 14);
    ax_3d = uiaxes(p_3d, 'Position', [10 10 440 680], 'Color', [0 0 0], 'XColor', 'none', 'YColor', 'none');
    view(ax_3d, 3); axis(ax_3d, 'equal'); grid(ax_3d, 'on');

    % --- 3. Footer / Status Bar ---
    p_foot = uipanel(g_main, 'BackgroundColor', [0.03 0.03 0.05], 'BorderType', 'none');
    lbl_footer = uilabel(p_foot, 'Text', 'SYSTEM READY | AMD Suite v23.5 Professional Edition', ...
        'Position', [10 10 600 20], 'FontColor', [0.4 0.4 0.4], 'FontSize', 10);
    uilabel(p_foot, 'Text', '© 2026 AMD Engineering Team', 'Position', [1100 10 200 20], ...
        'FontColor', [0.4 0.4 0.4], 'FontSize', 10, 'HorizontalAlignment', 'right');

    % --- Core Logic Functions ---
    function sync(~, ~)
        try
            mode = tg.SelectedTab.Tag; c = ctrls.(mode);
            inputs = [c(1).Value, c(2).Value, c(3).Value, c(4).Value];
            [req_v, comp, catalog, b_idx, m_name, m_unit, ~] = AMD_Logic(inputs, mode, project_root);
            
            % Update Info
            lbl_part.Text = ['👑 Selected: ', char(comp.PartName)];
            lbl_price.Text = sprintf('💰 Price: %d JPY', round(comp.Price_JPY));
            lbl_spec.Text = sprintf('📊 Required: %.2f %s (Spec: %.2f %s)', req_v, m_unit, comp.(m_name), m_unit);
            lbl_weight.Text = sprintf('⚖️ Weight: %.3f kg', comp.Weight_kg);
            lbl_status_msg.Text = 'Optimal component found.';
            lbl_status_msg.FontColor = success_color;
            
            % Update Visuals
            AMD_Visuals(ax_bar, ax_3d, catalog, b_idx, mode, inputs, m_name, m_unit);
            
            lbl_footer.Text = sprintf('MODE: %s | COMPONENT: %s', upper(mode), char(comp.PartName));
        catch ME
            lbl_status_msg.Text = 'Adjust parameters for analysis.';
            lbl_status_msg.FontColor = [0.8 0.4 0.4];
        end
    end

    btn_run.ButtonPushedFcn = @(btn, event) run_full();
    function run_full()
        btn_run.Enable = 'off';
        btn_run.Text = '⏳ GENERATING...';
        drawnow;
        
        try
            mode = tg.SelectedTab.Tag; c = ctrls.(mode);
            inputs = [c(1).Value, c(2).Value, c(3).Value, c(4).Value];
            [req_v, comp, catalog, b_idx, m_name, m_unit, desc_jp] = AMD_Logic(inputs, mode, project_root);
            
            % Generate Report
            AMD_Report(inputs(1), inputs(2), inputs(3), inputs(4), 1.5, mode, comp, req_v, m_name, m_unit, desc_jp, catalog, b_idx, output_dir, ax_3d);
            
            % Voice Feedback
            AMD_Voice(mode, comp.PartName, req_v, m_unit);
            
            lbl_status_msg.Text = 'Report exported successfully.';
        catch ME
            lbl_status_msg.Text = ['Error: ', ME.message];
        end
        
        btn_run.Enable = 'on';
        btn_run.Text = '🚀 GENERATE CERTIFICATE';
    end

    % Event Listeners
    fnames = fieldnames(ctrls);
    for idx = 1:length(fnames)
        for s = ctrls.(fnames{idx})
            addlistener(s, 'ValueChanged', @sync); 
        end
    end
    addlistener(tg, 'SelectionChanged', @sync);
    
    % Initial Sync
    sync(); 
end
