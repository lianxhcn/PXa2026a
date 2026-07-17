#!/usr/bin/env bash
# ============================================================
# setup-skills.sh — macOS / Linux 生成 skills 调用入口（symlink）
# 用法（在仓库根目录）：  bash scripts/setup-skills.sh
# 说明：
#   - skills/ 是唯一权威源；本脚本在 .claude/skills 与 .agents/skills 下为每个
#     skill 创建 symlink 入口（取去掉 NN- 序号的干净名）。
#   - 入口目录已在 .gitignore 中忽略，不入库。
# ============================================================
set -euo pipefail

# 定位仓库根（脚本在 scripts/ 下）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_ROOT="$REPO_ROOT/skills"

if [ ! -d "$SKILLS_ROOT" ]; then
  echo "未找到 skills/ 目录：$SKILLS_ROOT" >&2
  exit 1
fi

TARGETS=("$REPO_ROOT/.claude/skills" "$REPO_ROOT/.agents/skills")

# 收集所有含 SKILL.md 的 skill 源目录
mapfile -t SKILL_DIRS < <(find "$SKILLS_ROOT" -type f -name SKILL.md -exec dirname {} \; | sort -u)

if [ "${#SKILL_DIRS[@]}" -eq 0 ]; then
  echo "skills/ 下暂无含 SKILL.md 的 skill，直接退出。"
  exit 0
fi

for target in "${TARGETS[@]}"; do
  mkdir -p "$target"
  for src in "${SKILL_DIRS[@]}"; do
    name="$(basename "$src")"
    clean="${name#*-}"                 # 去掉前缀 NN-
    # 仅当确有 NN- 前缀时才剥离；否则保留原名
    if [[ ! "$name" =~ ^[0-9]+- ]]; then clean="$name"; fi
    link="$target/$clean"
    rm -rf "$link"
    ln -s "$src" "$link"
    echo "  [symlink] $clean -> $src"
  done
  echo "已生成入口：$target"
  echo
done

echo "完成。冒烟测试：启动 agent，让它复述某个 skill 的用途。"
