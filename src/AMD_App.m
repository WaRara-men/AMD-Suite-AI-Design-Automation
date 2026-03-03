% ==========================================
% Algo-Mech Designer (AMD) Suite - App v5.0
% Final Edition: User-Friendly UI & Smart Sync
% ==========================================

function AMD_App()
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    data_path = fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv');
    output_dir = fullfile(project_root, 'out');
    addpath(src_dir);

    bg_color = [0.05 0.05 0.08]; panel_bg = [0.1 0.1 0.15]; txt_color = [0.9 0.9 0.9];
    fig = uifigure('Name', 'AMD Suite v5.0 - Final Ultimate Edition', 'Position', [100 100 1100 600], 'Color', bg_color);
    current_lang = 'JP';

    % Language Toggle
    btn_lang = uibutton(fig, 'push', 'Text', '🌐 Switch to English', 'Position', [950 560 130 30], 'BackgroundColor', [0.2 0.2 0.2], 'FontColor', 'w');

    % Settings
    pnl_settings = uipanel(fig, 'Title', 'Design Settings', 'Position', [20 120 300 430], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    uilabel(pnl_settings, 'Text', 'Target Load / 目標荷重 [kg]:', 'Position', [10 360 250 22], 'FontColor', txt_color, 'FontWeight', 'bold');
    sld_load = uislider(pnl_settings, 'Limits', [5 100], 'Value', 30, 'Position', [20 330 250 3]);
    uilabel(pnl_settings, 'Text', 'Budget Limit / 予算上限 [JPY]:', 'Position', [10 260 250 22], 'FontColor', txt_color, 'FontWeight', 'bold');
    sld_budget = uislider(pnl_settings, 'Limits', [500 20000], 'Value', 5000, 'Position', [20 230 250 3]);

    % Results
    pnl_ana = uipanel(fig, 'Title', 'Analysis Results', 'Position', [330 120 340 430], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    ax_bar = uiaxes(pnl_ana, 'Position', [20 150 300 220], 'Color', bg_color, 'XColor', txt_color, 'YColor', txt_color);
    lbl_status = uilabel(pnl_ana, 'Text', 'Best: ---', 'FontSize', 14, 'FontWeight', 'bold', 'Position', [20 20 300 40], 'FontColor', [0.4 0.9 0.4]);

    % 3D Preview
    pnl_3d = uipanel(fig, 'Title', 'Live 3D Preview', 'Position', [680 120 400 430], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    ax_3d = uiaxes(pnl_3d, 'Position', [10 10 380 380], 'Color', [0 0 0], 'XColor', 'none', 'YColor', 'none');
    view(ax_3d, 3); axis(ax_3d, 'equal'); grid(ax_3d, 'on');

    % RUN BUTTON
    btn_run = uibutton(fig, 'push', 'Text', '🚀 RUN & GENERATE PDF', 'FontSize', 16, 'FontWeight', 'bold', 'BackgroundColor', [0.5 0.1 0.1], 'FontColor', 'white', 'Position', [100 30 900 70]);

    % --- Logic ---
    function update_3d_view(final_t, mat_name)
        cla(ax_3d);
        stl_file = fullfile(output_dir, 'View_in_3D.stl');
        if contains(mat_name, 'Aluminum'), col = [0.7 0.7 0.8];
        elseif contains(mat_name, 'Steel'), col = [0.4 0.4 0.45];
        elseif contains(mat_name, 'Carbon'), col = [0.1 0.1 0.1];
        else, col = [0.2 0.6 0.8]; end

        if exist(stl_file, 'file')
            try
                [v, f] = stlread(stl_file);
                patch(ax_3d, 'Faces', f, 'Vertices', v, 'FaceColor', col, 'EdgeColor', 'none', 'FaceLighting', 'gouraud');
                title(ax_3d, 'Real SolidWorks Model', 'Color', 'w');
            catch, draw_safe_block(final_t, col); end
        else, draw_safe_block(final_t, col); end
        material(ax_3d, 'shiny'); camlight(ax_3d, 'headlight');
    end

    function draw_safe_block(t, col)
        verts = [0 0 0; 150 0 0; 150 50 0; 0 50 0; 0 0 t; 150 0 t; 150 50 t; 0 50 t];
        faces = [1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8; 1 2 3 4; 5 6 7 8];
        patch(ax_3d, 'Faces', faces, 'Vertices', verts, 'FaceColor', col, 'EdgeColor', 'w');
        title(ax_3d, 'Virtual Preview (No Part Open)', 'Color', 'y');
    end

    function update_ui(~, ~)
        try
            catalog = readtable(data_path); mats = unique(catalog.Material); all_sols = [];
            for i = 1:length(mats)
                m_data = catalog(strcmp(catalog.Material, mats{i}), :);
                min_t = (sld_load.Value / m_data.StrengthFactor(1)) * 0.1 * 1.5;
                idx = find(m_data.Thickness >= min_t, 1, 'first');
                if ~isempty(idx), sol.Mat = string(mats{i}); sol.T = m_data.Thickness(idx); sol.W = (300) * sol.T * m_data.Density(idx); all_sols = [all_sols; sol]; end
            end
            [~, b_idx] = min([all_sols.W]); final = all_sols(b_idx);
            lbl_status.Text = ['🏆 Winner: ', char(final.Mat)];
            bar(ax_bar, [all_sols.W], 'FaceColor', [0.3 0.5 0.7]); set(ax_bar, 'XTickLabel', {all_sols.Mat});
            update_3d_view(final.T, final.Mat);
        catch
        end
    end

    btn_run.ButtonPushedFcn = @(btn, event) run_all();
    function run_all()
        btn_run.Text = '⌛ Generating Final PDF...'; btn_run.Enable = 'off'; drawnow;
        AMD_Main_Brain(sld_load.Value, sld_budget.Value, 1.5, current_lang);
        update_ui(); 
        btn_run.Text = '🚀 RUN & GENERATE PDF'; btn_run.Enable = 'on';
    end

    addlistener(sld_load, 'ValueChanged', @update_ui);
    addlistener(sld_budget, 'ValueChanged', @update_ui);
    update_ui();
end
