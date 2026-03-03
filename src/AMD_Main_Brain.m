% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v7.0
% The Ultimate Standalone Engine (No SW Needed)
% ==========================================

function AMD_Main_Brain(target_load, budget_limit, safety_factor, lang)
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    data_dir = fullfile(project_root, 'data');
    output_dir = fullfile(project_root, 'out');
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end
    
    % --- 1. AI Logic & Material Selection ---
    fprintf('🧠 [AI] Running Ultimate Optimization Engine...\n');
    catalog = readtable(fullfile(data_dir, 'Standard_Parts_Catalog.csv'));
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
    feasible = all_sols([all_sols.Price] <= budget_limit);
    if isempty(feasible), [~, b_idx] = min([all_sols.Price]); final_sol = all_sols(b_idx);
    else, [~, b_idx] = min([feasible.Weight]); final_sol = feasible(b_idx); end

    fprintf('   -> 🏆 Winner: %s (Thickness: %.1f mm)\n', final_sol.Material, final_sol.T);

    % --- 2. Professional Certificate Generation (PDF) ---
    fprintf('📜 [DOC] Generating Official Design Certificate...\n');
    pdf_path = fullfile(output_dir, 'AMD_Design_Certificate.pdf');
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        
        % --- Certificate Styling ---
        selection.ParagraphFormat.Alignment = 1; % Center
        selection.Font.Size = 28; selection.Font.Bold = 1; selection.Font.ColorIndex = 'wdBlue';
        
        if strcmp(lang, 'JP')
            selection.TypeText('★ AMD 公式設計証明書 ★'); selection.TypeParagraph;
            selection.Font.Size = 14; selection.Font.ColorIndex = 'wdAuto'; selection.Font.Bold = 0;
            selection.TypeText('本設計は、Algo-Mech Designer (AMD) AIエンジンによって最適化および保証されています。');
            selection.TypeParagraph; selection.TypeParagraph;
            
            selection.ParagraphFormat.Alignment = 0; % Left
            selection.Font.Size = 16; selection.Font.Bold = 1; selection.TypeText('【 設計要件 】'); selection.TypeParagraph;
            selection.Font.Size = 12; selection.Font.Bold = 0;
            selection.TypeText(sprintf(' - 目標荷重: %d kg\n - 予算上限: %d JPY\n - 適用安全率: %.1f', target_load, budget_limit, safety_factor));
            selection.TypeParagraph; selection.TypeParagraph;
            
            selection.Font.Size = 16; selection.Font.Bold = 1; selection.Font.ColorIndex = 'wdRed';
            selection.TypeText('【 AI 最適化結果 】'); selection.TypeParagraph;
            selection.Font.Size = 14; selection.Font.Bold = 1; selection.Font.ColorIndex = 'wdAuto';
            selection.TypeText(sprintf(' 👑 選定素材: %s', final_sol.Material)); selection.TypeParagraph;
            selection.Font.Size = 12; selection.Font.Bold = 0;
            selection.TypeText(sprintf(' - 推奨厚み: %.1f mm (型番: %s)\n - 推定重量: %.3f kg\n - 算出価格: %d JPY', final_sol.T, final_sol.PartNo, final_sol.Weight, final_sol.Price));
            
        else
            selection.TypeText('★ AMD Official Design Certificate ★'); selection.TypeParagraph;
            selection.Font.Size = 14; selection.Font.ColorIndex = 'wdAuto'; selection.Font.Bold = 0;
            selection.TypeText('This design is fully optimized and certified by the Algo-Mech Designer AI Engine.');
            selection.TypeParagraph; selection.TypeParagraph;
            
            selection.ParagraphFormat.Alignment = 0; % Left
            selection.Font.Size = 16; selection.Font.Bold = 1; selection.TypeText('[ Design Requirements ]'); selection.TypeParagraph;
            selection.Font.Size = 12; selection.Font.Bold = 0;
            selection.TypeText(sprintf(' - Target Load: %d kg\n - Budget Limit: %d JPY\n - Safety Factor: %.1f', target_load, budget_limit, safety_factor));
            selection.TypeParagraph; selection.TypeParagraph;
            
            selection.Font.Size = 16; selection.Font.Bold = 1; selection.Font.ColorIndex = 'wdRed';
            selection.TypeText('[ AI Optimization Result ]'); selection.TypeParagraph;
            selection.Font.Size = 14; selection.Font.Bold = 1; selection.Font.ColorIndex = 'wdAuto';
            selection.TypeText(sprintf(' 👑 Selected Material: %s', final_sol.Material)); selection.TypeParagraph;
            selection.Font.Size = 12; selection.Font.Bold = 0;
            selection.TypeText(sprintf(' - Optimal Thickness: %.1f mm (Part: %s)\n - Est. Weight: %.3f kg\n - Total Price: %d JPY', final_sol.T, final_sol.PartNo, final_sol.Weight, final_sol.Price));
        end
        
        selection.TypeParagraph; selection.TypeParagraph;
        selection.ParagraphFormat.Alignment = 1; % Center
        selection.Font.Size = 10; selection.Font.ColorIndex = 'wdGray50';
        selection.TypeText(['Generated on: ', datestr(now), ' | Powered by WaRara-men AMD Suite v7.0']);
        
        if exist(pdf_path, 'file'), delete(pdf_path); end
        doc.SaveAs2(pdf_path, 17); doc.Close(0); word.Quit;
        fprintf('   -> ✅ Certificate saved to /out/AMD_Design_Certificate.pdf\n');
    catch ME
        fprintf('   -> ❌ PDF Generation Failed: %s\n', ME.message);
        if exist('word', 'var'), word.Quit; end
    end

    % --- 3. Final Voice ---
    try
        NET.addAssembly('System.Speech'); speak = System.Speech.Synthesis.SpeechSynthesizer;
        if strcmp(lang, 'JP')
            msg = sprintf('設計が完了しました。最適な素材は、%s、です。証明書を発行しました。', char(final_sol.Material));
        else
            msg = sprintf('Design complete. The best material is %s. Certificate generated.', char(final_sol.Material));
        end
        speak.Speak(msg);
    catch, end
end
