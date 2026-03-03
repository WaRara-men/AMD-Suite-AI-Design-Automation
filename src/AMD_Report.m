% ==========================================
% Algo-Mech Designer (AMD) Suite - Reporter v22.1
% MULTI-MODE STABLE GRAPH ENGINE
% ==========================================
function AMD_Report(payload, length, radius, budget, safety, mode, motor, req_val, m_name, m_unit, desc_jp, catalog, b_idx, output_dir)
    fprintf('📜 [REPORT] Forging definitive certificate for %s...\n', mode);
    chart_path = fullfile(output_dir, 'temp_chart.png');
    render_path = fullfile(output_dir, 'temp_3d.png');
    
    % --- 📊 FIXED: Mode-Aware Graph Generation ---
    f1 = figure('Visible', 'off');
    switch mode
        case {'Arm', 'Lift', 'Mobile'}, plot_vals = catalog.Torque_Nm;
        case 'Power', plot_vals = catalog.Capacity_mAh;
        case 'Bolt', plot_vals = catalog.MaxShear_N;
    end
    bar(plot_vals, 'FaceColor', [0.3 0.3 0.3]); hold on;
    bar(b_idx, plot_vals(b_idx), 'FaceColor', [1.0 0.6 0.2]);
    set(gca, 'XTickLabel', catalog.PartName, 'XTickLabelRotation', 30);
    title(sprintf('%s Comparison', m_name));
    saveas(f1, chart_path); close(f1);
    
    % --- 📸 Simplified 3D Evidence ---
    f2 = figure('Visible', 'off', 'Color', 'w'); ax = axes(f2);
    [X, Y, Z] = cylinder([10 10], 20); surf(ax, Z*100, X, Y, 'FaceColor', [0.7 0.7 0.7]);
    view(3); axis equal; axis off; saveas(f2, render_path); close(f2);

    ts = datestr(now, 'yyyymmdd_HHMMSS');
    pdf_path = fullfile(output_dir, sprintf('AMD_Master_Cert_%s.pdf', ts));
    
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        
        selection.ParagraphFormat.Alignment = 1; selection.Font.Size = 24; selection.Font.Bold = 1;
        selection.TypeText('OFFICIAL ENGINEERING VERIFICATION'); selection.TypeParagraph;
        selection.Font.Size = 18; selection.TypeText(['■ ', mode, ' 分析証明書']); selection.TypeParagraph;
        
        selection.ParagraphFormat.Alignment = 0; selection.Font.Size = 11; selection.Font.Bold = 1;
        selection.TypeText('■ 解析の論理性 (Logic)'); selection.TypeParagraph;
        selection.Font.Bold = 0;
        selection.TypeText(sprintf('解析対象: %s. 必要スペック: %.2f %s. 選定された「%s」はこの条件をクリアする最適解です。', desc_jp, req_val, m_unit, char(motor.PartName)));
        selection.TypeParagraph; selection.TypeParagraph;

        selection.Font.Bold = 1; selection.TypeText('■ 詳細スペック ＆ 購入リンク (Specs & Link)'); selection.TypeParagraph;
        tbl = doc.Tables.Add(selection.Range, 4, 2); tbl.Borders.Enable = 1;
        specs = {'Product', char(motor.PartName); [m_name, ' [', m_unit, ']'], num2str(req_val, '%.2f'); 'Price', [num2str(round(motor.Price_JPY)), ' JPY']; 'Link', '🛒 CLICK TO BUY'};
        for r = 1:4
            tbl.Cell(r,1).Range.Text = specs{r,1}; tbl.Cell(r,1).Range.Font.Bold = 1;
            if r == 4, doc.Hyperlinks.Add(tbl.Cell(r,2).Range, char(motor.ProductURL), '', '', specs{r,2}); else tbl.Cell(r,2).Range.Text = specs{r,2}; end
        end
        doc.Range(tbl.Range.End, tbl.Range.End).Select; selection = word.Selection;
        selection.TypeParagraph; selection.InlineShapes.AddPicture(chart_path);
        
        selection.ParagraphFormat.Alignment = 2; selection.Font.Bold = 1;
        selection.TypeText('Chief Engineer: WaRara-men');
        
        doc.SaveAs2(pdf_path, 17); doc.Close(0); word.Quit;
        system(['start "" "', pdf_path, '"']); beep;
    catch ME, if exist('word', 'var'), word.Quit; end; end
    delete(chart_path); delete(render_path);
end
