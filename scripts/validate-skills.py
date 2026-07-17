#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
validate-skills.py — 校验 skills/ 目录规范（开放 Agent Skills 标准）

检查项：
  1. 每个 skill 文件夹须含 SKILL.md；
  2. SKILL.md 顶部须有 YAML front matter（--- ... ---）；
  3. YAML 头只允许 name 与 description 两个字段，且均非空；
  4. name 应与文件夹去掉 NN- 序号后的干净名一致；
  5. 可选子目录只能是 scripts/ references/ assets/（其余目录给出警告）。

用法（在仓库根目录）：  python scripts/validate-skills.py
返回码：0 = 全部通过；1 = 存在错误。
无第三方依赖（自带简易 front matter 解析，不需要 PyYAML）。
"""
import re
import sys
from pathlib import Path

# Windows 控制台可能是 GBK 编码，强制 stdout/stderr 用 UTF-8，避免中文/符号报错
for _stream in (sys.stdout, sys.stderr):
    try:
        _stream.reconfigure(encoding="utf-8")
    except (AttributeError, ValueError):
        pass

ALLOWED_KEYS = {"name", "description"}
ALLOWED_SUBDIRS = {"scripts", "references", "assets"}

REPO_ROOT = Path(__file__).resolve().parent.parent
SKILLS_ROOT = REPO_ROOT / "skills"


def parse_front_matter(text):
    """返回 (dict, error)。仅支持简单的 key: value 顶层字段。"""
    m = re.match(r"^---\s*\n(.*?)\n---\s*(\n|$)", text, re.DOTALL)
    if not m:
        return None, "缺少 YAML front matter（--- ... ---）"
    body = m.group(1)
    data = {}
    cur_key = None
    for raw in body.splitlines():
        if not raw.strip():
            continue
        # 续行（description 允许折行，以缩进开头）
        if raw[0] in " \t" and cur_key:
            data[cur_key] += " " + raw.strip()
            continue
        km = re.match(r"^([A-Za-z0-9_-]+)\s*:\s*(.*)$", raw)
        if not km:
            return None, f"无法解析的 YAML 行：{raw!r}"
        cur_key = km.group(1)
        data[cur_key] = km.group(2).strip()
    return data, None


def clean_name(folder_name):
    return re.sub(r"^\d+-", "", folder_name)


def validate_skill(skill_dir):
    errors, warnings = [], []
    skill_md = skill_dir / "SKILL.md"
    if not skill_md.exists():
        errors.append("缺少 SKILL.md")
        return errors, warnings

    text = skill_md.read_text(encoding="utf-8")
    data, err = parse_front_matter(text)
    if err:
        errors.append(err)
        return errors, warnings

    keys = set(data.keys())
    extra = keys - ALLOWED_KEYS
    if extra:
        errors.append(f"YAML 头含非法字段：{sorted(extra)}（只允许 name/description）")
    for req in ("name", "description"):
        if not data.get(req):
            errors.append(f"YAML 头缺少或为空：{req}")

    expected = clean_name(skill_dir.name)
    if data.get("name") and data["name"] != expected:
        warnings.append(f"name='{data['name']}' 与文件夹干净名 '{expected}' 不一致")

    for child in skill_dir.iterdir():
        if child.is_dir() and child.name not in ALLOWED_SUBDIRS:
            warnings.append(f"非标准子目录：{child.name}/（标准：scripts/references/assets）")

    return errors, warnings


def main():
    if not SKILLS_ROOT.exists():
        print(f"✗ 未找到 skills/ 目录：{SKILLS_ROOT}")
        return 1

    skill_dirs = sorted(
        p.parent for p in SKILLS_ROOT.rglob("SKILL.md")
    )
    if not skill_dirs:
        print("skills/ 下暂无含 SKILL.md 的 skill。")
        return 0

    total_errors = 0
    for sd in skill_dirs:
        rel = sd.relative_to(REPO_ROOT)
        errors, warnings = validate_skill(sd)
        if errors:
            total_errors += len(errors)
            print(f"✗ {rel}")
            for e in errors:
                print(f"    ERROR: {e}")
        else:
            print(f"✓ {rel}")
        for w in warnings:
            print(f"    warn : {w}")

    print()
    if total_errors:
        print(f"校验未通过：{total_errors} 个错误。")
        return 1
    print(f"校验通过：{len(skill_dirs)} 个 skill 全部合规。")
    return 0


if __name__ == "__main__":
    sys.exit(main())
