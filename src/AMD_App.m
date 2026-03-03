% ==========================================
% Algo-Mech Designer (AMD) Suite - App v4.1
% Fixed Gauge Error & Auto-Cleanup System
% ==========================================

function AMD_App()
    % --- 0. Path Management / パス管理 ---
    % Get project root / プロジェクトのルートを取得
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    data_path = fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv');
    addpath(src_dir);

    % Dark Theme Colors
    bg_color = [0.15 0.15 0.18];
    panel_bg = [0.2 0.2 0.25];
    txt_color = [0.9 0.9 0.9];

    fig = uifigure('Name', 'AMD Suite v4.1 - Clean Enterprise Dashboard', 'Position', [100 100 950 550], 'Color', bg_color);
    
    % --- Left Panel ---
    pnl_settings = uipanel(fig, 'Title', 'Settings', 'Position', [20 120 280 400], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    uilabel(pnl_settings, 'Text', 'Load [kg]:', 'Position', [10 330 100 22], 'FontColor', txt_color);
    sld_load = uislider(pnl_settings, 'Limits', [5 100], 'Value', 30, 'Position', [20 320 230 3], 'FontColor', txt_color);
    uilabel(pnl_settings, 'Text', 'Budget [JPY]:', 'Position', [10 260 100 22], 'FontColor', txt_color);
    sld_budget = uislider(pnl_settings, 'Limits', [500 20000], 'Value', 5000, 'Position', [20 250 230 3], 'FontColor', txt_color);
    uilabel(pnl_settings, 'Text', 'Safety Factor:', 'Position', [10 190 100 22], 'FontColor', txt_color);
    sld_safety = uislider(pnl_settings, 'Limits', [1.0 3.0], 'Value', 1.5, 'Position', [20 180 230 3], 'FontColor', txt_color);

    % Budget Gauge (FIXED: Compatible with all MATLAB versions)
    uilabel(pnl_settings, 'Text', 'Budget Usage / 予算使用率:', 'Position', [10 90 200 22], 'FontColor', txt_color);
    gauge_budget = uigauge(pnl_settings, 'linear', 'Position', [20 40 230 40], 'Limits', [0 100]);
    % Set colors via ScaleColors (Standard property)
    try
        gauge_budget.ScaleColors = [0 0.8 0; 0.8 0.8 0; 0.8 0 0];
        gauge_budget.ScaleColorLimits = [0 50; 50 80; 80 100];
    catch
        % Fallback for older versions
    end

    % --- Center/Right Panel ---
    pnl_ana = uipanel(fig, 'Title', 'Live Analytics', 'Position', [320 120 610 400], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    ax_bar = uiaxes(pnl_ana, 'Position', [20 200 280 160], 'Color', bg_color, 'XColor', txt_color, 'YColor', txt_color); title(ax_bar, 'Weight', 'Color', txt_color);
    ax_line = uiaxes(pnl_ana, 'Position', [320 20 270 340], 'Color', bg_color, 'XColor', txt_color, 'YColor', txt_color); title(ax_line, 'Sensitivity', 'Color', txt_color);
    lbl_status = uilabel(pnl_ana, 'Text', 'Best: ---', 'FontSize', 16, 'FontWeight', 'bold', 'Position', [30 30 280 30], 'FontColor', [0.3 0.8 0.3]);

    % --- Bottom Buttons ---
    btn_run = uibutton(fig, 'push', 'Text', '🚀 GENERATE PDF REPORT', ...
        'FontSize', 14, 'FontWeight', 'bold', 'BackgroundColor', [0.8 0.3 0.2], 'FontColor', 'white', ...
        'Position', [100 30 500 60]);
        
    btn_git = uibutton(fig, 'push', 'Text', '🌐 PUSH TO GITHUB', ...
        'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', [0.2 0.2 0.2], 'FontColor', 'white', ...
        'Position', [650 30 200 60]);

    % --- UI Sync Logic ---
    function update_ui(~, ~)
        try
            catalog = readtable(data_path);
            mats = unique(catalog.Material);
            all_sols = [];
            for i = 1:length(mats)
                m_data = catalog(strcmp(catalog.Material, mats{i}), :);
                min_t = (sld_load.Value / m_data.StrengthFactor(1)) * 0.1 * sld_safety.Value;
                idx = find(m_data.Thickness >= min_t, 1, 'first');
                if ~isempty(idx)
                    sol.Mat = string(mats{i});
                    sol.Weight = (300) * m_data.Thickness(idx) * m_data.Density(idx);
                    sol.Price = m_data.Price_JPY(idx);
                    all_sols = [all_sols; sol];
                end
            end
            feasible = all_sols([all_sols.Price] <= sld_budget.Value);
            if isempty(feasible), [~, b_idx] = min([all_sols.Price]); final = all_sols(b_idx);
            else, [~, b_idx] = min([feasible.Weight]); final = feasible(b_idx); end
            
            lbl_status.Text = ['🏆 Winner: ', char(final.Mat)];
            gauge_budget.Value = min(100, (final.Price / sld_budget.Value) * 100);
            bar(ax_bar, [all_sols.Weight], 'FaceColor', [0.3 0.6 0.8]); set(ax_bar, 'XTickLabel', {all_sols.Mat});
        catch
        end
    end

    btn_run.ButtonPushedFcn = @(btn, event) run_process();
    function run_process()
        btn_run.Text = '⌛ Processing...'; btn_run.Enable = 'off'; drawnow;
        AMD_Main_Brain(sld_load.Value, sld_budget.Value, sld_safety.Value);
        btn_run.Text = '🚀 GENERATE PDF REPORT'; btn_run.Enable = 'on';
    end

    btn_git.ButtonPushedFcn = @(btn, event) system(sprintf('cd "%s" && git add . && git commit -m "Auto-update" && git push', project_root));

    update_ui();
    addlistener(sld_load, 'ValueChanged', @update_ui);
    addlistener(sld_budget, 'ValueChanged', @update_ui);
    addlistener(sld_safety, 'ValueChanged', @update_ui);
end
