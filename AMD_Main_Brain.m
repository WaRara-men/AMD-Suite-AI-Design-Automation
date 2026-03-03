% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v2.4
% Catalog Integration & Safety Optimization
% ==========================================

% --- 1. Input Design Parameters / 設計パラメータの入力 ---
target_load = 25;      % [kg] Target load / 耐荷重
case_width  = 150;     % [mm] Case width / 幅

% --- 2. Brain (AI Optimization) / 脳 (AI 最適化) ---
fprintf('🧠 [AI] Starting Optimization... / 最適化計算を開始します...\n');

obj_func = @(t) (case_width * 2) * t * 0.0027; 
lb = 1.0; ub = 10.0;
min_t_required = target_load * 0.08;

% Optimization with Fallback / 最適化エンジン
try
    if license('test', 'gads_toolbox') && ~isempty(which('ga'))
        options = optimoptions('ga', 'Display', 'none');
        [optimal_thickness, ~] = ga(obj_func, 1, -1, -min_t_required, [], [], lb, ub, [], options);
    else
        search_lb = max(lb, min_t_required);
        [optimal_thickness, ~] = fminbnd(obj_func, search_lb, ub);
    end
catch
    optimal_thickness = max(lb, min_t_required);
end

% --- 3. Catalog Selection (NEW!) / カタログ選定機能 ---
% Load standard parts database / 標準部品データベースを読み込み
catalog = readtable('Standard_Parts_Catalog.csv');

% Find the nearest "safe" thickness from catalog
% カタログから、計算値以上の厚みで最も近いものを探す
valid_idx = find(catalog.Thickness >= optimal_thickness, 1, 'first');
if isempty(valid_idx)
    valid_idx = height(catalog); % Use max if out of range
end

selected_t = catalog.Thickness(valid_idx);
selected_part_no = catalog.PartNumber{valid_idx};
selected_lead_time = catalog.LeadTime{valid_idx};

fprintf('🎯 [AI] Theoretical: %.2f mm -> Catalog: %.1f mm (%s)\n', ...
    optimal_thickness, selected_t, selected_part_no);

% --- 4. Generate Analysis Plot / 解析グラフの作成 ---
loads = 5:5:50;
thickness_trend = loads * 0.08;
fig = figure('Visible', 'off');
plot(loads, thickness_trend, 'b--', 'LineWidth', 1.5); hold on;
plot(target_load, optimal_thickness, 'rp', 'MarkerSize', 10);
plot(target_load, selected_t, 'gs', 'MarkerSize', 12, 'LineWidth', 2);
grid on; xlabel('Load [kg]'); ylabel('Thickness [mm]');
title('AI Optimization & Catalog Selection');
legend('Required Strength', 'Theoretical (AI)', 'Selected (Catalog)');
graph_path = fullfile(pwd, 'ai_analysis_plot.png');
saveas(fig, graph_path); close(fig);

% --- 5. Send Data to Nerve (Bridge_Nerve.csv) / 神経へ送信 ---
% We send the SELECTED thickness, because that's what we actually buy!
T_bridge = table(case_width, selected_t, 'VariableNames', {'Width', 'Thickness'});
writetable(T_bridge, 'Bridge_Nerve.csv');
fprintf('✅ [3D] Bridge_Nerve.csv updated with Catalog Value.\n');

% --- 6. Automatic Report Generation (Word) / レポートの自動生成 ---
try
    word = actxserver('Word.Application'); word.Visible = 0;
    doc = word.Documents.Add; selection = word.Selection;
    
    selection.Style = 'Heading 1'; 
    selection.TypeText('AMD Design Report with Catalog Selection'); 
    selection.TypeParagraph;
    
    selection.Style = 'Normal'; 
    selection.TypeText(['Date: ', datestr(now)]); selection.TypeParagraph;
    selection.TypeText(sprintf('Target Load: %d kg', target_load)); selection.TypeParagraph;
    selection.TypeText(sprintf('AI Theoretical Result: %.2f mm', optimal_thickness)); selection.TypeParagraph;
    selection.TypeParagraph;
    
    % Catalog Info / カタログ情報
    selection.Font.Bold = 1;
    selection.TypeText('--- SELECTED STANDARD PART / 選定された標準部品 ---');
    selection.TypeParagraph;
    selection.Font.Bold = 0;
    selection.TypeText(sprintf('Part Number: %s', selected_part_no)); selection.TypeParagraph;
    selection.TypeText(sprintf('Catalog Thickness: %.1f mm', selected_t)); selection.TypeParagraph;
    selection.TypeText(sprintf('Estimated Delivery: %s', selected_lead_time)); selection.TypeParagraph;
    selection.TypeParagraph;
    
    selection.Style = 'Heading 2'; 
    selection.TypeText('Optimization Graph'); selection.TypeParagraph;
    selection.InlineShapes.AddPicture(graph_path); selection.TypeParagraph;
    
    file_name = fullfile(pwd, 'AMD_Design_Report.docx');
    if exist(file_name, 'file'), delete(file_name); end
    doc.SaveAs2(file_name); doc.Close; word.Quit;
    fprintf('✅ [REPORT] AI Report (Bilingual) generated with Catalog info!\n');
catch ME
    fprintf('❌ [REPORT] Error: %s\n', ME.message);
    if exist('word', 'var'), word.Quit; end
end
