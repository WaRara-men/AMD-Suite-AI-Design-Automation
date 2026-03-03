% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v5.6
% Ultra-Robust Connection & Auto-Recovery
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

    % --- 2. 🛰️ [NEW] Persistent SolidWorks Sync ---
    stl_path = fullfile(output_dir, 'View_in_3D.stl');
    fprintf('🛰️ [CONN] Searching for SolidWorks... / SWを探しています...\n');
    sw_success = false;
    
    try
        % Use actxserver instead of actxGetRunningServer for better compatibility
        % This will attach to existing if open, or start new if not.
        swApp = actxserver('SldWorks.Application');
        swModel = swApp.ActiveDoc;
        
        if ~isempty(swModel)
            fprintf('   -> ✅ Linked to: %s\n', swModel.GetTitle());
            
            % Update dimension / 寸法更新
            param = swModel.Parameter('Thickness');
            if ~isempty(param)
                param.SystemValue = final_sol.T / 1000;
                swModel.EditRebuild3();
                fprintf('   -> 📐 Dimension updated: %.1f mm\n', final_sol.T);
            end
            
            % Export STL
            swModel.SaveAs2(stl_path, 0, true, false);
            sw_success = true;
        else
            fprintf('   -> ⚠️ SolidWorks is up, but no PART file is open.\n');
        end
    catch ME
        fprintf('   -> ❌ Connection Failed: %s\n', ME.message);
    end

    if ~sw_success && exist(stl_path, 'file'), delete(stl_path); end

    % --- 3. Professional PDF Generation ---
    pdf_path = fullfile(output_dir, 'Final_Design_Report.pdf');
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        selection.Font.Size = 20; selection.Font.Bold = 1;
        title = 'AMD Analysis Report'; if strcmp(lang, 'JP'), title = 'AMD 最適設計報告書'; end
        selection.TypeText(title);
        doc.SaveAs2(pdf_path, 17); doc.Close; word.Quit;
    catch, if exist('word', 'var'), word.Quit; end; end

    % --- 4. Eloquent Voice ---
    try
        NET.addAssembly('System.Speech'); speak = System.Speech.Synthesis.SpeechSynthesizer;
        msg = sprintf('解析完了。素材は、%s、厚みは、%.1fミリです。', char(final_sol.Material), final_sol.T);
        if ~strcmp(lang, 'JP'), msg = sprintf('Analysis complete. Best material is %s.', char(final_sol.Material)); end
        speak.Speak(msg);
    catch, end
end
