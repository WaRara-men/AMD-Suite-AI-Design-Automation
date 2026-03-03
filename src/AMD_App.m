% ==========================================
% Algo-Mech Designer (AMD) Suite - App v15.0
% THE OMNIPOTENT 5-TAB CONTROLLER
% ==========================================

function AMD_App()
    src_dir = fileparts(mfilename('fullpath')); project_root = fileparts(src_dir);
    output_dir = fullfile(project_root, 'out'); addpath(src_dir); addpath(fullfile(src_dir, 'modules'));

    bg_color = [0.05 0.05 0.08]; panel_bg = [0.1 0.1 0.15]; txt_color = [0.95 0.95 0.95];
    fig = uifigure('Name', 'AMD Suite v15.0 - OMNIPOTENT ROBOT CENTER', 'Position', [100 100 1300 750], 'Color', bg_color);

    % --- Top Bar ---
    uilabel(fig, 'Text', '💎 AMD SUITE v15.0: THE OMNIPOTENT DESIGNER', 'FontSize', 22, 'FontWeight', 'bold', 'Position', [20 705 600 35], 'FontColor', [0.3 0.8 1.0]);

    % --- Tabs ---
    tg = uitabgroup(fig, 'Position', [20 120 350 570]);
    tab_arm = uitab(tg, 'Title', '🦾 Arm'); tab_lift = uitab(tg, 'Title', '🏗️ Lift');
    tab_mobile = uitab(tg, 'Title', '🏎️ Mobile'); tab_power = uitab(tg, 'Title', '🔋 Power'); tab_bolt = uitab(tg, 'Title', '🔩 Bolt');

    % --- Panel Builder ---
    function p = create_pnl(tab, title, desc)
        p = uipanel(tab, 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color, 'Position', [0 0 350 540], 'Title', title);
        uilabel(p, 'Text', desc, 'Position', [10 490 330 22], 'FontColor', [0.6 0.9 0.6], 'FontAngle', 'italic');
    end

    % 1. Arm
    p_arm = create_pnl(tab_arm, 'Robot Arm', 'アームのトルクと自重を計算');
    u_arm = [
        uislider(p_arm, 'Limits', [0.1 10], 'Value', 2, 'Position', [30 430 280 3], 'FontColor', 'w'), ...
        uislider(p_arm, 'Limits', [50 1000], 'Value', 300, 'Position', [30 350 280 3], 'FontColor', 'w'), ...
        uislider(p_arm, 'Limits', [2 50], 'Value', 10, 'Position', [30 270 280 3], 'FontColor', 'w'), ...
        uislider(p_arm, 'Limits', [1000 50000], 'Value', 15000, 'Position', [30 190 280 3], 'FontColor', 'w')
    ];
    uilabel(p_arm, 'Text', 'Payload [kg]', 'Position', [30 445 100 22], 'FontColor', 'w');
    uilabel(p_arm, 'Text', 'Length [mm]', 'Position', [30 365 100 22], 'FontColor', 'w');
    uilabel(p_arm, 'Text', 'Radius [mm]', 'Position', [30 285 100 22], 'FontColor', 'w');
    uilabel(p_arm, 'Text', 'Budget [JPY]', 'Position', [30 205 100 22], 'FontColor', 'w');

    % 2. Lift
    p_lift = create_pnl(tab_lift, 'Lifting Stage', '垂直昇降の巻上トルクを計算');
    u_lift = [
        uislider(p_lift, 'Limits', [1 50], 'Value', 5, 'Position', [30 430 280 3], 'FontColor', 'w'), ...
        uislider(p_lift, 'Limits', [10 100], 'Value', 30, 'Position', [30 350 280 3], 'FontColor', 'w'), ...
        uislider(p_lift, 'Limits', [0 10], 'Value', 0, 'Position', [30 270 280 3], 'FontColor', 'w', 'Visible', 'off'), ...
        uislider(p_lift, 'Limits', [1000 50000], 'Value', 15000, 'Position', [30 190 280 3], 'FontColor', 'w')
    ];
    uilabel(p_lift, 'Text', 'Vertical Payload [kg]', 'Position', [30 445 150 22], 'FontColor', 'w');
    uilabel(p_lift, 'Text', 'Pulley Radius [mm]', 'Position', [30 365 150 22], 'FontColor', 'w');
    uilabel(p_lift, 'Text', 'Budget [JPY]', 'Position', [30 205 100 22], 'FontColor', 'w');

    % 3. Mobile
    p_mobile = create_pnl(tab_mobile, 'Mobile Base', '走行車輪の駆動力と斜面摩擦');
    u_mob = [
        uislider(p_mobile, 'Limits', [1 100], 'Value', 20, 'Position', [30 430 280 3], 'FontColor', 'w'), ...
        uislider(p_mobile, 'Limits', [20 200], 'Value', 50, 'Position', [30 350 280 3], 'FontColor', 'w'), ...
        uislider(p_mobile, 'Limits', [0 45], 'Value', 15, 'Position', [30 270 280 3], 'FontColor', 'w'), ...
        uislider(p_mobile, 'Limits', [1000 50000], 'Value', 15000, 'Position', [30 190 280 3], 'FontColor', 'w')
    ];
    uilabel(p_mobile, 'Text', 'Total Robot Weight [kg]', 'Position', [30 445 200 22], 'FontColor', 'w');
    uilabel(p_mobile, 'Text', 'Wheel Radius [mm]', 'Position', [30 365 150 22], 'FontColor', 'w');
    uilabel(p_mobile, 'Text', 'Incline Angle [deg]', 'Position', [30 285 150 22], 'FontColor', 'w');
    uilabel(p_mobile, 'Text', 'Budget [JPY]', 'Position', [30 205 100 22], 'FontColor', 'w');

    % 4. Power
    p_power = create_pnl(tab_power, 'Power System', '消費電流からバッテリーを選定');
    u_pow = [
        uislider(p_power, 'Limits', [0.1 20], 'Value', 2.0, 'Position', [30 430 280 3], 'FontColor', 'w'), ...
        uislider(p_power, 'Limits', [0.5 24], 'Value', 3.0, 'Position', [30 350 280 3], 'FontColor', 'w'), ...
        uislider(p_power, 'Limits', [5 24], 'Value', 11.1, 'Position', [30 270 280 3], 'FontColor', 'w'), ...
        uislider(p_power, 'Limits', [1000 50000], 'Value', 15000, 'Position', [30 190 280 3], 'FontColor', 'w')
    ];
    uilabel(p_power, 'Text', 'Current Draw [A]', 'Position', [30 445 150 22], 'FontColor', 'w');
    uilabel(p_power, 'Text', 'Required Time [h]', 'Position', [30 365 150 22], 'FontColor', 'w');
    uilabel(p_power, 'Text', 'System Voltage [V]', 'Position', [30 285 150 22], 'FontColor', 'w');
    uilabel(p_power, 'Text', 'Budget [JPY]', 'Position', [30 205 100 22], 'FontColor', 'w');

    % 5. Bolt
    p_bolt = create_pnl(tab_bolt, 'Bolt & Joint', 'せん断荷重から最適なネジを選定');
    u_bolt = [
        uislider(p_bolt, 'Limits', [10 1000], 'Value', 200, 'Position', [30 430 280 3], 'FontColor', 'w'), ...
        uislider(p_bolt, 'Limits', [1 16], 'Value', 4, 'Position', [30 350 280 3], 'FontColor', 'w'), ...
        uislider(p_bolt, 'Limits', [0 10], 'Value', 0, 'Position', [30 270 280 3], 'FontColor', 'w', 'Visible', 'off'), ...
        uislider(p_bolt, 'Limits', [10 5000], 'Value', 1000, 'Position', [30 190 280 3], 'FontColor', 'w')
    ];
    uilabel(p_bolt, 'Text', 'Shear Load [kg]', 'Position', [30 445 150 22], 'FontColor', 'w');
    uilabel(p_bolt, 'Text', 'Number of Bolts', 'Position', [30 365 150 22], 'FontColor', 'w');
    uilabel(p_bolt, 'Text', 'Total Budget [JPY]', 'Position', [30 205 150 22], 'FontColor', 'w');

    % --- Panels ---
    pnl_ana = uipanel(fig, 'Title', 'Analysis', 'Position', [385 120 340 570], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    lbl_status = uilabel(pnl_ana, 'Text', 'Best: ---', 'FontSize', 16, 'FontWeight', 'bold', 'Position', [20 510 300 40], 'FontColor', [0.2 0.8 1.0]);
    lbl_phys = uilabel(pnl_ana, 'Text', '...', 'FontSize', 11, 'Position', [20 480 300 30], 'FontColor', [0.7 0.7 0.7]);
    ax_bar = uiaxes(pnl_ana, 'Position', [20 20 300 450], 'Color', bg_color, 'XColor', 'w', 'YColor', 'w');

    pnl_3d = uipanel(fig, 'Title', 'Live 3D', 'Position', [740 120 480 570], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    ax_3d = uiaxes(pnl_3d, 'Position', [10 10 460 530], 'Color', [0 0 0], 'XColor', 'none', 'YColor', 'none');

    btn_run = uibutton(fig, 'push', 'Text', '🚀 GENERATE OMNIPOTENT CERTIFICATE', 'FontSize', 16, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.1 0.6 0.3], 'FontColor', 'white', 'Position', [100 25 1100 80]);

    % --- Logic Bridge ---
    function [inputs, mode] = get_current_state()
        switch tg.SelectedTab.Title(5:end)
            case 'Arm', inputs = [u_arm(1).Value, u_arm(2).Value, u_arm(3).Value, u_arm(4).Value]; mode = 'Arm';
            case 'Lift', inputs = [u_lift(1).Value, u_lift(2).Value, u_lift(3).Value, u_lift(4).Value]; mode = 'Lift';
            case 'Mobile', inputs = [u_mob(1).Value, u_mob(2).Value, u_mob(3).Value, u_mob(4).Value]; mode = 'Mobile';
            case 'Power', inputs = [u_pow(1).Value, u_pow(2).Value, u_pow(3).Value, u_pow(4).Value]; mode = 'Power';
            case 'Bolt', inputs = [u_bolt(1).Value, u_bolt(2).Value, u_bolt(3).Value, u_bolt(4).Value]; mode = 'Bolt';
        end
    end

    function update_ui(~, ~)
        try
            [inputs, mode] = get_current_state();
            [req_val, comp, catalog, b_idx, extra_val, m_name, m_unit] = AMD_Logic(inputs, mode, project_root);
            
            lbl_status.Text = ['👑 Selected: ', char(comp.PartName)];
            lbl_phys.Text = sprintf('Req. %s: %.2f %s | Budget: %d JPY', m_name, req_val, m_unit, round(inputs(4)));
            
            AMD_Visuals(ax_bar, ax_3d, catalog, b_idx, mode, inputs, m_name, m_unit);
        catch, end
    end

    btn_run.ButtonPushedFcn = @(btn, event) run_full();
    function run_full()
        [inputs, mode] = get_current_state();
        [req_val, comp, catalog, b_idx, extra_val, m_name, m_unit] = AMD_Logic(inputs, mode, project_root);
        AMD_Report(mode, comp, req_val, m_name, m_unit, catalog, b_idx, output_dir);
        AMD_Voice(mode, comp.PartName);
    end

    % Listeners for all tabs
    for i=1:4
        addlistener(u_arm(i), 'ValueChanged', @update_ui); addlistener(u_lift(i), 'ValueChanged', @update_ui);
        addlistener(u_mob(i), 'ValueChanged', @update_ui); addlistener(u_pow(i), 'ValueChanged', @update_ui);
        addlistener(u_bolt(i), 'ValueChanged', @update_ui);
    end
    addlistener(tg, 'SelectionChanged', @update_ui);
    update_ui();
end
