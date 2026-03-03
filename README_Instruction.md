# 🚀 AMD Suite (Algo-Mech Designer) - Instruction Manual / 説明書

This project integrates **AI (MATLAB)**, **3D Design (SolidWorks)**, and **Cloud (Box)** to automate the entire engineering design workflow.

## 📋 Requirements / 必須要件
- **MATLAB** (Global Optimization Toolbox)
- **SolidWorks**
- **Microsoft Word**

## 📂 File Structure / ファイル構成
1. **`src/AMD_App.m` [NEW]**
   - **Interactive Dashboard.** Run this to control everything via GUI.
   - **ダッシュボードアプリ。** UIから直感的に設計をコントロールできます。
2. **`src/AMD_Main_Brain.m`**
   - **The Engine.** Core logic for AI and reporting.
   - **解析エンジン。** AI最適化とレポート生成の本体です。
3. **`data/Standard_Parts_Catalog.csv`**
   - **Database.** Material and price info.
   - **データベース。** 素材や価格の情報。

## 🛠️ Usage / 使いかた

### 🖥️ Interactive Mode (Recommended) / アプリで使う
1. Open MATLAB and run **`src/AMD_App.m`**.
2. Use sliders to set **Load, Budget, and Safety Factor**.
3. Click **"🚀 GENERATE ALL"** to update 3D models and generate reports.

### ⚙️ Automation Mode / 自動連携
The system automatically syncs results to your **Box folder** (`Box/AMD_Reports`) and sends a desktop notification upon completion.

---
**Developed by WaRara-men & Gemini CLI PM**
