% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v2.7
% Full Automation: Safety Factor & SW Capture
% ==========================================

% --- 0. Path Setup / パス設定 ---
addpath('../data');
output_dir = '../out';
if ~exist(output_dir, 'dir'), mkdir(output_dir); end

% --- 1. Design Requirements / 設計要件 ---
target_x = 200; 
target_y = 150; 
safety_factor = 1.5; % [NEW] Safety Factor / 安全率 (1.5倍の余裕)
required_reach = sqrt(target_x^2 + target_y^2);

% --- 2. Brain (AI Optimization) / 脳 (AI 最適化) ---
fprintf('🧠 [AI] Starting Safety-Aware Optimization... / 安全率を考慮した最適化を開始...\n');

% obj_func = Minimize Weight
obj_func = @(x) (x(1)*x(3) + x(2)*x(4)) * 0.0027; 

lb = [50, 50, 1.0, 1.0];   
ub = [400, 400, 10.0, 10.0]; 

% Constraints / 制約
% 1. Reach: L1 + L2 >= reach
% 2. Safety: Thickness must be >= (load * 0.08 * safety_factor)
% For this demo, we use a simple linear constraint
A = [-1, -1, 0, 0];
b = -required_reach;

try
    options = optimoptions('ga', 'Display', 'none');
    [x_opt, ~] = ga(obj_func, 4, A, b, [], [], lb, ub, [], options);
catch
    x_opt = [required_reach/2, required_reach/2, 3.0, 2.0];
end

% Apply Safety Factor to thickness results
x_opt(3:4) = x_opt(3:4) * safety_factor;

% --- 3. Catalog Selection / カタログ選定 ---
catalog = readtable('Standard_Parts_Catalog.csv');
idx1 = find(catalog.Thickness >= x_opt(3), 1, 'first');
if isempty(idx1), idx1 = height(catalog); end
selected_t1 = catalog.Thickness(idx1); part_no1 = catalog.PartNumber{idx1};

idx2 = find(catalog.Thickness >= x_opt(4), 1, 'first');
if isempty(idx2), idx2 = height(catalog); end
selected_t2 = catalog.Thickness(idx2); part_no2 = catalog.PartNumber{idx2};

% --- 4. SolidWorks Auto-Capture (NEW!) / SW自動撮影 ---
sw_image_path = fullfile(pwd, output_dir, 'sw_capture.png');
fprintf('📸 [SW] Attempting to capture SolidWorks model... / モデルを撮影中...\n');
try
    swApp = actxGetRunningServer('SldWorks.Application');
    swModel = swApp.ActiveDoc;
    if ~isempty(swModel)
        % Save current view as image
        swModel.SaveAs2(sw_image_path, 0, true, false);
        fprintf('   -> ✅ Capture Success! / 撮影成功！\n');
    else
        fprintf('   -> ⚠️ No active document in SolidWorks. / モデルが開かれていません。\n');
    end
catch
    fprintf('   -> ⚠️ SolidWorks not running. / SolidWorksが起動していません。\n');
end

% --- 5. Save Results / 結果の保存 ---
T_bridge = table(x_opt(1), x_opt(2), selected_t1, selected_t2, ...
    'VariableNames', {'L1', 'L2', 'T1', 'T2'});
writetable(T_bridge, fullfile(output_dir, 'Bridge_Nerve.csv'));

% --- 6. Universal Reporting / レポート生成 ---
try
    word = actxserver('Word.Application'); word.Visible = 0;
    doc = word.Documents.Add; selection = word.Selection;
    
    % Title
    selection.Font.Size = 24; selection.Font.Bold = 1;
    selection.TypeText('AMD Pro Design Report (Safety-Aware)'); selection.TypeParagraph;
    selection.TypeParagraph;
    
    % Safety Info
    selection.Font.Size = 12; selection.Font.Bold = 1;
    selection.TypeText(sprintf('🛡️ Safety Factor Applied / 適用された安全率: %.1f', safety_factor));
    selection.TypeParagraph; selection.TypeParagraph;
    
    % Data Table
    selection.Font.Bold = 0;
    selection.TypeText(sprintf('Link 1: L=%.1f, T=%.1f (%s)', x_opt(1), selected_t1, part_no1)); selection.TypeParagraph;
    selection.TypeText(sprintf('Link 2: L=%.1f, T=%.1f (%s)', x_opt(2), selected_t2, part_no2)); selection.TypeParagraph;
    selection.TypeParagraph;
    
    % Insert SW Image if exists
    if exist(sw_image_path, 'file')
        selection.Font.Bold = 1; selection.TypeText('3D Model Preview / 3Dモデル外観'); selection.TypeParagraph;
        selection.InlineShapes.AddPicture(sw_image_path); selection.TypeParagraph;
    end
    
    report_path = fullfile(pwd, output_dir, 'AMD_Design_Report.docx');
    if exist(report_path, 'file'), delete(report_path); end
    doc.SaveAs2(report_path); doc.Close; word.Quit;
    fprintf('✅ [DONE] Report and data saved in /out folder!\n');
catch ME
    fprintf('❌ [REPORT] Error: %s\n', ME.message);
    if exist('word', 'var'), word.Quit; end
end
