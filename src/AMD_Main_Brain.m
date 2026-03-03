% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v6.6
% Ultra-Direct OS Hook for SolidWorks 2025
% ==========================================

function AMD_Main_Brain(target_load, budget_limit, safety_factor, lang)
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    output_dir = fullfile(project_root, 'out');
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end
    
    % --- 1. AI Logic Result (Assumption) ---
    final_sol.T = 2.0; 

    % --- 2. 🛰️ [NEW] OS-Level Direct Hook ---
    fprintf('🛰️ [FORCE] Hooking SW 2025 via OS-level interface... / 強制接続を試行中...\n');
    sw_success = false;
    stl_path = fullfile(output_dir, 'View_in_3D.stl');
    
    try
        % 🎯 Try pointing directly to SW 2025 (Version 33)
        % This bypasses generic naming issues.
        try
            swApp = actxGetRunningServer('SldWorks.Application.33');
        catch
            try
                swApp = actxGetRunningServer('SldWorks.Application');
            catch
                swApp = actxserver('SldWorks.Application.33');
            end
        end
        
        % Wait for server stabilization
        pause(0.5);
        
        if iscom(swApp)
            % Check property existence safely
            if isprop(swApp, 'ActiveDoc') || ismethod(swApp, 'ActiveDoc')
                swModel = swApp.ActiveDoc;
                if ~isempty(swModel)
                    fprintf('   -> ✅ OS-Hook Success! Connected to: %s\n', swModel.GetTitle());
                    % Dimension Update
                    param = swModel.Parameter('Thickness');
                    if ~isempty(param)
                        param.SystemValue = final_sol.T / 1000;
                        swModel.EditRebuild3();
                    end
                    swModel.SaveAs2(stl_path, 0, true, false);
                    sw_success = true;
                else
                    fprintf('   -> ⚠️ SW Hooked, but no active document detected.\n');
                end
            else
                fprintf('   -> ❌ Critical: SW object found, but API is restricted.\n');
            end
        end
    catch ME
        fprintf('   -> ❌ Fatal Connection Error: %s\n', ME.message);
    end

    % --- 3. Reporting & Feedback ---
    try
        NET.addAssembly('System.Speech'); speak = System.Speech.Synthesis.SpeechSynthesizer;
        if sw_success, msg = '強制接続に成功しました！'; else, msg = '接続できませんでした。仮想モードで継続します。'; end
        speak.Speak(msg);
    catch, end
end
