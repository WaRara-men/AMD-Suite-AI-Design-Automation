% ==========================================
% Algo-Mech Designer (AMD) Suite - Voice v14.0
% RICH NARRATION SYSTEM
% ==========================================

function AMD_Voice(motor_name, arm_mass, req_t)
    try
        NET.addAssembly('System.Speech');
        speak = System.Speech.Synthesis.SpeechSynthesizer;
        msg = sprintf(['ロボットの精密解析が完了しました。アーム自重 %.2f キログラムを含めた必要トルクは、', ...
            '%.2f ニュートンメートルです。最適な部品として、%s、を選定しました。証明書にリンクを添付してあります。'], ...
            arm_mass, req_t, char(motor_name));
        speak.Speak(msg);
    catch
    end
end
