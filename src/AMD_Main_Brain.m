% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v5.0
% Final Polish: Smart Voice & Clean Paths
% ==========================================

function AMD_Main_Brain(target_load, budget_limit, safety_factor, lang)
    % --- 0. Path Setup ---
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    output_dir = fullfile(project_root, 'out');
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end
    
    % --- 1. AI Optimization ---
    catalog = readtable(fullfile(project_root, 'data', 'Standard_Parts_Catalog.csv'));
    materials = unique(catalog.Material);
    all_sols = struct('Material', {}, 'T', {}, 'PartNo', {}, 'Price', {}, 'Weight', {});

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

    % --- 2. SolidWorks Export ---
    stl_path = fullfile(output_dir, 'View_in_3D.stl');
    try
        swApp = actxGetRunningServer('SldWorks.Application');
        swModel = swApp.ActiveDoc;
        if ~isempty(swModel)
            swModel.SaveAs2(stl_path, 0, true, false);
            fprintf('✅ [3D] Real STL saved to /out folder.\n');
        else
            if exist(stl_path, 'file'), delete(stl_path); end
        end
    catch
        if exist(stl_path, 'file'), delete(stl_path); end
    end

    % --- 3. [NEW] Absolute Path Reporting / 保存場所の固定 ---
    pdf_name = 'Final_Design_Report.pdf';
    report_name = 'Final_Design_Report.docx';
    pdf_path = fullfile(output_dir, pdf_name);
    report_path = fullfile(output_dir, report_name);
    
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        
        % Multilingual Report Content
        if strcmp(lang, 'JP')
            selection.TypeText('AMD AI設計報告書'); selection.TypeParagraph;
            selection.TypeText(sprintf('荷重: %dkg, 素材: %s, 価格: %d円', target_load, final_sol.Material, final_sol.Price));
        else
            selection.TypeText('AMD AI Design Report'); selection.TypeParagraph;
            selection.TypeText(sprintf('Load: %dkg, Best: %s, Price: %d JPY', target_load, final_sol.Material, final_sol.Price));
        end
        
        if exist(report_path, 'file'), delete(report_path); end
        doc.SaveAs2(report_path); 
        doc.SaveAs2(pdf_path, 17); % Save as PDF
        doc.Close; word.Quit;
        fprintf('📄 [REPORT] Saved at: %s\n', pdf_path);
    catch
        if exist('word', 'var'), word.Quit; end
    end

    % --- 4. [NEW] Eloquent Voice / 饒舌な音声ガイド ---
    try
        NET.addAssembly('System.Speech');
        speak = System.Speech.Synthesis.SpeechSynthesizer;
        if strcmp(lang, 'JP')
            msg = sprintf('解析が完了しました。最適な素材は、%s、です。価格は、%d円、で、予算内に収まりました。', char(final_sol.Material), final_sol.Price);
        else
            msg = sprintf('Analysis complete. The best material is %s, costing %d yen. It is within your budget.', char(final_sol.Material), final_sol.Price);
        end
        speak.Speak(msg);
    catch, end

    % --- 5. Clean up stray files ---
    delete(fullfile(src_dir, '*.asv')); delete(fullfile(project_root, 'AMD 解析報告書*.*'));
end
