# ============================================================
# setup-skills.ps1 — Windows 生成 skills 调用入口（免管理员权限）
# 用法（在仓库根目录）：  scripts\setup-skills.ps1
# 说明：
#   - skills/ 是唯一权威源；本脚本在 .claude/skills 与 .agents/skills 下为每个
#     skill 生成一个入口（取去掉 NN- 序号的干净名）。
#   - 优先用目录 junction（免管理员权限）；不可用时回退为复制。
#   - 入口目录已在 .gitignore 中忽略，不入库。
# ============================================================

$ErrorActionPreference = 'Stop'

# 定位仓库根（脚本在 scripts/ 下）
$RepoRoot   = Split-Path -Parent $PSScriptRoot
$SkillsRoot = Join-Path $RepoRoot 'skills'
$Targets    = @(
    (Join-Path $RepoRoot '.claude\skills'),
    (Join-Path $RepoRoot '.agents\skills')
)

if (-not (Test-Path $SkillsRoot)) {
    Write-Error "未找到 skills/ 目录：$SkillsRoot"
}

# 收集所有 skill 源目录（core/ 与 extra/ 下含 SKILL.md 的文件夹）
$skillDirs = Get-ChildItem -Path $SkillsRoot -Directory -Recurse |
    Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') }

if (-not $skillDirs) {
    Write-Warning "skills/ 下暂无含 SKILL.md 的 skill，直接退出。"
    return
}

foreach ($target in $Targets) {
    if (-not (Test-Path $target)) {
        New-Item -ItemType Directory -Path $target -Force | Out-Null
    }

    foreach ($src in $skillDirs) {
        # 干净名：去掉前缀 NN-（如 03-replication-navigator -> replication-navigator）
        $clean = $src.Name -replace '^\d+-', ''
        $link  = Join-Path $target $clean

        if (Test-Path $link) {
            Remove-Item $link -Recurse -Force
        }

        $madeJunction = $false
        try {
            New-Item -ItemType Junction -Path $link -Target $src.FullName -ErrorAction Stop | Out-Null
            $madeJunction = $true
        } catch {
            # 回退为复制
            Copy-Item -Path $src.FullName -Destination $link -Recurse -Force
        }

        $mode = if ($madeJunction) { 'junction' } else { 'copy' }
        Write-Host ("  [{0,-8}] {1} -> {2}" -f $mode, $clean, $src.FullName)
    }
    Write-Host "已生成入口：$target`n"
}

Write-Host "完成。冒烟测试：启动 agent，让它复述某个 skill 的用途。"
