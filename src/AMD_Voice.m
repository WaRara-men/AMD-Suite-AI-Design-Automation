% ==========================================
% Algo-Mech Designer (AMD) Suite - Voice v13.0
% ==========================================
function AMD_Voice(motor_name, arm_mass)
    try
        NET.addAssembly('System.Speech');
        speak = System.Speech.Synthesis.SpeechSynthesizer;
        msg = sprintf('解析が完了しました。アーム自重 %.2f キロを考慮した結果、最適なモーターは %s です。', arm_mass, char(motor_name));
        speak.Speak(msg);
    catch
    end
end
