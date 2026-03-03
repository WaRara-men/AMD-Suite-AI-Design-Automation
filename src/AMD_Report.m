% ==========================================
% Algo-Mech Designer (AMD) Suite - Reporter v13.0
% ==========================================
function AMD_Report(payload, length, radius, budget, safety, mode, motor, arm_mass, req_t, catalog, b_idx, output_dir)
    fprintf('📜 [REPORT] Generating Definitive Certificate...\n');
    chart_path = fullfile(output_dir, 'temp_chart.png');
    f = figure('Visible', 'off'); bar(catalog.Torque_Nm); hold on; bar(b_idx, motor.Torque_Nm); saveas(f, chart_path); close(f);
    
    ts = datestr(now, 'yyyymmdd_HHMMSS');
    pdf_path = fullfile(output_dir, sprintf('AMD_Master_Cert_%s.pdf', ts));
    
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        
        selection.ParagraphFormat.Alignment = 1; selection.Font.Size = 24; selection.Font.Bold = 1; selection.Font.ColorIndex = 'wdBlue';
        selection.TypeText('ULTIMATE ENGINEERING CERTIFICATE'); selection.TypeParagraph;
        
        selection.ParagraphFormat.Alignment = 0; selection.Font.Size = 11; selection.Font.Bold = 1;
        selection.TypeText('■ 論理的選定根拠 (Engineering Selection Logic)'); selection.TypeParagraph;
        selection.Font.Bold = 0;
        logic_txt = sprintf(['目標荷重 %.1fkg、アーム長 %dmm に対し、AIは自重 %.3fkg を含む理論トルク %.2f Nm を算出。', ...
            '予算 %d円 内で最も軽量な「%s」を最適解として特定しました。'], payload, length, arm_mass, req_t, round(budget), char(motor.PartName));
        selection.TypeText(logic_txt); selection.TypeParagraph; selection.TypeParagraph;

        selection.Font.Bold = 1; selection.TypeText('■ 市場製品スペック ＆ 購入リンク (Specs & Link)'); selection.TypeParagraph;
        tbl = doc.Tables.Add(selection.Range, 5, 2); tbl.Borders.Enable = 1;
        specs = {'Selected Part', char(motor.PartName); 'Torque', [num2str(motor.Torque_Nm), ' Nm']; 'Weight', [num2str(motor.Weight_kg), ' kg']; 'Price', [num2str(round(motor.Price_JPY)), ' JPY']; 'Purchase', '🖱️ CLICK TO BUY'};
        for r = 1:5
            tbl.Cell(r,1).Range.Text = specs{r,1}; tbl.Cell(r,1).Range.Font.Bold = 1;
            if r == 5, doc.Hyperlinks.Add(tbl.Cell(r,2).Range, char(motor.ProductURL), '', '', specs{r,2}); else tbl.Cell(r,2).Range.Text = specs{r,2}; end
        end
        doc.Range(tbl.Range.End, tbl.Range.End).Select; selection = word.Selection;
        selection.TypeParagraph; selection.InlineShapes.AddPicture(chart_path);
        
        doc.SaveAs2(pdf_path, 17); doc.Close(0); word.Quit;
        system(['start "" "', pdf_path, '"']);
    catch ME, if exist('word', 'var'), word.Quit; end; end
    delete(chart_path);
end
