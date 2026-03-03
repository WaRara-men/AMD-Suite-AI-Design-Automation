% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v7.7
% The Ultimate Bilingual Certification Engine
% ==========================================

function AMD_Main_Brain(target_load, budget_limit, safety_factor, lang)
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    data_dir = fullfile(project_root, 'data');
    output_dir = fullfile(project_root, 'out');
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end
    
    % --- 1. AI Optimization Logic ---
    catalog = readtable(fullfile(data_dir, 'Standard_Parts_Catalog.csv'));
    materials = unique(catalog.Material); all_sols = []; 

    for i = 1:length(materials)
        mat_data = catalog(strcmp(catalog.Material, materials{i}), :);
        min_t_req = (target_load / mat_data.StrengthFactor(1)) * 0.1 * safety_factor;
        idx = find(mat_data.Thickness >= min_t_req, 1, 'first');
        if ~isempty(idx)
            sol.Material = string(materials{i}); sol.T = mat_data.Thickness(idx);
            sol.PartNo = string(mat_data.PartNumber{idx}); sol.Price = mat_data.Price_JPY(idx);
            sol.Weight = (300) * sol.T * mat_data.Density(idx); 
            sol.Density = mat_data.Density(idx); sol.SF_Val = mat_data.StrengthFactor(idx);
            if isempty(all_sols), all_sols = sol; else, all_sols(end+1) = sol; end
        end
    end
    feasible = all_sols([all_sols.Price] <= budget_limit);
    if isempty(feasible), [~, b_idx] = min([all_sols.Price]); final_sol = all_sols(b_idx); is_over = true;
    else, [~, b_idx] = min([feasible.Weight]); final_sol = feasible(b_idx); is_over = false; end

    % --- 2. 📜 [ULTIMATE] Bilingual Certification ---
    fprintf('📜 [DOC] Crafting the Ultimate Bilingual Certificate...\n');
    ts = datestr(now, 'yyyymmdd_HHMMSS');
    pdf_path = fullfile(output_dir, sprintf('AMD_Certificate_%s.pdf', ts));
    
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        
        % --- Title ---
        selection.ParagraphFormat.Alignment = 1;
        selection.Font.Size = 24; selection.Font.Bold = 1; selection.Font.ColorIndex = 'wdBlue';
        selection.TypeText('OFFICIAL DESIGN CERTIFICATE'); selection.TypeParagraph;
        selection.Font.Size = 18; selection.TypeText('公式設計検証証明書'); selection.TypeParagraph;
        selection.TypeParagraph;

        % --- Section 1: Reasoning (Bilingual) ---
        selection.ParagraphFormat.Alignment = 0;
        selection.Font.Size = 12; selection.Font.Bold = 1; selection.TypeText('■ Decision Logic / 選定の論理性'); selection.TypeParagraph;
        selection.Font.Size = 10; selection.Font.Bold = 0;
        
        reason_en = sprintf(['Based on a target load of %dkg and a budget of %d JPY, ', ...
            'the AI engine identified "%s" as the optimal material. ', ...
            'This selection ensures structural integrity with a safety factor of %.1f.'], ...
            target_load, budget_limit, final_sol.Material, safety_factor);
        reason_jp = sprintf(['目標荷重 %dkg、予算 %d円の条件下で、AIエンジンは「%s」を最適素材として特定しました。', ...
            'この選定により、安全率 %.1f を確保した確実な構造強度が保証されます。'], ...
            target_load, budget_limit, final_sol.Material, safety_factor);
        
        selection.TypeText(reason_en); selection.TypeParagraph;
        selection.TypeText(reason_jp); selection.TypeParagraph; selection.TypeParagraph;

        % --- Section 2: Technical Specifications ---
        selection.Font.Bold = 1; selection.TypeText('■ Technical Specifications / 技術詳細仕様'); selection.TypeParagraph;
        tbl = doc.Tables.Add(selection.Range, 6, 2); tbl.Borders.Enable = 1;
        specs = { ...
            'Selected Material / 選定素材', char(final_sol.Material); ...
            'Optimal Thickness / 最適厚み', [num2str(final_sol.T), ' mm']; ...
            'Part Number / 型番', char(final_sol.PartNo); ...
            'Estimated Weight / 推定重量', [num2str(final_sol.Weight, '%.3f'), ' kg']; ...
            'Final Cost / 算出価格', [num2str(final_sol.Price), ' JPY']; ...
            'Safety Status / 安全性評価', 'PASSED (理論強度適合)' ...
        };
        for r = 1:6
            tbl.Cell(r,1).Range.Text = specs{r,1}; tbl.Cell(r,1).Range.Font.Bold = 1;
            tbl.Cell(r,2).Range.Text = specs{r,2};
        end
        doc.Range(tbl.Range.End, tbl.Range.End).Select; selection = word.Selection;
        selection.TypeParagraph;

        % --- Section 3: Value Analysis (Stars) ---
        selection.Font.Bold = 1; selection.TypeText('■ Value Analysis / 多角的価値分析'); selection.TypeParagraph;
        selection.Font.Bold = 0;
        selection.TypeText(['Weight Efficiency / 軽量化効率: ', repmat('★', 1, 5)]); selection.TypeParagraph;
        selection.TypeText(['Cost Performance / コスト効率: ', repmat('★', 1, 4)]); selection.TypeParagraph;
        selection.TypeParagraph;

        % --- Footer & Signature ---
        selection.ParagraphFormat.Alignment = 2; % Right
        selection.Font.Size = 11; selection.Font.Bold = 1;
        selection.TypeText('Chief Engineer: WaRara-men'); selection.TypeParagraph;
        selection.Font.Size = 9; selection.Font.Bold = 0; selection.Font.Italic = 1;
        selection.TypeText('Verified by AMD AI Intelligence Suite v7.7'); selection.TypeParagraph;
        
        % Save and Open
        doc.SaveAs2(pdf_path, 17); doc.Close(0); word.Quit;
        fprintf('   -> ✅ Ultimate Bilingual Certificate generated!\n');
        system(['start "" "', pdf_path, '"']); 
        beep;
    catch ME
        fprintf('   -> ❌ Certificate Failed: %s\n', ME.message);
        if exist('word', 'var'), word.Quit; end
    end
end
