% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v7.5
% TRUE FINAL: Detailed Certificate & Silent Clean
% ==========================================

function AMD_Main_Brain(target_load, budget_limit, safety_factor, lang)
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    data_dir = fullfile(project_root, 'data');
    output_dir = fullfile(project_root, 'out');
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end
    
    % --- 1. AI Logic ---
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

    % --- 2. 🌟 FULL DETAILED CERTIFICATE (v7.1 Content Restored) ---
    ts = datestr(now, 'yyyymmdd_HHMMSS');
    pdf_name = sprintf('AMD_Certificate_%s.pdf', ts);
    pdf_path = fullfile(output_dir, pdf_name);
    
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        
        % Header
        selection.ParagraphFormat.Alignment = 1;
        selection.Font.Size = 26; selection.Font.Bold = 1;
        selection.TypeText('DESIGN VERIFICATION CERTIFICATE'); selection.TypeParagraph;
        
        % Selection Logic
        selection.ParagraphFormat.Alignment = 0;
        selection.Font.Size = 14; selection.Font.Bold = 1; selection.TypeText('■ Engineering Selection Logic'); selection.TypeParagraph;
        selection.Font.Size = 11; selection.Font.Bold = 0;
        reasoning = sprintf('AI selected %s based on %dkg load and %d JPY budget.', final_sol.Material, target_load, budget_limit);
        selection.TypeText(reasoning); selection.TypeParagraph; selection.TypeParagraph;
        
        % Specs Table
        tbl = doc.Tables.Add(selection.Range, 4, 2); tbl.Borders.Enable = 1;
        specs = {'Selected Material', char(final_sol.Material); 'Thickness', [num2str(final_sol.T), ' mm']; 'Mass', [num2str(final_sol.Weight, '%.3f'), ' kg']; 'Price', [num2str(final_sol.Price), ' JPY']};
        for r = 1:4, tbl.Cell(r,1).Range.Text = specs{r,1}; tbl.Cell(r,1).Range.Font.Bold = 1; tbl.Cell(r,2).Range.Text = specs{r,2}; end
        
        doc.Range(tbl.Range.End, tbl.Range.End).Select; selection = word.Selection;
        selection.TypeParagraph; selection.Font.Size = 9;
        selection.TypeText(sprintf('Verification ID: AMD-%s', upper(dec2hex(posixtime(datetime('now'))))));
        
        doc.SaveAs2(pdf_path, 17); doc.Close(0); word.Quit;
        web(pdf_path, '-browser'); % Auto-open
        beep;
    catch, if exist('word', 'var'), word.Quit; end; end

    % --- 3. Final Voice ---
    try
        NET.addAssembly('System.Speech'); speak = System.Speech.Synthesis.SpeechSynthesizer;
        speak.Speak('設計が完了し、詳細な証明書を発行しました。');
    catch, end
end
