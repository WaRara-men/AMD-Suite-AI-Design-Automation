% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v4.9
% Stable 3D Engine & Robust SW Interface
% ==========================================

function AMD_Main_Brain(target_load, budget_limit, safety_factor, lang)
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    data_dir = fullfile(project_root, 'data');
    output_dir = fullfile(project_root, 'out');
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end
    
    % --- 1. AI Logic ---
    catalog = readtable(fullfile(data_dir, 'Standard_Parts_Catalog.csv'));
    materials = unique(catalog.Material);
    all_solutions = struct('Material', {}, 'T', {}, 'PartNo', {}, 'Price', {}, 'Weight', {});

    for i = 1:length(materials)
        mat_data = catalog(strcmp(catalog.Material, materials{i}), :);
        min_t_req = (target_load / mat_data.StrengthFactor(1)) * 0.1 * safety_factor;
        idx = find(mat_data.Thickness >= min_t_req, 1, 'first');
        if ~isempty(idx)
            sol.Material = string(materials{i}); sol.T = mat_data.Thickness(idx);
            sol.PartNo = string(mat_data.PartNumber{idx}); sol.Price = mat_data.Price_JPY(idx);
            sol.Weight = (300) * sol.T * mat_data.Density(idx); all_solutions(end+1) = sol; 
        end
    end

    feasible = all_solutions([all_solutions.Price] <= budget_limit);
    if isempty(feasible), [~, b_idx] = min([all_solutions.Price]); final_sol = all_solutions(b_idx);
    else, [~, b_idx] = min([feasible.Weight]); final_sol = feasible(b_idx); end

    % --- 2. 💎 Robust SolidWorks Interface ---
    stl_path = fullfile(output_dir, 'View_in_3D.stl');
    fprintf('📦 [3D] Checking SolidWorks Status... / SWの状態を確認中...\n');
    sw_success = false;
    try
        swApp = actxGetRunningServer('SldWorks.Application');
        swModel = swApp.ActiveDoc;
        if ~isempty(swModel)
            swModel.SaveAs2(stl_path, 0, true, false);
            fprintf('   -> ✅ Real STL Generated from SolidWorks!\n');
            sw_success = true;
        else
            fprintf('   -> ⚠️ SW is open, but NO PART is active. / パーツが開かれていません。\n');
        end
    catch
        fprintf('   -> ⚠️ SolidWorks not detected. Falling back to Virtual.\n');
    end

    % If SW failed, remove old STL to force Virtual Preview
    if ~sw_success && exist(stl_path, 'file'), delete(stl_path); end

    % --- 3. Reporting (PDF) ---
    pdf_path = fullfile(output_dir, 'AMD_Decision_Report.pdf');
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        title = 'AMD Analysis Report'; if strcmp(lang, 'JP'), title = 'AMD 解析報告書'; end
        selection.Font.Size = 20; selection.Font.Bold = 1; selection.TypeText(title);
        doc.SaveAs2(pdf_path, 17); doc.Close; word.Quit;
    catch
        if exist('word', 'var'), word.Quit; end
    end

    % --- 4. 🧹 Auto-Organizer ---
    temp_patterns = {'*.asv', '*.m~', 'temp_*.*'};
    for p = 1:length(temp_patterns), delete(fullfile(src_dir, temp_patterns{p})); end

    % --- 5. Voice ---
    try
        NET.addAssembly('System.Speech');
        speak = System.Speech.Synthesis.SpeechSynthesizer;
        msg = '解析完了。'; if ~strcmp(lang, 'JP'), msg = 'Analysis complete.'; end
        speak.Speak(msg);
    catch, end
end
