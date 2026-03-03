% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v6.1
% Intelligent Smart-Search SW Connection
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

    % --- 2. 🛰️ [NEW] Intelligent SolidWorks Sync ---
    stl_path = fullfile(output_dir, 'View_in_3D.stl');
    sw_synced = false;
    fprintf('🛰️ [SW] Scanning for dimensions... / 寸法を自動探索中...\n');
    try
        swApp = actxGetRunningServer('SldWorks.Application');
        swModel = swApp.ActiveDoc;
        if ~isempty(swModel)
            % 1. Try Global Variable "Thickness"
            eqMgr = swModel.GetEquationMgr();
            for i = 0:eqMgr.GetCount()-1
                if contains(eqMgr.GetEquation(i), 'Thickness')
                    eqMgr.SetEquationAndValue(i, sprintf('"Thickness" = %f', final_sol.T));
                    sw_synced = true;
                    break;
                end
            end
            
            % 2. Try Direct Dimension "Thickness" (Sketch or Feature)
            if ~sw_synced
                params = {'Thickness', 'Thickness@Sketch1', 'D1@Boss-Extrude1', 'D1@押し出し1'};
                for p = 1:length(params)
                    dim = swModel.Parameter(params{p});
                    if ~isempty(dim)
                        dim.SystemValue = final_sol.T / 1000;
                        sw_synced = true;
                        fprintf('   -> ✅ Found and updated: %s\n', params{p});
                        break;
                    end
                end
            end
            
            if sw_synced
                swModel.EditRebuild3();
                swModel.SaveAs2(stl_path, 0, true, false);
            end
        end
    catch; end

    % --- 3. Reporting (PDF) ---
    pdf_path = fullfile(output_dir, 'Final_Report.pdf');
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        selection.TypeText(['Best Material: ', char(final_sol.Material)]);
        doc.SaveAs2(pdf_path, 17); doc.Close(0); word.Quit;
    catch, if exist('word', 'var'), word.Quit; end; end

    % --- 4. Smart Voice ---
    try
        NET.addAssembly('System.Speech'); speak = System.Speech.Synthesis.SpeechSynthesizer;
        if sw_synced
            msg = sprintf('解析完了。ソリッドワークスとの同期に成功しました。最適な素材は、%s、です。', char(final_sol.Material));
        else
            msg = sprintf('解析完了。最適な素材は、%s、ですが、モデルが見つかりませんでした。', char(final_sol.Material));
        end
        speak.Speak(msg);
    catch, end

    % --- 5. Clean-up ---
    delete(fullfile(project_root, 'AMD*.*')); delete(fullfile(project_root, 'Final*.*'));
end
