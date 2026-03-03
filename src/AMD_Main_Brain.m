% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v5.2
% Ultimate Direct SolidWorks Link (Zero Setup)
% ==========================================

function AMD_Main_Brain(target_load, budget_limit, safety_factor, lang)
    % --- 0. Path Setup ---
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    output_dir = fullfile(project_root, 'out');
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end
    
    % --- 1. AI Optimization (Standard logic) ---
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

    % --- 2. 🪄 [NEW] MAGIC: Direct SolidWorks Parameter Injection ---
    fprintf('🪄 [MAGIC] Attempting direct link to SolidWorks... / SWへ直接数値を流し込み中...\n');
    try
        swApp = actxGetRunningServer('SldWorks.Application');
        swModel = swApp.ActiveDoc;
        if ~isempty(swModel)
            % 🎯 直接「Thickness」という名前の寸法を探して書き込む
            % 寸法名は "Thickness@Sketch1" や "Thickness@Boss-Extrude1" などに対応
            % モデル内の全パラメータを走査
            
            % Set Thickness / 厚みをセット
            status = swModel.Parameter('Thickness');
            if ~isempty(status)
                % SolidWorks expects meters, so mm / 1000
                status.SystemValue = final_sol.T / 1000; 
                fprintf('   -> ✅ Dimension "Thickness" updated to %.1f mm\n', final_sol.T);
            else
                fprintf('   -> ⚠️ Dimension name "Thickness" not found in model.\n');
            end
            
            % Set Width / 幅もついでにセット
            status_w = swModel.Parameter('Width');
            if ~isempty(status_w)
                status_w.SystemValue = 150 / 1000; % 150mm
            end

            % 🌟 Force Update
            swModel.EditRebuild3(); 
            
            % Save preview STL
            stl_path = fullfile(output_dir, 'View_in_3D.stl');
            swModel.SaveAs2(stl_path, 0, true, false);
        else
            error('No active part');
        end
    catch ME
        fprintf('   -> 🌐 Direct link failed: %s. Using virtual preview.\n', ME.message);
    end

    % --- 3. Reporting (PDF) ---
    pdf_path = fullfile(output_dir, 'Final_Design_Report.pdf');
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        title = 'AMD Analysis Report'; if strcmp(lang, 'JP'), title = 'AMD 解析報告書'; end
        selection.Font.Size = 20; selection.Font.Bold = 1; selection.TypeText(title);
        doc.SaveAs2(pdf_path, 17); doc.Close; word.Quit;
    catch, if exist('word', 'var'), word.Quit; end; end

    % --- 4. Eloquent Voice ---
    try
        NET.addAssembly('System.Speech'); speak = System.Speech.Synthesis.SpeechSynthesizer;
        msg = sprintf('解析完了。最適な素材は、%s、です。', char(final_sol.Material));
        if ~strcmp(lang, 'JP'), msg = sprintf('Analysis complete. Best is %s.', char(final_sol.Material)); end
        speak.Speak(msg);
    catch, end
end
