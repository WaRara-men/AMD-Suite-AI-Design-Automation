% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v4.3
% Global Edition: Multi-Language & 3D Export
% ==========================================

function AMD_Main_Brain(target_load, budget_limit, safety_factor, lang)
    % --- 0. Path Setup ---
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    data_dir = fullfile(project_root, 'data');
    output_dir = fullfile(project_root, 'out');
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end
    
    % --- 1. Load Data & Optimize ---
    catalog = readtable(fullfile(data_dir, 'Standard_Parts_Catalog.csv'));
    materials = unique(catalog.Material);
    all_solutions = struct('Material', {}, 'T', {}, 'PartNo', {}, 'Price', {}, 'Weight', {});

    for i = 1:length(materials)
        mat_data = catalog(strcmp(catalog.Material, materials{i}), :);
        min_t_req = (target_load / mat_data.StrengthFactor(1)) * 0.1 * safety_factor;
        idx = find(mat_data.Thickness >= min_t_req, 1, 'first');
        if ~isempty(idx)
            sol.Material = string(materials{i});
            sol.T = mat_data.Thickness(idx);
            sol.PartNo = string(mat_data.PartNumber{idx});
            sol.Price = mat_data.Price_JPY(idx);
            sol.Weight = (300) * sol.T * mat_data.Density(idx);
            all_solutions(end+1) = sol; 
        end
    end

    % Decision Making
    feasible = all_solutions([all_solutions.Price] <= budget_limit);
    if isempty(feasible), [~, b_idx] = min([all_solutions.Price]); final_sol = all_solutions(b_idx);
    else, [~, b_idx] = min([feasible.Weight]); final_sol = feasible(b_idx); end

    % --- 2. [NEW] Mobile 3D Data Export / スマホ用3D出力 ---
    fprintf('📦 [3D] Exporting mobile-friendly 3D data... / スマホ用3Dデータを出力中...\n');
    try
        swApp = actxGetRunningServer('SldWorks.Application');
        swModel = swApp.ActiveDoc;
        if ~isempty(swModel)
            % Export as STL (Box can preview STL in 3D on Mobile!)
            stl_path = fullfile(output_dir, 'mobile_preview.STL');
            swModel.SaveAs2(stl_path, 0, true, false);
            fprintf('   -> ✅ 3D Mobile Data Generated!\n');
        end
    catch
        fprintf('   -> ⚠️ SolidWorks not active for 3D export.\n');
    end

    % --- 3. [NEW] Multi-Language Reporting / 多言語レポート ---
    report_path = fullfile(output_dir, 'AMD_Decision_Report.docx');
    pdf_path = fullfile(output_dir, 'AMD_Decision_Report.pdf');
    
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        
        if strcmp(lang, 'JP')
            title_txt = 'AMD 自動設計報告書 (グローバル版)';
            res_txt = sprintf('【最適解】 素材: %s, 推定重量: %.3f kg, 価格: %d JPY', final_sol.Material, final_sol.Weight, final_sol.Price);
        else
            title_txt = 'AMD AI Design Report (Global Edition)';
            res_txt = sprintf('[Winner] Material: %s, Weight: %.3f kg, Price: %d JPY', final_sol.Material, final_sol.Weight, final_sol.Price);
        end
        
        selection.Font.Size = 24; selection.Font.Bold = 1;
        selection.TypeText(title_txt); selection.TypeParagraph;
        selection.Font.Size = 12; selection.Font.Bold = 0;
        selection.TypeText(res_txt); selection.TypeParagraph;
        
        if exist(report_path, 'file'), delete(report_path); end
        doc.SaveAs2(report_path); doc.SaveAs2(pdf_path, 17);
        doc.Close; word.Quit;
    catch
        if exist('word', 'var'), word.Quit; end
    end

    % --- 4. Box Auto-Sync ---
    box_path = fullfile(getenv('USERPROFILE'), 'Box', 'AMD_Global_Project');
    if exist(fullfile(getenv('USERPROFILE'), 'Box'), 'dir')
        if ~exist(box_path, 'dir'), mkdir(box_path); end
        copyfile(pdf_path, fullfile(box_path, 'Report.pdf'));
        if exist(fullfile(output_dir, 'mobile_preview.STL'), 'file')
            copyfile(fullfile(output_dir, 'mobile_preview.STL'), fullfile(box_path, 'View_in_3D.stl'));
        end
        fprintf('✅ [SYNC] Mobile 3D and Report synced to Box!\n');
    end
end
