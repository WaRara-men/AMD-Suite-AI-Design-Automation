% ==========================================
% Algo-Mech Designer (AMD) Suite - App v7.0
% The Ultimate Standalone UI (Hyper-Visual)
% ==========================================

function AMD_App()
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    data_path = fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv');
    output_dir = fullfile(project_root, 'out');
    addpath(src_dir);

    bg_color = [0.05 0.05 0.08]; panel_bg = [0.1 0.1 0.15]; txt_color = [0.95 0.95 0.95]; hint_color = [0.6 0.6 0.6];
    fig = uifigure('Name', 'AMD Suite v7.0 - Standalone Pro Engine', 'Position', [100 100 1150 650], 'Color', bg_color);
    current_lang = 'JP';

    % --- Header ---
    uilabel(fig, 'Text', '⚡ AMD SUITE v7.0: VIRTUAL AI ENGINE', 'FontSize', 20, 'FontWeight', 'bold', 'Position', [20 610 500 30], 'FontColor', [0.3 0.8 1.0]);
    btn_lang = uibutton(fig, 'push', 'Text', '🌐 Switch to English', 'Position', [1000 615 130 30], 'BackgroundColor', [0.2 0.2 0.2], 'FontColor', 'w');

    % --- Left: Settings ---
    pnl_settings = uipanel(fig, 'Title', 'Design Parameters / 設計パラメータ', 'Position', [20 120 300 480], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    uilabel(pnl_settings, 'Text', '1. Target Load / 目標荷重 [kg]:', 'Position', [10 410 250 22], 'FontColor', txt_color, 'FontWeight', 'bold');
    uilabel(pnl_settings, 'Text', '→ 変形させたい重さを指定', 'Position', [20 395 250 15], 'FontColor', hint_color, 'FontSize', 10);
    sld_load = uislider(pnl_settings, 'Limits', [5 100], 'Value', 30, 'Position', [20 380 250 3], 'FontColor', txt_color);
    
    uilabel(pnl_settings, 'Text', '2. Budget Limit / 予算上限 [JPY]:', 'Position', [10 310 250 22], 'FontColor', txt_color, 'FontWeight', 'bold');
    uilabel(pnl_settings, 'Text', '→ 材料費の上限を指定', 'Position', [20 295 250 15], 'FontColor', hint_color, 'FontSize', 10);
    sld_budget = uislider(pnl_settings, 'Limits', [500 20000], 'Value', 5000, 'Position', [20 280 250 3], 'FontColor', txt_color);

    uilabel(pnl_settings, 'Text', '3. Safety Factor / 安全率:', 'Position', [10 210 250 22], 'FontColor', txt_color, 'FontWeight', 'bold');
    uilabel(pnl_settings, 'Text', '→ 壊れないための余裕 (1.5=1.5倍)', 'Position', [20 195 250 15], 'FontColor', hint_color, 'FontSize', 10);
    sld_safety = uislider(pnl_settings, 'Limits', [1.0 3.0], 'Value', 1.5, 'Position', [20 180 250 3], 'FontColor', txt_color);

    % --- Center: Analytics ---
    pnl_ana = uipanel(fig, 'Title', 'AI Analytics / 解析データ', 'Position', [330 120 340 480], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    lbl_status = uilabel(pnl_ana, 'Text', 'Best: ---', 'FontSize', 16, 'FontWeight', 'bold', 'Position', [20 400 300 40], 'FontColor', [1.0 0.8 0.2]);
    lbl_details = uilabel(pnl_ana, 'Text', 'Weight: --- kg | Cost: --- JPY', 'FontSize', 12, 'Position', [20 370 300 30], 'FontColor', txt_color);
    ax_bar = uiaxes(pnl_ana, 'Position', [20 20 300 320], 'Color', bg_color, 'XColor', txt_color, 'YColor', txt_color);

    % --- Right: HYPER 3D PREVIEW ---
    pnl_3d = uipanel(fig, 'Title', 'Hyper-Virtual 3D Engine / 仮想3D', 'Position', [680 120 450 480], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    ax_3d = uiaxes(pnl_3d, 'Position', [10 10 430 430], 'Color', [0 0 0], 'XColor', 'none', 'YColor', 'none');
    view(ax_3d, 3); axis(ax_3d, 'equal'); grid(ax_3d, 'on');

    btn_run = uibutton(fig, 'push', 'Text', '🚀 GENERATE DESIGN CERTIFICATE (PDF)', 'FontSize', 16, 'FontWeight', 'bold', 'BackgroundColor', [0.1 0.6 0.3], 'FontColor', 'white', 'Position', [100 30 950 70]);

    % --- 💎 Advanced Rendering Logic ---
    function render_hyper_3d(t, mat_name)
        cla(ax_3d);
        % Material properties
        if contains(mat_name, 'Aluminum')
            col = [0.8 0.8 0.85]; mat_type = 'metal'; edge_col = 'none';
        elseif contains(mat_name, 'Steel')
            col = [0.3 0.35 0.4]; mat_type = 'shiny'; edge_col = [0.2 0.2 0.2];
        elseif contains(mat_name, 'Carbon')
            col = [0.1 0.1 0.1]; mat_type = 'dull'; edge_col = [0.3 0.3 0.3];
        else
            col = [0.2 0.6 0.8]; mat_type = 'shiny'; edge_col = 'none';
        end

        % Draw block
        L = 150; W = 50;
        verts = [0 0 0; L 0 0; L W 0; 0 W 0; 0 0 t; L 0 t; L W t; 0 W t];
        faces = [1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8; 1 2 3 4; 5 6 7 8];
        patch(ax_3d, 'Faces', faces, 'Vertices', verts, 'FaceColor', col, 'EdgeColor', edge_col, 'FaceLighting', 'gouraud');
        
        % Hyper Lighting
        camlight(ax_3d, 'headlight'); camlight(ax_3d, 'right');
        material(ax_3d, mat_type);
        title(ax_3d, sprintf('[Render] %s (%.1fmm)', mat_name, t), 'Color', 'w', 'FontSize', 14);
        axis(ax_3d, 'tight'); axis(ax_3d, 'equal');
    end

    % --- Real-time Sync ---
    function sync_ui(~, ~)
        try
            catalog = readtable(data_path); mats = unique(catalog.Material); all_sols = [];
            for i = 1:length(mats)
                m_data = catalog(strcmp(catalog.Material, mats{i}), :);
                min_t = (sld_load.Value / m_data.StrengthFactor(1)) * 0.1 * sld_safety.Value;
                idx = find(m_data.Thickness >= min_t, 1, 'first');
                if ~isempty(idx), sol.Mat = string(mats{i}); sol.T = m_data.Thickness(idx); sol.W = (300) * sol.T * m_data.Density(idx); sol.P = m_data.Price_JPY(idx); all_sols = [all_sols; sol]; end
            end
            [~, b_idx] = min([all_sols.W]); final = all_sols(b_idx);
            
            lbl_status.Text = ['👑 Winner: ', char(final.Mat)];
            lbl_details.Text = sprintf('Weight: %.3f kg | Cost: %d JPY', final.W, final.P);
            
            bar(ax_bar, [all_sols.W], 'FaceColor', [0.2 0.7 0.8]); set(ax_bar, 'XTickLabel', {all_sols.Mat}); ylabel(ax_bar, 'Weight [kg]', 'Color', txt_color);
            
            render_hyper_3d(final.T, final.Mat);
        catch, end
    end

    btn_run.ButtonPushedFcn = @(btn, event) run_full();
    function run_full()
        btn_run.Text = '⌛ Generating Official PDF... / 証明書を作成中...'; btn_run.Enable = 'off'; drawnow;
        AMD_Main_Brain(sld_load.Value, sld_budget.Value, sld_safety.Value, current_lang);
        sync_ui(); 
        btn_run.Text = '🚀 GENERATE DESIGN CERTIFICATE (PDF)'; btn_run.Enable = 'on';
        winopen(output_dir); % Automatically open the folder to show the PDF
    end

    % Init
    addlistener(sld_load, 'ValueChanged', @sync_ui);
    addlistener(sld_budget, 'ValueChanged', @sync_ui);
    addlistener(sld_safety, 'ValueChanged', @sync_ui);
    sync_ui();
end
