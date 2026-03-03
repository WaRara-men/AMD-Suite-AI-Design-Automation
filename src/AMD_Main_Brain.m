% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v6.4
% Fixed Struct Errors & Bulletproof Brain
% ==========================================

function AMD_Main_Brain(target_load, budget_limit, safety_factor, lang)
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    output_dir = fullfile(project_root, 'out');
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end
    
    % --- 1. AI Logic (Stable Struct Pattern) ---
    catalog = readtable(fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv'));
    materials = unique(catalog.Material);
    
    % Use empty array of structs with pre-defined fields
    all_sols = []; 

    for i = 1:length(materials)
        mat_data = catalog(strcmp(catalog.Material, materials{i}), :);
        min_t_req = (target_load / mat_data.StrengthFactor(1)) * 0.1 * safety_factor;
        idx = find(mat_data.Thickness >= min_t_req, 1, 'first');
        if ~isempty(idx)
            % Define all fields every time
            sol.Material = string(materials{i}); 
            sol.T = mat_data.Thickness(idx);
            sol.PartNo = string(mat_data.PartNumber{idx}); 
            sol.Price = mat_data.Price_JPY(idx);
            sol.Weight = (300) * sol.T * mat_data.Density(idx);
            
            if isempty(all_sols), all_sols = sol; else, all_sols(end+1) = sol; end
        end
    end
    [~, b_idx] = min([all_sols.Weight]); final_sol = all_sols(b_idx);

    % --- 2. 🛰️ Robust SolidWorks Discovery ---
    fprintf('🛰️ [CONN] Searching for SolidWorks model... / モデルを探索中...\n');
    stl_path = fullfile(output_dir, 'View_in_3D.stl');
    sw_synced = false;
    
    try
        swApp = actxGetRunningServer('SldWorks.Application');
        % Check multiple times
        swModel = [];
        for r = 1:3
            try swModel = swApp.ActiveDoc; catch; end
            if ~isempty(swModel), break; end
            pause(0.3);
        end
        
        if ~isempty(swModel)
            fprintf('   -> ✅ Linked: %s\n', swModel.GetTitle());
            % Dim Sync
            params = {'Thickness', 'D1@Boss-Extrude1', 'D1@押し出し1'};
            for p = 1:length(params)
                dim = swModel.Parameter(params{p});
                if ~isempty(dim)
                    dim.SystemValue = final_sol.T / 1000;
                    sw_synced = true;
                    fprintf('      -> 📐 Dimension "%s" updated.\n', params{p});
                    break;
                end
            end
            swModel.EditRebuild3();
            swModel.SaveAs2(stl_path, 0, true, false);
        end
    catch; end

    % --- 3. Final Voice ---
    try
        NET.addAssembly('System.Speech'); speak = System.Speech.Synthesis.SpeechSynthesizer;
        msg = sprintf('解析完了。最適な素材は、%s、です。', char(final_sol.Material));
        speak.Speak(msg);
    catch, end
end
