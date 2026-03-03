% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v5.5
% Robust SW Connection & Flexible Dimensioning
% ==========================================

function AMD_Main_Brain(target_load, budget_limit, safety_factor, lang)
    % --- 0. Path Setup ---
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    output_dir = fullfile(project_root, 'out');
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end
    
    % --- 1. AI Optimization ---
    catalog = readtable(fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv'));
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
    feasible = all_sols([all_sols.Price] <= budget_limit);
    if isempty(feasible), [~, b_idx] = min([all_sols.Price]); final_sol = all_sols(b_idx);
    else, [~, b_idx] = min([feasible.Weight]); final_sol = feasible(b_idx); end

    % --- 2. 🛰️ [FIXED] Robust SolidWorks Connection ---
    stl_path = fullfile(output_dir, 'View_in_3D.stl');
    fprintf('🛰️ [DIAG] Connecting to SolidWorks... / SWに接続中...\n');
    sw_success = false;
    
    try
        % Try to hook into the running SW instance
        swApp = actxGetRunningServer('SldWorks.Application');
        % [FIX] Removed .Visible property to avoid COM error
        
        swModel = swApp.ActiveDoc;
        if ~isempty(swModel)
            % 🎯 Try multiple common dimension naming patterns
            % "Thickness", "Thickness@Sketch1", "Thickness@Boss-Extrude1" etc.
            dim_names = {'Thickness', 'Thickness@Sketch1', 'Thickness@Sketch2', 'Thickness@Boss-Extrude1'};
            found_dim = false;
            
            for d = 1:length(dim_names)
                param = swModel.Parameter(dim_names{d});
                if ~isempty(param)
                    param.SystemValue = final_sol.T / 1000; % mm to meters
                    swModel.EditRebuild3();
                    fprintf('   -> ✅ Dimension "%s" updated to %.1f mm\n', dim_names{d}, final_sol.T);
                    found_dim = true;
                    break;
                end
            end
            
            if ~found_dim
                fprintf('   -> ⚠️ No "Thickness" dimension found. Ensure your dimension is named exactly "Thickness".\n');
            end
            
            % Force STL Export
            swModel.SaveAs2(stl_path, 0, true, false);
            sw_success = true;
        else
            fprintf('   -> ⚠️ SolidWorks is open but no part file is active.\n');
        end
    catch
        fprintf('   -> ⚠️ SolidWorks connection failed. Switching to Virtual Mode.\n');
    end

    if ~sw_success && exist(stl_path, 'file'), delete(stl_path); end

    % --- 3. Professional Reporting (PDF) ---
    pdf_path = fullfile(output_dir, 'Final_Design_Report.pdf');
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        title = 'AMD Analysis Report'; if strcmp(lang, 'JP'), title = 'AMD 解析報告書'; end
        selection.Font.Size = 20; selection.Font.Bold = 1; selection.TypeText(title);
        doc.SaveAs2(pdf_path, 17); doc.Close; word.Quit;
    catch, if exist('word', 'var'), word.Quit; end; end

    % --- 4. 🔊 Eloquent Voice ---
    try
        NET.addAssembly('System.Speech'); speak = System.Speech.Synthesis.SpeechSynthesizer;
        if strcmp(lang, 'JP')
            msg = sprintf('解析が完了しました。最適な素材は、%s、です。', char(final_sol.Material));
        else
            msg = sprintf('Analysis complete. The best material is %s.', char(final_sol.Material));
        end
        speak.Speak(msg);
    catch, end

    % --- 5. Cleanup ---
    delete(fullfile(src_dir, '*.asv')); 
    delete(fullfile(project_root, 'AMD Final Result*.*'));
    delete(fullfile(project_root, 'AMD 解析報告書*.*'));
end
