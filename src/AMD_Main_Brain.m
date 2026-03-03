% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v7.3
% Unique Timestamped PDF & Forced Front-Open
% ==========================================

function AMD_Main_Brain(target_load, budget_limit, safety_factor, lang)
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    data_dir = fullfile(project_root, 'data');
    output_dir = fullfile(project_root, 'out');
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end
    
    % --- 1. AI Logic & Specification Logic ---
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
    [~, b_idx] = min([all_sols.Weight]); final_sol = all_sols(b_idx);

    % --- 2. 🌟 Unique PDF Generation (Time-stamped) ---
    ts = datestr(now, 'yyyymmdd_HHMMSS');
    pdf_name = sprintf('AMD_Certificate_%s.pdf', ts);
    pdf_path = fullfile(output_dir, pdf_name);
    
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        
        selection.ParagraphFormat.Alignment = 1;
        selection.Font.Size = 26; selection.Font.Bold = 1;
        selection.TypeText('OFFICIAL DESIGN CERTIFICATE'); selection.TypeParagraph;
        selection.Font.Size = 12; selection.Font.Bold = 0;
        selection.TypeText(sprintf('Result: %s | Time: %s', final_sol.Material, datestr(now)));
        
        % Save as PDF
        doc.SaveAs2(pdf_path, 17); doc.Close(0); word.Quit;
        fprintf('   -> ✅ Certificate generated: %s\n', pdf_name);
        
        % 🌟 [NEW] FORCED FRONT-OPEN USING WEB COMMAND
        % ブラウザを使用して最前面でPDFを開く
        web(pdf_path, '-browser');
        
        beep;
    catch ME
        fprintf('   -> ❌ PDF Generation Failed: %s\n', ME.message);
        if exist('word', 'var'), word.Quit; end
    end

    % --- 3. Final Voice ---
    try
        NET.addAssembly('System.Speech'); speak = System.Speech.Synthesis.SpeechSynthesizer;
        msg = sprintf('設計完了。最新の証明書を開きます。');
        speak.Speak(msg);
    catch, end
end
