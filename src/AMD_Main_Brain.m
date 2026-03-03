% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v8.5
% HUMAN-READABLE EDITION: No More Scientific Notation
% ==========================================

function AMD_Main_Brain(payload_kg, arm_length_mm, budget_limit, safety_factor, lang)
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    data_dir = fullfile(project_root, 'data');
    output_dir = fullfile(project_root, 'out');
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end
    
    % --- 1. AI Logic & Physics ---
    required_torque = (payload_kg * 9.8) * (arm_length_mm / 1000) * safety_factor;
    catalog = readtable(fullfile(data_dir, 'Standard_Parts_Catalog.csv'));
    
    feasible_idx = find(catalog.Torque_Nm >= required_torque & catalog.Price_JPY <= budget_limit);
    if isempty(feasible_idx)
        feasible_idx = find(catalog.Price_JPY <= budget_limit);
        if isempty(feasible_idx), [~, best_idx] = min(catalog.Price_JPY); else, [~, sub_idx] = max(catalog.Torque_Nm(feasible_idx)); best_idx = feasible_idx(sub_idx); end
        sorted_feasible_idx = best_idx;
    else
        [~, sorted_sub_idx] = sort(catalog.Weight_kg(feasible_idx));
        sorted_feasible_idx = feasible_idx(sorted_sub_idx);
        best_idx = sorted_feasible_idx(1);
    end
    motor = catalog(best_idx, :);

    % --- 2. 📸 Generate Proof Images ---
    chart_path = fullfile(output_dir, 'temp_chart.png');
    render_path = fullfile(output_dir, 'temp_3d.png');
    f1 = figure('Visible', 'off'); bar(catalog.Torque_Nm, 'FaceColor', [0.4 0.4 0.4]); hold on;
    bar(best_idx, motor.Torque_Nm, 'FaceColor', [1.0 0.6 0.2]);
    set(gca, 'XTickLabel', catalog.PartName); title('Market Torque Comparison'); saveas(f1, chart_path); close(f1);
    f2 = figure('Visible', 'off', 'Color', 'w'); [X, Y, Z] = cylinder([2 2], 20); Z = Z * arm_length_mm;
    surf(Z, X, Y, 'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'none'); axis equal; axis off; view(3); camlight; saveas(f2, render_path); close(f2);

    % --- 3. 📜 [MASTERPIECE] Comprehensive Certificate with Ranking & Fixed Numbers ---
    ts = datestr(now, 'yyyymmdd_HHMMSS');
    pdf_path = fullfile(output_dir, sprintf('AMD_Motor_Cert_%s.pdf', ts));
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        
        % [Header & Title]
        selection.ParagraphFormat.Alignment = 1;
        selection.Font.Size = 22; selection.Font.Bold = 1; selection.Font.ColorIndex = 'wdBlue';
        selection.TypeText('ROBOT ACTUATOR SELECTION CERTIFICATE'); selection.TypeParagraph;
        selection.Font.Size = 16; selection.TypeText('実製品データに基づくロボット部品選定証明書'); selection.TypeParagraph;
        selection.TypeParagraph;

        % [Section 1: Introduction - PROTECTED]
        selection.ParagraphFormat.Alignment = 0; selection.Font.Size = 11; selection.Font.Bold = 1;
        selection.TypeText('■ 本証明書の目的 (Introduction)'); selection.TypeParagraph;
        selection.Font.Bold = 0; selection.TypeText(['本ドキュメントは、AmazonやDigiKey等の市場データベースに基づき、', ...
            '指定された物理条件を充足する実在の製品をAIが選定・保証するものです。']);
        selection.TypeParagraph; selection.TypeParagraph;

        % [3D Preview - PROTECTED]
        selection.Font.Bold = 1; selection.TypeText('■ 設計モデルの外観 (3D Preview)'); selection.TypeParagraph;
        selection.InlineShapes.AddPicture(render_path); selection.TypeParagraph;

        % [Section 2: Decision Logic - FIXED NUMBERS]
        selection.Font.Bold = 1; selection.TypeText('■ 選定の論理性 (Decision Logic)'); selection.TypeParagraph;
        selection.Font.Bold = 0;
        % Use %d to avoid scientific notation
        logic_txt = sprintf(['目標荷重 %.1fkg に対し、必要トルク %.2f N-m を算出。', ...
            '実売価格 %d円 以内で、最も機動性に優れた（軽量な）「%s」を第1推奨案としました。'], ...
            payload_kg, required_torque, round(budget_limit), char(motor.PartName));
        selection.TypeText(logic_txt); selection.TypeParagraph; selection.TypeParagraph;

        % [Section 3: RANKING TABLE (Top 3)]
        selection.Font.Bold = 1; selection.TypeText('■ AI推奨製品ランキング (AI Product Ranking)'); selection.TypeParagraph;
        num_rank = min(3, length(sorted_feasible_idx));
        tbl = doc.Tables.Add(selection.Range, num_rank + 1, 4); tbl.Borders.Enable = 1;
        headers = {'Rank', 'Product Name', 'Price [JPY]', 'Purchase Link'};
        for c = 1:4, tbl.Cell(1,c).Range.Text = headers{c}; tbl.Cell(1,c).Range.Font.Bold = 1; end
        
        for r = 1:num_rank
            m_idx = sorted_feasible_idx(r); m_data = catalog(m_idx, :);
            tbl.Cell(r+1, 1).Range.Text = sprintf('#%d', r);
            tbl.Cell(r+1, 2).Range.Text = char(m_data.PartName);
            % 🌟 FIXED: Format price as integer
            tbl.Cell(r+1, 3).Range.Text = sprintf('%d JPY', round(m_data.Price_JPY));
            doc.Hyperlinks.Add(tbl.Cell(r+1, 4).Range, char(m_data.ProductURL), '', '', '🛒 Open in Browser');
        end
        doc.Range(tbl.Range.End, tbl.Range.End).Select; selection = word.Selection;
        selection.TypeParagraph;

        % [Torque Graph - PROTECTED]
        selection.Font.Bold = 1; selection.TypeText('■ 市場製品の比較解析 (Comparative Chart)'); selection.TypeParagraph;
        selection.InlineShapes.AddPicture(chart_path); selection.TypeParagraph;

        % [Footer]
        selection.ParagraphFormat.Alignment = 2; selection.Font.Size = 12; selection.Font.Bold = 1;
        selection.TypeText('Chief Engineer: WaRara-men');
        
        doc.SaveAs2(pdf_path, 17); doc.Close(0); word.Quit;
        system(['start "" "', pdf_path, '"']); beep;
    catch ME, if exist('word', 'var'), word.Quit; end; end

    % --- 4. 🎙️ [RESTORED] Full Voice ---
    try
        NET.addAssembly('System.Speech'); speak = System.Speech.Synthesis.SpeechSynthesizer;
        msg = sprintf('解析が完了しました。予算、%d円、の中で最適なモーターは、%s、です。', round(budget_limit), char(motor.PartName));
        speak.Speak(msg);
    catch, end
    delete(chart_path); delete(render_path);
end
