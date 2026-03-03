% ==========================================
% Algo-Mech Designer (AMD) Suite - App v5.7
% Hyper-Robust Connection Dashboard
% ==========================================

function AMD_App()
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    data_path = fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv');
    output_dir = fullfile(project_root, 'out');
    addpath(src_dir);

    bg_color = [0.05 0.05 0.08]; panel_bg = [0.1 0.1 0.15]; txt_color = [0.9 0.9 0.9];
    fig = uifigure('Name', 'AMD Suite v5.7 - Connection Booster', 'Position', [100 100 1150 650], 'Color', bg_color);
    current_lang = 'JP';

    % Indicator
    uilabel(fig, 'Text', 'SW Connection Status:', 'Position', [20 615 150 22], 'FontColor', 'w');
    status_lamp = uilamp(fig, 'Position', [170 615 20 20], 'Color', [0.8 0.2 0.2]);
    lbl_sw = uilabel(fig, 'Text', 'OFFLINE (INITIALIZING)', 'Position', [200 615 400 22], 'FontColor', [0.8 0.2 0.2]);

    % Panels (Simplified)
    pnl_settings = uipanel(fig, 'Title', 'Settings', 'Position', [20 120 300 480], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    sld_load = uislider(pnl_settings, 'Limits', [5 100], 'Value', 30, 'Position', [20 400 250 3]);
    sld_budget = uislider(pnl_settings, 'Limits', [500 20000], 'Value', 5000, 'Position', [20 300 250 3]);
    btn_test_sw = uibutton(pnl_settings, 'push', 'Text', '🔄 RE-SCAN SOLIDWORKS', 'Position', [50 50 200 40]);

    pnl_3d = uipanel(fig, 'Title', '3D View', 'Position', [680 120 450 480], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    ax_3d = uiaxes(pnl_3d, 'Position', [10 10 430 430], 'Color', [0 0 0], 'XColor', 'none', 'YColor', 'none');
    view(ax_3d, 3); axis(ax_3d, 'equal'); grid(ax_3d, 'on');

    btn_run = uibutton(fig, 'push', 'Text', '🚀 RUN ANALYSIS', 'FontSize', 16, 'FontWeight', 'bold', 'BackgroundColor', [0.5 0.1 0.1], 'FontColor', 'white', 'Position', [100 30 950 70]);

    % --- 🚀 Super Robust Connection Test ---
    btn_test_sw.ButtonPushedFcn = @(btn, event) check_sw_robust();
    function connected = check_sw_robust()
        lbl_sw.Text = 'SCANNING... / 探索中...'; status_lamp.Color = [0.8 0.8 0.2]; drawnow;
        try
            % Try multiple methods to find the server
            try
                swApp = actxGetRunningServer('SldWorks.Application');
            catch
                swApp = actxserver('SldWorks.Application');
            end
            
            if ~isempty(swApp) && ~isempty(swApp.ActiveDoc)
                lbl_sw.Text = ['ONLINE: ', swApp.ActiveDoc.GetTitle()];
                lbl_sw.FontColor = [0.3 0.8 0.3]; status_lamp.Color = [0.3 0.8 0.3];
                connected = true;
            elseif ~isempty(swApp)
                lbl_sw.Text = 'ONLINE (BUT NO PART OPEN)';
                lbl_sw.FontColor = [0.8 0.8 0.2]; status_lamp.Color = [0.8 0.8 0.2];
                connected = false;
            else
                error('SW App handle is empty');
            end
        catch
            lbl_sw.Text = 'OFFLINE (RETRY AS ADMINISTRATOR?)';
            lbl_sw.FontColor = [0.8 0.2 0.2]; status_lamp.Color = [0.8 0.2 0.2];
            connected = false;
        end
    end

    % --- Core Logic ---
    function update_ui(~, ~)
        try
            % Virtual preview logic
            cla(ax_3d);
            verts = [0 0 0; 150 0 0; 150 50 0; 0 50 0; 0 0 2; 150 0 2; 150 50 2; 0 50 2];
            faces = [1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8; 1 2 3 4; 5 6 7 8];
            patch(ax_3d, 'Faces', faces, 'Vertices', verts, 'FaceColor', [0.3 0.5 0.7], 'EdgeColor', 'w');
            axis(ax_3d, 'tight'); axis(ax_3d, 'equal'); camlight(ax_3d, 'headlight');
        catch, end
    end

    btn_run.ButtonPushedFcn = @(btn, event) run_all();
    function run_all()
        btn_run.Text = '⌛ Processing...'; btn_run.Enable = 'off'; drawnow;
        AMD_Main_Brain(sld_load.Value, sld_budget.Value, 1.5, current_lang);
        btn_run.Text = '🚀 RUN ANALYSIS'; btn_run.Enable = 'on';
        check_sw_robust();
    end

    addlistener(sld_load, 'ValueChanged', @update_ui);
    update_ui();
    check_sw_robust();
end
