# 🌐 How to Publish to GitHub / GitHubへの公開手順

Follow these steps to upload your project to GitHub.
以下の手順でプロジェクトをGitHubにアップロードしてください。

### 1. Create a Repository on GitHub / GitHubでリポジトリを作成
1. Go to [GitHub](https://github.com/) and login.
2. Click **"New"** to create a new repository.
3. Name it: `AMD-Suite-AI-Design-Automation`
4. Choose **"Public"** and click **"Create repository"**. (Do NOT initialize with README/License as we already have them).

### 2. Upload using Command Line / コマンドラインでアップロード
Open your terminal (Command Prompt or PowerShell) in the `AMD_Project` folder and run:

```bash
# Initialize git / Gitを初期化
git init

# Add all files / ファイルをステージング
git add .

# Commit / コミット
git commit -m "Initial release: AI-driven design automation suite for TDU students"

# Link to GitHub / GitHubリポジトリに紐付け
# ※ [YOUR_USERNAME] を自分のGitHub名に書き換えてください
git remote add origin https://github.com/[YOUR_USERNAME]/AMD-Suite-AI-Design-Automation.git

# Push / アップロード
git branch -M main
git push -u origin main
```

### 3. Done! / 完了！
Now your project is live! You can share the link with your professors or in your resume.
これであなたのプロジェクトが世界に公開されました！履歴書や先生へのアピールに使えます。
