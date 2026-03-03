% ==========================================
% Algo-Mech Designer (AMD) Suite - App v15.1
% TRUE SYNC EDITION: Tab-Switch Driven Refresh
% ==========================================

function AMD_App()
    src_dir = fileparts(mfilename('fullpath')); project_root = fileparts(src_dir);
    data_path = fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv');
    output_dir = fullfile(project_root, 'out'); addpath(src_dir);

    bg_color = [0.05 0.05 0.08]; panel_bg = [0.1 0.1 0.15]; txt_color = [0.95 0.95 0.95];
    fig = uifigure('Name', 'AMD Suite v15.1 - Synchronized Design Center', 'Position', [100 100 1300 750], 'Color', bg_color);

    % --- Header ---
    uilabel(fig, 'Text', '💎 AMD SUITE: SYNCHRONIZED DESIGN CENTER', 'FontSize', 22, 'FontWeight', 'bold', 'Position', [20 705 600 35], 'FontColor', [0.3 0.8 1.0]);

    % --- 🌟 5-TAB GROUP ---
    tg = uitabgroup(fig, 'Position', [20 120 350 570]);
    tab_arm = uitab(tg, 'Title', '🦾 Arm'); tab_lift = uitab(tg, 'Title', '🏗️ Lift');
    tab_mobile = uitab(tg, 'Title', '🏎️ Mobile'); tab_power = uitab(tg, 'Title', '🔋 Power'); tab_bolt = uitab(tg, 'Title', '🔩 Bolt');

    % --- UI Component Storage ---
    % 構造体にスライダーを格納し、タブ切り替え時にアクセス可能にします
    ctrls = struct();

    % 1. Arm
    p_arm = uipanel(tab_arm, 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color, 'Position', [0 0 350 540], 'Title', 'Arm Specs');
    ctrls.Arm = [uislider(p_arm, 'Limits', [0.1 10], 'Value', 2, 'Position', [30 430 280 3]), ...
                 uislider(p_arm, 'Limits', [50 1000], 'Value', 300, 'Position', [30 350 280 3]), ...
                 uislider(p_arm, 'Limits', [2 50], 'Value', 10, 'Position', [30 270 280 3]), ...
                 uislider(p_arm, 'Limits', [1000 50000], 'Value', 15000, 'Position', [30 190 280 3])];
    
    % 2. Lift
    p_lift = uipanel(tab_lift, 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color, 'Position', [0 0 350 540], 'Title', 'Lift Specs');
    ctrls.Lift = [uislider(p_lift, 'Limits', [1 50], 'Value', 5, 'Position', [30 430 280 3]), ...
                  uislider(p_lift, 'Limits', [10 100], 'Value', 30, 'Position', [30 350 280 3]), ...
                  uislider(p_lift, 'Limits', [0 1], 'Value', 0, 'Position', [30 270 280 3], 'Visible', 'off'), ...
                  uislider(p_lift, 'Limits', [1000 50000], 'Value', 15000, 'Position', [30 190 280 3])];

    % 3. Mobile
    p_mob = uipanel(tab_mobile, 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color, 'Position', [0 0 350 540], 'Title', 'Mobile Specs');
    ctrls.Mobile = [uislider(p_mob, 'Limits', [1 100], 'Value', 20, 'Position', [30 430 280 3]), ...
                    uislider(p_mob, 'Limits', [20 200], 'Value', 50, 'Position', [30 350 280 3]), ...
                    uislider(p_mob, 'Limits', [0 45], 'Value', 15, 'Position', [30 270 280 3]), ...
                    uislider(p_mob, 'Limits', [1000 50000], 'Value', 15000, 'Position', [30 190 280 3])];

    % 4. Power
    p_pow = uipanel(tab_power, 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color, 'Position', [0 0 350 540], 'Title', 'Power Specs');
    ctrls.Power = [uislider(p_pow, 'Limits', [0.1 20], 'Value', 2.0, 'Position', [30 430 280 3]), ...
                   uislider(p_pow, 'Limits', [0.5 24], 'Value', 3.0, 'Position', [30 350 280 3]), ...
                   uislider(p_pow, 'Limits', [5 24], 'Value', 11.1, 'Position', [30 270 280 3]), ...
                   uislider(p_pow, 'Limits', [1000 50000], 'Value', 15000, 'Position', [30 190 280 3])];

    % 5. Bolt
    p_bolt = uipanel(tab_bolt, 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color, 'Position', [0 0 350 540], 'Title', 'Bolt Specs');
    ctrls.Bolt = [uislider(p_bolt, 'Limits', [10 1000], 'Value', 200, 'Position', [30 430 280 3]), ...
                  uislider(p_bolt, 'Limits', [1 16], 'Value', 4, 'Position', [30 350 280 3]), ...
                  uislider(p_bolt, 'Limits', [0 1], 'Value', 0, 'Position', [30 270 280 3], 'Visible', 'off'), ...
                  uislider(p_bolt, 'Limits', [10 5000], 'Value', 1000, 'Position', [30 190 280 3])];

    % Fix all label colors to white
    all_sliders = [ctrls.Arm, ctrls.Lift, ctrls.Mobile, ctrls.Power, ctrls.Bolt];
    for s = all_sliders, s.FontColor = 'w'; end

    % --- Analysis & 3D ---
    p_ana = uipanel(fig, 'Title', 'Analysis Results', 'Position', [385 120 340 570], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    lbl_status = uilabel(p_ana, 'Text', 'Best: ---', 'FontSize', 16, 'FontWeight', 'bold', 'Position', [20 510 300 40], 'FontColor', [0.2 0.8 1.0]);
    ax_bar = uiaxes(p_ana, 'Position', [20 20 300 450], 'Color', bg_color, 'XColor', 'w', 'YColor', 'w');

    p_3d = uipanel(fig, 'Title', 'Live 3D Preview', 'Position', [740 120 480 570], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    ax_3d = uiaxes(p_3d, 'Position', [10 10 460 530], 'Color', [0 0 0], 'XColor', 'none', 'YColor', 'none');

    btn_run = uibutton(fig, 'push', 'Text', '🚀 GENERATE OMNIPOTENT CERTIFICATE', 'FontSize', 16, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.1 0.6 0.3], 'FontColor', 'white', 'Position', [100 25 1100 80]);

    % --- 🎯 Master Sync Refresh Engine ---
    function update_ui(~, ~)
        try
            mode = tg.SelectedTab.Title(5:end);
            % Fetch current tab's inputs dynamically
            active_ctrls = ctrls.(mode);
            inputs = [active_ctrls(1).Value, active_ctrls(2).Value, active_ctrls(3).Value, active_ctrls(4).Value];
            
            % Logic & Component Selection
            [req_v, comp, catalog, b_idx, e_v, m_name, m_unit] = AMD_Logic(inputs, mode, project_root);
            
            % Update UI Text
            lbl_status.Text = ['👑 Selected: ', char(comp.PartName)];
            
            % Update 3D & Graph Modules
            AMD_Visuals(ax_bar, ax_3d, catalog, b_idx, mode, inputs, m_name, m_unit);
        catch, end
    end

    btn_run.ButtonPushedFcn = @(btn, event) run_full();
    function run_full()
        [inputs, mode] = get_state();
        [req_v, comp, catalog, b_idx, e_v, m_name, m_unit] = AMD_Logic(inputs, mode, project_root);
        AMD_Report(mode, comp, req_v, m_name, m_unit, catalog, b_idx, output_dir);
        AMD_Voice(mode, comp.PartName);
    end

    function [i, m] = get_state()
        m = tg.SelectedTab.Title(5:end); c = ctrls.(m);
        i = [c(1).Value, c(2).Value, c(3).Value, c(4).Value];
    end

    % --- Real-time Listeners ---
    for s = all_sliders, addlistener(s, 'ValueChanged', @update_ui); end
    % 🌟 SYNC ON TAB SWITCH!
    addlistener(tg, 'SelectionChanged', @update_ui);
    
    update_ui(); % Init
end
