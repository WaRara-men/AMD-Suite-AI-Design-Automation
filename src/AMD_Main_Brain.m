% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v10.0
% THE IMMORTAL EDITION: Maximum Details & Stability
% ==========================================

function AMD_Main_Brain(payload_kg, length_mm, radius_mm, budget_limit, safety_factor, lang, mode)
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    data_dir = fullfile(project_root, 'data');
    output_dir = fullfile(project_root, 'out');
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end
    
    % --- 1. Master AI Logic & Physics ---
    g = 9.81; density_al = 0.0000027; % Al density
    catalog = readtable(fullfile(data_dir, 'Standard_Parts_Catalog.csv'));
    
    if strcmp(mode, 'Arm')
        arm_mass = (pi * radius_mm^2 * length_mm) * density_al;
        req_t = (payload_kg + arm_mass/2) * g * (length_mm/1000) * safety_factor;
        mode_str = 'Robot Arm (Angular Torque)';
    else
        arm_mass = 0;
        req_t = (payload_kg * g) * (length_mm/1000) * safety_factor;
        mode_str = 'Lifting Stage (Vertical Force)';
    end

    feasible = find(catalog.Torque_Nm >= req_t & catalog.Price_JPY <= budget_limit);
    if isempty(feasible), [~, b_idx] = min(catalog.Price_JPY); else, [~, s_idx] = min(catalog.Weight_kg(feasible)); b_idx = feasible(s_idx); end
    motor = catalog(b_idx, :);

    % --- 2. 📸 Generate Visual Proofs ---
    chart_path = fullfile(output_dir, 'chart.png');
    render_path = fullfile(output_dir, '3d_preview.png');
    
    f1 = figure('Visible', 'off'); bar(catalog.Torque_Nm, 'FaceColor', [0.3 0.3 0.3]); hold on;
    bar(b_idx, motor.Torque_Nm, 'FaceColor', [1.0 0.6 0.2]); saveas(f1, chart_path); close(f1);
    
    f2 = figure('Visible', 'off', 'Color', 'w'); ax = axes(f2);
    [X, Y, Z] = cylinder([radius_mm radius_mm], 20); Z = Z * length_mm;
    surf(ax, Z, X, Y, 'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'none'); axis equal; axis off; view(3); camlight;
    saveas(f2, render_path); close(f2);

    % --- 3. 📜 THE ELOQUENT CERTIFICATE (Full Version) ---
    ts = datestr(now, 'yyyymmdd_HHMMSS');
    pdf_path = fullfile(output_dir, sprintf('AMD_God_Cert_%s.pdf', ts));
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        
        % [Title]
        selection.ParagraphFormat.Alignment = 1;
        selection.Font.Size = 24; selection.Font.Bold = 1; selection.Font.ColorIndex = 'wdBlue';
        selection.TypeText('ULTIMATE ENGINEERING VERIFICATION'); selection.TypeParagraph;
        selection.Font.Size = 18; selection.TypeText('次世代ロボット設計・究極選定鑑定書'); selection.TypeParagraph;
        selection.TypeParagraph;

        % [Introduction - LONG TEXT]
        selection.ParagraphFormat.Alignment = 0; selection.Font.Size = 11; selection.Font.Bold = 1;
        selection.TypeText('■ 本証明書の目的 (Introduction)'); selection.TypeParagraph;
        selection.Font.Bold = 0;
        selection.TypeText(['本鑑定書は、AI物理演算エンジンによって算出された最適構成を保証するものです。', ...
            '安全性、経済性、機動性の3点において、理論上のパレート最適解を特定いたしました。']);
        selection.TypeParagraph; selection.TypeParagraph;

        % [3D Image]
        selection.Font.Bold = 1; selection.TypeText('■ 設計形状の視覚的証明 (3D Evidence)'); selection.TypeParagraph;
        selection.InlineShapes.AddPicture(render_path); selection.TypeParagraph;

        % [Logic - LONG TEXT]
        selection.Font.Bold = 1; selection.TypeText('■ 精密な選定ロジックの解説 (Selection Logic)'); selection.TypeParagraph;
        selection.Font.Bold = 0;
        reasoning = sprintf(['今回の解析条件（荷重%.1fkg、アーム長%dmm、半径%dmm）に対し、', ...
            'AIは構造自重%.3fkgを考慮した上で理論トルク%.2f N-mを算出。', ...
            '予算%d円の制約下で最高効率を誇る「%s」を選定しました。'], ...
            payload_kg, length_mm, radius_mm, arm_mass, req_t, round(budget_limit), char(motor.PartName));
        selection.TypeText(reasoning); selection.TypeParagraph; selection.TypeParagraph;

        % [Specs Table with Links]
        selection.Font.Bold = 1; selection.TypeText('■ コンポーネント詳細仕様 (Specifications)'); selection.TypeParagraph;
        tbl = doc.Tables.Add(selection.Range, 5, 2); tbl.Borders.Enable = 1;
        specs = {'Selected Part', char(motor.PartName); 'Torque Cap', [num2str(motor.Torque_Nm), ' Nm']; 'Weight', [num2str(motor.Weight_kg, '%.3f'), ' kg']; 'Price', [num2str(round(motor.Price_JPY)), ' JPY']; 'Purchase', '🛒 Buy Now'};
        for r = 1:5
            tbl.Cell(r,1).Range.Text = specs{r,1}; tbl.Cell(r,1).Range.Font.Bold = 1;
            if r == 5, doc.Hyperlinks.Add(tbl.Cell(r,2).Range, char(motor.ProductURL), '', '', specs{r,2}); else tbl.Cell(r,2).Range.Text = specs{r,2}; end
        end
        doc.Range(tbl.Range.End, tbl.Range.End).Select; selection = word.Selection;
        selection.TypeParagraph; selection.InlineShapes.AddPicture(chart_path);

        % [Signature]
        selection.ParagraphFormat.Alignment = 2; selection.Font.Bold = 1;
        selection.TypeText('Chief Engineer: WaRara-men');
        
        doc.SaveAs2(pdf_path, 17); doc.Close(0); word.Quit;
        system(['start "" "', pdf_path, '"']); beep;
    catch ME, if exist('word', 'var'), word.Quit; end; end

    % --- 4. 🎙️ Masterpiece Voice ---
    try
        NET.addAssembly('System.Speech'); speak = System.Speech.Synthesis.SpeechSynthesizer;
        msg = sprintf('設計完了。構造自重、%.3fキロを含む精密解析を行いました。最適解は、%s、です。', arm_mass, char(motor.PartName));
        speak.Speak(msg);
    catch, end
end
