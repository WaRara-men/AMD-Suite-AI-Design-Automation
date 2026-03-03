% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v7.6
% Professional Certification & Engineering Logic
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
            sol.Density = mat_data.Density(idx); sol.SF = mat_data.StrengthFactor(idx);
            if isempty(all_sols), all_sols = sol; else, all_sols(end+1) = sol; end
        end
    end
    feasible = all_sols([all_sols.Price] <= budget_limit);
    if isempty(feasible), [~, b_idx] = min([all_sols.Price]); final_sol = all_sols(b_idx); is_over = true;
    else, [~, b_idx] = min([feasible.Weight]); final_sol = feasible(b_idx); is_over = false; end

    % --- 2. 📜 [ENHANCED] Professional Certification ---
    fprintf('📜 [DOC] Crafting detailed engineering report...\n');
    ts = datestr(now, 'yyyymmdd_HHMMSS');
    pdf_path = fullfile(output_dir, sprintf('AMD_Certificate_%s.pdf', ts));
    
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        
        % --- Title & Design ---
        selection.ParagraphFormat.Alignment = 1;
        selection.Font.Size = 24; selection.Font.Bold = 1; selection.Font.ColorIndex = 'wdBlue';
        selection.TypeText('DESIGN VERIFICATION CERTIFICATE'); selection.TypeParagraph;
        selection.Font.Size = 14; selection.Font.ColorIndex = 'wdAuto'; selection.Font.Bold = 0;
        selection.TypeText('Engineering analysis performed by AMD AI Optimization Suite'); selection.TypeParagraph;
        selection.TypeParagraph;

        % --- Section 1: Selection Logic ---
        selection.ParagraphFormat.Alignment = 0;
        selection.Font.Size = 12; selection.Font.Bold = 1; selection.TypeText('■ Engineering Decision Logic / 選定の論理性'); selection.TypeParagraph;
        selection.Font.Size = 10; selection.Font.Bold = 0;
        
        reasoning = sprintf(['The AI engine evaluated %d different material candidates. ', ...
            'Selection priority was given to minimizing total mass (kg) while strictly adhering to ', ...
            'a target load of %dkg and a safety factor of %.1f. ', ...
            'The material "%s" was identified as the optimal solution.'], ...
            length(materials), target_load, safety_factor, final_sol.Material);
        if is_over
            reasoning = [reasoning, ' Note: Target budget was exceeded; selected based on lowest possible price.'];
        else
            reasoning = [reasoning, sprintf(' Total cost was kept within the %d JPY budget.', budget_limit)];
        end
        selection.TypeText(reasoning); selection.TypeParagraph; selection.TypeParagraph;

        % --- Section 2: Technical Specs Table ---
        selection.Font.Bold = 1; selection.TypeText('■ Optimized Specification / 最適化スペック'); selection.TypeParagraph;
        tbl = doc.Tables.Add(selection.Range, 5, 2); tbl.Borders.Enable = 1;
        specs = {'Material / 素材', char(final_sol.Material); 'Thickness / 厚み', [num2str(final_sol.T), ' mm']; 'Part No / 型番', char(final_sol.PartNo); 'Est. Weight / 推定重量', [num2str(final_sol.Weight, '%.3f'), ' kg']; 'Total Cost / 算出価格', [num2str(final_sol.Price), ' JPY']};
        for r = 1:5, tbl.Cell(r,1).Range.Text = specs{r,1}; tbl.Cell(r,1).Range.Font.Bold = 1; tbl.Cell(r,2).Range.Text = specs{r,2}; end
        doc.Range(tbl.Range.End, tbl.Range.End).Select; selection = word.Selection;
        selection.TypeParagraph;

        % --- Footer ---
        selection.ParagraphFormat.Alignment = 1;
        selection.Font.Size = 8; selection.Font.ColorIndex = 'wdGray50';
        selection.TypeText(sprintf('Report ID: AMD-%s | System: TDU Standard Catalog v2026', upper(dec2hex(posixtime(datetime('now'))))));
        
        % Save and Open
        doc.SaveAs2(pdf_path, 17); doc.Close(0); word.Quit;
        fprintf('   -> ✅ Professional Certificate opened!\n');
        system(['start "" "', pdf_path, '"']); % Guaranteed open
        beep;
    catch ME
        fprintf('   -> ❌ PDF Generation Failed: %s\n', ME.message);
        if exist('word', 'var'), word.Quit; end
    end

    % --- 3. Final Voice ---
    try
        NET.addAssembly('System.Speech'); speak = System.Speech.Synthesis.SpeechSynthesizer;
        speak.Speak(sprintf('設計が完了しました。最適な素材は、%s、です。', char(final_sol.Material)));
    catch, end
end
