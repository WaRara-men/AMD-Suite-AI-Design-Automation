% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v9.0
% Multi-Mode Engineering Engine: Precision Physics
% ==========================================

function AMD_Main_Brain(payload_kg, length_mm, radius_mm, budget_limit, safety_factor, lang, mode)
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    data_dir = fullfile(project_root, 'data');
    output_dir = fullfile(project_root, 'out');
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end
    
    % --- 1. Advanced Physics Engine / 精密物理演算 ---
    g = 9.81; % Gravity
    density_al = 0.0000027; % kg/mm^3 (Aluminum)
    
    if strcmp(mode, 'Arm')
        % 💡 Mode: Robotic Arm (Considers Arm Weight)
        arm_volume = pi * radius_mm^2 * length_mm;
        arm_mass = arm_volume * density_al;
        % Torque at base = (Payload + ArmMass/2) * g * Length
        required_torque = (payload_kg + arm_mass/2) * g * (length_mm / 1000) * safety_factor;
        description = sprintf('Arm Mode: Weight of arm (%.2fkg) was included.', arm_mass);
    else
        % 💡 Mode: Lifting Stage (Vertical Force)
        required_torque = (payload_kg * g) * (length_mm / 1000) * safety_factor;
        arm_mass = 0;
        description = 'Lifting Mode: Pure vertical payload lift.';
    end

    % --- 2. AI Catalog Search ---
    catalog = readtable(fullfile(data_dir, 'Standard_Parts_Catalog.csv'));
    feasible_idx = find(catalog.Torque_Nm >= required_torque & catalog.Price_JPY <= budget_limit);
    if isempty(feasible_idx)
        [~, best_idx] = min(catalog.Price_JPY); sorted_idx = best_idx;
    else
        [~, s_idx] = sort(catalog.Weight_kg(feasible_idx));
        sorted_idx = feasible_idx(s_idx); best_idx = sorted_idx(1);
    end
    motor = catalog(best_idx, :);

    % --- 3. 📜 Masterpiece Certification (v9.0 Content) ---
    ts = datestr(now, 'yyyymmdd_HHMMSS');
    pdf_path = fullfile(output_dir, sprintf('AMD_Design_Cert_%s.pdf', ts));
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        
        selection.ParagraphFormat.Alignment = 1;
        selection.Font.Size = 22; selection.Font.Bold = 1; selection.Font.ColorIndex = 'wdBlue';
        selection.TypeText('ADVANCED MULTI-MODE DESIGN CERTIFICATE'); selection.TypeParagraph;
        selection.Font.Size = 16; selection.TypeText('多目的ロボット設計・精密選定証明書'); selection.TypeParagraph;
        
        selection.ParagraphFormat.Alignment = 0; selection.Font.Size = 10; selection.Font.Bold = 0; selection.Font.ColorIndex = 'wdAuto';
        selection.TypeParagraph;
        selection.Font.Bold = 1; selection.TypeText('■ Engineering Analysis Logic / 設計の論理的根拠'); selection.TypeParagraph;
        selection.Font.Bold = 0;
        
        analysis_txt = sprintf(['Target: %s mode. Load: %.1fkg, Length: %dmm, Radius: %dmm.\n', ...
            'Calculated Structural Mass: %.3f kg. Total Required Torque: %.2f N-m.\n', ...
            'The AI selected "%s" as the optimal actuator from market data.'], ...
            mode, payload_kg, length_mm, radius_mm, arm_mass, required_torque, char(motor.PartName));
        selection.TypeText(analysis_txt); selection.TypeParagraph;

        % Specs Table with URL
        selection.TypeParagraph; selection.Font.Bold = 1; selection.TypeText('■ Component Specifications / 部品詳細'); selection.TypeParagraph;
        tbl = doc.Tables.Add(selection.Range, 5, 2); tbl.Borders.Enable = 1;
        specs = {'Product Name', char(motor.PartName); 'Torque Rating', [num2str(motor.Torque_Nm), ' N-m']; 'System Weight', [num2str(motor.Weight_kg + arm_mass, '%.3f'), ' kg']; 'Price', [num2str(round(motor.Price_JPY)), ' JPY']; 'Buy Link', '🖱️ Click to Open'};
        for r = 1:5
            tbl.Cell(r,1).Range.Text = specs{r,1}; tbl.Cell(r,1).Range.Font.Bold = 1;
            if r == 5, doc.Hyperlinks.Add(tbl.Cell(r,2).Range, char(motor.ProductURL), '', '', specs{r,2}); else tbl.Cell(r,2).Range.Text = specs{r,2}; end
        end
        
        doc.Range(tbl.Range.End, tbl.Range.End).Select; selection = word.Selection;
        selection.TypeParagraph; selection.ParagraphFormat.Alignment = 2;
        selection.Font.Bold = 1; selection.TypeText('Chief Engineer: WaRara-men');
        
        doc.SaveAs2(pdf_path, 17); doc.Close(0); word.Quit;
        system(['start "" "', pdf_path, '"']); beep;
    catch, if exist('word', 'var'), word.Quit; end; end

    % --- 4. Voice ---
    try
        NET.addAssembly('System.Speech'); speak = System.Speech.Synthesis.SpeechSynthesizer;
        msg = sprintf('設計完了。構造重量、%.3fキログラムを含め計算しました。最適なモーターは%sです。', arm_mass, char(motor.PartName));
        speak.Speak(msg);
    catch, end
end
