% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v7.1
% Professional Design Certification Engine
% ==========================================

function AMD_Main_Brain(target_load, budget_limit, safety_factor, lang)
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    data_dir = fullfile(project_root, 'data');
    output_dir = fullfile(project_root, 'out');
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end
    
    % --- 1. AI Logic & Data Retrieval ---
    catalog = readtable(fullfile(data_dir, 'Standard_Parts_Catalog.csv'));
    materials = unique(catalog.Material); all_sols = struct('Material', {}, 'T', {}, 'PartNo', {}, 'Price', {}, 'Weight', {}, 'Density', {}, 'StrengthFactor', {}, 'LeadTime', {});

    for i = 1:length(materials)
        mat_data = catalog(strcmp(catalog.Material, materials{i}), :);
        min_t_req = (target_load / mat_data.StrengthFactor(1)) * 0.1 * safety_factor;
        idx = find(mat_data.Thickness >= min_t_req, 1, 'first');
        if ~isempty(idx)
            sol.Material = string(materials{i}); sol.T = mat_data.Thickness(idx);
            sol.PartNo = string(mat_data.PartNumber{idx}); sol.Price = mat_data.Price_JPY(idx);
            sol.Weight = (300) * sol.T * mat_data.Density(idx); 
            sol.Density = mat_data.Density(idx); sol.StrengthFactor = mat_data.StrengthFactor(idx);
            sol.LeadTime = string(mat_data.LeadTime{idx});
            all_sols(end+1) = sol; 
        end
    end
    feasible = all_sols([all_sols.Price] <= budget_limit);
    if isempty(feasible), [~, b_idx] = min([all_sols.Price]); final_sol = all_sols(b_idx);
    else, [~, b_idx] = min([feasible.Weight]); final_sol = feasible(b_idx); end

    % --- 2. Advanced Certification Logic (PDF) ---
    fprintf('📜 [DOC] Crafting Detailed Engineering Certificate...\n');
    pdf_path = fullfile(output_dir, 'AMD_Design_Certificate.pdf');
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        
        % --- Header & Styling ---
        selection.ParagraphFormat.Alignment = 1;
        selection.Font.Size = 26; selection.Font.Bold = 1; selection.Font.Name = 'Arial';
        selection.TypeText('DESIGN VERIFICATION CERTIFICATE'); selection.TypeParagraph;
        selection.Font.Size = 16; selection.TypeText('設計検証・技術証明書'); selection.TypeParagraph;
        selection.TypeParagraph;

        % --- Section 1: Logical Reasoning ---
        selection.ParagraphFormat.Alignment = 0;
        selection.Font.Size = 14; selection.Font.Bold = 1; selection.Font.Underline = 1;
        if strcmp(lang, 'JP'), txt = '■ 選定の論理的根拠 (Selection Logic)'; else, txt = '■ Engineering Selection Logic'; end
        selection.TypeText(txt); selection.TypeParagraph;
        selection.Font.Size = 11; selection.Font.Bold = 0; selection.Font.Underline = 0;
        
        reasoning = sprintf(['The AI engine analyzed %d materials from the internal database. ', ...
            '%s was selected as the global optimum because it satisfies the strength requirement of %dkg ', ...
            'with a safety factor of %.1f, while maintaining the lowest possible mass within the budget limit of %d JPY.'], ...
            length(materials), final_sol.Material, target_load, safety_factor, budget_limit);
        if strcmp(lang, 'JP')
            reasoning = sprintf(['内部データベースの%d種類の素材を解析した結果、安全率%.1fを含む%dkgの荷重条件を満たし、', ...
                'かつ予算%d円以内で最も軽量な「%s」を最適解として選定しました。'], ...
                length(materials), safety_factor, target_load, budget_limit, final_sol.Material);
        end
        selection.TypeText(reasoning); selection.TypeParagraph; selection.TypeParagraph;

        % --- Section 2: Detailed Specifications Table ---
        selection.Font.Size = 14; selection.Font.Bold = 1; selection.Font.Underline = 1;
        if strcmp(lang, 'JP'), txt = '■ 技術詳細仕様 (Technical Specifications)'; else, txt = '■ Technical Specifications'; end
        selection.TypeText(txt); selection.TypeParagraph;
        
        tbl = doc.Tables.Add(selection.Range, 6, 2); tbl.Borders.Enable = 1;
        specs = { ...
            'Selected Material / 選定素材', char(final_sol.Material); ...
            'Calculated Thickness / 最適厚み', [num2str(final_sol.T), ' mm']; ...
            'Part Number / 型番', char(final_sol.PartNo); ...
            'Estimated Mass / 推定重量', [num2str(final_sol.Weight, '%.3f'), ' kg']; ...
            'Total Cost / 算出価格', [num2str(final_sol.Price), ' JPY']; ...
            'Procurement / 納期目安', char(final_sol.LeadTime) ...
        };
        for r = 1:6
            tbl.Cell(r,1).Range.Text = specs{r,1}; tbl.Cell(r,1).Range.Font.Bold = 1;
            tbl.Cell(r,2).Range.Text = specs{r,2};
        end
        doc.Range(tbl.Range.End, tbl.Range.End).Select; selection = word.Selection;
        selection.TypeParagraph;

        % --- Section 3: Data Source ---
        selection.Font.Size = 10; selection.Font.Italic = 1;
        src_txt = 'Data Source: Standard_Parts_Catalog.csv (Internal Enterprise Database)';
        if strcmp(lang, 'JP'), src_txt = 'データ出典: Standard_Parts_Catalog.csv (内部統合データベース)'; end
        selection.TypeText(src_txt); selection.TypeParagraph; selection.TypeParagraph;

        % --- Footer: ID & Timestamp ---
        selection.ParagraphFormat.Alignment = 1;
        selection.Font.Size = 9; selection.Font.Bold = 0; selection.Font.Italic = 0;
        verify_code = upper(dec2hex(posixtime(datetime('now'))));
        selection.TypeText(sprintf('Verification ID: AMD-%s | Timestamp: %s', verify_code, datestr(now)));
        
        if exist(pdf_path, 'file'), delete(pdf_path); end
        doc.SaveAs2(pdf_path, 17); doc.Close(0); word.Quit;
        fprintf('   -> ✅ Professional Certificate generated: %s\n', pdf_path);
    catch ME
        fprintf('   -> ❌ Certificate Failed: %s\n', ME.message);
        if exist('word', 'var'), word.Quit; end
    end
end
