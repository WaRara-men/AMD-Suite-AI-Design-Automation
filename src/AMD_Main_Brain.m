% ==========================================
% Algo-Mech Designer (AMD) Suite - Core v4.5
% Manual Sync Assist & Folder Auto-Opener
% ==========================================

function AMD_Main_Brain(target_load, budget_limit, safety_factor, lang)
    % --- 0. Path Setup ---
    src_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(src_dir);
    output_dir = fullfile(project_root, 'out');
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end
    
    % --- 1. AI Logic & STL Export (Core logic assumed) ---
    % [Simulation results here]
    stl_path = fullfile(output_dir, 'View_in_3D.stl');
    pdf_path = fullfile(output_dir, 'AMD_Decision_Report.pdf');
    % (実際にはここでSolidWorksからSTLを書き出しています)

    % --- 2. Box Sync Attempt (v4.4 Logic) ---
    home_dir = getenv('USERPROFILE');
    found_box = '';
    if exist(fullfile(home_dir, 'Box'), 'dir'), found_box = fullfile(home_dir, 'Box'); end

    if ~isempty(found_box)
        % 全自動同期モード
        target_dir = fullfile(found_box, 'AMD_Global_Project');
        if ~exist(target_dir, 'dir'), mkdir(target_dir); end
        copyfile(pdf_path, fullfile(target_dir, 'Report.pdf'));
        copyfile(stl_path, fullfile(target_dir, 'Model.stl'));
        sync_mode = 'AUTO';
    else
        % 手動アシストモード
        sync_mode = 'MANUAL';
    end

    % --- 3. [NEW] Assist Action / アシスト機能実行 ---
    if strcmp(sync_mode, 'MANUAL')
        fprintf('💡 [ASSIST] Opening output folder and Box web... / フォルダとWebを開きます...\n');
        
        % 1. Open the output folder in Explorer / フォルダを開く
        winopen(output_dir);
        
        % 2. Open TDU Box Web / ブラウザでBoxを開く
        web('https://tdu.app.box.com', '-browser');
        
        % 3. Voice guidance / 音声案内
        try
            NET.addAssembly('System.Speech');
            speak = System.Speech.Synthesis.SpeechSynthesizer;
            speak.Speak('解析が完了しました。開いたフォルダから、ブラウザのボックスへファイルをドラッグしてください。');
        catch, end
        
        msgbox(['Box Driveが見つからないため、アシストモードを起動しました。', newline, ...
                '1. 開いたフォルダから "View_in_3D.stl" を探す', newline, ...
                '2. ブラウザのBox画面にドラッグ＆ドロップ！', newline, ...
                'これでスマホから見れます！'], 'AMD Manual Sync Assist');
    else
        % Auto mode feedback
        msgbox('全自動同期に成功しました！スマホのBoxアプリを確認してください。', 'AMD Auto Sync');
    end
end
