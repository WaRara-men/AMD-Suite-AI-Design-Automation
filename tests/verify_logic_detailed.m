% ==========================================
% Algo-Mech Designer (AMD) Suite - Logic Verification
% ==========================================
function verify_logic_detailed()
    fprintf('🧪 Running Detailed Module Verification... / 詳細モジュール検証を開始...\n');
    tests_dir = pwd;
    project_root = fileparts(tests_dir);
    src_dir = fullfile(project_root, 'src');
    addpath(src_dir);
    
    g = 9.81;
    pass_count = 0;
    total_tests = 5;
    
    % --- 1. Arm Mode ---
    load = 2; len = 300; rad = 20; budget = 10000;
    inputs = [load, len, rad, budget];
    arm_m = (pi * rad^2 * len) * 0.0000027;
    expected_req_val = (load + arm_m/2) * g * (len/1000) * 1.5;
    [req_val, comp, ~, ~, ~, ~, ~] = AMD_Logic(inputs, 'Arm', project_root);
    if abs(req_val - expected_req_val) < 1e-4
        fprintf('✅ [Arm] Logic: Correct (%.2f Nm)\n', req_val);
        pass_count = pass_count + 1;
    else
        fprintf('❌ [Arm] Logic: MISMATCH! (Expected %.2f, Got %.2f)\n', expected_req_val, req_val);
    end
    
    % --- 2. Lift Mode ---
    load = 5; p_rad = 50; eff = 80; budget = 10000;
    inputs = [load, p_rad, eff, budget];
    real_load = load / (max(0.1, eff) / 100); 
    expected_req_val = (real_load * g) * (p_rad/1000) * 1.5;
    [req_val, ~, ~, ~, ~, ~, ~] = AMD_Logic(inputs, 'Lift', project_root);
    if abs(req_val - expected_req_val) < 1e-4
        fprintf('✅ [Lift] Logic: Correct (%.2f Nm)\n', req_val);
        pass_count = pass_count + 1;
    else
        fprintf('❌ [Lift] Logic: MISMATCH! (Expected %.2f, Got %.2f)\n', expected_req_val, req_val);
    end
    
    % --- 3. Mobile Mode ---
    w = 10; r = 100; inc = 15; budget = 10000;
    inputs = [w, r, inc, budget];
    expected_req_val = (w*g*sin(inc*pi/180) + 0.15*w*g*cos(inc*pi/180)) * (r/1000) * 1.5;
    [req_val, ~, ~, ~, ~, ~, ~] = AMD_Logic(inputs, 'Mobile', project_root);
    if abs(req_val - expected_req_val) < 1e-4
        fprintf('✅ [Mobile] Logic: Correct (%.2f Nm)\n', req_val);
        pass_count = pass_count + 1;
    else
        fprintf('❌ [Mobile] Logic: MISMATCH! (Expected %.2f, Got %.2f)\n', expected_req_val, req_val);
    end
    
    % --- 4. Power Mode ---
    cur = 5; t = 2; v = 11.1; budget = 10000;
    inputs = [cur, t, v, budget];
    expected_req_val = cur * t * 1000 * 1.2;
    [req_val, ~, ~, ~, ~, ~, ~] = AMD_Logic(inputs, 'Power', project_root);
    if abs(req_val - expected_req_val) < 1e-4
        fprintf('✅ [Power] Logic: Correct (%.2f mAh)\n', req_val);
        pass_count = pass_count + 1;
    else
        fprintf('❌ [Power] Logic: MISMATCH! (Expected %.2f, Got %.2f)\n', expected_req_val, req_val);
    end
    
    % --- 5. Bolt Mode ---
    l = 100; n = 4; sf = 2.0; budget = 10000;
    inputs = [l, n, sf, budget];
    expected_req_val = (l * g * max(1.0, sf)) / max(1, n);
    [req_val, ~, ~, ~, ~, ~, ~] = AMD_Logic(inputs, 'Bolt', project_root);
    if abs(req_val - expected_req_val) < 1e-4
        fprintf('✅ [Bolt] Logic: Correct (%.2f N)\n', req_val);
        pass_count = pass_count + 1;
    else
        fprintf('❌ [Bolt] Logic: MISMATCH! (Expected %.2f, Got %.2f)\n', expected_req_val, req_val);
    end
    
    if pass_count == total_tests
        fprintf('🏆 [RESULT] All 5 modules verified successfully!\n');
    else
        fprintf('⚠️ [RESULT] Verification failed for %d modules.\n', total_tests - pass_count);
    end
end

