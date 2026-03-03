% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v5.8
% Unsinkable SW Connection Logic
% ==========================================

function AMD_Main_Brain(target_load, budget_limit, safety_factor, lang)
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    output_dir = fullfile(project_root, 'out');
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end
    
    % --- 1. AI Logic (Assumption: result in final_sol) ---
    % ... (Existing stable optimization logic) ...
    final_sol.T = 2.0; final_sol.Material = "Aluminum"; final_sol.Price = 1000;

    % --- 2. 🛰️ [NEW] Safe SolidWorks Interface ---
    stl_path = fullfile(output_dir, 'View_in_3D.stl');
    sw_success = false;
    
    fprintf('🛰️ [CONN] Safe-hooking SolidWorks... / SWへの安全な接続を試行中...\n');
    try
        swApp = [];
        % Attempt to attach to existing
        try swApp = actxGetRunningServer('SldWorks.Application'); catch; end
        % If not found, attempt to create
        if isempty(swApp), swApp = actxserver('SldWorks.Application'); end
        
        % Check if SW App is genuinely usable
        if iscom(swApp)
            swModel = swApp.ActiveDoc;
            if ~isempty(swModel)
                fprintf('   -> ✅ Connected to part: %s\n', swModel.GetTitle());
                % Update Thickness
                param = swModel.Parameter('Thickness');
                if ~isempty(param)
                    param.SystemValue = final_sol.T / 1000;
                    swModel.EditRebuild3();
                end
                % Export STL
                swModel.SaveAs2(stl_path, 0, true, false);
                sw_success = true;
            else
                fprintf('   -> ⚠️ No active part found in SolidWorks.\n');
            end
        else
            fprintf('   -> ❌ SW COM object is invalid.\n');
        end
    catch ME
        fprintf('   -> ❌ Connection Error: %s\n', ME.message);
    end

    if ~sw_success && exist(stl_path, 'file'), delete(stl_path); end

    % --- 3. Reporting ---
    pdf_path = fullfile(output_dir, 'Final_Design_Report.pdf');
    try
        word = actxserver('Word.Application'); doc = word.Documents.Add;
        doc.SaveAs2(pdf_path, 17); doc.Close; word.Quit;
    catch, if exist('word', 'var'), word.Quit; end; end
end
