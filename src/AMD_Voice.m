% ==========================================
% Algo-Mech Designer (AMD) Suite - Voice v22.0
% ==========================================
function AMD_Voice(mode, comp_name, req_val, m_unit)
    try
        NET.addAssembly('System.Speech');
        speak = System.Speech.Synthesis.SpeechSynthesizer;
        
        % 🌟 RESTORED: RICH STORYTELLING NARRATION
        msg = sprintf(['解析が完了しました。%sモードにおける過酷な条件に対し、AIはミリ秒単位でシミュレーションを行いました。', ...
            'その結果、必要な%sである %.2f %s を満たし、かつ最もコストパフォーマンスに優れた、%s、を最適解として特定しました。', ...
            '詳細は証明書をご確認ください。'], ...
            char(mode), 'スペック', req_val, m_unit, char(comp_name));
            
        speak.Speak(msg);
    catch
    end
end
