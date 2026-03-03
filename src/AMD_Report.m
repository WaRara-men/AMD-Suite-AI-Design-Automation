% ==========================================
% Algo-Mech Designer (AMD) Suite - Reporter v15.0
% ==========================================
function AMD_Report(mode, comp, req_val, metric_name, metric_unit, catalog, b_idx, output_dir)
    fprintf('📜 [REPORT] Generating Omnipotent Certificate...\n');
    chart_path = fullfile(output_dir, 'temp_chart.png');
    
    % Save current figures from the UI implicitly or recreate them silently
    f1 = figure('Visible', 'off');
    switch mode
        case {'Arm', 'Lift', 'Mobile'}, vals = catalog.Torque_Nm;
        case 'Power', vals = catalog.Capacity_mAh;
        case 'Bolt', vals = catalog.MaxShear_N;
    end
    bar(vals); hold on; bar(b_idx, vals(b_idx)); saveas(f1, chart_path); close(f1);
    
    ts = datestr(now, 'yyyymmdd_HHMMSS');
    pdf_path = fullfile(output_dir, sprintf('AMD_Master_Cert_%s.pdf', ts));
    
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        
        selection.ParagraphFormat.Alignment = 1; selection.Font.Size = 24; selection.Font.Bold = 1; selection.Font.ColorIndex = 'wdBlue';
        selection.TypeText('ULTIMATE OMNIPOTENT DESIGN CERTIFICATE'); selection.TypeParagraph;
        selection.Font.Size = 18; selection.TypeText(sprintf('モジュール: %s 解析鑑定書', mode)); selection.TypeParagraph;
        selection.TypeParagraph;

        selection.ParagraphFormat.Alignment = 0; selection.Font.Size = 11; selection.Font.Bold = 1;
        selection.TypeText('■ 論理的選定根拠 (Engineering Selection Logic)'); selection.TypeParagraph;
        selection.Font.Bold = 0;
        logic_txt = sprintf(['AIは物理シミュレーションにより、必要な %s が %.2f %s であると算出しました。', ...
            '該当するカタログデータベースの中から、要求スペックを満たし、かつ予算制約内で最もコストパフォーマンスに優れた', ...
            '「%s」を最適コンポーネントとして特定しました。'], metric_name, req_val, metric_unit, char(comp.PartName));
        selection.TypeText(logic_txt); selection.TypeParagraph; selection.TypeParagraph;

        selection.Font.Bold = 1; selection.TypeText('■ 性能仕様 ＆ 購入リンク (Specs & Link)'); selection.TypeParagraph;
        tbl = doc.Tables.Add(selection.Range, 4, 2); tbl.Borders.Enable = 1;
        
        % Dynamic Specs
        specs = {
            'Selected Component', char(comp.PartName); 
            metric_name, [num2str(req_val, '%.2f'), ' ', metric_unit]; 
            'Unit Price', [num2str(round(comp.Price_JPY)), ' JPY']; 
            'Purchase URL', '🖱️ CLICK TO BUY'
        };
        for r = 1:4
            tbl.Cell(r,1).Range.Text = specs{r,1}; tbl.Cell(r,1).Range.Font.Bold = 1;
            if r == 4, doc.Hyperlinks.Add(tbl.Cell(r,2).Range, char(comp.ProductURL), '', '', specs{r,2}); else tbl.Cell(r,2).Range.Text = specs{r,2}; end
        end
        doc.Range(tbl.Range.End, tbl.Range.End).Select; selection = word.Selection;
        selection.TypeParagraph; selection.InlineShapes.AddPicture(chart_path);
        
        doc.SaveAs2(pdf_path, 17); doc.Close(0); word.Quit;
        system(['start "" "', pdf_path, '"']);
    catch ME, if exist('word', 'var'), word.Quit; end; end
    delete(chart_path);
end
