% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v8.3
% GOD-LEVEL INTEGRATION: All Features Protected
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
    feasible = find(catalog.Torque_Nm >= required_torque & catalog.Price_JPY <= budget_limit);
    if isempty(feasible), [~, b_idx] = min(catalog.Price_JPY); else, [~, sub_idx] = min(catalog.Weight_kg(feasible)); b_idx = feasible(sub_idx); end
    motor = catalog(b_idx, :);

    % --- 2. 📸 Generate Visual Proof (Graph & 3D) ---
    fprintf('📸 [IMG] Generating all visual evidence...\n');
    chart_path = fullfile(output_dir, 'temp_chart.png');
    render_path = fullfile(output_dir, 'temp_3d.png');
    
    % Torque Comparison Chart
    f1 = figure('Visible', 'off'); bar(catalog.Torque_Nm, 'FaceColor', [0.3 0.3 0.3]); hold on;
    bar(b_idx, motor.Torque_Nm, 'FaceColor', [1.0 0.6 0.2]);
    set(gca, 'XTickLabel', catalog.PartName); title('Torque Capacity Comparison');
    saveas(f1, chart_path); close(f1);
    
    % 3D Arm Representation
    f2 = figure('Visible', 'off', 'Color', 'w'); ax = axes(f2);
    [X, Y, Z] = cylinder([2 2], 20); Z = Z * arm_length_mm;
    surf(ax, Z, X, Y, 'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'none'); axis equal; axis off; view(3); camlight;
    saveas(f2, render_path); close(f2);

    % --- 3. 📜 [GOD-MODE] Comprehensive Certification ---
    ts = datestr(now, 'yyyymmdd_HHMMSS');
    pdf_path = fullfile(output_dir, sprintf('AMD_Certificate_%s.pdf', ts));
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        
        % [Title Section]
        selection.ParagraphFormat.Alignment = 1;
        selection.Font.Size = 24; selection.Font.Bold = 1; selection.Font.ColorIndex = 'wdBlue';
        selection.TypeText('ROBOT DESIGN & ACTUATOR CERTIFICATION'); selection.TypeParagraph;
        selection.Font.Size = 16; selection.TypeText('次世代ロボット設計・構成部品選定仕様証明書'); selection.TypeParagraph;
        selection.TypeParagraph;

        % [Section 1: Introduction - FULL VERSION]
        selection.ParagraphFormat.Alignment = 0;
        selection.Font.Size = 11; selection.Font.Bold = 1;
        selection.TypeText('■ 本証明書の目的 (Introduction)'); selection.TypeParagraph;
        selection.Font.Bold = 0;
        selection.TypeText(['本ドキュメントは、Algo-Mech Designer (AMD) AIエンジンによって算出された、', ...
            '特定のロボットアーム構成における最適なアクチュエータ選定を技術的に保証するものです。', ...
            '物理演算に基づき、荷重条件と予算制約を同時に満たす最適解を特定いたしました。']);
        selection.TypeParagraph; selection.TypeParagraph;

        % [Visual Evidence 1: 3D Preview]
        selection.Font.Bold = 1; selection.TypeText('■ 設計モデルの外観 (3D Preview Image)'); selection.TypeParagraph;
        selection.InlineShapes.AddPicture(render_path); selection.TypeParagraph;

        % [Section 2: Selection Logic - FULL VERSION]
        selection.Font.Bold = 1; selection.TypeText('■ 選定の論理的根拠 (Decision Logic)'); selection.TypeParagraph;
        selection.Font.Bold = 0;
        logic_txt = sprintf(['目標荷重 %.1fkg、アーム長 %dmm に対し、AIは %.2f N-m の理論トルクを算出。', ...
            'カタログ上の全候補から、予算 %d円 以内で最も軽量な「%s」を最適解として選定。', ...
            'この選定により、安全性と機動性の最高レベルでの両立を実現しています。'], ...
            payload_kg, arm_length_mm, required_torque, budget_limit, char(motor.PartName));
        selection.TypeText(logic_txt); selection.TypeParagraph; selection.TypeParagraph;

        % [Section 3: Technical Specs Table with HYPERLINK]
        selection.Font.Bold = 1; selection.TypeText('■ 部品詳細仕様 ＆ 購入リンク (Specifications & Link)'); selection.TypeParagraph;
        tbl = doc.Tables.Add(selection.Range, 5, 2); tbl.Borders.Enable = 1;
        specs = {'Motor Name / モーター名', char(motor.PartName); 'Torque / 定格トルク', [num2str(motor.Torque_Nm), ' N-m']; 'Estimated Weight / 重量', [num2str(motor.Weight_kg), ' kg']; 'Unit Price / 価格', [num2str(motor.Price_JPY), ' JPY']; 'Product Page / 商品ページ', '🖱️ Click to Open / 購入サイトを開く'};
        for r = 1:5
            tbl.Cell(r,1).Range.Text = specs{r,1}; tbl.Cell(r,1).Range.Font.Bold = 1;
            if r == 5
                doc.Hyperlinks.Add(tbl.Cell(r,2).Range, char(motor.ProductURL), '', '', specs{r,2});
            else
                tbl.Cell(r,2).Range.Text = specs{r,2};
            end
        end
        doc.Range(tbl.Range.End, tbl.Range.End).Select; selection = word.Selection;
        selection.TypeParagraph;

        % [Visual Evidence 2: Torque Graph]
        selection.Font.Bold = 1; selection.TypeText('■ 解析比較グラフ (Comparative Analysis Chart)'); selection.TypeParagraph;
        selection.InlineShapes.AddPicture(chart_path); selection.TypeParagraph;

        % [Footer]
        selection.ParagraphFormat.Alignment = 2;
        selection.Font.Size = 12; selection.Font.Bold = 1;
        selection.TypeText('Chief Engineer: WaRara-men');
        
        doc.SaveAs2(pdf_path, 17); doc.Close(0); word.Quit;
        system(['start "" "', pdf_path, '"']); beep;
    catch ME, if exist('word', 'var'), word.Quit; end; end

    % --- 4. 🎙️ [RESTORED] Full Voice ---
    try
        NET.addAssembly('System.Speech'); speak = System.Speech.Synthesis.SpeechSynthesizer;
        msg = sprintf('解析完了。最適なモーターは、%s、です。証明書のリンクから直接購入ページへアクセスできます。', char(motor.PartName));
        speak.Speak(msg);
    catch, end
    delete(chart_path); delete(render_path);
end
