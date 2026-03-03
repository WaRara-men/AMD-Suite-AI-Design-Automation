% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v5.7
% Zero-Failure Connection & Error Diagnostics
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
    [~, b_idx] = min([all_sols.Weight]); final_sol = all_sols(b_idx);

    % --- 2. 🛰️ [NEW] Super Robust SolidWorks Sync ---
    stl_path = fullfile(output_dir, 'View_in_3D.stl');
    sw_success = false;
    
    fprintf('🛰️ [CONN] Attempting to hook SolidWorks... / SWへの接続を試行中...\n');
    try
        % ATTEMPT 1: Get existing instance
        try
            swApp = actxGetRunningServer('SldWorks.Application');
        catch
            % ATTEMPT 2: Create new instance (or force attach)
            swApp = actxserver('SldWorks.Application');
        end
        
        swModel = swApp.ActiveDoc;
        if ~isempty(swModel)
            % Parameter Injection
            param = swModel.Parameter('Thickness');
            if ~isempty(param)
                param.SystemValue = final_sol.T / 1000;
                swModel.EditRebuild3();
            end
            % STL Export
            swModel.SaveAs2(stl_path, 0, true, false);
            sw_success = true;
            fprintf('   -> ✅ Success: Dimension updated and STL saved.\n');
        else
            fprintf('   -> ⚠️ Connected to SW, but NO PART is open.\n');
        end
    catch ME
        fprintf('   -> ❌ Connection Error: %s\n', ME.message);
        fprintf('   -> 💡 Tip: Try running BOTH MATLAB and SolidWorks as Administrator!\n');
    end

    if ~sw_success && exist(stl_path, 'file'), delete(stl_path); end

    % --- 3. Reporting & Voice ---
    pdf_path = fullfile(output_dir, 'Final_Design_Report.pdf');
    try
        word = actxserver('Word.Application'); doc = word.Documents.Add;
        doc.SaveAs2(pdf_path, 17); doc.Close; word.Quit;
    catch, if exist('word', 'var'), word.Quit; end; end

    try
        NET.addAssembly('System.Speech'); speak = System.Speech.Synthesis.SpeechSynthesizer;
        msg = sprintf('解析完了。素材は、%s、です。', char(final_sol.Material));
        speak.Speak(msg);
    catch, end
end
