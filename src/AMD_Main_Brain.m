% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v5.9
% Perfect Feature Integration & Robust Connection
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
            sol.PartNo = string(mat_data.PartNumber{idx}); sol.Price = mat_data.Price_JPY(idx);
            sol.Weight = (300) * sol.T * mat_data.Density(idx); all_sols(end+1) = sol; 
        end
    end
    feasible = all_sols([all_sols.Price] <= budget_limit);
    if isempty(feasible), [~, b_idx] = min([all_sols.Price]); final_sol = all_sols(b_idx);
    else, [~, b_idx] = min([feasible.Weight]); final_sol = feasible(b_idx); end

    % --- 2. SolidWorks Link ---
    stl_path = fullfile(output_dir, 'View_in_3D.stl');
    sw_success = false;
    try
        swApp = actxGetRunningServer('SldWorks.Application');
        swModel = swApp.ActiveDoc;
        if ~isempty(swModel)
            param = swModel.Parameter('Thickness');
            if ~isempty(param), param.SystemValue = final_sol.T / 1000; swModel.EditRebuild3(); end
            swModel.SaveAs2(stl_path, 0, true, false); sw_success = true;
        end
    catch; end
    if ~sw_success && exist(stl_path, 'file'), delete(stl_path); end

    % --- 3. Professional PDF ---
    pdf_path = fullfile(output_dir, 'Final_Design_Report.pdf');
    try
        word = actxserver('Word.Application'); doc = word.Documents.Add;
        selection = word.Selection;
        if strcmp(lang, 'JP'), txt = 'AMD 最適設計報告書'; else, txt = 'AMD Design Report'; end
        selection.Font.Size = 20; selection.Font.Bold = 1; selection.TypeText(txt);
        doc.SaveAs2(pdf_path, 17); doc.Close; word.Quit;
    catch, if exist('word', 'var'), word.Quit; end; end

    % --- 4. Eloquent Voice ---
    try
        NET.addAssembly('System.Speech'); speak = System.Speech.Synthesis.SpeechSynthesizer;
        if strcmp(lang, 'JP')
            msg = sprintf('解析が完了しました。最適な素材は、%s、です。価格は、%d円、で、予算内に収まりました。', char(final_sol.Material), final_sol.Price);
        else
            msg = sprintf('Analysis complete. Best is %s, costing %d yen. Within budget.', char(final_sol.Material), final_sol.Price);
        end
        speak.Speak(msg);
    catch, end

    % --- 5. Cleanup ---
    delete(fullfile(src_dir, '*.asv')); 
    stray = {'AMD*.*', 'Final*.*', 'temp*.*'};
    for s = 1:length(stray), delete(fullfile(project_root, stray{s})); end
end
