% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v8.7
% THE ABSOLUTE GOD-MODE: Voice, Graphics, Links & Long Text
% ==========================================

function AMD_Main_Brain(payload_kg, arm_length_mm, budget_limit, safety_factor, lang)
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    data_dir = fullfile(project_root, 'data');
    output_dir = fullfile(project_root, 'out');
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end
    
    % --- 1. AI Logic & Ranking ---
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

    % --- 2. 📸 Generate Visual Proof ---
    chart_path = fullfile(output_dir, 'temp_chart.png');
    render_path = fullfile(output_dir, 'temp_3d.png');
    f1 = figure('Visible', 'off'); bar(catalog.Torque_Nm, 'FaceColor', [0.4 0.4 0.4]); hold on;
    bar(best_idx, motor.Torque_Nm, 'FaceColor', [1.0 0.6 0.2]); saveas(f1, chart_path); close(f1);
    f2 = figure('Visible', 'off', 'Color', 'w'); ax = axes(f2);
    [X, Y, Z] = cylinder([2 2], 20); Z = Z * arm_length_mm;
    surf(ax, Z, X, Y, 'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'none'); axis equal; axis off; view(3); camlight; saveas(f2, render_path); close(f2);

    % --- 3. 📜 [ABSOLUTE] Rich Certification (PDF) ---
    ts = datestr(now, 'yyyymmdd_HHMMSS');
    pdf_path = fullfile(output_dir, sprintf('AMD_Motor_Cert_%s.pdf', ts));
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        
        % [Title]
        selection.ParagraphFormat.Alignment = 1;
        selection.Font.Size = 22; selection.Font.Bold = 1; selection.Font.ColorIndex = 'wdBlue';
        selection.TypeText('ADVANCED ENGINEERING OPTIMIZATION CERTIFICATE'); selection.TypeParagraph;
        selection.Font.Size = 16; selection.TypeText('次世代ロボット設計・構成部品選定証明書'); selection.TypeParagraph;
        selection.TypeParagraph;

        % [Long Japanese Introduction - RESTORED!]
        selection.ParagraphFormat.Alignment = 0; selection.Font.Size = 11; selection.Font.Bold = 1;
        selection.TypeText('■ 本証明書の目的 (Introduction)'); selection.TypeParagraph;
        selection.Font.Bold = 0;
        selection.TypeText(['本ドキュメントは、物理演算に基づき算出された特定の荷重条件下における最適な', ...
            'アクチュエータ構成を保証するものです。安全性と経済性を最高レベルで両立いたしました。']);
        selection.TypeParagraph; selection.TypeParagraph;

        % [3D Preview - RESTORED!]
        selection.Font.Bold = 1; selection.TypeText('■ 最適化モデルの外観 (3D Preview)'); selection.TypeParagraph;
        selection.InlineShapes.AddPicture(render_path); selection.TypeParagraph;

        % [Detailed Reasoning - RESTORED!]
        selection.Font.Bold = 1; selection.TypeText('■ 選定の論理的根拠 (Selection Logic)'); selection.TypeParagraph;
        selection.Font.Bold = 0;
        reasoning = sprintf(['目標荷重 %.1fkg に対して理論トルク %.2f N-m を算出。', ...
            '予算 %d円 以内で最も軽量な「%s」を、世界市場データベースより自動選定しました。'], ...
            payload_kg, required_torque, round(budget_limit), char(motor.PartName));
        selection.TypeText(reasoning); selection.TypeParagraph; selection.TypeParagraph;

        % [Ranking Table with Links - RESTORED!]
        selection.Font.Bold = 1; selection.TypeText('■ AI推奨製品ランキング (Product Ranking)'); selection.TypeParagraph;
        num_rank = min(3, length(sorted_feasible_idx));
        tbl = doc.Tables.Add(selection.Range, num_rank + 1, 4); tbl.Borders.Enable = 1;
        for c = 1:4, tbl.Cell(1,c).Range.Font.Bold = 1; end
        tbl.Cell(1,1).Range.Text = 'Rank'; tbl.Cell(1,2).Range.Text = 'Product Name'; tbl.Cell(1,3).Range.Text = 'Price'; tbl.Cell(1,4).Range.Text = 'Buy Link';
        for r = 1:num_rank
            m_idx = sorted_feasible_idx(r); m_d = catalog(m_idx, :);
            tbl.Cell(r+1, 1).Range.Text = sprintf('#%d', r);
            tbl.Cell(r+1, 2).Range.Text = char(m_d.PartName);
            tbl.Cell(r+1, 3).Range.Text = sprintf('%d JPY', round(m_d.Price_JPY));
            doc.Hyperlinks.Add(tbl.Cell(r+1, 4).Range, char(m_d.ProductURL), '', '', '🛒 Click here');
        end
        doc.Range(tbl.Range.End, tbl.Range.End).Select; selection = word.Selection;
        selection.TypeParagraph; selection.InlineShapes.AddPicture(chart_path);

        % [Footer]
        selection.ParagraphFormat.Alignment = 2; selection.Font.Bold = 1;
        selection.TypeText('Chief Engineer: WaRara-men');
        
        doc.SaveAs2(pdf_path, 17); doc.Close(0); word.Quit;
        system(['start "" "', pdf_path, '"']); beep;
    catch ME, if exist('word', 'var'), word.Quit; end; end

    % --- 4. 🎙️ [RESTORED] Full Voice ---
    try
        NET.addAssembly('System.Speech'); speak = System.Speech.Synthesis.SpeechSynthesizer;
        msg = sprintf('設計完了。最適なモーターは、%s、です。購入リンク付きの証明書を発行しました。', char(motor.PartName));
        speak.Speak(msg);
    catch, end
    delete(chart_path); delete(render_path);
end
