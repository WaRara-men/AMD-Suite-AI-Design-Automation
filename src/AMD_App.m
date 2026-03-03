% ==========================================
% Algo-Mech Designer (AMD) Suite - App v9.0
% The Ultimate Tabbed Multi-Purpose Dashboard
% ==========================================

function AMD_App()
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    data_path = fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv');
    addpath(src_dir);

    bg_color = [0.05 0.05 0.08]; panel_bg = [0.1 0.1 0.15]; txt_color = [0.95 0.95 0.95];
    fig = uifigure('Name', 'AMD Suite v9.0 - Multi-Purpose Robot Center', 'Position', [100 100 1200 700], 'Color', bg_color);
    current_lang = 'JP';

    % --- 🌟 TAB GROUP ---
    tg = uitabgroup(fig, 'Position', [20 120 350 550]);
    tab_arm = uitab(tg, 'Title', '🦾 Robot Arm');
    tab_lift = uitab(tg, 'Title', '🏗️ Lifting Stage');

    % --- Tab 1: Arm Settings ---
    pnl_arm = uipanel(tab_arm, 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color, 'Position', [0 0 350 520]);
    uilabel(pnl_arm, 'Text', 'Payload / 持ち上げる重さ [kg]:', 'Position', [10 450 250 22], 'FontColor', txt_color, 'FontWeight', 'bold');
    sld_load = uislider(pnl_arm, 'Limits', [0.1 10.0], 'Value', 2.0, 'Position', [20 430 280 3], 'FontColor', txt_color);
    
    uilabel(pnl_arm, 'Text', 'Arm Length / アーム長 [mm]:', 'Position', [10 360 250 22], 'FontColor', txt_color, 'FontWeight', 'bold');
    sld_len = uislider(pnl_arm, 'Limits', [50 1000], 'Value', 300, 'Position', [20 340 280 3], 'FontColor', txt_color);

    uilabel(pnl_arm, 'Text', 'Rod Radius / 棒の半径 [mm]:', 'Position', [10 270 250 22], 'FontColor', txt_color, 'FontWeight', 'bold');
    sld_rad = uislider(pnl_arm, 'Limits', [2 50], 'Value', 10, 'Position', [20 250 280 3], 'FontColor', txt_color);

    uilabel(pnl_arm, 'Text', 'Budget / 予算上限 [JPY]:', 'Position', [10 180 250 22], 'FontColor', txt_color, 'FontWeight', 'bold');
    sld_budget = uislider(pnl_settings, 'Limits', [1000 50000], 'Value', 15000, 'Position', [20 160 280 3], 'FontColor', txt_color);

    % --- Analytics & 3D ---
    pnl_ana = uipanel(fig, 'Title', 'Analysis Results', 'Position', [380 120 340 550], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    lbl_status = uilabel(pnl_ana, 'Text', 'Best: ---', 'FontSize', 16, 'FontWeight', 'bold', 'Position', [20 480 300 40], 'FontColor', [0.2 0.8 1.0]);
    lbl_phys = uilabel(pnl_ana, 'Text', 'Structural Mass: --- kg', 'FontSize', 11, 'Position', [20 440 300 30], 'FontColor', [0.7 0.7 0.7]);
    ax_bar = uiaxes(pnl_ana, 'Position', [20 20 300 400], 'Color', bg_color, 'XColor', txt_color, 'YColor', txt_color);

    pnl_3d = uipanel(fig, 'Title', 'Live 3D Preview', 'Position', [740 120 440 550], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    ax_3d = uiaxes(pnl_3d, 'Position', [10 10 420 500], 'Color', [0 0 0], 'XColor', 'none', 'YColor', 'none');
    view(ax_3d, 3); axis(ax_3d, 'equal'); grid(ax_3d, 'on');

    btn_run = uibutton(fig, 'push', 'Text', '🚀 SELECT MOTOR & GENERATE OFFICIAL CERTIFICATE', 'FontSize', 16, 'FontWeight', 'bold', 'BackgroundColor', [0.1 0.4 0.6], 'FontColor', 'white', 'Position', [100 20 1000 80]);

    % --- Core Logic ---
    function update_ui(~, ~)
        try
            catalog = readtable(data_path);
            % Advanced Physics: Arm Mass included
            arm_mass = (pi * sld_rad.Value^2 * sld_len.Value) * 0.0000027; % kg
            req_t = (sld_load.Value + arm_mass/2) * 9.81 * (sld_len.Value / 1000) * 1.5;
            
            [~, b_idx] = min(catalog.Weight_kg(catalog.Torque_Nm >= req_t));
            if isempty(b_idx), [~, b_idx] = min(catalog.Price_JPY); end
            motor = catalog(b_idx, :);
            
            % Human-readable integer formatting
            lbl_status.Text = ['👑 Selected: ', char(motor.PartName)];
            lbl_phys.Text = sprintf('Arm Weight: %.3f kg | Req. Torque: %.2f Nm', arm_mass, req_t);
            
            bar(ax_bar, catalog.Torque_Nm, 'FaceColor', [0.2 0.3 0.4]); hold(ax_bar, 'on');
            bar(ax_bar, b_idx, motor.Torque_Nm, 'FaceColor', [1.0 0.6 0.2]); hold(ax_bar, 'off');
            
            % 💎 LIVE 3D Update (Reflecting Radius!)
            cla(ax_3d); [X, Y, Z] = cylinder([sld_rad.Value sld_rad.Value], 20); Z = Z * sld_len.Value;
            surf(ax_3d, Z, X, Y, 'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'none');
            [Xm, Ym, Zm] = sphere(20); Xm = Xm*25; Ym = Ym*25; Zm = Zm*25;
            surf(ax_3d, Xm, Ym, Zm, 'FaceColor', [1.0 0.6 0.2], 'EdgeColor', 'none');
            view(ax_3d, 3); axis(ax_3d, 'equal'); camlight(ax_3d); material(ax_3d, 'shiny');
        catch, end
    end

    btn_run.ButtonPushedFcn = @(btn, event) AMD_Main_Brain(sld_load.Value, sld_len.Value, sld_rad.Value, sld_budget.Value, 1.5, current_lang, 'Arm');
    addlistener(sld_load, 'ValueChanged', @update_ui);
    addlistener(sld_len, 'ValueChanged', @update_ui);
    addlistener(sld_rad, 'ValueChanged', @update_ui);
    update_ui();
end
