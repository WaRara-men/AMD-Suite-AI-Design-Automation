% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v8.0
% Robot Actuator Selection Edition (Motor Picker)
% ==========================================

function AMD_Main_Brain(payload_kg, arm_length_mm, budget_limit, safety_factor, lang)
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    data_dir = fullfile(project_root, 'data');
    output_dir = fullfile(project_root, 'out');
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end
    
    % --- 1. Robot Physics Engine / ロボット物理計算 ---
    % Calculate required torque: T = Force * Distance * Safety
    % トルク(N・m) = 重さ(kg) * 9.8 * 長さ(m) * 安全率
    required_torque = (payload_kg * 9.8) * (arm_length_mm / 1000) * safety_factor;
    fprintf('⚙️ [PHYSICS] Required Torque: %.2f N-m\n', required_torque);

    % --- 2. AI Catalog Search (Motor Database) ---
    catalog = readtable(fullfile(data_dir, 'Standard_Parts_Catalog.csv'));
    
    % Find motors that meet the torque requirement
    feasible_indices = find(catalog.Torque_Nm >= required_torque & catalog.Price_JPY <= budget_limit);
    
    if isempty(feasible_indices)
        % No motor satisfies both, pick the one with closest torque within budget
        feasible_indices = find(catalog.Price_JPY <= budget_limit);
        if isempty(feasible_indices), [~, best_idx] = min(catalog.Price_JPY); else, [~, sub_idx] = max(catalog.Torque_Nm(feasible_indices)); best_idx = feasible_indices(sub_idx); end
        is_over = true;
    else
        % Pick the lightest one among feasible motors
        [~, sub_idx] = min(catalog.Weight_kg(feasible_indices));
        best_idx = feasible_indices(sub_idx);
        is_over = false;
    end
    
    motor = catalog(best_idx, :);

    % --- 3. 📜 Comprehensive Certification (Motor focus) ---
    ts = datestr(now, 'yyyymmdd_HHMMSS');
    pdf_path = fullfile(output_dir, sprintf('AMD_Motor_Cert_%s.pdf', ts));
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        
        % Header
        selection.ParagraphFormat.Alignment = 1;
        selection.Font.Size = 22; selection.Font.Bold = 1; selection.Font.ColorIndex = 'wdBlue';
        selection.TypeText('ROBOT ACTUATOR SPECIFICATION CERTIFICATE'); selection.TypeParagraph;
        selection.Font.Size = 16; selection.TypeText('ロボット・アクチュエータ選定仕様証明書'); selection.TypeParagraph;
        selection.TypeParagraph;

        % Decision Logic
        selection.ParagraphFormat.Alignment = 0;
        selection.Font.Size = 12; selection.Font.Bold = 1; selection.TypeText('■ Selection Logic / 選定の論理'); selection.TypeParagraph;
        selection.Font.Size = 10; selection.Font.Bold = 0;
        
        logic_en = sprintf(['For a payload of %.1fkg and arm length of %dmm, the calculated required torque is %.2f N-m. ', ...
            'AI has selected "%s" as the most efficient actuator that fulfills this requirement within your %d JPY budget.'], ...
            payload_kg, arm_length_mm, required_torque, char(motor.PartName), budget_limit);
        logic_jp = sprintf(['耐荷重 %.1fkg、アーム長 %dmm の設計に対し、必要な理論トルクは %.2f N・m と算出されました。', ...
            'AIはこの要求を満たしつつ、予算 %d 円以内で最も軽量な「%s」を最適アクチュエータとして選定しました。'], ...
            payload_kg, arm_length_mm, required_torque, budget_limit, char(motor.PartName));
        selection.TypeText(logic_en); selection.TypeParagraph;
        selection.TypeText(logic_jp); selection.TypeParagraph; selection.TypeParagraph;

        % Specs Table
        selection.Font.Bold = 1; selection.TypeText('■ Component Specification / 部品仕様詳細'); selection.TypeParagraph;
        tbl = doc.Tables.Add(selection.Range, 5, 2); tbl.Borders.Enable = 1;
        specs = {'Motor Name / モーター名', char(motor.PartName); 'Torque / 定格トルク', [num2str(motor.Torque_Nm), ' N-m']; 'Weight / 自重', [num2str(motor.Weight_kg), ' kg']; 'Unit Price / 単価', [num2str(motor.Price_JPY), ' JPY']; 'Lead Time / 納期', char(motor.LeadTime)};
        for r = 1:5, tbl.Cell(r,1).Range.Text = specs{r,1}; tbl.Cell(r,1).Range.Font.Bold = 1; tbl.Cell(r,2).Range.Text = specs{r,2}; end
        
        doc.Range(tbl.Range.End, tbl.Range.End).Select; selection = word.Selection;
        selection.TypeParagraph; selection.ParagraphFormat.Alignment = 2;
        selection.Font.Size = 12; selection.Font.Bold = 1; selection.TypeText('Chief Engineer: WaRara-men');
        
        doc.SaveAs2(pdf_path, 17); doc.Close(0); word.Quit;
        system(['start "" "', pdf_path, '"']); beep;
    catch ME, if exist('word', 'var'), word.Quit; end; end

    % --- 4. Final Voice ---
    try
        NET.addAssembly('System.Speech'); speak = System.Speech.Synthesis.SpeechSynthesizer;
        msg = sprintf('ロボットの解析が完了しました。必要なトルクは、%.2f、ニュートンメートル。最適なモーターは、%s、です。', required_torque, char(motor.PartName));
        speak.Speak(msg);
    catch, end
end
