% ==========================================
% Algo-Mech Designer (AMD) Suite - App v6.0
% High-Visibility Dark Theme Dashboard
% ==========================================

function AMD_App()
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    data_path = fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv');
    output_dir = fullfile(project_root, 'out');
    addpath(src_dir);

    % Colors: High Visibility for Dark Theme
    bg_color = [0.05 0.05 0.08]; panel_bg = [0.1 0.1 0.15]; 
    txt_color = [0.95 0.95 0.95]; % ALMOST WHITE
    hint_color = [0.7 0.7 0.7];   % LIGHT GRAY

    fig = uifigure('Name', 'AMD Suite v6.0 - High Visibility Edition', 'Position', [100 100 1150 650], 'Color', bg_color);
    current_lang = 'JP';

    % --- UI: Header ---
    uilabel(fig, 'Text', 'SW Connection:', 'Position', [20 615 100 22], 'FontColor', 'w');
    status_lamp = uilamp(fig, 'Position', [120 615 20 20], 'Color', [0.8 0.2 0.2]);
    lbl_sw = uilabel(fig, 'Text', 'OFFLINE', 'Position', [150 615 400 22], 'FontColor', 'w');

    % --- UI: Settings (Fixed Text Colors) ---
    pnl_settings = uipanel(fig, 'Title', 'Design Settings', 'Position', [20 120 300 480], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    
    uilabel(pnl_settings, 'Text', '1. Target Load / 目標荷重 [kg]:', 'Position', [10 410 250 22], 'FontColor', txt_color, 'FontWeight', 'bold');
    uilabel(pnl_settings, 'Text', '→ 耐えたい重さを指定', 'Position', [20 395 250 15], 'FontColor', hint_color, 'FontSize', 10);
    sld_load = uislider(pnl_settings, 'Limits', [5 100], 'Value', 30, 'Position', [20 380 250 3], 'FontColor', txt_color);
    
    uilabel(pnl_settings, 'Text', '2. Budget Limit / 予算上限 [JPY]:', 'Position', [10 310 250 22], 'FontColor', txt_color, 'FontWeight', 'bold');
    uilabel(pnl_settings, 'Text', '→ 材料費の上限を指定', 'Position', [20 295 250 15], 'FontColor', hint_color, 'FontSize', 10);
    sld_budget = uislider(pnl_settings, 'Limits', [500 20000], 'Value', 5000, 'Position', [20 280 250 3], 'FontColor', txt_color);

    uilabel(pnl_settings, 'Text', '3. Safety Factor / 安全率:', 'Position', [10 210 250 22], 'FontColor', txt_color, 'FontWeight', 'bold');
    uilabel(pnl_settings, 'Text', '→ 壊れないための余裕 (1.5倍など)', 'Position', [20 195 250 15], 'FontColor', hint_color, 'FontSize', 10);
    sld_safety = uislider(pnl_settings, 'Limits', [1.0 3.0], 'Value', 1.5, 'Position', [20 180 250 3], 'FontColor', txt_color);

    btn_test = uibutton(pnl_settings, 'push', 'Text', '🔄 RE-SCAN SOLIDWORKS', 'Position', [50 50 200 40], 'BackgroundColor', [0.3 0.3 0.3], 'FontColor', 'w');

    % --- UI: Results & 3D ---
    pnl_ana = uipanel(fig, 'Title', 'Analysis Results', 'Position', [330 120 340 480], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    lbl_status = uilabel(pnl_ana, 'Text', 'Best: ---', 'FontSize', 14, 'FontWeight', 'bold', 'Position', [20 20 300 40], 'FontColor', [0.4 0.9 0.4]);
    ax_bar = uiaxes(pnl_ana, 'Position', [20 150 300 220], 'Color', bg_color, 'XColor', txt_color, 'YColor', txt_color);

    pnl_3d = uipanel(fig, 'Title', 'Live 3D Preview', 'Position', [680 120 450 480], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    ax_3d = uiaxes(pnl_3d, 'Position', [10 10 430 430], 'Color', [0 0 0], 'XColor', 'none', 'YColor', 'none');
    view(ax_3d, 3); axis(ax_3d, 'equal'); grid(ax_3d, 'on');

    btn_run = uibutton(fig, 'push', 'Text', '🚀 RUN ANALYSIS & GENERATE PDF', 'FontSize', 16, 'FontWeight', 'bold', 'BackgroundColor', [0.5 0.1 0.1], 'FontColor', 'white', 'Position', [100 30 950 70]);

    % --- Functions ---
    function check_sw()
        if ~isvalid(fig), return; end
        try
            swApp = actxGetRunningServer('SldWorks.Application');
            if ~isempty(swApp.ActiveDoc)
                lbl_sw.Text = ['ONLINE: ', swApp.ActiveDoc.GetTitle()];
                lbl_sw.FontColor = [0.3 0.8 0.3]; status_lamp.Color = [0.3 0.8 0.3];
            else, lbl_sw.Text = 'ONLINE (NO PART OPEN)'; lbl_sw.FontColor = [0.8 0.8 0.2]; status_lamp.Color = [0.8 0.8 0.2]; end
        catch, lbl_sw.Text = 'OFFLINE'; lbl_sw.FontColor = [0.8 0.2 0.2]; status_lamp.Color = [0.8 0.2 0.2]; end
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
            lbl_status.Text = ['🏆 Best: ', char(final.Mat)];
            bar(ax_bar, [all_sols.W], 'FaceColor', [0.3 0.5 0.7]); set(ax_bar, 'XTickLabel', {all_sols.Mat});
            % Draw fallback
            cla(ax_3d);
            verts = [0 0 0; 150 0 0; 150 50 0; 0 50 0; 0 0 final.T; 150 0 final.T; 150 50 final.T; 0 50 final.T];
            faces = [1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8; 1 2 3 4; 5 6 7 8];
            patch(ax_3d, 'Faces', faces, 'Vertices', verts, 'FaceColor', [0.3 0.5 0.7], 'EdgeColor', 'w');
            axis(ax_3d, 'tight'); axis(ax_3d, 'equal'); camlight(ax_3d, 'headlight');
        catch, end
    end

    btn_run.ButtonPushedFcn = @(btn, event) run_all();
    function run_all()
        btn_run.Text = '⌛ Analyzing...'; btn_run.Enable = 'off'; drawnow;
        AMD_Main_Brain(sld_load.Value, sld_budget.Value, sld_safety.Value, current_lang);
        sync_ui(); check_sw();
        btn_run.Text = '🚀 RUN ANALYSIS & GENERATE PDF'; btn_run.Enable = 'on';
    end

    btn_test.ButtonPushedFcn = @(btn, event) check_sw();
    addlistener(sld_load, 'ValueChanged', @sync_ui);
    addlistener(sld_budget, 'ValueChanged', @sync_ui);
    addlistener(sld_safety, 'ValueChanged', @sync_ui);
    sync_ui(); check_sw();
end
