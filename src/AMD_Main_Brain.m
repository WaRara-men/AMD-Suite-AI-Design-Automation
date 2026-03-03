% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v6.2
% SW Dimension Scanner & Dimension Inspector
% ==========================================

function AMD_Main_Brain(target_load, budget_limit, safety_factor, lang)
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    data_dir = fullfile(project_root, 'data');
    output_dir = fullfile(project_root, 'out');
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end
    
    % --- 1. AI Logic ---
    catalog = readtable(fullfile(data_dir, 'Standard_Parts_Catalog.csv'));
    materials = unique(catalog.Material); all_sols = struct('Material', {}, 'T', {}, 'PartNo', {}, 'Price', {}, 'Weight', {});
    for i = 1:length(materials)
        mat_data = catalog(strcmp(catalog.Material, materials{i}), :);
        min_t_req = (target_load / mat_data.StrengthFactor(1)) * 0.1 * safety_factor;
        idx = find(mat_data.Thickness >= min_t_req, 1, 'first');
        if ~isempty(idx)
            sol.Material = string(materials{i}); sol.T = mat_data.Thickness(idx);
            sol.PartNo = string(mat_data.PartNumber{idx}); sol.Price = mat_data.Price_JPY(idx);
            sol.Weight = (300) * sol.T * mat_data.Density(idx); all_sols(end+1) = sol; 
        end
    end
    [~, b_idx] = min([all_sols.Weight]); final_sol = all_sols(b_idx);

    % --- 2. 🛰️ [NEW] Full Model Dimension Scanner ---
    stl_path = fullfile(output_dir, 'View_in_3D.stl');
    sw_synced = false;
    fprintf('\n🔍 [SCAN] Scanning SolidWorks Model Dimensions... / 全寸法をスキャン中...\n');
    
    try
        swApp = actxGetRunningServer('SldWorks.Application');
        swModel = swApp.ActiveDoc;
        if ~isempty(swModel)
            fprintf('--- Dimensions found in your model / 見つかった寸法一覧 ---\n');
            % 🎯 Get all dimensions using DisplayDimension traversal
            swFeat = swModel.FirstFeature;
            while ~isempty(swFeat)
                swDispDim = swFeat.GetFirstDisplayDimension;
                while ~isempty(swDispDim)
                    swDim = swDispDim.GetDimension;
                    dimName = swDim.FullName;
                    dimVal = swDim.SystemValue * 1000; % meters to mm
                    fprintf('   [*] Name: %s (Current: %.2f mm)\n', dimName, dimVal);
                    
                    % 🌟 Automatic Matching Logic
                    % If name contains "Thickness" or "D1@Boss-Extrude1" (common names)
                    target_names = {'Thickness', '厚み', 'D1@Boss-Extrude1', 'D1@押し出し1', 'D1@Sketch1'};
                    for tn = 1:length(target_names)
                        if contains(dimName, target_names{tn}, 'IgnoreCase', true)
                            swDim.SystemValue = final_sol.T / 1000;
                            sw_synced = true;
                            fprintf('      -> ✅ MATCHED and UPDATED!\n');
                        end
                    end
                    swDispDim = swFeat.GetNextDisplayDimension(swDispDim);
                end
                swFeat = swFeat.GetNextFeature;
            end
            fprintf('-------------------------------------------------------\n');
            
            if sw_synced
                swModel.EditRebuild3();
                swModel.SaveAs2(stl_path, 0, true, false);
            end
        end
    catch ME
        fprintf('   -> ⚠️ Connection Error: %s\n', ME.message);
    end

    if ~sw_synced && exist(stl_path, 'file'), delete(stl_path); end

    % --- 3. Reporting & Voice ---
    try
        NET.addAssembly('System.Speech'); speak = System.Speech.Synthesis.SpeechSynthesizer;
        if sw_synced
            msg = '同期に成功しました！モデルを見てください！';
        else
            msg = 'モデルの寸法が見つかりませんでした。画面の一覧を確認してください。';
        end
        speak.Speak(msg);
    catch, end
    fprintf('✅ [DONE] Check command window for scan results.\n');
end
