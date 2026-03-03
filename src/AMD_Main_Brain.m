% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v8.2
% E-Commerce Link Edition: Clickable PDF
% ==========================================

function AMD_Main_Brain(payload_kg, arm_length_mm, budget_limit, safety_factor, lang)
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    data_dir = fullfile(project_root, 'data');
    output_dir = fullfile(project_root, 'out');
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end
    
    % --- 1. AI Logic & Data Retrieval (Including URL) ---
    required_torque = (payload_kg * 9.8) * (arm_length_mm / 1000) * safety_factor;
    catalog = readtable(fullfile(data_dir, 'Standard_Parts_Catalog.csv'));
    feasible = find(catalog.Torque_Nm >= required_torque & catalog.Price_JPY <= budget_limit);
    if isempty(feasible), [~, b_idx] = min(catalog.Price_JPY); else, [~, sub_idx] = min(catalog.Weight_kg(feasible)); b_idx = feasible(sub_idx); end
    motor = catalog(b_idx, :);

    % --- 2. 📸 Generate Proof Images ---
    chart_path = fullfile(output_dir, 'temp_chart.png');
    render_path = fullfile(output_dir, 'temp_3d.png');
    f1 = figure('Visible', 'off'); bar(catalog.Torque_Nm, 'FaceColor', [0.3 0.3 0.3]); hold on;
    bar(b_idx, motor.Torque_Nm, 'FaceColor', [1.0 0.6 0.2]); saveas(f1, chart_path); close(f1);
    f2 = figure('Visible', 'off', 'Color', 'w'); [X, Y, Z] = cylinder([2 2], 20); Z = Z * arm_length_mm;
    surf(Z, X, Y, 'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'none'); axis equal; axis off; view(3); camlight;
    saveas(f2, render_path); close(f2);

    % --- 3. 📜 [HYPERLINK] Clickable Certificate ---
    ts = datestr(now, 'yyyymmdd_HHMMSS');
    pdf_path = fullfile(output_dir, sprintf('AMD_Motor_Cert_%s.pdf', ts));
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        
        % Header
        selection.ParagraphFormat.Alignment = 1;
        selection.Font.Size = 22; selection.Font.Bold = 1; selection.Font.ColorIndex = 'wdBlue';
        selection.TypeText('ROBOT ACTUATOR SPECIFICATION CERTIFICATE'); selection.TypeParagraph;
        selection.TypeParagraph;

        % Specs Table with HYPERLINK
        selection.ParagraphFormat.Alignment = 0;
        selection.Font.Size = 12; selection.Font.Bold = 1; selection.Font.ColorIndex = 'wdAuto';
        selection.TypeText('■ Component Specification / 選定部品の購入リンク'); selection.TypeParagraph;
        
        tbl = doc.Tables.Add(selection.Range, 5, 2); tbl.Borders.Enable = 1;
        specs = {'Motor Name / モーター名', char(motor.PartName); 'Torque / 定格トルク', [num2str(motor.Torque_Nm), ' N-m']; 'Weight / 自重', [num2str(motor.Weight_kg), ' kg']; 'Unit Price / 単価', [num2str(motor.Price_JPY), ' JPY']; 'Product Page / 商品ページ', '🖱️ Click here to Open / クリックして開く'};
        
        for r = 1:5
            tbl.Cell(r,1).Range.Text = specs{r,1}; tbl.Cell(r,1).Range.Font.Bold = 1;
            if r == 5
                % 🌟 MAGIC: Add Hyperlink to the cell!
                doc.Hyperlinks.Add(tbl.Cell(r,2).Range, char(motor.ProductURL), '', '', specs{r,2});
            else
                tbl.Cell(r,2).Range.Text = specs{r,2};
            end
        end
        
        doc.Range(tbl.Range.End, tbl.Range.End).Select; selection = word.Selection;
        selection.TypeParagraph; selection.InlineShapes.AddPicture(render_path);
        
        doc.SaveAs2(pdf_path, 17); doc.Close(0); word.Quit;
        system(['start "" "', pdf_path, '"']); beep;
    catch ME, if exist('word', 'var'), word.Quit; end; end

    % --- 4. Final Voice ---
    try
        NET.addAssembly('System.Speech'); speak = System.Speech.Synthesis.SpeechSynthesizer;
        msg = sprintf('解析完了。証明書の中のリンクから、%s、の購入ページへ直接アクセスできます。', char(motor.PartName));
        speak.Speak(msg);
    catch, end
    delete(chart_path); delete(render_path);
end
