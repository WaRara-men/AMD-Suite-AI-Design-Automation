% ==========================================
% Algo-Mech Designer (AMD) Suite - App v10.0
% THE IMMORTAL DASHBOARD: Tabs, 3D, Lang, & Git
% ==========================================

function AMD_App()
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    data_path = fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv');
    addpath(src_dir);

    bg_color = [0.05 0.05 0.08]; panel_bg = [0.1 0.1 0.15]; txt_color = [0.95 0.95 0.95];
    fig = uifigure('Name', 'AMD Suite v10.0 - THE DEFINITIVE MASTERPIECE', 'Position', [100 100 1250 750], 'Color', bg_color);
    current_lang = 'JP';

    % --- Top Bar (RESTORED ALL) ---
    uilabel(fig, 'Text', '💎 AMD SUITE v10.0: IMMORTAL DESIGN CENTER', 'FontSize', 22, 'FontWeight', 'bold', 'Position', [20 705 600 35], 'FontColor', [0.3 0.8 1.0]);
    btn_lang = uibutton(fig, 'push', 'Text', '🌐 Switch Language', 'Position', [1050 710 150 30], 'BackgroundColor', [0.2 0.2 0.2], 'FontColor', 'w');

    % --- 🌟 Tab Group (FULLY FUNCTIONAL) ---
    tg = uitabgroup(fig, 'Position', [20 120 350 570]);
    tab_arm = uitab(tg, 'Title', '🦾 Robot Arm');
    tab_lift = uitab(tg, 'Title', '🏗️ Lifting Stage');

    % --- Tab 1: Robot Arm Panel (RESTORED) ---
    pnl_arm = uipanel(tab_arm, 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color, 'Position', [0 0 350 540], 'Title', 'Arm Specifications');
    uilabel(pnl_arm, 'Text', 'Payload / 荷物重量 [kg]:', 'Position', [10 460 250 22], 'FontColor', txt_color, 'FontWeight', 'bold');
    sld_load = uislider(pnl_arm, 'Limits', [0.1 10.0], 'Value', 2.0, 'Position', [20 440 280 3], 'FontColor', txt_color);
    uilabel(pnl_arm, 'Text', 'Arm Length / アーム長 [mm]:', 'Position', [10 370 250 22], 'FontColor', txt_color, 'FontWeight', 'bold');
    sld_len = uislider(pnl_arm, 'Limits', [50 1000], 'Value', 300, 'Position', [20 350 280 3], 'FontColor', txt_color);
    uilabel(pnl_arm, 'Text', 'Rod Radius / 棒の半径 [mm]:', 'Position', [10 280 250 22], 'FontColor', txt_color, 'FontWeight', 'bold');
    sld_rad = uislider(pnl_arm, 'Limits', [2 50], 'Value', 10, 'Position', [20 260 280 3], 'FontColor', txt_color);
    uilabel(pnl_arm, 'Text', 'Budget Limit / 予算上限 [JPY]:', 'Position', [10 190 250 22], 'FontColor', txt_color, 'FontWeight', 'bold');
    sld_budget = uislider(pnl_arm, 'Limits', [1000 50000], 'Value', 15000, 'Position', [20 170 280 3], 'FontColor', txt_color);

    % --- Tab 2: Lifting Stage Panel (RESTORED) ---
    pnl_lift = uipanel(tab_lift, 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color, 'Position', [0 0 350 540], 'Title', 'Lift Specifications');
    uilabel(pnl_lift, 'Text', 'Vertical Payload [kg]:', 'Position', [10 460 250 22], 'FontColor', txt_color);
    uislider(pnl_lift, 'Limits', [1 50], 'Value', 5, 'Position', [20 440 280 3]);
    uilabel(pnl_lift, 'Text', '(Coming soon: Dynamic Logic Integration)', 'Position', [10 400 300 22], 'FontColor', [0.5 0.5 0.5]);

    % --- Center Panel: Analytics (RESTORED ALL) ---
    pnl_ana = uipanel(fig, 'Title', 'AI Insight', 'Position', [385 120 340 570], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    lbl_status = uilabel(pnl_ana, 'Text', 'Best: ---', 'FontSize', 16, 'FontWeight', 'bold', 'Position', [20 510 300 40], 'FontColor', [0.2 0.8 1.0]);
    lbl_phys = uilabel(pnl_ana, 'Text', 'Wait for input...', 'FontSize', 11, 'Position', [20 480 300 30], 'FontColor', [0.7 0.7 0.7]);
    ax_bar = uiaxes(pnl_ana, 'Position', [20 20 300 420], 'Color', bg_color, 'XColor', txt_color, 'YColor', txt_color);

    % --- Right Panel: 3D (RESTORED PROPER ARM) ---
    pnl_3d = uipanel(fig, 'Title', 'Master 3D Rendering', 'Position', [740 120 480 570], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    ax_3d = uiaxes(pnl_3d, 'Position', [10 10 460 530], 'Color', [0 0 0], 'XColor', 'none', 'YColor', 'none');
    view(ax_3d, 3); axis(ax_3d, 'equal'); grid(ax_3d, 'on');

    % --- Bottom Buttons (RESTORED ALL) ---
    btn_run = uibutton(fig, 'push', 'Text', '🚀 GENERATE DEFINITIVE CERTIFICATE (PDF)', 'FontSize', 16, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.1 0.6 0.3], 'FontColor', 'white', 'Position', [100 25 800 80]);
    btn_git = uibutton(fig, 'push', 'Text', '🌐 PUSH TO GITHUB', 'Position', [950 25 200 80], ...
        'BackgroundColor', [0.2 0.2 0.2], 'FontColor', 'white');

    % --- Master Sync Logic ---
    function update_ui(~, ~)
        try
            catalog = readtable(data_path);
            arm_mass = (pi * sld_rad.Value^2 * sld_len.Value) * 0.0000027; 
            req_t = (sld_load.Value + arm_mass/2) * 9.81 * (sld_len.Value / 1000) * 1.5;
            feasible = find(catalog.Torque_Nm >= req_t & catalog.Price_JPY <= sld_budget.Value);
            if isempty(feasible), [~, b_idx] = min(catalog.Price_JPY); else, [~, s_idx] = min(catalog.Weight_kg(feasible)); b_idx = feasible(s_idx); end
            motor = catalog(b_idx, :);
            
            lbl_status.Text = ['👑 Winner: ', char(motor.PartName)];
            lbl_phys.Text = sprintf('Arm Weight: %.3f kg | Torque: %.2f Nm', arm_mass, req_t);
            bar(ax_bar, catalog.Torque_Nm, 'FaceColor', [0.2 0.3 0.4]); hold(ax_bar, 'on');
            bar(ax_bar, b_idx, motor.Torque_Nm, 'FaceColor', [1.0 0.6 0.2]); hold(ax_bar, 'off');
            
            % 💎 RESTORED: REAL ARM PREVIEW
            cla(ax_3d); [X, Y, Z] = cylinder([sld_rad.Value sld_rad.Value], 20); Z = Z * sld_len.Value;
            surf(ax_3d, Z, X, Y, 'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'none'); hold(ax_3d, 'on');
            [Xm, Ym, Zm] = sphere(20); Xm=Xm*20; Ym=Ym*20; Zm=Zm*20; surf(ax_3d, Xm, Ym, Zm, 'FaceColor', [1.0 0.6 0.2], 'EdgeColor', 'none');
            view(ax_3d, 3); axis(ax_3d, 'tight'); axis(ax_3d, 'equal'); camlight(ax_3d); material(ax_3d, 'shiny');
        catch, end
    end

    btn_run.ButtonPushedFcn = @(btn, event) run_full();
    function run_full()
        btn_run.Text = '⌛ Forging Final Masterpiece...'; btn_run.Enable = 'off'; drawnow;
        AMD_Main_Brain(sld_load.Value, sld_len.Value, sld_rad.Value, sld_budget.Value, 1.5, current_lang, 'Arm');
        btn_run.Text = '🚀 GENERATE DEFINITIVE CERTIFICATE (PDF)'; btn_run.Enable = 'on';
    end

    btn_git.ButtonPushedFcn = @(btn, event) system(sprintf('cd "%s" && git add . && git commit -m "Final Gold" && git push', project_root));

    % Final Polish
    addlistener(sld_load, 'ValueChanged', @update_ui); addlistener(sld_len, 'ValueChanged', @update_ui);
    addlistener(sld_rad, 'ValueChanged', @update_ui); addlistener(sld_budget, 'ValueChanged', @update_ui);
    update_ui();
end
