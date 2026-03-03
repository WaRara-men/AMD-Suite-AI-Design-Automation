% ==========================================
% Algo-Mech Designer (AMD) Suite - App v12.0
% IMMORTAL MODULAR DASHBOARD
% ==========================================

function AMD_App()
    src_dir = fileparts(mfilename('fullpath')); project_root = fileparts(src_dir);
    data_path = fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv');
    output_dir = fullfile(project_root, 'out'); addpath(src_dir);

    bg_color = [0.05 0.05 0.08]; panel_bg = [0.1 0.1 0.15]; txt_color = [0.95 0.95 0.95];
    fig = uifigure('Name', 'AMD Suite v12.0 - IMMORTAL MODULAR EDITION', 'Position', [100 100 1250 750], 'Color', bg_color);
    current_lang = 'JP';

    % --- 🛡️ PROTECTED UI ELEMENTS ---
    uilabel(fig, 'Text', '💎 AMD SUITE v12.0: ULTIMATE ROBOT DESIGN CENTER', 'FontSize', 22, 'FontWeight', 'bold', 'Position', [20 710 600 35], 'FontColor', [0.3 0.8 1.0]);
    btn_lang = uibutton(fig, 'push', 'Text', '🌐 Switch Language', 'Position', [1050 715 150 30], 'BackgroundColor', [0.2 0.2 0.2], 'FontColor', 'w');

    tg = uitabgroup(fig, 'Position', [20 120 400 580]);
    tab_arm = uitab(tg, 'Title', '🦾 Arm'); tab_lift = uitab(tg, 'Title', '🏗️ Lift');
    tab_mobile = uitab(tg, 'Title', '🏎️ Mobile'); tab_power = uitab(tg, 'Title', '🔋 Power'); tab_bolt = uitab(tg, 'Title', '🔩 Bolt');

    % --- Panels (WHITE TEXT GUARANTEED) ---
    function p = create_pnl(tab, title, desc)
        p = uipanel(tab, 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color, 'Position', [0 0 400 550], 'Title', title);
        uilabel(p, 'Text', desc, 'Position', [10 500 380 22], 'FontColor', [0.6 0.9 0.6], 'FontAngle', 'italic');
    end

    p_arm = create_pnl(tab_arm, 'Robot Arm', 'アームのトルクと自重を計算します / Rotational torque & arm weight.');
    sld_load = uislider(p_arm, 'Limits', [0.1 10], 'Value', 2, 'Position', [30 430 340 3], 'FontColor', 'w'); uilabel(p_arm, 'Text', 'Payload [kg]', 'Position', [30 445 100 22], 'FontColor', 'w');
    sld_len = uislider(p_arm, 'Limits', [50 1000], 'Value', 300, 'Position', [30 340 340 3], 'FontColor', 'w'); uilabel(p_arm, 'Text', 'Length [mm]', 'Position', [30 355 100 22], 'FontColor', 'w');
    sld_rad = uislider(p_arm, 'Limits', [2 50], 'Value', 10, 'Position', [30 250 340 3], 'FontColor', 'w'); uilabel(p_arm, 'Text', 'Radius [mm]', 'Position', [30 265 100 22], 'FontColor', 'w');
    sld_budget = uislider(p_arm, 'Limits', [1000 50000], 'Value', 15000, 'Position', [30 160 340 3], 'FontColor', 'w'); uilabel(p_arm, 'Text', 'Budget [JPY]', 'Position', [30 175 100 22], 'FontColor', 'w');

    p_lift = create_pnl(tab_lift, 'Lifting Stage', '垂直昇降の力を計算します / Vertical force.');
    sld_load_l = uislider(p_lift, 'Limits', [0.1 50], 'Value', 5, 'Position', [30 430 340 3], 'FontColor', 'w'); uilabel(p_lift, 'Text', 'Vertical Payload [kg]', 'Position', [30 445 200 22], 'FontColor', 'w');

    % Analytics & 3D
    pnl_ana = uipanel(fig, 'Title', 'AI Insight', 'Position', [435 120 340 580], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    lbl_status = uilabel(pnl_ana, 'Text', 'Best: ---', 'FontSize', 16, 'FontWeight', 'bold', 'Position', [20 520 300 40], 'FontColor', [0.2 0.8 1.0]);
    ax_bar = uiaxes(pnl_ana, 'Position', [20 20 300 450], 'Color', bg_color, 'XColor', txt_color, 'YColor', txt_color);

    pnl_3d = uipanel(fig, 'Title', '3D Preview', 'Position', [790 120 480 580], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    ax_3d = uiaxes(pnl_3d, 'Position', [10 10 460 540], 'Color', [0 0 0], 'XColor', 'none', 'YColor', 'none');
    view(ax_3d, 3); axis(ax_3d, 'equal'); grid(ax_3d, 'on');

    btn_run = uibutton(fig, 'push', 'Text', '🚀 GENERATE OFFICIAL CERTIFICATE', 'FontSize', 16, 'FontWeight', 'bold', 'BackgroundColor', [0.1 0.6 0.3], 'FontColor', 'white', 'Position', [100 25 1100 80]);

    % --- Master Logic Bridge ---
    function update_ui(~, ~)
        try
            % Call External Logic File
            mode = tg.SelectedTab.Title(5:end); % 'Arm' or 'Lift'
            [req_t, motor, arm_mass] = AMD_Logic(sld_load.Value, sld_len.Value, sld_rad.Value, sld_budget.Value, 1.5, mode, data_path);
            
            lbl_status.Text = ['👑 Winner: ', char(motor.PartName)];
            bar(ax_bar, [motor.Torque_Nm], 'FaceColor', [1.0 0.6 0.2]); ylabel(ax_bar, 'Torque [Nm]');
            
            % 💎 RESTORED: ORANGE WEIGHT PREVIEW
            cla(ax_3d); 
            [X, Y, Z] = cylinder([sld_rad.Value sld_rad.Value], 20); Z = Z * sld_len.Value;
            surf(ax_3d, Z, X, Y, 'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'none'); hold(ax_3d, 'on');
            [Xm, Ym, Zm] = sphere(20); Xm=Xm*25+sld_len.Value; Ym=Ym*25; Zm=Zm*25;
            surf(ax_3d, Xm, Ym, Zm, 'FaceColor', [1.0 0.5 0.0], 'EdgeColor', 'none'); % ORANGE WEIGHT!
            view(ax_3d, 3); axis(ax_3d, 'tight'); axis(ax_3d, 'equal'); camlight(ax_3d); material(ax_3d, 'shiny');
        catch, end
    end

    btn_run.ButtonPushedFcn = @(btn, event) run_full();
    function run_full()
        mode = tg.SelectedTab.Title(5:end);
        [req_t, motor, arm_mass] = AMD_Logic(sld_load.Value, sld_len.Value, sld_rad.Value, sld_budget.Value, 1.5, mode, data_path);
        % Call External Report File (PROTECTED)
        AMD_Report(sld_load.Value, sld_len.Value, sld_rad.Value, sld_budget.Value, 1.5, mode, motor, arm_mass, req_t, output_dir);
        
        % Voice
        try NET.addAssembly('System.Speech'); speak = System.Speech.Synthesis.SpeechSynthesizer; speak.Speak(sprintf('設計完了。最適解は%sです。', char(motor.PartName))); catch, end
    end

    addlistener(sld_load, 'ValueChanged', @update_ui); addlistener(sld_len, 'ValueChanged', @update_ui);
    addlistener(sld_rad, 'ValueChanged', @update_ui); addlistener(sld_budget, 'ValueChanged', @update_ui);
    update_ui();
end
