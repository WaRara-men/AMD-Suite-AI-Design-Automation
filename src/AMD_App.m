% ==========================================
% Algo-Mech Designer (AMD) Suite - App v4.3
% Global Edition: Language Toggle & 3D Sync
% ==========================================

function AMD_App()
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    data_path = fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv');
    addpath(src_dir);

    % Colors
    bg_color = [0.1 0.1 0.12];
    panel_bg = [0.15 0.15 0.2];
    txt_color = [0.9 0.9 0.9];

    fig = uifigure('Name', 'AMD Suite v4.3 - Global 3D Dashboard', 'Position', [100 100 950 550], 'Color', bg_color);
    
    % --- Language State ---
    current_lang = 'JP'; % Default

    % --- Language Switcher (NEW) ---
    btn_lang = uibutton(fig, 'push', 'Text', '🌐 Switch to English', 'Position', [800 500 130 30], ...
        'BackgroundColor', [0.3 0.3 0.3], 'FontColor', 'w');

    % UI Components
    pnl_settings = uipanel(fig, 'Title', '設計設定 / Settings', 'Position', [20 120 280 370], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    lbl_load = uilabel(pnl_settings, 'Text', '目標荷重 / Load [kg]:', 'Position', [10 300 200 22], 'FontColor', txt_color);
    sld_load = uislider(pnl_settings, 'Limits', [5 100], 'Value', 30, 'Position', [20 290 230 3]);
    
    lbl_budget = uilabel(pnl_settings, 'Text', '予算制限 / Budget [JPY]:', 'Position', [10 230 200 22], 'FontColor', txt_color);
    sld_budget = uislider(pnl_settings, 'Limits', [500 20000], 'Value', 5000, 'Position', [20 220 230 3]);

    pnl_ana = uipanel(fig, 'Title', '解析 / Analytics', 'Position', [320 120 610 370], 'BackgroundColor', panel_bg, 'ForegroundColor', txt_color);
    lbl_status = uilabel(pnl_ana, 'Text', '最適な素材: ---', 'FontSize', 18, 'FontWeight', 'bold', 'Position', [30 30 500 40], 'FontColor', [0.4 0.9 0.4]);
    ax = uiaxes(pnl_ana, 'Position', [30 80 550 250], 'Color', bg_color, 'XColor', txt_color, 'YColor', txt_color);

    btn_run = uibutton(fig, 'push', 'Text', '🚀 全自動解析 & 3D同期 (RUN)', ...
        'FontSize', 16, 'FontWeight', 'bold', 'BackgroundColor', [0.7 0.2 0.2], 'FontColor', 'white', ...
        'Position', [100 30 750 70]);

    % --- Language Toggle Logic ---
    btn_lang.ButtonPushedFcn = @(btn, event) toggle_lang();
    function toggle_lang()
        if strcmp(current_lang, 'JP')
            current_lang = 'EN';
            btn_lang.Text = '🌐 日本語に切替';
            lbl_load.Text = 'Target Load [kg]:';
            lbl_budget.Text = 'Budget Limit [JPY]:';
            btn_run.Text = '🚀 RUN AI & SYNC MOBILE 3D';
            pnl_settings.Title = 'Settings';
            pnl_ana.Title = 'Analytics';
        else
            current_lang = 'JP';
            btn_lang.Text = '🌐 Switch to English';
            lbl_load.Text = '目標荷重 / Load [kg]:';
            lbl_budget.Text = '予算制限 / Budget [JPY]:';
            btn_run.Text = '🚀 全自動解析 & 3D同期 (RUN)';
            pnl_settings.Title = '設計設定';
            pnl_ana.Title = '解析';
        end
        update_ui();
    end

    % --- Core UI Sync ---
    function update_ui(~, ~)
        try
            catalog = readtable(data_path);
            mats = unique(catalog.Material);
            all_sols = [];
            for i = 1:length(mats)
                m_data = catalog(strcmp(catalog.Material, mats{i}), :);
                min_t = (sld_load.Value / m_data.StrengthFactor(1)) * 0.1 * 1.5;
                idx = find(m_data.Thickness >= min_t, 1, 'first');
                if ~isempty(idx), sol.Mat = string(mats{i}); sol.W = (300) * m_data.Thickness(idx) * m_data.Density(idx); all_sols = [all_sols; sol]; end
            end
            [~, b_idx] = min([all_sols.W]); final = all_sols(b_idx);
            
            if strcmp(current_lang, 'JP'), lbl_status.Text = ['🏆 最適な素材: ', char(final.Mat)];
            else, lbl_status.Text = ['🏆 Winner: ', char(final.Mat)]; end
            
            bar(ax, [all_sols.W], 'FaceColor', [0.2 0.5 0.8]); set(ax, 'XTickLabel', {all_sols.Mat});
        catch
        end
    end

    % --- Run Process ---
    btn_run.ButtonPushedFcn = @(btn, event) run_global_process();
    function run_global_process()
        btn_run.Text = '...Processing / 実行中...'; btn_run.Enable = 'off'; drawnow;
        
        % Run Brain with Language Info
        AMD_Main_Brain(sld_load.Value, sld_budget.Value, 1.5, current_lang);
        
        % 📢 Voice (Language Aware!)
        try
            NET.addAssembly('System.Speech');
            speak = System.Speech.Synthesis.SpeechSynthesizer;
            if strcmp(current_lang, 'JP')
                speak.Speak(['解析が完了しました。最適な素材は、', char(lbl_status.Text(9:end)), 'です。']);
            else
                speak.Speak(['Analysis complete. Best choice is ', char(lbl_status.Text(11:end)), '.']);
            end
        catch, end
        
        if strcmp(current_lang, 'JP'), btn_run.Text = '🚀 全自動解析 & 3D同期 (RUN)';
        else, btn_run.Text = '🚀 RUN AI & SYNC MOBILE 3D'; end
        btn_run.Enable = 'on';
        
        msgbox('Sync Success! Check your Mobile Box app for 3D preview.', 'Global Sync');
    end

    addlistener(sld_load, 'ValueChanged', @update_ui);
    addlistener(sld_budget, 'ValueChanged', @update_ui);
    update_ui();
end
