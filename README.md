# AI 时代的实证研究基础

> 连享会 · 2026 暑期班「初级班」课件仓库（2026-07-21 至 07-23，三天）

本仓库是一本用 [Quarto](https://quarto.org/) 编译的 online book，通过 GitHub
Pages 发布：**<https://lianxhcn.github.io/PXa2026a/>**。

它同时承担四重身份：

1. **课程主页**：三天课表与报名学员的导航入口；
2. **六讲讲义**：严格对应已发布的课程大纲，双主线（方法主线 + AI 工作流主线）并行；
3. **可复现项目**：`data/` + `examples/`，学员克隆后可在本地跑通；
4. **skills 工具箱**：`skills/` 文件夹 + 一份「skills 上手指南」，承载本次课程的核心
   转型——从"逐行教命令"转向"配好 skills、让 agent 干活、人来检查"。

## 快速开始

```bash
git clone https://github.com/lianxhcn/PXa2026a.git
cd PXa2026a
quarto preview        # 本地预览；或 quarto render 生成 docs/
```

安装并启用 skills（跨 agent 同一套源）：

```powershell
# Windows
scripts/setup-skills.ps1
```

```bash
# macOS / Linux
bash scripts/setup-skills.sh
```

详见站内「[AI 工作流与 skills 上手](https://lianxhcn.github.io/PXa2026a/skills-guide.html)」页。

## 目录结构

```
PXa2026a/
├── index.qmd / syllabus.qmd / settings.qmd / skills-guide.qmd
├── lectures/   # 六讲讲义
├── appendix/   # 提示词模板 · skills 索引 · 数据集 · 阅读清单 · FAQ · 扩展案例
├── skills/     # skills 唯一权威来源：core/ + extra/ + README.md
├── scripts/    # setup-skills.ps1 / .sh · validate-skills.py
├── data/  examples/  images/
└── docs/       # render 输出，GitHub Pages 发布源
```

## 许可

本仓库采用**双许可**：

- **正文**（讲义文字、图表、课程内容）：[CC BY-NC 4.0](LICENSE)（署名—非商业性使用）；
- **代码与 skills**（`skills/`、`scripts/`、`examples/`、`data/` 中的可执行部分）：
  [MIT](LICENSE-CODE)。

主案例 Lane (2025, QJE) 与扩展案例 Akcigit et al. (2022, QJE) 的复现数据来自
Harvard Dataverse，本仓库**不再分发原始数据包**，只提供下载脚本与复现指引；请遵守
原始数据的许可条款。

## 关于连享会

连享会由中山大学连玉君老师团队维护，长期分享 Stata 应用与实证研究经验。
主页：<https://www.lianxh.cn>。
