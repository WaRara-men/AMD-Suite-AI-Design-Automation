% ==========================================
% Algo-Mech Designer (AMD) Suite - App v7.4
% Full UI Restoration & Auto-Cleanup
% ==========================================

function AMD_App()
    % --- 0. Setup Paths ---
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    data_path = fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv');
    output_dir = fullfile(project_root, 'out');
    addpath(src_dir);

    % --- 1. Startup Cleanup / 起動時にお掃除 ---
    fprintf('🧹 [CLEAN] Cleaning project environment...\n');
    stray = {'*.asv', 'AMD_*.pdf', 'Final_*.pdf', '*.docx', 'ai_analysis_plot.png', 'sensitivity_plot.png'};
    for s = 1:length(stray)
        delete(fullfile(project_root, stray{s}));
        delete(fullfile(src_dir, stray{s}));
    end

    % --- 2. UI Construction ---
    bg_color = [0.05 0.05 0.08]; panel_bg = [0.1 0.1 0.15]; txt_color = [0.95 0.95 0.95];
    fig = uifigure('Name', 'AMD Suite v7.4 - Final Clean Edition', 'Position', [100 100 1150 650], 'Color', bg_color);
    current_lang = 'JP';

    % Language Switch
    btn_lang = uibutton(fig, 'push', 'Text', '🌐 Switch to English', 'Position', [1000 610 130 30], 'BackgroundColor', [0.2 0.2 0.2], 'FontColor', 'w');

    % Settings Panel
    pnl_settings = uipanel(fig, 'Title', 'Design Parameters', 'Position', [20 120 300 480], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    uilabel(pnl_settings, 'Text', 'Target Load [kg]:', 'Position', [10 410 200 22], 'FontColor', txt_color);
    sld_load = uislider(pnl_settings, 'Limits', [5 100], 'Value', 30, 'Position', [20 390 250 3], 'FontColor', txt_color);
    uilabel(pnl_settings, 'Text', 'Budget Limit [JPY]:', 'Position', [10 310 200 22], 'FontColor', txt_color);
    sld_budget = uislider(pnl_settings, 'Limits', [500 20000], 'Value', 5000, 'Position', [20 290 250 3], 'FontColor', txt_color);
    uilabel(pnl_settings, 'Text', 'Safety Factor:', 'Position', [10 210 200 22], 'FontColor', txt_color);
    sld_safety = uislider(pnl_settings, 'Limits', [1.0 3.0], 'Value', 1.5, 'Position', [20 190 250 3], 'FontColor', txt_color);

    % Analytics Panel
    pnl_ana = uipanel(fig, 'Title', 'AI Analytics', 'Position', [330 120 340 480], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    lbl_status = uilabel(pnl_ana, 'Text', 'Best: ---', 'FontSize', 16, 'FontWeight', 'bold', 'Position', [20 420 300 40], 'FontColor', [1.0 0.8 0.2]);
    ax_bar = uiaxes(pnl_ana, 'Position', [20 20 300 380], 'Color', bg_color, 'XColor', txt_color, 'YColor', txt_color);

    % 3D Preview Panel
    pnl_3d = uipanel(fig, 'Title', 'Live 3D Preview', 'Position', [680 120 450 480], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    ax_3d = uiaxes(pnl_3d, 'Position', [10 10 430 430], 'Color', [0 0 0], 'XColor', 'none', 'YColor', 'none');
    view(ax_3d, 3); axis(ax_3d, 'equal'); grid(ax_3d, 'on');

    % RUN BUTTON
    btn_run = uibutton(fig, 'push', 'Text', '🚀 GENERATE DESIGN CERTIFICATE (PDF)', 'FontSize', 16, 'FontWeight', 'bold', 'BackgroundColor', [0.1 0.6 0.3], 'FontColor', 'white', 'Position', [100 30 950 70]);

    % --- 3. Logic Functions ---
    function render_3d(t, mat)
        cla(ax_3d);
        col = [0.7 0.7 0.8]; if contains(mat, 'Carbon'), col = [0.1 0.1 0.1]; end
        L = 150; W = 50;
        verts = [0 0 0; L 0 0; L W 0; 0 W 0; 0 0 t; L 0 t; L W t; 0 W t];
        faces = [1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8; 1 2 3 4; 5 6 7 8];
        patch(ax_3d, 'Faces', faces, 'Vertices', verts, 'FaceColor', col, 'EdgeColor', 'w');
        axis(ax_3d, 'tight'); axis(ax_3d, 'equal'); camlight(ax_3d, 'headlight'); material(ax_3d, 'shiny');
    end

    function sync_ui(~, ~)
        try
            catalog = readtable(data_path); mats = unique(catalog.Material); all_sols = [];
            for i = 1:length(mats)
                m_data = catalog(strcmp(catalog.Material, mats{i}), :);
                min_t = (sld_load.Value / m_data.StrengthFactor(1)) * 0.1 * sld_safety.Value;
                idx = find(m_data.Thickness >= min_t, 1, 'first');
                if ~isempty(idx), sol.Mat = string(mats{i}); sol.T = m_data.Thickness(idx); sol.W = (300) * sol.T * m_data.Density(idx); all_sols = [all_sols; sol]; end
            end
            [~, b_idx] = min([all_sols.W]); final = all_sols(b_idx);
            lbl_status.Text = ['👑 Best: ', char(final.Mat)];
            bar(ax_bar, [all_sols.W], 'FaceColor', [0.2 0.7 0.8]); set(ax_bar, 'XTickLabel', {all_sols.Mat});
            render_3d(final.T, final.Mat);
        catch, end
    end

    btn_run.ButtonPushedFcn = @(btn, event) run_full_process();
    function run_full_process()
        btn_run.Text = '⌛ Generating Official Certificate...'; btn_run.Enable = 'off'; drawnow;
        AMD_Main_Brain(sld_load.Value, sld_budget.Value, sld_safety.Value, current_lang);
        sync_ui();
        btn_run.Text = '🚀 GENERATE DESIGN CERTIFICATE (PDF)'; btn_run.Enable = 'on';
    end

    % Event Listeners
    addlistener(sld_load, 'ValueChanged', @sync_ui);
    addlistener(sld_budget, 'ValueChanged', @sync_ui);
    addlistener(sld_safety, 'ValueChanged', @sync_ui);
    sync_ui(); % Initial Draw
end
