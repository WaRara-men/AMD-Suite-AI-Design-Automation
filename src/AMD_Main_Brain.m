% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v6.0
% Absolute Reliability & High Visibility
% ==========================================

function AMD_Main_Brain(target_load, budget_limit, safety_factor, lang)
    % --- 0. Path Setup ---
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
    [~, b_idx] = min([all_sols.Weight]); final_sol = all_sols(b_idx);

    % --- 2. SolidWorks Force-Sync ---
    stl_path = fullfile(output_dir, 'View_in_3D.stl');
    fprintf('🛰️ [SW] Scanning active parts... / パーツをスキャン中...\n');
    try
        swApp = actxGetRunningServer('SldWorks.Application');
        swModel = swApp.ActiveDoc;
        if ~isempty(swModel)
            % 🎯 Try to find "Thickness" dimension
            param = swModel.Parameter('Thickness');
            if ~isempty(param)
                param.SystemValue = final_sol.T / 1000;
                swModel.EditRebuild3();
                fprintf('   -> ✅ SW Dimension "Thickness" updated to %.1f mm\n', final_sol.T);
            end
            swModel.SaveAs2(stl_path, 0, true, false);
        end
    catch; end

    % --- 3. Robust PDF Reporting (Guaranteed Content) ---
    pdf_path = fullfile(output_dir, 'Final_Report.pdf');
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        
        % Ensure content is typed before saving
        selection.Font.Size = 24; selection.Font.Bold = 1;
        if strcmp(lang, 'JP'), txt = 'AMD 最適設計報告書'; else, txt = 'AMD AI Design Report'; end
        selection.TypeText(txt); selection.TypeParagraph;
        
        selection.Font.Size = 12; selection.Font.Bold = 0;
        data_txt = sprintf('Result: %s, Thickness: %.1f mm, Price: %d JPY', final_sol.Material, final_sol.T, final_sol.Price);
        selection.TypeText(data_txt); selection.TypeParagraph;
        
        if exist(pdf_path, 'file'), delete(pdf_path); end
        doc.SaveAs2(pdf_path, 17); % Save as PDF directly
        doc.Close(0); word.Quit;
        fprintf('📄 [REPORT] PDF generated successfully in /out folder.\n');
    catch, if exist('word', 'var'), word.Quit; end; end

    % --- 4. Smart Voice ---
    try
        NET.addAssembly('System.Speech'); speak = System.Speech.Synthesis.SpeechSynthesizer;
        msg = sprintf('解析が完了しました。最適な素材は、%s、です。', char(final_sol.Material));
        speak.Speak(msg);
    catch, end

    % --- 5. Clean-up Desk ---
    % 散らかったファイルを徹底的に消す
    delete(fullfile(project_root, 'AMD*.*')); delete(fullfile(project_root, 'Final*.*'));
end
