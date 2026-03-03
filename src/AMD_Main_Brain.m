% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v5.1
% SolidWorks Force-Sync & Clear Reporting
% ==========================================

function AMD_Main_Brain(target_load, budget_limit, safety_factor, lang)
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    output_dir = fullfile(project_root, 'out');
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end
    
    % --- 1. AI Optimization (Calculates final_sol) ---
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

    % --- 2. [UPDATE] Bridge Nerve (Must be saved BEFORE SW Sync) ---
    T_bridge = cell2table({final_sol.T, 150, char(final_sol.Material), final_sol.Price}, ...
        'VariableNames', {'Thickness', 'Width', 'Material', 'Price'});
    writetable(T_bridge, fullfile(output_dir, 'Bridge_Nerve.csv'));

    % --- 3. [UPDATE] Intelligent SolidWorks Sync ---
    stl_path = fullfile(output_dir, 'View_in_3D.stl');
    fprintf('📦 [3D] Synchronizing with SolidWorks... / SWと同期中...\n');
    try
        swApp = actxGetRunningServer('SldWorks.Application');
        swModel = swApp.ActiveDoc;
        if ~isempty(swModel)
            % 🌟 FORCE REBUILD: これでモデルが最新のCSVを読み込みます
            swModel.ForceRebuild3(true);
            % Save current state as STL
            swModel.SaveAs2(stl_path, 0, true, false);
            fprintf('   -> ✅ SW Model Updated and STL Generated.\n');
        else
            error('No active part');
        end
    catch
        fprintf('   -> 🌐 SW Sync failed. Showing Virtual Preview.\n');
        if exist(stl_path, 'file'), delete(stl_path); end
    end

    % --- 4. Reporting (PDF) ---
    pdf_path = fullfile(output_dir, 'Final_Design_Report.pdf');
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        title = 'AMD Analysis Report'; if strcmp(lang, 'JP'), title = 'AMD 解析報告書'; end
        selection.Font.Size = 20; selection.Font.Bold = 1; selection.TypeText(title);
        doc.SaveAs2(pdf_path, 17); doc.Close; word.Quit;
        fprintf('📄 [REPORT] Saved at: %s\n', pdf_path);
    catch, if exist('word', 'var'), word.Quit; end; end

    % --- 5. Eloquent Voice ---
    try
        NET.addAssembly('System.Speech'); speak = System.Speech.Synthesis.SpeechSynthesizer;
        if strcmp(lang, 'JP')
            msg = sprintf('解析が完了しました。最適な素材は、%s、です。価格は、%d円、です。', char(final_sol.Material), final_sol.Price);
        else
            msg = sprintf('Analysis complete. The best material is %s, costing %d yen.', char(final_sol.Material), final_sol.Price);
        end
        speak.Speak(msg);
    catch, end
end
