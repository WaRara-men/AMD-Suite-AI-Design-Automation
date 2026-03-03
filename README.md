# 🚀 AMD Suite (Algo-Mech Designer)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![MATLAB](https://img.shields.io/badge/Made%20with-MATLAB-blue.svg)](https://www.mathworks.com/products/matlab.html)

**AMD Suite** is a professional AI-driven engineering design automation platform. It bridges algorithmic optimization with physical 3D modeling by integrating **MATLAB (AI/Brains)**, **SolidWorks (3D/Body)**, and **Box (Cloud/Archive)**.

**AMD Suite** は、AI駆動型のプロフェッショナルな工学設計自動化プラットフォームです。**MATLAB (AI/脳)**、**SolidWorks (3D/体)**、**Box (クラウド/書庫)** を統合し、アルゴリズムによる最適化と物理的な3Dモデリングをシームレスに繋ぎます。

---

## ✨ New in v2.7 / 最新機能 (v2.7)

- **🛡️ Safety Factor (Margin of Safety)**: Automatically applies a configurable safety margin (default 1.5x) to AI-calculated dimensions to ensure real-world reliability.
  - **安全率の適用**: AIが計算した寸法に、自動で1.5倍（調整可能）のマージンを乗せ、現実世界での強度不足を防ぎます。
- **📸 SolidWorks Auto-Capture**: Automatically takes a screenshot of the active SolidWorks model and embeds it into the final Word report for 100% automated documentation.
  - **SolidWorks 自動撮影**: 実行時、SolidWorksで開いているモデルを自動で撮影。スクリーンショットをレポートに自動で貼り付け、報告書作成を完全自動化します。
- **📂 Professional Organization**: Clean folder structure separating source code, data catalogs, and generated outputs.
  - **フォルダ整理**: プログラム本体、データカタログ、出力を整理し、プロフェッショナルな構成にアップデートしました。

---

## 📂 File Architecture / ファイル構成

| Path / パス | Role / 役割 | Language/Tool |
| :--- | :--- | :--- |
| `src/AMD_Main_Brain.m` | Central intelligence & automation script / 司令塔 | MATLAB |
| `data/Standard_Parts_Catalog.csv`| Parts catalog for material selection / 部品カタログ | CSV |
| `out/` | All generated reports, captured images, and CSVs / 出力全般 | (Output Folder) |

---

## 🛠️ System Requirements / システム要件

- **MATLAB** (R2020a+)
  - *Global Optimization Toolbox*
- **SolidWorks** (Running for Auto-Capture)
- **Microsoft Word**

---

## 🚀 Usage / 使いかた

### 1. Run the AI / AIを実行する
1. Open SolidWorks and have your model ready (optional for capture).
2. Open `src/AMD_Main_Brain.m` in MATLAB and run (**F5**).
3. The system will automatically optimize, capture the SW view, and generate files in `out/`.

1. SolidWorksを起動し、モデルを表示しておきます（自動撮影用）。
2. MATLABで `src/AMD_Main_Brain.m` を開き、実行（**F5**）してください。
3. システムが自動的に最適化を行い、SW画面を撮影し、`out/` フォルダに全ファイルを生成します。

---

## ⚖️ License / ライセンス
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---
Developed by **WaRara-men** (TDU Student)
