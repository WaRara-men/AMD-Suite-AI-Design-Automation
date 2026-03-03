# 🚀 AMD Suite (Algo-Mech Designer)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![MATLAB](https://img.shields.io/badge/Made%20with-MATLAB-blue.svg)](https://www.mathworks.com/products/matlab.html)

**AMD Suite** is an enterprise-grade AI-driven engineering design automation platform. Decoupled, maintainable, and robust.

**AMD Suite** は、エンタープライズレベルのAI駆動型工学設計自動化プラットフォームです。設定とロジックを分離し、保守性と堅牢性を極限まで高めています。

---

## ✨ Enterprise Edition (v3.0)

- **⚙️ JSON Configuration**: Externalize all design parameters (Safety Factor, targets, etc.) to `config/settings.json`. No need to touch the code.
- **🛠️ Environment Setup**: One-click environment initialization with root `setup.m`.
- **🧪 Health Checks**: Diagnostic suite in `tests/` to verify system integrity.
- **🛡️ Advanced Safety**: Refined safety factor logic and modular data loading.
- **📸 Pro Documentation**: Enhanced SolidWorks capture and formatted Word reporting.

---

## 📂 Architecture / 構成

- `setup.m`: Run first! Initializes paths and environment.
- `src/`: Core simulation and AI logic.
- `config/`: System and design parameters (`settings.json`).
- `data/`: Material and part catalogs.
- `tests/`: System health checks and diagnostics.
- `out/`: Generated professional artifacts.

---

## 🚀 Getting Started / はじめかた

1. Clone the repository / クローンします。
2. Run **`setup()`** in MATLAB / MATLABで `setup()` を実行して初期化します。
3. Edit **`config/settings.json`** for your specs / 設定ファイルを編集して要件を入力します。
4. Run **`AMD_Main_Brain`** to generate results / `AMD_Main_Brain` を実行して設計を開始します。

---

## 🗺️ Roadmap / 今後の展望

- [ ] **Multi-Body Support**: Automating complex assemblies.
- [ ] **Cloud Sync API**: Native Box/OneDrive integration for distributed teams.
- [ ] **Web Dashboard**: Real-time optimization tracking via web interface.

---
Developed by **WaRara-men** (Enterprise Automation Lead)
