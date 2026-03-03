% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v4.6
% Final Global 3D Edition: Real STL Export
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
        mat_name = materials{i};
        mat_data = catalog(strcmp(catalog.Material, mat_name), :);
        min_t_req = (target_load / mat_data.StrengthFactor(1)) * 0.1 * safety_factor;
        idx = find(mat_data.Thickness >= min_t_req, 1, 'first');
        if ~isempty(idx)
            sol.Material = string(mat_name);
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

    % --- 2. 💎 REAL SolidWorks STL Export / 本物のSTL出力 ---
    stl_path = fullfile(output_dir, 'View_in_3D.stl');
    fprintf('📦 [3D] Interfacing with SolidWorks... / 3Dデータを抽出中...\n');
    try
        swApp = actxGetRunningServer('SldWorks.Application');
        swModel = swApp.ActiveDoc;
        if ~isempty(swModel)
            % 🌟 Save as STL (Format 1: STL)
            % swModel.SaveAs2(path, 0, false, false)
            swModel.SaveAs2(stl_path, 0, true, false);
            fprintf('   -> ✅ Real 3D Data Generated: %s\n', stl_path);
        else
            fprintf('   -> ⚠️ No active SolidWorks document found.\n');
        end
    catch
        fprintf('   -> ⚠️ SolidWorks is not running. STL export skipped.\n');
    end

    % --- 3. Reporting (PDF Export) ---
    pdf_path = fullfile(output_dir, 'AMD_Decision_Report.pdf');
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        if strcmp(lang, 'JP')
            title = 'AMD 設計報告書'; 
            msg = sprintf('荷重: %dkg, 推奨: %s, 価格: %d円', target_load, final_sol.Material, final_sol.Price);
        else
            title = 'AMD Design Report';
            msg = sprintf('Load: %dkg, Best: %s, Price: %d JPY', target_load, final_sol.Material, final_sol.Price);
        end
        selection.Font.Size = 24; selection.Font.Bold = 1; selection.TypeText(title); selection.TypeParagraph;
        selection.Font.Size = 12; selection.Font.Bold = 0; selection.TypeText(msg); selection.TypeParagraph;
        doc.SaveAs2(fullfile(output_dir, 'Report.docx'));
        doc.SaveAs2(pdf_path, 17); % PDF
        doc.Close; word.Quit;
    catch
        if exist('word', 'var'), word.Quit; end
    end

    % --- 4. 🚀 Global Manual Assist / 多言語手動アシスト ---
    fprintf('💡 [ASSIST] Activating Manual Sync Guide...\n');
    winopen(output_dir);
    web('https://tdu.app.box.com', '-browser');
    
    % Voice Guidance based on Language
    try
        NET.addAssembly('System.Speech');
        speak = System.Speech.Synthesis.SpeechSynthesizer;
        if strcmp(lang, 'JP')
            guide_msg = '解析が完了しました。開いたフォルダから、View in 3Dファイルを、ブラウザのボックスへドラッグしてください。';
            title_msg = '手動アップロード案内';
            body_msg = '1. フォルダから "View_in_3D.stl" を探す\n2. ブラウザのBoxへポイッ！';
        else
            guide_msg = 'Analysis complete. Please drag the View in 3D file from the opened folder to the Box browser.';
            title_msg = 'Manual Upload Guide';
            body_msg = '1. Find "View_in_3D.stl" in the folder\n2. Drag & Drop to the Box browser!';
        end
        speak.Speak(guide_msg);
        msgbox(sprintf(body_msg), title_msg);
    catch, end
end
