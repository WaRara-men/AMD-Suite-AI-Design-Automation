% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v2.2
% Bilingual Edition (English & Japanese)
% ==========================================

% --- 1. Input Design Parameters / 設計パラメータの入力 ---
% Define your design goals here / ここに設計目標を入力します
target_load = 25;      % [kg] Target load to withstand / 耐えたい重さ
case_width  = 150;     % [mm] Required width for components / 必要な幅

% --- 2. Brain (AI / Genetic Algorithm) / 脳 (AI / 遺伝的アルゴリズム) ---
% Goal: Minimize weight while clearing strength constraints
% 目標: 強度条件をクリアしつつ、重量を最小化する
fprintf('🧠 [AI] Starting Genetic Algorithm optimization... / 遺伝的アルゴリズムを開始します...\n');

% Objective Function: Minimize weight (Width * Thickness * Density)
% 目的関数: 重量を最小化したい (幅 × 厚み × 比重)
obj_func = @(t) (case_width * 2) * t * 0.0027; 

lb = 1.0;  % Minimum thickness [mm] / 厚みの下限
ub = 10.0; % Maximum thickness [mm] / 厚みの上限

% Constraint: Thickness must be >= (load * 0.08)
% 制約条件: 厚みは (荷重 * 0.08) 以上でなければならない
A = -1; 
b = -(target_load * 0.08); 

% Execute Genetic Algorithm (GA) / 遺伝的アルゴリズムを実行
options = optimoptions('ga', 'Display', 'none');
[optimal_thickness, min_weight] = ga(obj_func, 1, A, b, [], [], lb, ub, [], options);

fprintf('🎯 [AI] Optimal solution found! / 最適解を発見しました！\n');
fprintf('   - Thickness / 厚み: %.2f mm\n', optimal_thickness);
fprintf('   - Est. Weight / 推定重量: %.3f kg\n', min_weight);

% --- 3. Generate Analysis Plot / 解析グラフの作成 ---
% Visualize how AI found the design point / AIの思考を可視化します
loads = 5:5:50;
thickness_trend = loads * 0.08;
fig = figure('Visible', 'off');
plot(loads, thickness_trend, 'b--', 'LineWidth', 1.5); hold on;
plot(target_load, optimal_thickness, 'rp', 'MarkerSize', 15, 'MarkerFaceColor', 'r');
grid on; xlabel('Load [kg]'); ylabel('Required Thickness [mm]');
title('AI Optimization: Load vs. Thickness / AI最適化結果');
legend('Required Strength / 必要強度', 'AI Optimized Point / AI最適化点');
graph_path = fullfile(pwd, 'ai_analysis_plot.png');
saveas(fig, graph_path); close(fig);

% --- 4. Send Data to Nerve (Bridge_Nerve.csv) / 神経 (Bridge_Nerve.csv) へ送信 ---
% This CSV links MATLAB and SolidWorks / このCSVがMATLABとSolidWorksを繋ぎます
T_bridge = table(case_width, optimal_thickness, 'VariableNames', {'Width', 'Thickness'});
writetable(T_bridge, 'Bridge_Nerve.csv');
fprintf('✅ [3D] Bridge_Nerve.csv updated. / 神経ファイルを更新しました。\n');

% --- 5. Automatic Report Generation (Word) / レポートの自動生成 ---
try
    word = actxserver('Word.Application'); word.Visible = 0;
    doc = word.Documents.Add; selection = word.Selection;
    
    % Report Title / タイトル
    selection.Style = 'Heading 1'; 
    selection.TypeText('AMD AI Design Report / 次世代AI自動設計報告書'); 
    selection.TypeParagraph;
    
    % Design Details / 設計詳細
    selection.Style = 'Normal'; 
    selection.TypeText(['Date / 日時: ', datestr(now)]); selection.TypeParagraph;
    selection.TypeText(sprintf('Target Load / 目標耐荷重: %d kg', target_load)); selection.TypeParagraph;
    selection.TypeText(sprintf('AI Optimized Thickness / AI最適厚み: %.2f mm', optimal_thickness)); selection.TypeParagraph;
    selection.TypeText(sprintf('Minimized Weight / 最小化重量: %.3f kg', min_weight)); selection.TypeParagraph;
    
    % Optimization Plot / 最適化グラフ
    selection.Style = 'Heading 2'; 
    selection.TypeText('Optimization Graph / 最適化グラフ'); 
    selection.TypeParagraph;
    selection.InlineShapes.AddPicture(graph_path); selection.TypeParagraph;
    selection.TypeText('Figure 1: Result of AI optimization / AIによる最適化結果'); selection.TypeParagraph;
    
    % Save and Close / 保存と終了
    file_name = fullfile(pwd, 'AMD_Design_Report.docx');
    if exist(file_name, 'file'), delete(file_name); end
    doc.SaveAs2(file_name); doc.Close; word.Quit;
    fprintf('✅ [REPORT] AI Report generated! / AIレポートを生成しました！\n');
    fprintf('   -> %s\n', file_name);
catch ME
    fprintf('❌ [REPORT] Error occurred / エラーが発生しました: %s\n', ME.message);
    if exist('word', 'var'), word.Quit; end
end
