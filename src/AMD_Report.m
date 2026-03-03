% ==========================================
% Algo-Mech Designer (AMD) Suite - Reporter v23.0
% ULTIMATE SNAPSHOT EDITION: Real 3D in PDF
% ==========================================
function AMD_Report(payload, length, radius, budget, safety, mode, motor, req_val, m_name, m_unit, desc_jp, catalog, b_idx, output_dir, ax_3d)
    fprintf('📜 [REPORT] Crafting Masterpiece Certificate with Real 3D...\n');
    chart_path = fullfile(output_dir, 'temp_chart.png');
    render_path = fullfile(output_dir, 'temp_3d.png');
    
    % --- 📸 REAL SNAPSHOT FROM UI ---
    % アプリ画面の3Dビューをそのまま写真にします
    exportgraphics(ax_3d, render_path, 'Resolution', 300);
    
    % --- 📊 Ranking Graph ---
    f1 = figure('Visible', 'off'); 
    switch mode
        case {'Arm', 'Lift', 'Mobile'}, plot_vals = catalog.Torque_Nm;
        case 'Power', plot_vals = catalog.Capacity_mAh;
        case 'Bolt', plot_vals = catalog.MaxShear_N;
    end
    bar(plot_vals, 'FaceColor', [0.3 0.3 0.3]); hold on; bar(b_idx, plot_vals(b_idx), 'FaceColor', [1.0 0.6 0.2]);
    set(gca, 'XTickLabel', catalog.PartName, 'XTickLabelRotation', 30); saveas(f1, chart_path); close(f1);

    ts = datestr(now, 'yyyymmdd_HHMMSS');
    pdf_path = fullfile(output_dir, sprintf('AMD_Zenith_Cert_%s.pdf', ts));
    
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        
        % Header
        selection.ParagraphFormat.Alignment = 1; selection.Font.Size = 24; selection.Font.Bold = 1; selection.Font.ColorIndex = 'wdBlue';
        selection.TypeText('ZENITH ENGINEERING VERIFICATION'); selection.TypeParagraph;
        
        % 🌟 [RESTORED] RICH DESCRIPTIONS
        selection.ParagraphFormat.Alignment = 0; selection.Font.Size = 11; selection.Font.Bold = 1; selection.Font.ColorIndex = 'wdAuto';
        selection.TypeText('■ 本証明書の目的 (Purpose)'); selection.TypeParagraph;
        selection.Font.Bold = 0;
        selection.TypeText(['本ドキュメントは、AI物理シミュレーションにより「', mode, '」構成における最適部品選定を技術的に保証するものです。']);
        selection.TypeParagraph; selection.TypeParagraph;

        % 🌟 [FIXED] REAL 3D IMAGE INSERT
        selection.Font.Bold = 1; selection.TypeText('■ 設計モデルの視覚的証明 (3D Design Evidence)'); selection.TypeParagraph;
        selection.InlineShapes.AddPicture(render_path); selection.TypeParagraph;

        % logic
        selection.Font.Bold = 1; selection.TypeText('■ 選定の論理性 (Logic)'); selection.TypeParagraph;
        selection.Font.Bold = 0;
        selection.TypeText(sprintf('解析条件: %s. 要求値: %.2f %s. 最適解: %s.', desc_jp, req_val, m_unit, char(motor.PartName)));
        selection.TypeParagraph; selection.TypeParagraph;

        % Specs Table
        tbl = doc.Tables.Add(selection.Range, 4, 2); tbl.Borders.Enable = 1;
        specs = {'Product', char(motor.PartName); [m_name, ' [', m_unit, ']'], num2str(req_val, '%.2f'); 'Price', [num2str(round(motor.Price_JPY)), ' JPY']; 'Buy Link', '🛒 CLICK TO PURCHASE'};
        for r = 1:4
            tbl.Cell(r,1).Range.Text = specs{r,1}; tbl.Cell(r,1).Range.Font.Bold = 1;
            if r == 4, doc.Hyperlinks.Add(tbl.Cell(r,2).Range, char(motor.ProductURL), '', '', specs{r,2}); else tbl.Cell(r,2).Range.Text = specs{r,2}; end
        end
        doc.Range(tbl.Range.End, tbl.Range.End).Select; selection = word.Selection;
        selection.TypeParagraph; selection.InlineShapes.AddPicture(chart_path);
        
        selection.ParagraphFormat.Alignment = 2; selection.Font.Bold = 1; selection.TypeText('Chief Engineer: WaRara-men');
        
        doc.SaveAs2(pdf_path, 17); doc.Close(0); word.Quit;
        system(['start "" "', pdf_path, '"']); beep;
    catch ME, if exist('word', 'var'), word.Quit; end; end
    delete(chart_path); delete(render_path);
end
