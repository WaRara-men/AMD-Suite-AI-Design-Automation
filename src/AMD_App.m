% ==========================================
% Algo-Mech Designer (AMD) Suite - App v5.6
% Dashboard with Connection Indicator
% ==========================================

function AMD_App()
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    data_path = fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv');
    output_dir = fullfile(project_root, 'out');
    addpath(src_dir);

    % [STARTUP CLEANUP]
    delete(fullfile(project_root, 'AMD*.*')); % Clear old stray reports

    bg_color = [0.05 0.05 0.08]; panel_bg = [0.1 0.1 0.15]; txt_color = [0.9 0.9 0.9];
    fig = uifigure('Name', 'AMD Suite v5.6 - Smart Connection Suite', 'Position', [100 100 1150 650], 'Color', bg_color);
    current_lang = 'JP';

    % --- Top Bar ---
    btn_lang = uibutton(fig, 'push', 'Text', '🌐 Switch Language', 'Position', [1000 610 130 30], 'BackgroundColor', [0.2 0.2 0.2], 'FontColor', 'w');
    
    % 🛰️ [NEW] CONNECTION INDICATOR
    uilabel(fig, 'Text', 'SW Connection:', 'Position', [20 615 100 22], 'FontColor', 'w');
    status_lamp = uilamp(fig, 'Position', [120 615 20 20], 'Color', [0.8 0.2 0.2]); % Red by default
    lbl_sw = uilabel(fig, 'Text', 'OFFLINE', 'Position', [150 615 200 22], 'FontColor', [0.8 0.2 0.2]);

    % Panels
    pnl_settings = uipanel(fig, 'Title', 'Design Settings', 'Position', [20 120 300 480], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    sld_load = uislider(pnl_settings, 'Limits', [5 100], 'Value', 30, 'Position', [20 400 250 3]);
    sld_budget = uislider(pnl_settings, 'Limits', [500 20000], 'Value', 5000, 'Position', [20 300 250 3]);

    btn_test_sw = uibutton(pnl_settings, 'push', 'Text', '🔄 TEST SW CONNECTION', 'Position', [50 50 200 40], ...
        'BackgroundColor', [0.3 0.3 0.3], 'FontColor', 'w');

    pnl_ana = uipanel(fig, 'Title', 'Analytics', 'Position', [330 120 340 480], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    ax_bar = uiaxes(pnl_ana, 'Position', [20 200 300 220], 'Color', bg_color, 'XColor', txt_color, 'YColor', txt_color);
    lbl_status = uilabel(pnl_ana, 'Text', 'Best: ---', 'FontSize', 14, 'FontWeight', 'bold', 'Position', [20 20 300 40], 'FontColor', [0.4 0.9 0.4]);

    pnl_3d = uipanel(fig, 'Title', '3D Preview', 'Position', [680 120 450 480], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    ax_3d = uiaxes(pnl_3d, 'Position', [10 10 430 430], 'Color', [0 0 0], 'XColor', 'none', 'YColor', 'none');
    view(ax_3d, 3); axis(ax_3d, 'equal'); grid(ax_3d, 'on');

    btn_run = uibutton(fig, 'push', 'Text', '🚀 RUN & SYNC 3D', 'FontSize', 16, 'FontWeight', 'bold', 'BackgroundColor', [0.5 0.1 0.1], 'FontColor', 'white', 'Position', [100 30 950 70]);

    % --- Connection Logic ---
    btn_test_sw.ButtonPushedFcn = @(btn, event) check_sw_connection();
    function connected = check_sw_connection()
        lbl_sw.Text = 'SCANNING...'; status_lamp.Color = [0.8 0.8 0.2]; drawnow;
        try
            swApp = actxserver('SldWorks.Application');
            if ~isempty(swApp.ActiveDoc)
                lbl_sw.Text = ['ONLINE: ', swApp.ActiveDoc.GetTitle()];
                lbl_sw.FontColor = [0.3 0.8 0.3]; status_lamp.Color = [0.3 0.8 0.3];
                connected = true;
            else
                lbl_sw.Text = 'ONLINE (BUT NO PART OPEN)';
                lbl_sw.FontColor = [0.8 0.8 0.2]; status_lamp.Color = [0.8 0.8 0.2];
                connected = false;
            end
        catch
            lbl_sw.Text = 'OFFLINE (SW NOT DETECTED)';
            lbl_sw.FontColor = [0.8 0.2 0.2]; status_lamp.Color = [0.8 0.2 0.2];
            connected = false;
        end
    end

    % --- Sync ---
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
            lbl_status.Text = ['🏆 Best: ', char(final.Mat)];
            bar(ax_bar, [all_sols.W], 'FaceColor', [0.3 0.5 0.7]); set(ax_bar, 'XTickLabel', {all_sols.Mat});
            
            % Draw fallback preview
            cla(ax_3d);
            verts = [0 0 0; 150 0 0; 150 50 0; 0 50 0; 0 0 final.T; 150 0 final.T; 150 50 final.T; 0 50 final.T];
            faces = [1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8; 1 2 3 4; 5 6 7 8];
            patch(ax_3d, 'Faces', faces, 'Vertices', verts, 'FaceColor', [0.3 0.5 0.7], 'EdgeColor', 'w');
            axis(ax_3d, 'tight'); axis(ax_3d, 'equal'); camlight(ax_3d, 'headlight');
        catch
        end
    end

    btn_run.ButtonPushedFcn = @(btn, event) run_all();
    function run_all()
        btn_run.Text = '⌛ Processing...'; btn_run.Enable = 'off'; drawnow;
        AMD_Main_Brain(sld_load.Value, sld_budget.Value, 1.5, current_lang);
        update_ui(); 
        btn_run.Text = '🚀 RUN & SYNC 3D'; btn_run.Enable = 'on';
        check_sw_connection(); % Refresh connection lamp
    end

    addlistener(sld_load, 'ValueChanged', @update_ui);
    addlistener(sld_budget, 'ValueChanged', @update_ui);
    update_ui();
    check_sw_connection(); % Initial check
end
