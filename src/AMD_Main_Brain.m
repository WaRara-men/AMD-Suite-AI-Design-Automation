% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v6.5
% Admin-Level Connection & CLSID Discovery
% ==========================================

function AMD_Main_Brain(target_load, budget_limit, safety_factor, lang)
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    output_dir = fullfile(project_root, 'out');
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end
    
    % --- 1. AI Logic (Simplified logic assumed for focus on SW) ---
    final_sol.T = 2.0; final_sol.Material = "Aluminum";

    % --- 2. 🛰️ [NEW] Super-Powered Admin Connection ---
    stl_path = fullfile(output_dir, 'View_in_3D.stl');
    sw_synced = false;
    fprintf('🛰️ [ADMIN] Attempting privileged connection... / 特権接続を試行中...\n');
    
    try
        % Method A: Standard Server Hook
        swApp = actxserver('SldWorks.Application');
        
        % Method B: CLSID Check (Deep registry discovery)
        if isempty(swApp)
            fprintf('   -> 🔍 Method B: Attempting via CLSID...\n');
            swApp = actxserver('{B4875574-4D45-11D1-A28C-00C04FBD2A07}'); % Generic SW CLSID
        end
        
        % If we have the app, FORCE ActiveDoc retrieval
        if iscom(swApp)
            swModel = swApp.ActiveDoc;
            if ~isempty(swModel)
                fprintf('   -> ✅ Privilege Bypass Success! Linked to: %s\n', swModel.GetTitle());
                % Parameter Injection
                param = swModel.Parameter('Thickness');
                if ~isempty(param)
                    param.SystemValue = final_sol.T / 1000;
                    swModel.EditRebuild3();
                    fprintf('   -> 📐 Thickness updated to %.1f mm\n', final_sol.T);
                end
                swModel.SaveAs2(stl_path, 0, true, false);
                sw_synced = true;
            else
                fprintf('   -> ⚠️ SW reachable, but ActiveDoc is restricted by permissions.\n');
                fprintf('   -> 💡 HELP: Close SW and re-run BOTH MATLAB and SW as ADMINISTRATOR.\n');
            end
        end
    catch ME
        fprintf('   -> ❌ Critical Connection Error: %s\n', ME.message);
    end

    % --- 3. Final Voice Report ---
    try
        NET.addAssembly('System.Speech'); speak = System.Speech.Synthesis.SpeechSynthesizer;
        if sw_synced
            msg = '接続に成功しました！モデルを確認してください。';
        else
            msg = '管理者権限の壁に阻まれました。両方のアプリを管理者として実行し直してください。';
        end
        speak.Speak(msg);
    catch, end
end
