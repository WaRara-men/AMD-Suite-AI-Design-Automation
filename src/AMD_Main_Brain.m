% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v6.3
% Persistent ActiveDoc Retrieval & Fix
% ==========================================

function AMD_Main_Brain(target_load, budget_limit, safety_factor, lang)
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    output_dir = fullfile(project_root, 'out');
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end
    
    % --- 1. AI Logic ---
    catalog = readtable(fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv'));
    materials = unique(catalog.Material); all_sols = struct('Material', {}, 'T', {}, 'PartNo', {}, 'Price', {}, 'Weight', {});
    for i = 1:length(materials)
        mat_data = catalog(strcmp(catalog.Material, materials{i}), :);
        min_t_req = (target_load / mat_data.StrengthFactor(1)) * 0.1 * safety_factor;
        idx = find(mat_data.Thickness >= min_t_req, 1, 'first');
        if ~isempty(idx)
            sol.Material = string(materials{i}); sol.T = mat_data.Thickness(idx);
            all_sols(end+1) = sol; 
        end
    end
    [~, b_idx] = min([all_sols.Weight]); final_sol = all_sols(b_idx);

    % --- 2. 🛰️ [NEW] Persistent SolidWorks Discovery ---
    stl_path = fullfile(output_dir, 'View_in_3D.stl');
    sw_synced = false;
    fprintf('🛰️ [CONN] Attempting to find active model... / アクティブなモデルを探索中...\n');
    
    try
        swApp = actxGetRunningServer('SldWorks.Application');
        % 🎯 Try to get ActiveDoc multiple times / しつこく取得を試みる
        swModel = [];
        for retry = 1:3
            try swModel = swApp.ActiveDoc; catch; end
            if ~isempty(swModel), break; end
            pause(0.5);
        end
        
        if ~isempty(swModel)
            fprintf('   -> ✅ Connected: %s\n', swModel.GetTitle());
            
            % List and Update
            swFeat = swModel.FirstFeature;
            while ~isempty(swFeat)
                swDispDim = swFeat.GetFirstDisplayDimension;
                while ~isempty(swDispDim)
                    swDim = swDispDim.GetDimension;
                    dimName = swDim.FullName;
                    % target: 厚みに関連しそうな名前をすべて更新
                    targets = {'Thickness', 'D1@Boss-Extrude1', 'D1@押し出し1', 'D1@Sketch1'};
                    for t = 1:length(targets)
                        if contains(dimName, targets{t}, 'IgnoreCase', true)
                            swDim.SystemValue = final_sol.T / 1000;
                            sw_synced = true;
                            fprintf('      -> 📐 Dimension "%s" updated to %.1f mm\n', dimName, final_sol.T);
                        end
                    end
                    swDispDim = swFeat.GetNextDisplayDimension(swDispDim);
                end
                swFeat = swFeat.GetNextFeature;
            end
            
            if sw_synced
                swModel.EditRebuild3();
                swModel.SaveAs2(stl_path, 0, true, false);
            end
        else
            fprintf('   -> ⚠️ SW found, but ActiveDoc is inaccessible. Try clicking SW window first!\n');
        end
    catch
        fprintf('   -> ❌ SolidWorks server not found.\n');
    end

    % --- 3. Reporting & Voice ---
    try
        NET.addAssembly('System.Speech'); speak = System.Speech.Synthesis.SpeechSynthesizer;
        if sw_synced, msg = 'モデルとの同期に成功しました。';
        else, msg = '解析完了。モデルが見つかりませんでした。'; end
        speak.Speak(msg);
    catch, end
end
