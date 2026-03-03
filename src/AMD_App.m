% ==========================================
% Algo-Mech Designer (AMD) Suite - App v4.7
% Dashboard with Live 3D Preview (Patch based)
% ==========================================

function AMD_App()
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    data_path = fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv');
    output_dir = fullfile(project_root, 'out');
    addpath(src_dir);

    % Colors
    bg_color = [0.08 0.08 0.1];
    panel_bg = [0.12 0.12 0.15];
    txt_color = [0.9 0.9 0.9];

    fig = uifigure('Name', 'AMD Suite v4.7 - Ultimate 3D Dashboard', 'Position', [100 100 1000 600], 'Color', bg_color);
    current_lang = 'JP';

    % --- Language Switcher ---
    btn_lang = uibutton(fig, 'push', 'Text', '🌐 Switch to English', 'Position', [850 550 130 30], ...
        'BackgroundColor', [0.3 0.3 0.3], 'FontColor', 'w');

    % --- Panels ---
    pnl_settings = uipanel(fig, 'Title', 'Settings', 'Position', [20 120 250 430], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    sld_load = uislider(pnl_settings, 'Limits', [5 100], 'Value', 30, 'Position', [20 350 210 3]);
    sld_budget = uislider(pnl_settings, 'Limits', [500 20000], 'Value', 5000, 'Position', [20 250 210 3]);

    pnl_ana = uipanel(fig, 'Title', 'Analytics', 'Position', [280 120 340 430], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    ax_bar = uiaxes(pnl_ana, 'Position', [20 150 300 220], 'Color', bg_color, 'XColor', txt_color, 'YColor', txt_color);
    lbl_status = uilabel(pnl_ana, 'Text', 'Best: ---', 'FontSize', 14, 'FontWeight', 'bold', 'Position', [20 20 300 40], 'FontColor', [0.4 0.9 0.4]);

    % 💎 [NEW] 3D PREVIEW PANEL
    pnl_3d = uipanel(fig, 'Title', 'Live 3D Preview / 3Dプレビュー', 'Position', [630 120 350 430], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    ax_3d = uiaxes(pnl_3d, 'Position', [10 10 330 380], 'Color', [0 0 0], 'XColor', 'none', 'YColor', 'none');
    view(ax_3d, 3); axis(ax_3d, 'equal'); grid(ax_3d, 'on'); light(ax_3d);

    btn_run = uibutton(fig, 'push', 'Text', '🚀 RUN ANALYSIS & UPDATE 3D', ...
        'FontSize', 16, 'FontWeight', 'bold', 'BackgroundColor', [0.6 0.1 0.1], 'FontColor', 'white', ...
        'Position', [100 30 800 70]);

    % --- 3D Update Function ---
    function update_3d_view()
        stl_file = fullfile(output_dir, 'View_in_3D.stl');
        if exist(stl_file, 'file')
            cla(ax_3d);
            try
                [v, f, n] = stlread(stl_file);
                patch(ax_3d, 'Faces', f, 'Vertices', v, 'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'none', 'FaceLighting', 'gouraud');
                material(ax_3d, 'shiny'); camlight(ax_3d, 'headlight');
                title(ax_3d, 'Current Design (Live)', 'Color', 'w');
            catch
                title(ax_3d, 'Wait for SW Export...', 'Color', 'y');
            end
        end
    end

    % --- Logic ---
    function update_ui(~, ~)
        catalog = readtable(data_path);
        mats = unique(catalog.Material);
        all_sols = [];
        for i = 1:length(mats)
            m_data = catalog(strcmp(catalog.Material, mats{i}), :);
            min_t = (sld_load.Value / m_data.StrengthFactor(1)) * 0.1 * 1.5;
            idx = find(m_data.Thickness >= min_t, 1, 'first');
            if ~isempty(idx), sol.Mat = string(mats{i}); sol.W = (300) * m_data.Thickness(idx) * m_data.Density(idx); all_sols = [all_sols; sol]; end
        end
        [~, b_idx] = min([all_sols.W]); final = all_sols(b_idx);
        lbl_status.Text = ['🏆 Winner: ', char(final.Mat)];
        bar(ax_bar, [all_sols.W], 'FaceColor', [0.2 0.5 0.8]); set(ax_bar, 'XTickLabel', {all_sols.Mat});
    end

    btn_run.ButtonPushedFcn = @(btn, event) run_all();
    function run_and_log_error(ME)
        uialert(fig, ME.message, 'Error');
    end

    function run_all()
        btn_run.Text = '⌛ Analyzing & Exporting 3D...'; btn_run.Enable = 'off'; drawnow;
        try
            AMD_Main_Brain(sld_load.Value, sld_budget.Value, 1.5, current_lang);
            update_3d_view(); % 💎 Refresh 3D
        catch ME
            run_and_log_error(ME);
        end
        btn_run.Text = '🚀 RUN ANALYSIS & UPDATE 3D'; btn_run.Enable = 'on';
    end

    addlistener(sld_load, 'ValueChanged', @update_ui);
    addlistener(sld_budget, 'ValueChanged', @update_ui);
    update_ui();
    update_3d_view(); % Initial check
end
