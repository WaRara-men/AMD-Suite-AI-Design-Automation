% ==========================================
% Algo-Mech Designer (AMD) Suite - Reporter v23.5
% ULTIMATE SNAPSHOT EDITION: Real 3D in PDF
% ==========================================
function AMD_Report(payload, length, radius, budget, safety, mode, motor, req_val, m_name, m_unit, desc_jp, catalog, b_idx, output_dir, ax_3d)
    fprintf('📜 [REPORT] Crafting Masterpiece Certificate with Real 3D and Enhanced Analytics...\n');
    chart_path1 = fullfile(output_dir, 'temp_chart_ranking.png');
    chart_path2 = fullfile(output_dir, 'temp_chart_scatter.png');
    render_path = fullfile(output_dir, 'temp_3d.png');
    
    % --- 📸 REAL SNAPSHOT FROM UI ---
    exportgraphics(ax_3d, render_path, 'Resolution', 300);
    
    % --- 📊 Graph 1: Ranking (Bar) ---
    f1 = figure('Visible', 'off', 'Color', 'w'); 
    switch mode
        case {'Arm', 'Lift', 'Mobile'}, plot_vals = catalog.Torque_Nm; y_label = 'Torque [Nm]';
        case 'Power', plot_vals = catalog.Capacity_mAh; y_label = 'Capacity [mAh]';
        case 'Bolt', plot_vals = catalog.MaxShear_N; y_label = 'Shear Force [N]';
    end
    bar(plot_vals, 'FaceColor', [0.8 0.8 0.8]); hold on; 
    bar(b_idx, plot_vals(b_idx), 'FaceColor', [1.0 0.6 0.2]);
    yline(req_val, '--r', 'Required', 'LineWidth', 1.5);
    title(['Catalog Ranking: ', m_name]); ylabel(y_label);
    set(gca, 'XTickLabel', catalog.PartName, 'XTickLabelRotation', 45, 'FontSize', 9);
    grid on; saveas(f1, chart_path1); close(f1);

    % --- 📊 Graph 2: Price vs Performance (Scatter) ---
    f2 = figure('Visible', 'off', 'Color', 'w');
    scatter(catalog.Price_JPY, plot_vals, 100, 'filled', 'MarkerFaceColor', [0.5 0.5 0.5]); hold on;
    scatter(motor.Price_JPY, plot_vals(b_idx), 150, 'filled', 'MarkerFaceColor', [1.0 0.4 0.0]);
    text(motor.Price_JPY, plot_vals(b_idx), ['  Selected: ', char(motor.PartName)], 'FontWeight', 'bold');
    xlabel('Price [JPY]'); ylabel(y_label); title('Cost-Performance Analysis');
    grid on; saveas(f2, chart_path2); close(f2);

    ts = datestr(now, 'yyyymmdd_HHMMSS');
    pdf_path = fullfile(output_dir, sprintf('AMD_Zenith_Cert_%s.pdf', ts));
    
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        
        % Header & Branding
        selection.ParagraphFormat.Alignment = 1; selection.Font.Size = 26; selection.Font.Bold = 1; selection.Font.ColorIndex = 'wdBlue';
        selection.TypeText('ZENITH ENGINEERING VERIFICATION'); selection.TypeParagraph;
        selection.Font.Size = 10; selection.Font.Bold = 0; selection.Font.ColorIndex = 'wdGray50';
        selection.TypeText(['Generated on: ', datestr(now)]); selection.TypeParagraph; selection.TypeParagraph;
        
        % Purpose
        selection.ParagraphFormat.Alignment = 0; selection.Font.Size = 12; selection.Font.Bold = 1; selection.Font.ColorIndex = 'wdAuto';
        selection.TypeText('■ 技術的証明の目的 (Purpose)'); selection.TypeParagraph;
        selection.Font.Bold = 0; selection.Font.Size = 11;
        selection.TypeText(['本ドキュメントは、AMD Suite v23.5 AIシミュレーションにより「', mode, '」における最適部品「', char(motor.PartName), '」の選定を公式に証明するものです。']);
        selection.TypeParagraph; selection.TypeParagraph;

        % 3D Evidence
        selection.Font.Bold = 1; selection.TypeText('■ 設計モデルの視覚的証明 (3D Design Evidence)'); selection.TypeParagraph;
        shape = selection.InlineShapes.AddPicture(render_path); 
        shape.Width = 400; % Scale down a bit to fit better
        selection.TypeParagraph; selection.TypeParagraph;

        % Selection Logic & Specs
        selection.Font.Bold = 1; selection.TypeText('■ 解析結果と仕様 (Analysis & Specs)'); selection.TypeParagraph;
        tbl = doc.Tables.Add(selection.Range, 5, 2); tbl.Borders.Enable = 1;
        specs = {
            'Selected Component', char(motor.PartName);
            'Analyzed Metric', [m_name, ': ', num2str(req_val, '%.2f'), ' ', m_unit];
            'Price (Estimated)', [num2str(round(motor.Price_JPY)), ' JPY'];
            'Weight Class', [num2str(motor.Weight_kg, '%.3f'), ' kg'];
            'Action', '🛒 [CLICK TO PURCHASE]'
        };
        for r = 1:5
            tbl.Cell(r,1).Range.Text = specs{r,1}; tbl.Cell(r,1).Range.Font.Bold = 1;
            if r == 5, doc.Hyperlinks.Add(tbl.Cell(r,2).Range, char(motor.ProductURL), '', '', specs{r,2}); else tbl.Cell(r,2).Range.Text = specs{r,2}; end
        end
        doc.Range(tbl.Range.End, tbl.Range.End).Select; selection = word.Selection;
        selection.TypeParagraph;

        % Analytics Graphs
        selection.Font.Bold = 1; selection.TypeText('■ 高度なデータ分析 (Advanced Analytics)'); selection.TypeParagraph;
        selection.InlineShapes.AddPicture(chart_path1); selection.TypeParagraph;
        selection.InlineShapes.AddPicture(chart_path2); selection.TypeParagraph;

        % Footer Links
        selection.TypeParagraph; selection.Font.Bold = 1; selection.Font.Size = 10;
        selection.TypeText('■ 関連リソース (Links)'); selection.TypeParagraph;
        selection.Font.Bold = 0;
        doc.Hyperlinks.Add(selection.Range, 'https://github.com/WaRara-men/AMD-Suite-AI-Design-Automation', '', '', '📁 Visit Project Repository');
        selection.TypeParagraph;
        doc.Hyperlinks.Add(selection.Range, 'https://wa-rara.net/amd-manual', '', '', '📖 Online Documentation & Manual');
        selection.TypeParagraph; selection.TypeParagraph;
        
        selection.ParagraphFormat.Alignment = 2; selection.Font.Bold = 1; selection.Font.Size = 12;
        selection.TypeText('AMD Suite Certified Engineering Team'); selection.TypeParagraph;
        selection.TypeText('Chief Engineer: WaRara-men');
        
        doc.SaveAs2(pdf_path, 17); doc.Close(0); word.Quit;
        system(['start "" "', pdf_path, '"']); beep;
        fprintf('✅ [SUCCESS] Report generated: %s\n', pdf_path);
    catch ME
        fprintf('❌ [ERROR] Report generation failed: %s\n', ME.message);
        if exist('word', 'var'), word.Quit; end
    end
    delete(chart_path1); delete(chart_path2); delete(render_path);
end
