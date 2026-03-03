# 🚀 AMD Suite (Algo-Mech Designer)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![MATLAB](https://img.shields.io/badge/Made%20with-MATLAB-blue.svg)](https://www.mathworks.com/products/matlab.html)

**AMD Suite** is an AI-driven engineering design automation platform that bridges the gap between algorithmic optimization and physical 3D modeling. It integrates **MATLAB (AI/Brains)**, **SolidWorks (3D/Body)**, and **Box (Cloud/Archive)** to automate the entire engineering workflow from specification to final documentation.

**AMD Suite** は、アルゴリズムによる最適化と物理的な3Dモデリングの橋渡しをする、AI駆動型の工学設計自動化プラットフォームです。**MATLAB (AI/脳)**、**SolidWorks (3D/体)**、**Box (クラウド/書庫)** を統合し、仕様策定から最終報告書の作成までの全工程を自動化します。

---

## ✨ Key Features / 主な機能

- **🧠 AI Brain (Optimization)**: Uses Genetic Algorithms (GA) to find the optimal thickness and dimensions to minimize weight while satisfying load constraints.
- **🧬 Bridge Nerve (CSV Link)**: Real-time data synchronization between MATLAB calculations and SolidWorks design tables.
- **📄 Auto Report (Word)**: Generates a professional engineering report in `.docx` format, including optimization plots and design specs automatically.
- **☁️ Cloud Integrated**: Designed to work seamlessly with Box for team collaboration and versioned design management.

---

## 📂 File Architecture / ファイル構成

| File / ファイル名 | Role / 役割 | Language/Tool |
| :--- | :--- | :--- |
| `AMD_Main_Brain.m` | Central intelligence & report generator / 司令塔・レポート生成 | MATLAB |
| `Bridge_Nerve.csv` | Data bridge to SolidWorks / SolidWorksへのデータ中継 | CSV |
| `AMD_Design_Report.docx` | Generated design report / 生成された設計報告書 | MS Word |
| `ai_analysis_plot.png` | Optimization result visual / 最適化結果のグラフ | PNG (MATLAB) |

---

## 🛠️ System Requirements / システム要件

- **MATLAB** (R2020a+)
  - *Global Optimization Toolbox*
- **SolidWorks** (Standard or higher)
- **Microsoft Word**

---

## 🚀 Usage / 使いかた

### 1. Run the AI / AIを実行する
Open `AMD_Main_Brain.m` in MATLAB and run it (**F5**). 
The AI will calculate the optimal thickness and generate `Bridge_Nerve.csv` and `AMD_Design_Report.docx`.

MATLABで `AMD_Main_Brain.m` を開き、実行（**F5**）してください。
AIが最適な厚みを計算し、`Bridge_Nerve.csv` と `AMD_Design_Report.docx` を生成します。

### 2. Connect to SolidWorks / SolidWorksと連携する
Link your SolidWorks model dimensions to the generated `Bridge_Nerve.csv` using a **Design Table** (`Insert` > `Tables` > `Design Table`).

SolidWorksのモデル寸法を、**設計テーブル**（`挿入` > `テーブル` > `設計テーブル`）を使用して `Bridge_Nerve.csv` にリンクさせてください。

---

## ⚖️ License / ライセンス
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---
Developed by **WaRara-men** (TDU Student)
