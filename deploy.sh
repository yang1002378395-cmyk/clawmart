#!/bin/bash
# ClawMart GitHub Pages 部署脚本
# 用法：bash deploy.sh

set -e

cd "$(dirname "$0")"

echo "🚀 部署 ClawMart 到 GitHub Pages..."

# 检查 gh 登录状态
if ! gh auth status &>/dev/null; then
    echo "❌ 未登录 GitHub CLI"
    echo "请运行：gh auth login"
    exit 1
fi

# 获取 GitHub 用户名
GH_USER=$(gh api user --jq '.login')
echo "✅ 已登录：$GH_USER"

# 创建仓库（如果不存在）
REPO_NAME="clawmart"
if ! gh repo view "$GH_USER/$REPO_NAME" &>/dev/null; then
    echo "📦 创建仓库：$GH_USER/$REPO_NAME"
    gh repo create "$REPO_NAME" --public --description "OpenClaw 安装服务 - 让 AI Agent 为你工作"
fi

# 设置 remote
if ! git remote | grep -q origin; then
    git remote add origin "https://github.com/$GH_USER/$REPO_NAME.git"
fi

# 提交并推送
git add -A
git commit -m "Update landing page" || true
git branch -M main
git push -u origin main --force

# 启用 GitHub Pages
echo "🌐 启用 GitHub Pages..."
gh api -X POST "repos/$GH_USER/$REPO_NAME/pages" \
    -f source='{"branch":"main","path":"/"}' 2>/dev/null || \
    echo "⚠️  Pages 可能已启用，请手动检查"

echo ""
echo "✅ 部署完成！"
echo "🔗 https://$GH_USER.github.io/$REPO_NAME"
echo ""
echo "📋 下一步："
echo "1. 访问上面的链接确认页面正常"
echo "2. 在掘金/社交媒体分享链接"
echo "3. 设置自定义域名（可选）"
