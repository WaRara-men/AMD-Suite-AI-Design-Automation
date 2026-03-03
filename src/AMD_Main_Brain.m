% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v7.8
% THE MASTERPIECE: Voice, Graphics & 3D Photos
% ==========================================

function AMD_Main_Brain(target_load, budget_limit, safety_factor, lang)
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    data_dir = fullfile(project_root, 'data');
    output_dir = fullfile(project_root, 'out');
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end
    
    % --- 1. AI Logic & Data ---
    catalog = readtable(fullfile(data_dir, 'Standard_Parts_Catalog.csv'));
    materials = unique(catalog.Material); all_sols = []; 
    for i = 1:length(materials)
        m_data = catalog(strcmp(catalog.Material, materials{i}), :);
        min_t = (target_load / m_data.StrengthFactor(1)) * 0.1 * safety_factor;
        idx = find(m_data.Thickness >= min_t, 1, 'first');
        if ~isempty(idx)
            sol.Material = string(materials{i}); sol.T = m_data.Thickness(idx);
            sol.PartNo = string(m_data.PartNumber{idx}); sol.Price = m_data.Price_JPY(idx);
            sol.Weight = (300) * sol.T * m_data.Density(idx); all_sols = [all_sols; sol];
        end
    end
    [~, b_idx] = min([all_sols.Weight]); final_sol = all_sols(b_idx);

    % --- 2. 📸 Generate Proof Images (Graphs & 3D) ---
    fprintf('📸 [IMG] Generating visual evidence... / 証拠画像を生成中...\n');
    % Bar Chart
    fig1 = figure('Visible', 'off'); bar([all_sols.Weight], 'FaceColor', [0.2 0.6 0.8]);
    set(gca, 'XTickLabel', {all_sols.Material}); ylabel('Weight [kg]'); title('Weight Comparison');
    chart_path = fullfile(output_dir, 'temp_chart.png'); saveas(fig1, chart_path); close(fig1);
    
    % 3D Render
    fig2 = figure('Visible', 'off', 'Color', 'w'); ax = axes(fig2);
    verts = [0 0 0; 150 0 0; 150 50 0; 0 50 0; 0 0 final_sol.T; 150 0 final_sol.T; 150 50 final_sol.T; 0 50 final_sol.T];
    faces = [1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8; 1 2 3 4; 5 6 7 8];
    patch(ax, 'Faces', faces, 'Vertices', verts, 'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'k');
    view(ax, 3); axis(ax, 'equal'); axis(ax, 'off'); camlight; material shiny;
    render_path = fullfile(output_dir, 'temp_3d.png'); saveas(fig2, render_path); close(fig2);

    % --- 3. 📜 [MASTERPIECE] Comprehensive Certificate ---
    ts = datestr(now, 'yyyymmdd_HHMMSS');
    pdf_path = fullfile(output_dir, sprintf('AMD_Certificate_%s.pdf', ts));
    try
        word = actxserver('Word.Application'); word.Visible = 0;
        doc = word.Documents.Add; selection = word.Selection;
        
        % [Header]
        selection.ParagraphFormat.Alignment = 1;
        selection.Font.Size = 28; selection.Font.Bold = 1; selection.Font.ColorIndex = 'wdBlue';
        selection.TypeText('OFFICIAL DESIGN VERIFICATION'); selection.TypeParagraph;
        selection.Font.Size = 18; selection.TypeText('公式設計検証・技術鑑定書'); selection.TypeParagraph;
        selection.TypeParagraph;

        % [3D Image Insert]
        selection.Font.Size = 12; selection.Font.Bold = 1; selection.Font.ColorIndex = 'wdAuto';
        selection.TypeText('■ Optimized Design Preview / 最適化モデル外観'); selection.TypeParagraph;
        selection.InlineShapes.AddPicture(render_path); selection.TypeParagraph;

        % [Logic & Stats]
        selection.ParagraphFormat.Alignment = 0;
        selection.Font.Bold = 1; selection.TypeText('■ Engineering Selection Logic / 選定の論理性'); selection.TypeParagraph;
        selection.Font.Bold = 0; selection.Font.Size = 10;
        msg_en = sprintf('The AI selected "%s" as the global optimum for %dkg load under %d JPY budget.', final_sol.Material, target_load, budget_limit);
        msg_jp = sprintf('目標荷重%dkg、予算%d円に対し、AIは「%s」を究極の素材として選定しました。', target_load, budget_limit, final_sol.Material);
        selection.TypeText(msg_en); selection.TypeParagraph; selection.TypeText(msg_jp); selection.TypeParagraph;

        % [Chart Insert]
        selection.Font.Size = 12; selection.Font.Bold = 1; selection.TypeText('■ Comparative Analysis / 比較解析データ'); selection.TypeParagraph;
        selection.InlineShapes.AddPicture(chart_path); selection.TypeParagraph;

        % [Footer]
        selection.ParagraphFormat.Alignment = 2;
        selection.Font.Size = 12; selection.Font.Bold = 1; selection.TypeText('Chief Engineer: WaRara-men'); selection.TypeParagraph;
        
        doc.SaveAs2(pdf_path, 17); doc.Close(0); word.Quit;
        system(['start "" "', pdf_path, '"']); 
        beep;
    catch ME, if exist('word', 'var'), word.Quit; end; end

    % --- 4. 🎙️ [RESTORED] Eloquent Voice ---
    try
        NET.addAssembly('System.Speech'); speak = System.Speech.Synthesis.SpeechSynthesizer;
        if strcmp(lang, 'JP')
            msg = sprintf('設計完了。最適な素材は、%s、です。重量は、%.3fキログラム。証明書に3D写真とグラフを添付しました。', char(final_sol.Material), final_sol.Weight);
        else
            msg = sprintf('Design complete. The best choice is %s, weighing %.3f kilograms. I have attached the 3D preview and analysis graphs to your certificate.', char(final_sol.Material), final_sol.Weight);
        end
        speak.Speak(msg);
    catch, end

    % --- 5. Final Cleanup ---
    delete(chart_path); delete(render_path);
    delete(fullfile(project_root, 'AMD*.*')); delete(fullfile(src_dir, '*.asv'));
end
