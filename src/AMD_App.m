% ==========================================
% Algo-Mech Designer (AMD) Suite - App v3.5
% Interactive Dashboard with Analytics
% ==========================================

function AMD_App()
    src_dir = fileparts(mfilename('fullpath'));
    addpath(src_dir);
    data_path = fullfile(fileparts(src_dir), 'data', 'Standard_Parts_Catalog.csv');

    fig = uifigure('Name', 'AMD Suite - Analytical Dashboard', 'Position', [100 100 900 550]);
    
    % --- Left Panel ---
    pnl_settings = uipanel(fig, 'Title', 'Settings', 'Position', [20 120 280 400]);
    uilabel(pnl_settings, 'Text', 'Load [kg]:', 'Position', [10 330 100 22]);
    sld_load = uislider(pnl_settings, 'Limits', [5 100], 'Value', 30, 'Position', [20 320 230 3]);
    uilabel(pnl_settings, 'Text', 'Budget [JPY]:', 'Position', [10 260 100 22]);
    sld_budget = uislider(pnl_settings, 'Limits', [500 20000], 'Value', 5000, 'Position', [20 250 230 3]);
    uilabel(pnl_settings, 'Text', 'Safety Factor:', 'Position', [10 190 100 22]);
    sld_safety = uislider(pnl_settings, 'Limits', [1.0 3.0], 'Value', 1.5, 'Position', [20 180 230 3]);

    % --- Center/Right Panel: Analytics ---
    pnl_ana = uipanel(fig, 'Title', 'Advanced Analytics / 高度な解析', 'Position', [320 120 560 400]);
    ax_bar = uiaxes(pnl_ana, 'Position', [30 210 240 150]); title(ax_bar, 'Current Weight');
    ax_line = uiaxes(pnl_ana, 'Position', [300 30 240 330]); title(ax_line, 'Sensitivity (Weight vs Load)');
    lbl_status = uilabel(pnl_ana, 'Text', 'Best: ---', 'FontSize', 14, 'FontWeight', 'bold', 'Position', [30 30 240 30]);

    % --- Bottom ---
    btn_run = uibutton(fig, 'push', 'Text', '🚀 RUN ANALYSIS & LOG HISTORY', ...
        'FontSize', 14, 'FontWeight', 'bold', 'BackgroundColor', [0.2 0.4 0.7], 'FontColor', 'white', ...
        'Position', [100 30 700 60]);

    function update_ui(~, ~)
        try
            catalog = readtable(data_path);
            mats = unique(catalog.Material);
            all_sols = [];
            
            % Real-time bar chart
            for i = 1:length(mats)
                m_data = catalog(strcmp(catalog.Material, mats{i}), :);
                min_t = (sld_load.Value / m_data.StrengthFactor(1)) * 0.1 * sld_safety.Value;
                idx = find(m_data.Thickness >= min_t, 1, 'first');
                if ~isempty(idx)
                    sol.Mat = string(mats{i});
                    sol.W = (300) * m_data.Thickness(idx) * m_data.Density(idx);
                    all_sols = [all_sols; sol];
                end
            end
            bar(ax_bar, [all_sols.W]); set(ax_bar, 'XTickLabel', {all_sols.Mat});
            
            % Sensitivity Trend
            load_range = linspace(sld_load.Value*0.5, sld_load.Value*1.5, 10);
            hold(ax_line, 'off');
            for i = 1:length(mats)
                m_data = catalog(strcmp(catalog.Material, mats{i}), :);
                w_trend = [];
                for l = load_range
                    t_req = (l / m_data.StrengthFactor(1)) * 0.1 * sld_safety.Value;
                    v_idx = find(m_data.Thickness >= t_req, 1, 'first');
                    if ~isempty(v_idx), w_trend(end+1) = (300) * m_data.Thickness(v_idx) * m_data.Density(v_idx);
                    else w_trend(end+1) = NaN; end
                end
                plot(ax_line, load_range, w_trend, '-o', 'DisplayName', char(mats{i})); hold(ax_line, 'on');
            end
            grid(ax_line, 'on'); xlabel(ax_line, 'Load'); ylabel(ax_line, 'Weight');
            
            % Best Label
            feasible = all_sols; % Simplified for real-time
            [~, b_idx] = min([feasible.W]);
            lbl_status.Text = ['🏆 Winner: ', char(feasible(b_idx).Mat)];
        catch
        end
    end

    btn_run.ButtonPushedFcn = @(btn, event) run_and_log();
    function run_and_log()
        btn_run.Text = '⌛ Calculating & Logging...'; btn_run.Enable = 'off'; drawnow;
        AMD_Main_Brain(sld_load.Value, sld_budget.Value, sld_safety.Value);
        btn_run.Text = '🚀 RUN ANALYSIS & LOG HISTORY'; btn_run.Enable = 'on';
    end

    update_ui();
    addlistener(sld_load, 'ValueChanged', @update_ui);
    addlistener(sld_budget, 'ValueChanged', @update_ui);
    addlistener(sld_safety, 'ValueChanged', @update_ui);
end
