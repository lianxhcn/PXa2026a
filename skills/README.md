# skills 工具箱

本目录是课程 skills 的**唯一权威来源**（开放 Agent Skills 格式，agent 无关）。`.claude/skills/`
与 `.agents/skills/` 只是各 agent 的发现入口，由 `scripts/setup-skills.*` 本地生成，不入库。

面向学员的完整介绍见在线书「[AI 工作流与 skills 上手](https://lianxhcn.github.io/PXa2026a/skills-guide.html)」。

## 安装三步

```text
① 克隆仓库           git clone https://github.com/lianxhcn/PXa2026a.git
② 生成调用入口       scripts/setup-skills.ps1   （macOS/Linux：bash scripts/setup-skills.sh）
③ 30 秒冒烟测试       启动 agent，让它复述某个 skill 的用途
```

生成入口时取去掉 `NN-` 序号的干净名（例如 `core/03-replication-navigator` → 入口
`replication-navigator`）。

## 分层

- **`core/`**（课程必备，目标 5±2 个）：三天课堂上每个都会现场用到至少一次；
- **`extra/`**（进阶自选）：课后按需探索，衔接高级班与论文班。

## core 清单

| skill | 用途 | 主战场 |
|---|---|---|
| `core/01-paper-context` | 研究背景/贡献/文献定位 →「背景卡」 | 第 1 讲 |
| `core/02-paper-strategy` | P-S-D-M-I 五层拆解 →「策略卡」 | 第 1、3 讲 |
| `core/03-replication-navigator` | README → 复现路线图、主程序调用 | 第 1、6 讲 |
| `core/04-data-cleaning-planner` | 清洗计划、merge 检查、EDA 建议 | 第 2 讲 |
| `core/05-regression-interpreter` | 回归表解读、因果表述检查 | 第 4、5 讲 |
| `core/06-repro-logger` | 复现日志、变量字典、样本筛选日志 | 第 1、2、6 讲 |
| `core/07-stata-runner`（引用型） | 让 agent 本地运行 Stata（Stata All in One 附带） | 全程 |

> `01`–`06` 由写作窗口随章自研，`07-stata-runner`（引用型）与 setup 脚本由基建窗口维护。
> 入库前须通过 `scripts/validate-skills.py`，并在 Claude Code 与 Codex 双端测试自动触发、
> 显式调用与执行结果三项。

## 每个 skill 的规范

- `SKILL.md` 的 YAML 头**只写 `name` 与 `description`**；`description` 写清触发场景、边界与
  关键触发词；
- 正文含固定小节：「何时用」「输入输出约定」「最小使用示例」「来源与许可」；
- 可选子目录：`scripts/`（可执行脚本）、`references/`（方法说明与检查标准）、`assets/`
  （模板与静态资源）；
- agent 专属增量放 `adapters/<agent>/`，不写进公共 SKILL.md。
