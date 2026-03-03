% ==========================================
% Algo-Mech Designer (AMD) Suite - Reporter v12.0
% High-Quality Bilingual Certificate Engine
% ==========================================

function AMD_Report(payload, length, radius, budget, safety, mode, motor, arm_mass, req_t, output_dir)
    fprintf('📜 [REPORT] Forging professional certificate...
');
    ts = datestr(now, 'yyyymmdd_HHMMSS');
    pdf_path = fullfile(output_dir, sprintf('AMD_Master_Cert_%s.pdf', ts));
    
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        
        % --- Title ---
        selection.ParagraphFormat.Alignment = 1;
        selection.Font.Size = 24; selection.Font.Bold = 1; selection.Font.ColorIndex = 'wdBlue';
        selection.TypeText('ULTIMATE ROBOTICS DESIGN CERTIFICATE'); selection.TypeParagraph;
        selection.Font.Size = 18; selection.TypeText('究極のロボット設計・構成部品選定鑑定書'); selection.TypeParagraph;
        selection.TypeParagraph;

        % --- Section 1: Intro (LONG TEXT) ---
        selection.ParagraphFormat.Alignment = 0; selection.Font.Size = 11; selection.Font.Bold = 1;
        selection.TypeText('■ 本証明書の目的 (Introduction)'); selection.TypeParagraph;
        selection.Font.Bold = 0;
        selection.TypeText(['本鑑定書は、AI物理演算により「', mode, '」における最適構成を保証するものです。', ...
            '安全性、経済性、機動性の3点において、理論上のパレート最適解を特定いたしました。']);
        selection.TypeParagraph; selection.TypeParagraph;

        % --- Section 2: Logic (LONG TEXT) ---
        selection.Font.Bold = 1; selection.TypeText('■ 緻密な選定ロジックの解説 (Selection Logic)'); selection.TypeParagraph;
        selection.Font.Bold = 0;
        logic_txt = sprintf(['目標荷重 %.1fkg に対して理論トルク %.2f N-m を算出。', ...
            '予算 %d円 の制約下で最高効率を誇る「%s」を、世界市場データベースより自動選定しました。'], ...
            payload, req_t, round(budget), char(motor.PartName));
        selection.TypeText(logic_txt); selection.TypeParagraph; selection.TypeParagraph;

        % --- Section 3: Specs Table with HYPERLINK ---
        selection.Font.Bold = 1; selection.TypeText('■ 部品詳細仕様 ＆ 購入リンク (Specifications & Link)'); selection.TypeParagraph;
        tbl = doc.Tables.Add(selection.Range, 5, 2); tbl.Borders.Enable = 1;
        specs = {'Product Name', char(motor.PartName); 'Torque Rating', [num2str(motor.Torque_Nm), ' Nm']; 'System Weight', [num2str(motor.Weight_kg + arm_mass, '%.3f'), ' kg']; 'Price', [num2str(round(motor.Price_JPY)), ' JPY']; 'Purchase', '🖱️ Click to Open / 購入サイトを開く'};
        for r = 1:5
            tbl.Cell(r,1).Range.Text = specs{r,1}; tbl.Cell(r,1).Range.Font.Bold = 1;
            if r == 5, doc.Hyperlinks.Add(tbl.Cell(r,2).Range, char(motor.ProductURL), '', '', specs{r,2}); else tbl.Cell(r,2).Range.Text = specs{r,2}; end
        end
        doc.Range(tbl.Range.End, tbl.Range.End).Select; selection = word.Selection;
        selection.TypeParagraph;

        % --- Footer ---
        selection.ParagraphFormat.Alignment = 2; selection.Font.Bold = 1;
        selection.TypeText('Chief Engineer: WaRara-men');
        
        doc.SaveAs2(pdf_path, 17); doc.Close(0); word.Quit;
        system(['start "" "', pdf_path, '"']); beep;
    catch ME, if exist('word', 'var'), word.Quit; end; end
end
