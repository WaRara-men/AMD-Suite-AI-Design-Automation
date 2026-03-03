function setup() % Algo - Mech Designer(AMD) Suite -
    Setup Script
        % Run this script once to initialize the environment.

          fprintf(
              '🛠️  Initializing AMD Suite Environment... / 環境を初期化中...\n');

% Get root directory of the project root_dir = fileparts(mfilename('fullpath'));
cd(root_dir);

% Add subfolders to MATLAB Path addpath(fullfile(root_dir, 'src'));
addpath(fullfile(root_dir, 'data'));
addpath(fullfile(root_dir, 'config'));
savepath;

% Create output directory if it doesn't exist out_path =
    fullfile(root_dir, 'out');
if
  ~exist(out_path, 'dir') mkdir(out_path);
% Create hidden.gitkeep to ensure folder stays in git fid =
    fopen(fullfile(out_path, '.gitkeep'), 'w');
fclose(fid);
fprintf('   - out/ directory created. / 出力用フォルダを作成しました。\n');
end

    % Verify Toolboxes v = ver;
hasGA = any(strcmp({v.Name}, 'Global Optimization Toolbox'));

if hasGA
  fprintf(
      '✅ Global Optimization Toolbox found. / ツールボックスを確認しました。\n');
else
  warning(
      '❌ Global Optimization Toolbox NOT found! AI optimization will skip GA. / ツールボックスが見つかりません。');
end

    fprintf(
        '✨ Setup Complete! Use "src/AMD_Main_Brain" to start. / 設定完了！\n');
end
