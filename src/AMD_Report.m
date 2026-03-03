% ==========================================
% Algo-Mech Designer (AMD) Suite - Reporter v14.0
% TRUE MASTERPIECE: Long Text, 3D Render, Graph & Links
% ==========================================

function AMD_Report(payload, length, radius, budget, safety, mode, motor, arm_mass, req_t, catalog, b_idx, output_dir)
    fprintf('📜 [REPORT] Crafting Zenith Certificate...\n');
    ts = datestr(now, 'yyyymmdd_HHMMSS');
    pdf_path = fullfile(output_dir, sprintf('AMD_Zenith_Cert_%s.pdf', ts));
    
    chart_path = fullfile(output_dir, 'temp_chart.png');
    render_path = fullfile(output_dir, 'temp_3d.png');
    
    % --- Visual Capture ---
    f1 = figure('Visible', 'off'); bar(catalog.Torque_Nm); hold on; bar(b_idx, motor.Torque_Nm); saveas(f1, chart_path); close(f1);
    f2 = figure('Visible', 'off', 'Color', 'w'); ax = axes(f2);
    [X, Y, Z] = cylinder([radius radius], 20); Z = Z * length; surf(ax, Z, X, Y, 'FaceColor', [0.7 0.7 0.7]);
    hold on; [Xm, Ym, Zm] = sphere(20); Xm=Xm*25+length; Ym=Ym*25; Zm=Zm*25; surf(ax, Xm, Ym, Zm, 'FaceColor', [1.0 0.5 0.0]);
    view(3); axis equal; axis off; saveas(f2, render_path); close(f2);

    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        
        % Header (Center)
        selection.ParagraphFormat.Alignment = 1;
        selection.Font.Size = 26; selection.Font.Bold = 1; selection.Font.ColorIndex = 'wdBlue';
        selection.TypeText('ZENITH ENGINEERING VERIFICATION'); selection.TypeParagraph;
        selection.Font.Size = 18; selection.TypeText('究極のロボット設計・構成部品選定鑑定書'); selection.TypeParagraph;
        selection.TypeParagraph;

        % Intro (Long Text)
        selection.ParagraphFormat.Alignment = 0; selection.Font.Size = 11; selection.Font.Bold = 1;
        selection.TypeText('■ はじめに (Introduction)'); selection.TypeParagraph;
        selection.Font.Bold = 0;
        selection.TypeText(['本ドキュメントは、AI物理演算により「Robot Arm」における最適構成を保証するものです。', ...
            '安全性、経済性、機動性の3点において、理論上のパレート最適解を特定いたしました。']);
        selection.TypeParagraph; selection.TypeParagraph;

        % 3D Render Image
        selection.Font.Bold = 1; selection.TypeText('■ 設計モデルの外観 (3D Design Evidence)'); selection.TypeParagraph;
        selection.InlineShapes.AddPicture(render_path); selection.TypeParagraph;

        % Logic (Long Text)
        selection.Font.Bold = 1; selection.TypeText('■ 精密選定ロジック (Selection Logic)'); selection.TypeParagraph;
        selection.Font.Bold = 0;
        logic_txt = sprintf(['目標荷重 %.1fkg、アーム長 %dmm に対し、AIは自重 %.3fkg を含む理論トルク %.2f Nm を算出。', ...
            '予算 %d円 内で最高効率を誇る「%s」を、世界市場データベースより自動選定しました。'], ...
            payload, length, arm_mass, req_t, round(budget), char(motor.PartName));
        selection.TypeText(logic_txt); selection.TypeParagraph; selection.TypeParagraph;

        % Specs Table with HYPERLINK
        selection.Font.Bold = 1; selection.TypeText('■ 技術詳細 ＆ 購入リンク (Specifications & Purchase)'); selection.TypeParagraph;
        tbl = doc.Tables.Add(selection.Range, 5, 2); tbl.Borders.Enable = 1;
        specs = {'Motor Name', char(motor.PartName); 'Torque Cap', [num2str(motor.Torque_Nm), ' Nm']; 'System Mass', [num2str(motor.Weight_kg + arm_mass, '%.3f'), ' kg']; 'Total Cost', [num2str(round(motor.Price_JPY)), ' JPY']; 'Product URL', '🖱️ CLICK TO PURCHASE'};
        for r = 1:5
            tbl.Cell(r,1).Range.Text = specs{r,1}; tbl.Cell(r,1).Range.Font.Bold = 1;
            if r == 5, doc.Hyperlinks.Add(tbl.Cell(r,2).Range, char(motor.ProductURL), '', '', specs{r,2}); else tbl.Cell(r,2).Range.Text = specs{r,2}; end
        end
        doc.Range(tbl.Range.End, tbl.Range.End).Select; selection = word.Selection;
        selection.TypeParagraph;

        % Comparison Graph
        selection.Font.Bold = 1; selection.TypeText('■ 市場比較データ (Analysis Graph)'); selection.TypeParagraph;
        selection.InlineShapes.AddPicture(chart_path);

        % Footer
        selection.ParagraphFormat.Alignment = 2; selection.Font.Bold = 1;
        selection.TypeText('Chief Engineer: WaRara-men');
        
        doc.SaveAs2(pdf_path, 17); doc.Close(0); word.Quit;
        system(['start "" "', pdf_path, '"']); beep;
    catch ME, if exist('word', 'var'), word.Quit; end; end
    delete(chart_path); delete(render_path);
end
