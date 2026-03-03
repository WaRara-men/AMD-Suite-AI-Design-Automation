% ==========================================
% Algo-Mech Designer (AMD) Suite - App v4.8
% Dashboard with Virtual 3D & Auto-Organizer
% ==========================================

function AMD_App()
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    data_path = fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv');
    output_dir = fullfile(project_root, 'out');
    addpath(src_dir);

    % Colors
    bg_color = [0.05 0.05 0.08];
    panel_bg = [0.1 0.1 0.15];
    txt_color = [0.9 0.9 0.9];

    fig = uifigure('Name', 'AMD Suite v4.8 - Ultimate Clean Dashboard', 'Position', [100 100 1050 600], 'Color', bg_color);
    current_lang = 'JP';

    % --- UI Setup ---
    btn_lang = uibutton(fig, 'push', 'Text', '🌐 Switch to English', 'Position', [900 560 130 30], 'BackgroundColor', [0.2 0.2 0.2], 'FontColor', 'w');
    
    pnl_settings = uipanel(fig, 'Title', 'Settings', 'Position', [20 120 250 430], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    sld_load = uislider(pnl_settings, 'Limits', [5 100], 'Value', 30, 'Position', [20 350 210 3]);
    sld_budget = uislider(pnl_settings, 'Limits', [500 20000], 'Value', 5000, 'Position', [20 250 210 3]);

    pnl_ana = uipanel(fig, 'Title', 'Analysis', 'Position', [280 120 340 430], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    ax_bar = uiaxes(pnl_ana, 'Position', [20 150 300 220], 'Color', bg_color, 'XColor', txt_color, 'YColor', txt_color);
    lbl_status = uilabel(pnl_ana, 'Text', 'Best: ---', 'FontSize', 14, 'FontWeight', 'bold', 'Position', [20 20 300 40], 'FontColor', [0.4 0.9 0.4]);

    pnl_3d = uipanel(fig, 'Title', 'Live 3D Preview (Real or Virtual)', 'Position', [630 120 400 430], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    ax_3d = uiaxes(pnl_3d, 'Position', [10 10 380 380], 'Color', [0 0 0], 'XColor', 'none', 'YColor', 'none');
    view(ax_3d, 3); axis(ax_3d, 'equal'); grid(ax_3d, 'on'); 

    btn_run = uibutton(fig, 'push', 'Text', '🚀 RUN ANALYSIS & ORGANIZE FILES', 'FontSize', 16, 'FontWeight', 'bold', 'BackgroundColor', [0.5 0.1 0.1], 'FontColor', 'white', 'Position', [100 30 850 70]);

    % --- 💎 Improved 3D View (Real STL or Virtual Block) ---
    function update_3d_view(final_t)
        cla(ax_3d);
        stl_file = fullfile(output_dir, 'View_in_3D.stl');
        
        if exist(stl_file, 'file')
            % Try to load Real STL
            try
                [v, f] = stlread(stl_file);
                patch(ax_3d, 'Faces', f, 'Vertices', v, 'FaceColor', [0.6 0.6 0.7], 'EdgeColor', 'none', 'FaceLighting', 'gouraud');
                title(ax_3d, 'SolidWorks: Real Model', 'Color', 'w');
            catch
                show_virtual_block(final_t);
            end
        else
            % No STL, show Virtual Block
            show_virtual_block(final_t);
        end
        material(ax_3d, 'shiny'); camlight(ax_3d, 'headlight');
    end

    function show_virtual_block(t)
        % Generate a simple 3D block in the axis
        [X, Y, Z] = meshgrid([0 150], [0 50], [0 t]);
        K = convhull(X(:), Y(:), Z(:));
        trisurf(K, X(:), Y(:), Z(:), 'FaceColor', [0.2 0.6 0.8], 'EdgeColor', 'w', 'Parent', ax_3d);
        title(ax_3d, 'Virtual Preview (No SW)', 'Color', 'y');
    end

    % --- Logic ---
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
            bar(ax_bar, [all_sols.W], 'FaceColor', [0.2 0.5 0.8]); set(ax_bar, 'XTickLabel', {all_sols.Mat});
            update_3d_view(final.T); % Real-time virtual update
        catch
        end
    end

    btn_run.ButtonPushedFcn = @(btn, event) run_all();
    function run_all()
        btn_run.Text = '⌛ Processing & Cleaning...'; btn_run.Enable = 'off'; drawnow;
        AMD_Main_Brain(sld_load.Value, sld_budget.Value, 1.5, current_lang);
        update_ui(); 
        btn_run.Text = '🚀 RUN ANALYSIS & ORGANIZE FILES'; btn_run.Enable = 'on';
    end

    addlistener(sld_load, 'ValueChanged', @update_ui);
    addlistener(sld_budget, 'ValueChanged', @update_ui);
    update_ui();
end
