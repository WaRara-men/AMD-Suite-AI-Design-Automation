% ==========================================
% Algo-Mech Designer (AMD) Suite - Edge Case Verification
% ==========================================
function verify_edge_cases()
    fprintf('🧪 Running Edge Case Diagnostics... / エッジケース診断を開始...\n');
    % --- Path Setup ---
    current_path = mfilename('fullpath');
    if isempty(current_path)
        % Running as a script or from command line
        project_root = pwd; 
    else
        [tests_dir, ~, ~] = fileparts(current_path);
        project_root = fileparts(tests_dir);
    end
    
    src_dir = fullfile(project_root, 'src');
    if exist(src_dir, 'dir')
        addpath(src_dir);
    end
    
    g = 9.81;
    pass_count = 0;
    total_tests = 0;
    
    % --- Helper for reporting ---
    function report_test(name, condition, details)
        total_tests = total_tests + 1;
        if condition
            fprintf('✅ [%s] %s\n', name, details);
            pass_count = pass_count + 1;
        else
            fprintf('❌ [%s] FAILED: %s\n', name, details);
        end
    end

    % 1. Arm Mode - Zero Inputs
    [req, comp, ~, ~, ~, ~, ~] = AMD_Logic([0, 0, 0, 0], 'Arm', project_root);
    report_test('Arm-Zero', req == 0, sprintf('Req=%.2f Nm, Selected: %s (Budget: 0 -> Fallback: Cheapest)', req, comp.PartName{1}));

    % 2. Arm Mode - Massive Inputs
    [req, comp, ~, ~, ~, ~, ~] = AMD_Logic([1000, 5000, 500, 100000], 'Arm', project_root);
    report_test('Arm-Massive', req > 0, sprintf('Req=%.2f Nm, Selected: %s', req, comp.PartName{1}));

    % 3. Lift Mode - Zero Efficiency
    % Should not divide by zero because of max(0.1, eff)
    [req, comp, ~, ~, ~, ~, ~] = AMD_Logic([5, 50, 0, 10000], 'Lift', project_root);
    report_test('Lift-ZeroEff', req > 0, sprintf('Req=%.2f Nm (Handled 0%% efficiency)', req));

    % 4. Mobile Mode - Flat Surface (0 deg)
    [req, comp, ~, ~, ~, ~, ~] = AMD_Logic([10, 100, 0, 10000], 'Mobile', project_root);
    expected = (0 + 0.15*10*g*1) * (100/1000) * 1.5;
    report_test('Mobile-Flat', abs(req - expected) < 1e-4, sprintf('Req=%.2f Nm', req));

    % 5. Mobile Mode - Vertical Surface (90 deg)
    [req, comp, ~, ~, ~, ~, ~] = AMD_Logic([10, 100, 90, 10000], 'Mobile', project_root);
    expected = (10*g*1 + 0.15*10*g*0) * (100/1000) * 1.5;
    report_test('Mobile-Vertical', abs(req - expected) < 1e-4, sprintf('Req=%.2f Nm', req));

    % 6. Power Mode - Zero Requirements
    [req, comp, ~, ~, ~, ~, ~] = AMD_Logic([0, 0, 11.1, 0], 'Power', project_root);
    report_test('Power-Zero', req == 0, sprintf('Req=%.2f mAh, Selected: %s', req, comp.PartName{1}));

    % 7. Bolt Mode - Zero Bolts
    % Should not divide by zero because of max(1, n)
    [req, comp, ~, ~, ~, ~, ~] = AMD_Logic([100, 0, 2.0, 10000], 'Bolt', project_root);
    expected = (100 * g * 2.0) / 1;
    report_test('Bolt-ZeroBolts', abs(req - expected) < 1e-4, sprintf('Req=%.2f N (Handled 0 bolts)', req));

    % 8. Bolt Mode - Zero Safety Factor
    % Should use max(1.0, sf)
    [req, comp, ~, ~, ~, ~, ~] = AMD_Logic([100, 4, 0, 10000], 'Bolt', project_root);
    expected = (100 * g * 1.0) / 4;
    report_test('Bolt-ZeroSF', abs(req - expected) < 1e-4, sprintf('Req=%.2f N (Handled 0 SF)', req));

    % Summary
    fprintf('\n📊 [SUMMARY] Edge Case Diagnostics: %d/%d Passed.\n', pass_count, total_tests);
    if pass_count == total_tests
        fprintf('🚀 System is robust against edge cases!\n');
    else
        fprintf('⚠️ System has potential vulnerabilities.\n');
    end
end
