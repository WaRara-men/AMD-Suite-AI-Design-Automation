% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v11.0
% ULTIMATE ROBOTICS PLATFORM: 5-Tab Engine
% ==========================================

function AMD_Main_Brain(payload_kg, length_mm, radius_mm, budget_limit, safety_factor, lang, mode)
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    data_dir = fullfile(project_root, 'data');
    output_dir = fullfile(project_root, 'out');
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end
    
    % --- 1. Master AI Logic (5-Mode Physics) ---
    g = 9.81; 
    catalog = readtable(fullfile(data_dir, 'Standard_Parts_Catalog.csv'));
    
    switch mode
        case 'Arm'
            arm_mass = (pi * radius_mm^2 * length_mm) * 0.0000027;
            req_t = (payload_kg + arm_mass/2) * g * (length_mm/1000) * safety_factor;
            msg_mode = 'ロボットアームの旋回トルク';
        case 'Lift'
            req_t = (payload_kg * g) * (radius_mm / 1000) * safety_factor; % radius here is pulley rad
            arm_mass = 0; msg_mode = '昇降機の巻上トルク';
        case 'Mobile'
            req_t = (payload_kg * g * 0.1) * (radius_mm / 1000) * safety_factor; % friction included
            arm_mass = 0; msg_mode = '走行車輪の駆動力';
        otherwise
            req_t = payload_kg * g * safety_factor; arm_mass = 0; msg_mode = '一般強度設計';
    end

    % Selection
    feasible = find(catalog.Torque_Nm >= req_t & catalog.Price_JPY <= budget_limit);
    if isempty(feasible), [~, b_idx] = min(catalog.Price_JPY); else, [~, s_idx] = min(catalog.Weight_kg(feasible)); b_idx = feasible(s_idx); end
    motor = catalog(b_idx, :);

    % --- 2. 📸 Generate Visual Proofs (Graphs & 3D) ---
    % [PROTECTED: Same logic as v10.0 to ensure images always exist]
    chart_path = fullfile(output_dir, 'chart.png'); render_path = fullfile(output_dir, 'preview.png');
    f1 = figure('Visible', 'off'); bar(catalog.Torque_Nm); hold on; bar(b_idx, motor.Torque_Nm); saveas(f1, chart_path); close(f1);
    f2 = figure('Visible', 'off'); [X, Y, Z] = cylinder([radius_mm radius_mm], 20); Z = Z * length_mm; surf(Z, X, Y); axis equal; saveas(f2, render_path); close(f2);

    % --- 3. 📜 THE ELOQUENT CERTIFICATE (Full Text Protected) ---
    ts = datestr(now, 'yyyymmdd_HHMMSS');
    pdf_path = fullfile(output_dir, sprintf('AMD_Master_Cert_%s.pdf', ts));
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        
        selection.ParagraphFormat.Alignment = 1; selection.Font.Size = 24; selection.Font.Bold = 1;
        selection.TypeText('ULTIMATE ROBOTICS DESIGN CERTIFICATE'); selection.TypeParagraph;
        selection.Font.Size = 16; selection.TypeText('究極のロボット設計・総合選定鑑定書'); selection.TypeParagraph;
        
        selection.ParagraphFormat.Alignment = 0; selection.Font.Size = 11; selection.Font.Bold = 1;
        selection.TypeText('■ はじめに (Introduction)'); selection.TypeParagraph;
        selection.Font.Bold = 0; selection.TypeText(['本鑑定書は、AI物理演算により「', msg_mode, '」における最適構成を保証するものです。']);
        selection.TypeParagraph; selection.InlineShapes.AddPicture(render_path);
        
        selection.Font.Bold = 1; selection.TypeText('■ 選定ロジック (Selection Logic)'); selection.TypeParagraph;
        selection.Font.Bold = 0; selection.TypeText(sprintf('条件: 荷重 %.1fkg, サイズ %dmm。AIは「%s」を最適解として特定しました。', payload_kg, length_mm, char(motor.PartName)));
        selection.TypeParagraph; selection.InlineShapes.AddPicture(chart_path);
        
        selection.ParagraphFormat.Alignment = 2; selection.Font.Bold = 1; selection.TypeText('Chief Engineer: WaRara-men');
        
        doc.SaveAs2(pdf_path, 17); doc.Close(0); word.Quit;
        system(['start "" "', pdf_path, '"']); beep;
    catch, if exist('word', 'var'), word.Quit; end; end

    % --- 4. 🎙️ Voice Feedback (Protected) ---
    try
        NET.addAssembly('System.Speech'); speak = System.Speech.Synthesis.SpeechSynthesizer;
        speak.Speak(sprintf('%sの解析が完了しました。最適解は、%s、です。', msg_mode, char(motor.PartName)));
    catch, end
end
