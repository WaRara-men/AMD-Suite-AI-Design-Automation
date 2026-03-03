% ==========================================
% Algo-Mech Designer (AMD) Suite - App v9.1
% THE DEFINITIVE GOD-MODE: Tabs, Voice, 3D, Git & Zero-e
% ==========================================

function AMD_App()
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    data_path = fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv');
    output_dir = fullfile(project_root, 'out');
    addpath(src_dir);

    % --- Colors & Theme ---
    bg_color = [0.05 0.05 0.08]; panel_bg = [0.1 0.1 0.15]; txt_color = [0.95 0.95 0.95];
    fig = uifigure('Name', 'AMD Suite v9.1 - Ultimate Integrated Design Center', 'Position', [100 100 1250 700], 'Color', bg_color);
    current_lang = 'JP';

    % --- Top Bar ---
    uilabel(fig, 'Text', '🤖 AMD SUITE: ROBOT DESIGN CENTER', 'FontSize', 20, 'FontWeight', 'bold', 'Position', [20 655 500 30], 'FontColor', [1.0 0.6 0.2]);
    btn_lang = uibutton(fig, 'push', 'Text', '🌐 Switch to English', 'Position', [1050 660 150 30], 'BackgroundColor', [0.2 0.2 0.2], 'FontColor', 'w');

    % --- 🌟 Tab Group ---
    tg = uitabgroup(fig, 'Position', [20 120 350 520]);
    tab_arm = uitab(tg, 'Title', '🦾 Robot Arm');
    tab_lift = uitab(tg, 'Title', '🏗️ Lifting Stage');

    % --- Tab 1: Arm Settings ---
    pnl_arm = uipanel(tab_arm, 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color, 'Position', [0 0 350 490], 'Title', 'Arm Specs');
    uilabel(pnl_arm, 'Text', 'Payload / 荷物重量 [kg]:', 'Position', [10 420 250 22], 'FontColor', txt_color, 'FontWeight', 'bold');
    sld_load = uislider(pnl_arm, 'Limits', [0.1 10.0], 'Value', 2.0, 'Position', [20 400 280 3], 'FontColor', txt_color);
    
    uilabel(pnl_arm, 'Text', 'Arm Length / アーム長 [mm]:', 'Position', [10 330 250 22], 'FontColor', txt_color, 'FontWeight', 'bold');
    sld_len = uislider(pnl_arm, 'Limits', [50 1000], 'Value', 300, 'Position', [20 310 280 3], 'FontColor', txt_color);

    uilabel(pnl_arm, 'Text', 'Rod Radius / 棒の半径 [mm]:', 'Position', [10 240 250 22], 'FontColor', txt_color, 'FontWeight', 'bold');
    sld_rad = uislider(pnl_arm, 'Limits', [2 50], 'Value', 10, 'Position', [20 220 280 3], 'FontColor', txt_color);

    uilabel(pnl_arm, 'Text', 'Budget / 予算上限 [JPY]:', 'Position', [10 150 250 22], 'FontColor', txt_color, 'FontWeight', 'bold');
    sld_budget = uislider(pnl_arm, 'Limits', [1000 50000], 'Value', 15000, 'Position', [20 130 280 3], 'FontColor', txt_color);

    % --- Center Panel: Analytics ---
    pnl_ana = uipanel(fig, 'Title', 'AI Analytics', 'Position', [380 120 340 520], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    lbl_status = uilabel(pnl_ana, 'Text', 'Best: ---', 'FontSize', 16, 'FontWeight', 'bold', 'Position', [20 460 300 40], 'FontColor', [0.2 0.8 1.0]);
    lbl_phys = uilabel(pnl_ana, 'Text', 'Structural Mass: --- kg', 'FontSize', 11, 'Position', [20 430 300 30], 'FontColor', [0.7 0.7 0.7]);
    ax_bar = uiaxes(pnl_ana, 'Position', [20 20 300 380], 'Color', bg_color, 'XColor', txt_color, 'YColor', txt_color);

    % --- Right Panel: 3D ---
    pnl_3d = uipanel(fig, 'Title', 'Live 3D Preview', 'Position', [740 120 480 520], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    ax_3d = uiaxes(pnl_3d, 'Position', [10 10 460 480], 'Color', [0 0 0], 'XColor', 'none', 'YColor', 'none');
    view(ax_3d, 3); axis(ax_3d, 'equal'); grid(ax_3d, 'on');

    % --- Bottom Buttons ---
    btn_run = uibutton(fig, 'push', 'Text', '🚀 SELECT MOTOR & GENERATE OFFICIAL CERTIFICATE', 'FontSize', 16, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.1 0.4 0.6], 'FontColor', 'white', 'Position', [100 25 800 75]);
    
    btn_git = uibutton(fig, 'push', 'Text', '🌐 SYNC TO GITHUB', 'Position', [950 25 200 75], ...
        'BackgroundColor', [0.2 0.2 0.2], 'FontColor', 'white', 'FontSize', 12);

    % --- Core UI Logic ---
    function update_ui(~, ~)
        try
            catalog = readtable(data_path);
            arm_mass = (pi * sld_rad.Value^2 * sld_len.Value) * 0.0000027; % kg
            req_t = (sld_load.Value + arm_mass/2) * 9.81 * (sld_len.Value / 1000) * 1.5;
            
            feasible = find(catalog.Torque_Nm >= req_t & catalog.Price_JPY <= sld_budget.Value);
            if isempty(feasible), [~, b_idx] = min(catalog.Price_JPY); else, [~, s_idx] = min(catalog.Weight_kg(feasible)); b_idx = feasible(s_idx); end
            motor = catalog(b_idx, :);
            
            lbl_status.Text = ['👑 Selected: ', char(motor.PartName)];
            lbl_phys.Text = sprintf('Arm Weight: %.3f kg | Req. Torque: %.2f Nm | Budget: %d JPY', arm_mass, req_t, round(sld_budget.Value));
            
            bar(ax_bar, catalog.Torque_Nm, 'FaceColor', [0.2 0.3 0.4]); hold(ax_bar, 'on');
            bar(ax_bar, b_idx, motor.Torque_Nm, 'FaceColor', [1.0 0.6 0.2]); hold(ax_bar, 'off');
            set(ax_bar, 'XTickLabel', catalog.PartName);
            
            % 3D Draw
            cla(ax_3d); [X, Y, Z] = cylinder([sld_rad.Value sld_rad.Value], 20); Z = Z * sld_len.Value;
            surf(ax_3d, Z, X, Y, 'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'none');
            [Xm, Ym, Zm] = sphere(20); Xm = Xm*25; Ym = Ym*25; Zm = Zm*25;
            surf(ax_3d, Xm, Ym, Zm, 'FaceColor', [1.0 0.6 0.2], 'EdgeColor', 'none');
            view(ax_3d, 3); axis(ax_3d, 'equal'); camlight(ax_3d); material(ax_3d, 'shiny');
        catch, end
    end

    btn_run.ButtonPushedFcn = @(btn, event) AMD_Main_Brain(sld_load.Value, sld_len.Value, sld_rad.Value, sld_budget.Value, 1.5, current_lang, 'Arm');
    btn_git.ButtonPushedFcn = @(btn, event) system(sprintf('cd "%s" && git add . && git commit -m "Auto-update" && git push', project_root));

    % Listeners
    addlistener(sld_load, 'ValueChanged', @update_ui);
    addlistener(sld_len, 'ValueChanged', @update_ui);
    addlistener(sld_rad, 'ValueChanged', @update_ui);
    addlistener(sld_budget, 'ValueChanged', @update_ui);
    update_ui();
end
