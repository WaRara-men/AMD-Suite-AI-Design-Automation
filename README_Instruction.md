# 🚀 AMD Suite v7.0 - The Ultimate Standalone AI Engine

SolidWorksや複雑な設定は一切不要！
MATLAB単体で **「AIによる素材選定」「リアルタイム3Dプレビュー」「公式設計証明書の自動発行」** を完結させる、究極のスタンドアロン・アプリケーションです。

## 🌟 主な機能 (Features)

1. **🧠 超高速 AI エンジン**: 
   目標荷重・予算・安全率を入力するだけで、鉄・アルミ・カーボンから最適な素材と厚みを瞬時に算出します。
2. **💎 Hyper-Virtual 3D プレビュー**: 
   SolidWorksがなくても、MATLABがその場で光と影のレンダリングを行い、素材ごとの質感（メタリック、マットなど）を超美麗にリアルタイム表示します。
3. **📜 公式設計証明書 (PDF) の自動発行**: 
   ボタン一つで、AIが保証するプロ仕様の「Design Certificate (PDF)」を自動生成します。

---

## 🖥️ 使いかた (How to use)

### わずか2ステップで完了！
1. MATLABのコマンドウィンドウで以下を実行し、ダッシュボードを起動します：
   ```matlab
   cd src
   AMD_App
   ```
2. スライダーを動かして設計条件を決め、画面下の緑色のボタン **[🚀 GENERATE DESIGN CERTIFICATE]** を押すだけ！

### 出力結果
完了すると自動的に `out/` フォルダが開き、生成されたばかりの **`AMD_Design_Certificate.pdf`** が確認できます。

---

## 📂 フォルダ構成
- **`src/`**: アプリ本体とAIエンジン (`AMD_App.m`, `AMD_Main_Brain.m`)
- **`data/`**: 素材のカタログデータベース
- **`out/`**: 生成された設計証明書 (PDF) の保存先

---
**Developed by WaRara-men & Gemini CLI PM**
*Engineering simplified, visualization amplified.*
