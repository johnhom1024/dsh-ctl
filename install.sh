#!/bin/bash
# install.sh — 把 dsh-ctl 装进本机某个 PATH 目录（软链，仓库仍是真相源）
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT="$REPO_DIR/dsh-ctl"

[ -x "$SCRIPT" ] || { echo "找不到 $SCRIPT，请在仓库根目录运行" >&2; exit 1; }

# 选目标目录：已有 PATH 优先，否则 ~/.local/bin 并提示加 PATH
target_dir=""
for d in "$HOME/.local/bin" "$HOME/bin" "/usr/local/bin" "/opt/homebrew/bin"; do
  case ":$PATH:" in
    *":$d:"*) target_dir="$d"; break ;;
  esac
done
if [ -z "$target_dir" ]; then
  target_dir="$HOME/.local/bin"
  echo "提示: $target_dir 不在 PATH，装完后请把它加进 shell 配置："
  echo "  echo 'export PATH=\"$target_dir:\$PATH\"' >> ~/.zshrc && source ~/.zshrc"
fi

mkdir -p "$target_dir"
ln -sf "$SCRIPT" "$target_dir/dsh-ctl"
echo "已安装: $target_dir/dsh-ctl -> $SCRIPT"

# 环境预检：装完大概率要用的东西先看一眼
echo
echo "== 环境预检 =="
ok=1
command -v node >/dev/null 2>&1 && echo "node:      $(node --version)" || { echo "node:      未安装（dsh web 需要）"; ok=0; }
if command -v pnpm >/dev/null 2>&1; then
  echo "pnpm:      $(pnpm --version)"
elif command -v yarn >/dev/null 2>&1 && ! yarn --version 2>/dev/null | grep -q '^1\.'; then
  echo "yarn:      $(yarn --version)"
elif command -v npx >/dev/null 2>&1; then
  echo "npx:       可用"
else
  echo "包管理器:  未找到 pnpm / yarn 2+ / npx，dsh-ctl install 会失败"
  ok=0
fi

echo
if [ "$ok" = "1" ]; then
  echo "下一步:"
  echo "  dsh-ctl install && dsh-ctl start && dsh-ctl open"
else
  echo "先补齐上面缺的东西，然后:"
  echo "  dsh-ctl install && dsh-ctl start && dsh-ctl open"
fi
