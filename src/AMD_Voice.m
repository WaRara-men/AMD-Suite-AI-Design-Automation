% ==========================================
% Algo-Mech Designer (AMD) Suite - Voice v15.0
% ==========================================
function AMD_Voice(mode, comp_name)
    try
        NET.addAssembly('System.Speech');
        speak = System.Speech.Synthesis.SpeechSynthesizer;
        msg = sprintf('%s モジュールの精密解析が完了しました。最適な部品は %s です。', mode, char(comp_name));
        speak.Speak(msg);
    catch
    end
end
