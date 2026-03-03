% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v5.3
% Robust SolidWorks Explorer & Diagnostics
% ==========================================

function AMD_Main_Brain(target_load, budget_limit, safety_factor, lang)
    % --- 0. Path Setup ---
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    output_dir = fullfile(project_root, 'out');
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end
    
    % --- 1. AI Logic (Simplified for brevity) ---
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

    % --- 2. 🛰️ [ENHANCED] SolidWorks Connection Diagnostics ---
    stl_path = fullfile(output_dir, 'View_in_3D.stl');
    fprintf('🛰️ [DIAG] Scanning for SolidWorks instance... / SWをスキャン中...\n');
    sw_success = false;
    
    try
        % 1. Try to get active server
        try
            swApp = actxGetRunningServer('SldWorks.Application');
        catch
            % 2. If failed, try to create server (might take time)
            swApp = actxserver('SldWorks.Application');
        end
        
        swApp.Visible = true;
        swModel = swApp.ActiveDoc;
        
        if ~isempty(swModel)
            % Check if it's a PART file
            if swModel.GetType() == 1 % 1 = Part
                fprintf('   -> ✅ Connected to Model: %s\n', swModel.GetTitle());
                
                % 🎯 Inject Parameter
                status = swModel.Parameter('Thickness');
                if ~isempty(status)
                    status.SystemValue = final_sol.T / 1000;
                    swModel.EditRebuild3();
                    fprintf('   -> ✅ Dimension "Thickness" updated.\n');
                else
                    fprintf('   -> ⚠️ No dimension named "Thickness" found. Please rename your dimension!\n');
                end
                
                % 🌟 Export STL
                swModel.SaveAs2(stl_path, 0, true, false);
                sw_success = true;
            else
                fprintf('   -> ⚠️ Active file is NOT a Part file. Please open a .sldprt file.\n');
            end
        else
            fprintf('   -> ⚠️ SolidWorks is open, but NO FILE is open. / ファイルが開かれていません。\n');
        end
    catch ME
        fprintf('   -> ❌ Connection Error: %s\n', ME.message);
    end

    if ~sw_success && exist(stl_path, 'file'), delete(stl_path); end

    % --- 3. Reporting ---
    pdf_path = fullfile(output_dir, 'Final_Design_Report.pdf');
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        selection.TypeText(['AMD Final Result: ', char(final_sol.Material)]);
        doc.SaveAs2(pdf_path, 17); doc.Close; word.Quit;
    catch, if exist('word', 'var'), word.Quit; end; end

    % --- 4. Final Notification ---
    try
        NET.addAssembly('System.Speech'); speak = System.Speech.Synthesis.SpeechSynthesizer;
        msg = '解析終了。'; if ~strcmp(lang, 'JP'), msg = 'Analysis complete.'; end
        speak.Speak(msg);
    catch, end
end
