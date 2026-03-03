% Algo - Mech Designer(AMD) Suite -
    Diagnostic Test
        % Run this to verify the pipeline.

          fprintf('🧪 Running AMD Suite Diagnostics... / 診断を開始...\n');

try % 1. Check Path if isempty (which('AMD_Main_Brain'))
          error('src/ folder not in path. Run setup.m first!');
end

    % 2. Check Config config_path = fullfile(pwd, 'config', 'settings.json');
if
  ~exist(config_path, 'file') error('config/settings.json missing!');
end fprintf('   - Path and Config: OK\n');

% 3. Check Data data_path = fullfile(pwd, 'data', 'Standard_Parts_Catalog.csv');
if
  ~exist(data_path, 'file') error('data/Standard_Parts_Catalog.csv missing!');
end fprintf('   - Catalog Data: OK\n');

    % 4. System Check (Placeholder for more complex logic)
    fprintf('✅ All diagnostics passed! / 全ての診断をクリアしました！\n');
    catch ME fprintf('❌ Diagnostics FAILED: %s\n', ME.message);
    end
