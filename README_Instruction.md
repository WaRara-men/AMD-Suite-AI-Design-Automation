# 🚀 AMD Suite (Algo-Mech Designer) - Instruction Manual / 説明書

This project integrates **AI (MATLAB)**, **3D Design (SolidWorks)**, and **Cloud (Box)** to automate the entire engineering design workflow.
このプロジェクトは、**AI (MATLAB)**、**3D設計 (SolidWorks)**、**クラウド (Box)**を統合し、工学設計のすべてを自動化するプラットフォームです。

## 📋 Requirements / 必須要件

To run this system, you need the following software and toolboxes:
本システムを実行するには、以下のソフトウェアとツールボックスが必要です。

### 1. Software / ソフトウェア
- **MATLAB** (R2020a or later recommended)
- **SolidWorks** (Standard/Professional/Premium)
- **Microsoft Word** (For automatic report generation / レポート自動生成用)

### 2. MATLAB Toolboxes / MATLAB ツールボックス
- **Global Optimization Toolbox** (Essential for AI/GA optimization / AI最適化に必須)
- *Optional: MATLAB Report Generator (If you use advanced reporting / 高度なレポート機能を使う場合)*

---

## 📂 File Structure / ファイル構成

1. **`AMD_Main_Brain.m`**
   - **Role:** The Brain. Runs AI optimization and generates reports.
   - **役割:** 司令塔（脳）。AI（遺伝的アルゴリズム）を用いて最適設計を行い、レポートを生成します。

2. **`Bridge_Nerve.csv`**
   - **Role:** The Nerve. Transfers data from MATLAB to SolidWorks.
   - **役割:** 神経。MATLABで計算された数値をSolidWorksへ伝達します。

3. **`README_Instruction.md`**
   - **Role:** This manual.
   - **役割:** この説明書です。

---

## 🛠️ Usage / 使いかた

### STEP 1: Run the Brain (MATLAB) / 脳を動かす
1. Open `AMD_Main_Brain.m` in MATLAB.
2. Edit `target_load` to your desired value.
3. Press **F5** to run.
   - `Bridge_Nerve.csv` and `AMD_Design_Report.docx` will be generated.

### STEP 2: Link with the Body (SolidWorks) / 体と繋ぐ
1. Open your model in SolidWorks.
2. Go to `Insert` > `Tables` > `Design Table`. / `挿入` > `テーブル` > `設計テーブル`
3. Choose **"From file"** and select **`Bridge_Nerve.csv`**.
4. Link your dimensions to the columns.

---
**Developed by TDU Student & Gemini CLI PM**
