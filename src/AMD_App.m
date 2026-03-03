% ==========================================
% Algo-Mech Designer (AMD) Suite - App v4.9
% Informative Dashboard & Error-Proof 3D
% ==========================================

function AMD_App()
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    data_path = fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv');
    output_dir = fullfile(project_root, 'out');
    addpath(src_dir);

    bg_color = [0.05 0.05 0.08]; panel_bg = [0.1 0.1 0.15]; txt_color = [0.9 0.9 0.9];
    fig = uifigure('Name', 'AMD Suite v4.9 - Pro Visual Dashboard', 'Position', [100 100 1100 600], 'Color', bg_color);
    current_lang = 'JP';

    % --- UI: Language & Info ---
    btn_lang = uibutton(fig, 'push', 'Text', '🌐 Switch to English', 'Position', [950 560 130 30], 'BackgroundColor', [0.2 0.2 0.2], 'FontColor', 'w');
    
    % --- Settings Panel with Descriptions / 説明付き設定 ---
    pnl_settings = uipanel(fig, 'Title', 'Design Settings / 設計設定', 'Position', [20 120 300 430], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    
    lbl_load = uilabel(pnl_settings, 'Text', '1. Target Load / 目標荷重 [kg]:', 'Position', [10 360 250 22], 'FontColor', txt_color, 'FontWeight', 'bold');
    uilabel(pnl_settings, 'Text', '→ 変形させたい重さを指定', 'Position', [20 345 250 15], 'FontColor', [0.6 0.6 0.6], 'FontSize', 10);
    sld_load = uislider(pnl_settings, 'Limits', [5 100], 'Value', 30, 'Position', [20 330 250 3]);
    
    lbl_budget = uilabel(pnl_settings, 'Text', '2. Budget Limit / 予算上限 [JPY]:', 'Position', [10 260 250 22], 'FontColor', txt_color, 'FontWeight', 'bold');
    uilabel(pnl_settings, 'Text', '→ 材料費の上限を指定', 'Position', [20 245 250 15], 'FontColor', [0.6 0.6 0.6], 'FontSize', 10);
    sld_budget = uislider(pnl_settings, 'Limits', [500 20000], 'Value', 5000, 'Position', [20 230 250 3]);

    % --- 3D Preview Panel ---
    pnl_3d = uipanel(fig, 'Title', 'Live 3D Preview', 'Position', [680 120 400 430], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    ax_3d = uiaxes(pnl_3d, 'Position', [10 10 380 380], 'Color', [0 0 0], 'XColor', 'none', 'YColor', 'none');
    view(ax_3d, 3); axis(ax_3d, 'equal'); grid(ax_3d, 'on');

    % --- Analytics Panel ---
    pnl_ana = uipanel(fig, 'Title', 'Results', 'Position', [330 120 340 430], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    ax_bar = uiaxes(pnl_ana, 'Position', [20 150 300 220], 'Color', bg_color, 'XColor', txt_color, 'YColor', txt_color);
    lbl_status = uilabel(pnl_ana, 'Text', 'Best: ---', 'FontSize', 14, 'FontWeight', 'bold', 'Position', [20 20 300 40], 'FontColor', [0.4 0.9 0.4]);

    btn_run = uibutton(fig, 'push', 'Text', '🚀 RUN ANALYSIS', 'FontSize', 16, 'FontWeight', 'bold', 'BackgroundColor', [0.5 0.1 0.1], 'FontColor', 'white', 'Position', [100 30 900 70]);

    % --- 💎 Error-Proof 3D Drawing / 堅牢な3D描画 ---
    function update_3d_view(final_t, mat_name)
        cla(ax_3d);
        stl_file = fullfile(output_dir, 'View_in_3D.stl');
        
        % Set color based on material
        if contains(mat_name, 'Aluminum'), mat_color = [0.7 0.7 0.8];
        elseif contains(mat_name, 'Steel'), mat_color = [0.4 0.4 0.45];
        elseif contains(mat_name, 'Carbon'), mat_color = [0.1 0.1 0.1];
        else, mat_color = [0.2 0.6 0.8]; end

        if exist(stl_file, 'file')
            try
                [v, f] = stlread(stl_file);
                patch(ax_3d, 'Faces', f, 'Vertices', v, 'FaceColor', mat_color, 'EdgeColor', 'none', 'FaceLighting', 'gouraud');
                title(ax_3d, 'Real SolidWorks Model', 'Color', 'w');
            catch
                draw_safe_block(final_t, mat_color);
            end
        else
            draw_safe_block(final_t, mat_color);
        end
        material(ax_3d, 'shiny'); camlight(ax_3d, 'headlight');
    end

    function draw_safe_block(t, mat_color)
        % Stable cube drawing using fill3
        L = 150; W = 50;
        verts = [0 0 0; L 0 0; L W 0; 0 W 0; 0 0 t; L 0 t; L W t; 0 W t];
        faces = [1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8; 1 2 3 4; 5 6 7 8];
        patch(ax_3d, 'Faces', faces, 'Vertices', verts, 'FaceColor', mat_color, 'EdgeColor', 'w');
        title(ax_3d, 'Virtual Preview', 'Color', 'y');
    end

    % --- Logic & Events ---
    function update_ui(~, ~)
        try
            catalog = readtable(data_path);
            mats = unique(catalog.Material); all_sols = [];
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
        btn_run.Text = '⌛ Processing...'; btn_run.Enable = 'off'; drawnow;
        AMD_Main_Brain(sld_load.Value, sld_budget.Value, 1.5, current_lang);
        update_ui(); 
        btn_run.Text = '🚀 RUN ANALYSIS'; btn_run.Enable = 'on';
    end

    addlistener(sld_load, 'ValueChanged', @update_ui);
    addlistener(sld_budget, 'ValueChanged', @update_ui);
    update_ui();
end
