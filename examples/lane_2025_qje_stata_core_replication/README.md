# Lane (2025, QJE)：Stata 核心结果复现与方法迁移

本工作区用于复现 *Manufacturing Revolutions: Industrial Policy and Industrialization in South Korea* 的正文核心结果，并将其中的 DID 思路整理为可迁移的 Stata 教学材料。

## 工作边界

- 上游源包为 `D:/github_lianxh/PXa2026a/examples/Lane_2025_QJE_paper_codes/replicationpackage/`。
- 上游源包只读：不修改其 `config.yml`、`code/`、`data/`、`log/` 或 `output/`。
- 本工作区的脚本只从上游读取数据和代码；所有日志、中间结果、图表和表格只写入本工作区。
- 当前范围为正文的 Figure 2--5、Table 2--5 及其估计逻辑；不运行附录、补充附录和缺失工厂微观数据的模块。

## 目录说明

- `docs/`：复现范围、来源映射、运行日志、结果核对和 DID 讲义。
- `source_audit/`：上游文件清单、SHA-256 哈希和本地改动记录。
- `code/replication_port/`：尽量忠实于原作者 Stata 逻辑的本地移植代码。
- `code/stata_output_port/`：将原作者 R 作图与排表逻辑改写为 Stata 的代码。
- `code/method_rewrite/`：以 `reghdfe`、`csdid` 和 `drdid` 编写的教学化、可迁移版本。
- `data/intermediate/`、`output/`、`logs/`：本工作区的运行产物，不回写上游源包。

## 运行原则

1. 先运行 `code/00_setup_local.do`，由它检查上游源包和本工作区路径。
2. 不在上游源包的工作目录中执行任何会生成文件的脚本。
3. 每个新增脚本的开头必须说明其上游 `.do` / `.R` 来源、改写类型、输入和输出位置。
4. 每次重跑后，将命令、输出和与原文的差异补充到 `docs/02_replication_log.md`。

## 当前状态

- 工作区、来源审计文件与本地 Stata 环境检查已完成。
- 已完成 `F02` 的四个官方 `xtdidregress` 规格，并输出趋势图、
  事件研究图和预趋势诊断；全程未运行 R。
- 已完成 `F05` 的 5 位行业政策资本动态 DID 与原生 Stata 图。
- `gph2xl` 未安装，但当前 `F02` 的原生 Stata 作图不依赖该命令。
- 已完成 `T02T04` 的 `l_ship` 双重稳健核心版；`F03`、`F04` 与 `T05` 及
  T02--T04 的其他结果仍未执行。
