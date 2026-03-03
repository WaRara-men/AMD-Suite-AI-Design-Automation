% == == == == == == == == == == == == == == == == == == == == == == == == == ==
    == == == == == == == == == ==
    = % Algo - Mech Designer(AMD) Suite -
      Core v3.0(Enterprise Edition) % Full Automation : JSON Settings,
    Safety Factor &SW Capture %
            -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -%
            Description
    : %
      Central intelligence module.Decouples parameters from logic using JSON.%
        == == == == == == == == == == == == == == == == == == == == == == == ==
        == == == == == == == == == == == ==
    =

        % -- -0. Path &
        Config Setup / パスと設定の読み込み-- -
            fprintf(
                '\n⚙️  Loading AMD Suite v3.0... / システムを読み込み中...\n');

% Load JSON settings config_file = 'settings.json';
% Assuming folder is in path via setup.m if isempty (which(config_file))
        error('❌ Cannot find settings.json. Please run setup.m first!');
end

    try settings_json = fileread(which(config_file));
cfg = jsondecode(settings_json);
fprintf(
    '   - Configuration loaded successfully. / 設定ファイルの読み込み完了。\n');
catch ME error('❌ Failed to parse settings.json: %s', ME.message);
end

    % Extract parameters dcfg = cfg.design_parameters;
pcfg = cfg.paths;
pref = cfg.preferences;

% Ensure output directory exists relative to root root_dir =
    fileparts(fileparts(mfilename('fullpath')));
% Up one from src / output_path = fullfile(root_dir, pcfg.output_dir);
if
  ~exist(output_path, 'dir'), mkdir(output_path);
end

        % -- -1. Design Calculations / 設計計算-- -
    required_reach = sqrt(dcfg.target_x ^ 2 + dcfg.target_y ^ 2);
fprintf(
    '🧠 [AI] Optimizing for reach: %.1f mm with SF: %.1f... / 最適化中...\n',
    ... required_reach, dcfg.safety_factor);

% Objective : Minimize Weight(Simple Example) obj_func =
    @(x)(x(1) * x(3) + x(2) * x(4)) * dcfg.density;

lb = [ 50, 50, 1.0, 1.0 ];
ub = [ 400, 400, 10.0, 10.0 ];

A = [ -1, -1, 0, 0 ];
b = -required_reach;

try options = optimoptions('ga', 'Display', 'none');
[ x_opt, ~] = ga(obj_func, 4, A, b, [], [], lb, ub, [], options);
catch x_opt = [ required_reach / 2, required_reach / 2, 3.0, 2.0 ];
end

    % Apply Safety Factor to thickness results
          x_opt(3 : 4) = x_opt(3 : 4) * dcfg.safety_factor;

% -- -2. Catalog Selection / カタログ選定-- - try catalog =
    readtable(fullfile(root_dir, pcfg.data_dir, pcfg.catalog_file));

idx1 = find(catalog.Thickness >= x_opt(3), 1, 'first');
if isempty (idx1)
  , idx1 = height(catalog);
end selected_t1 = catalog.Thickness(idx1);
part_no1 = catalog.PartNumber{idx1};

idx2 = find(catalog.Thickness >= x_opt(4), 1, 'first');
if isempty (idx2)
  , idx2 = height(catalog);
end selected_t2 = catalog.Thickness(idx2);
part_no2 = catalog.PartNumber{idx2};
catch ME warning('⚠️ Data catalog load failed: %s. Using raw thickness.',
                 ME.message);
selected_t1 = x_opt(3);
part_no1 = 'RAW';
selected_t2 = x_opt(4);
part_no2 = 'RAW';
end

        % -- -3. SolidWorks Auto -
    Capture / SW自動撮影-- -
    sw_image_path = fullfile(output_path, 'sw_capture.png');
if pref
  .auto_capture_sw
      fprintf('📸 [SW] Capturing SolidWorks active model... / 撮影中...\n');
try swApp = actxGetRunningServer('SldWorks.Application');
swModel = swApp.ActiveDoc;
if
  ~isempty(swModel) swModel.SaveAs2(sw_image_path, 0, true, false);
fprintf('   -> ✅ Capture Success! / 撮影成功！\n');
end catch fprintf(
    '   -> ⚠️ SolidWorks integration skipped. / 連携をスキップしました。\n');
end end

        % -- -4. Export &Reporting / 書き出しとレポート-- -
    % Data Bridge T_bridge =
    table(x_opt(1), x_opt(2), selected_t1, selected_t2, ... 'VariableNames',
          {'L1', 'L2', 'T1', 'T2'});
writetable(T_bridge, fullfile(output_path, 'Bridge_Nerve.csv'));

% Word Report if pref.generate_word_report try word =
    actxserver('Word.Application');
word.Visible = 0;
doc = word.Documents.Add;
selection = word.Selection;

selection.Font.Size = 24;
selection.Font.Bold = 1;
selection.TypeText('AMD Enterprise Design Report');
selection.TypeParagraph;

selection.Font.Size = 12;
selection.Font.Bold = 1;
selection.TypeText(sprintf('Shielded by Safety Factor: %.2f',
                           dcfg.safety_factor));
selection.TypeParagraph;
selection.TypeParagraph;

selection.Font.Bold = 0;
selection.TypeText(sprintf('Link 1: L=%.1f, T=%.1f (%s)', x_opt(1), selected_t1,
                           part_no1));
selection.TypeParagraph;
selection.TypeText(sprintf('Link 2: L=%.1f, T=%.1f (%s)', x_opt(2), selected_t2,
                           part_no2));
selection.TypeParagraph;

if exist (sw_image_path, 'file')
  selection.TypeParagraph;
selection.InlineShapes.AddPicture(sw_image_path);
end

    report_path = fullfile(output_path, 'AMD_Design_Report.docx');
if exist (report_path, 'file')
  , delete (report_path);
end doc.SaveAs2(report_path);
doc.Close;
word.Quit;
fprintf('📄 [REPORT] Enterprise report generated in /out.\n');
catch ME fprintf('❌ [REPORT] Failed: %s\n', ME.message);
if exist ('word', 'var')
  , word.Quit;
end end end

    fprintf('\n✨ All processes completed / すべての工程が完了しました\n');
