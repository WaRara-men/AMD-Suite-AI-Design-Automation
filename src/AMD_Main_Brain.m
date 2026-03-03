% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v5.4
% Perfect Integration: Real Voice & Auto-Scale 3D
% ==========================================

function AMD_Main_Brain(target_load, budget_limit, safety_factor, lang)
    % --- 0. Path Setup ---
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    output_dir = fullfile(project_root, 'out');
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end
    
    % --- 1. AI Optimization (Full Logic Restored) ---
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

    % --- 2. 🪄 Advanced SolidWorks Sync ---
    stl_path = fullfile(output_dir, 'View_in_3D.stl');
    sw_status = 'Disconnected';
    try
        swApp = actxGetRunningServer('SldWorks.Application');
        swModel = swApp.ActiveDoc;
        if ~isempty(swModel)
            % Set Dimension if exists
            param = swModel.Parameter('Thickness');
            if ~isempty(param)
                param.SystemValue = final_sol.T / 1000;
                swModel.EditRebuild3();
            end
            % Force STL Export for Preview
            swModel.SaveAs2(stl_path, 0, true, false);
            sw_status = sprintf('Connected: %s', swModel.GetTitle());
        end
    catch
        if exist(stl_path, 'file'), delete(stl_path); end
    end

    % --- 3. Professional Reporting (PDF) ---
    pdf_path = fullfile(output_dir, 'Final_Design_Report.pdf');
    temp_docx = fullfile(output_dir, 'temp_report.docx');
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        selection.Font.Size = 20; selection.Font.Bold = 1;
        if strcmp(lang, 'JP'), txt = 'AMD 最適設計結果'; else, txt = 'AMD Design Result'; end
        selection.TypeText(txt); selection.TypeParagraph;
        selection.Font.Size = 12; selection.Font.Bold = 0;
        selection.TypeText(sprintf('Material: %s, Weight: %.3f kg, Price: %d JPY', final_sol.Material, final_sol.Weight, final_sol.Price));
        if exist(temp_docx, 'file'), delete(temp_docx); end
        doc.SaveAs2(temp_docx); doc.SaveAs2(pdf_path, 17); % Export PDF
        doc.Close; word.Quit;
        if exist(temp_docx, 'file'), delete(temp_docx); end
        fprintf('📄 [REPORT] Final PDF saved: %s\n', pdf_path);
    catch, if exist('word', 'var'), word.Quit; end; end

    % --- 4. 🔊 Eloquent Voice (Restored!) ---
    try
        NET.addAssembly('System.Speech'); speak = System.Speech.Synthesis.SpeechSynthesizer;
        if strcmp(lang, 'JP')
            msg = sprintf('解析が完了しました。最適な素材は、%s、です。価格は、%d円、で、予算内に収まりました。', char(final_sol.Material), final_sol.Price);
        else
            msg = sprintf('Analysis complete. The best material is %s, costing %d yen. It is within budget.', char(final_sol.Material), final_sol.Price);
        end
        speak.Speak(msg);
    catch, end

    % --- 5. Cleanup ---
    delete(fullfile(src_dir, '*.asv')); 
    delete(fullfile(project_root, 'AMD Final Result*.*')); % Remove stray files
    delete(fullfile(project_root, 'AMD 解析報告書*.*'));
end
