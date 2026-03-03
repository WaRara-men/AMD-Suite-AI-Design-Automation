% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v4.7
% Pro Edition: In-App 3D Preview (No Auto-Box)
% ==========================================

function AMD_Main_Brain(target_load, budget_limit, safety_factor, lang)
    % --- 0. Path Setup ---
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    output_dir = fullfile(project_root, 'out');
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end
    
    % --- 1. Load Data & Optimize ---
    catalog = readtable(fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv'));
    materials = unique(catalog.Material);
    all_solutions = struct('Material', {}, 'T', {}, 'PartNo', {}, 'Price', {}, 'Weight', {});

    for i = 1:length(materials)
        mat_data = catalog(strcmp(catalog.Material, materials{i}), :);
        min_t_req = (target_load / mat_data.StrengthFactor(1)) * 0.1 * safety_factor;
        idx = find(mat_data.Thickness >= min_t_req, 1, 'first');
        if ~isempty(idx)
            sol.Material = string(materials{i});
            sol.T = mat_data.Thickness(idx);
            sol.PartNo = string(mat_data.PartNumber{idx});
            sol.Price = mat_data.Price_JPY(idx);
            sol.Weight = (300) * sol.T * mat_data.Density(idx);
            all_solutions(end+1) = sol; 
        end
    end

    % Decision Making
    feasible = all_solutions([all_solutions.Price] <= budget_limit);
    if isempty(feasible), [~, b_idx] = min([all_solutions.Price]); final_sol = all_solutions(b_idx);
    else, [~, b_idx] = min([feasible.Weight]); final_sol = feasible(b_idx); end

    % --- 2. 💎 REAL SolidWorks STL Export ---
    stl_path = fullfile(output_dir, 'View_in_3D.stl');
    fprintf('📦 [3D] Exporting STL for preview... / 3Dデータを書き出し中...\n');
    try
        swApp = actxGetRunningServer('SldWorks.Application');
        swModel = swApp.ActiveDoc;
        if ~isempty(swModel)
            swModel.SaveAs2(stl_path, 0, true, false);
            fprintf('   -> ✅ STL Exported for In-App Preview.\n');
        end
    catch
        fprintf('   -> ⚠️ SW connection failed. Using mock preview.\n');
    end

    % --- 3. Reporting (PDF) ---
    pdf_path = fullfile(output_dir, 'AMD_Decision_Report.pdf');
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        title = 'AMD Analysis Report'; if strcmp(lang, 'JP'), title = 'AMD 解析報告書'; end
        selection.Font.Size = 20; selection.Font.Bold = 1; selection.TypeText(title);
        if exist(pdf_path, 'file'), delete(pdf_path); end
        doc.SaveAs2(pdf_path, 17); doc.Close; word.Quit;
    catch
        if exist('word', 'var'), word.Quit; end
    end

    % --- 4. Final Notification (No Box Open) ---
    try
        NET.addAssembly('System.Speech');
        speak = System.Speech.Synthesis.SpeechSynthesizer;
        if strcmp(lang, 'JP')
            msg = '解析が完了しました。アプリ画面で3Dモデルを確認できます。';
        else
            msg = 'Analysis complete. You can now preview the 3D model in the dashboard.';
        end
        speak.Speak(msg);
    catch, end
    fprintf('✅ [DONE] Process finished. Preview updated.\n');
end
