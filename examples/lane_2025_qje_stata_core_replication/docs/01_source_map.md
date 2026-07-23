# 上游代码与本地 Stata 文件对应表

上游根目录固定为：

`D:/github_lianxh/PXa2026a/examples/Lane_2025_QJE_paper_codes/replicationpackage/`

本地文件名使用 `ID__用途__from-来源文件` 的结构。`replication_port` 表示尽量忠实移植；`stata_output_port` 表示仅把 R 输出改为 Stata；`method_rewrite` 表示为教学和迁移重新实现估计。

| ID | 上游 Stata 估计 | 上游 R 输出 | 计划本地文件 | 改写类型 | 预期本地输出 |
|---|---|---|---|---|---|
| F02 | `code/0_analysis/1_main_scripts/1_run_growth_analysis.do` | `code/1_figures/Figure2.R` | `replication_port/F02__est__from-do-1_run_growth_analysis.do`; `stata_output_port/F02__official_graphs__from-do-1_run_growth_analysis.do`; `stata_output_port/F02__combine__official_graphs.do`; `method_rewrite/F02__csdid__from-do-1_run_growth_analysis.do` | 忠实移植；原生 Stata 作图；方法重写 | 增长趋势、动态效应图与预趋势诊断。 |
| F03 | `2a_run_devoutcomes_analysis.do`; `2b_run_koreatrade_analysis.do` | `code/1_figures/Figure3.R` | `replication_port/F03__est__from-do-2a_devoutcomes__2b_koreatrade.do`; `stata_output_port/F03__plot__from-r-Figure3.R.do` | 忠实移植；R→Stata 作图 | 生产率与韩国贸易结果图。 |
| T02T04 | `code/0_analysis/1_main_scripts/3b_run_doublerobust_analysis.do` | `code/2_tables/Table2-4.R` | `replication_port/T02T04__est__from-do-3b_doublerobust.do`; `stata_output_port/T02T04__table__from-r-Table2-4.R.do`; `method_rewrite/T02T04__csdid-drdid__from-do-3b_doublerobust.do` | 忠实移植；R→Stata 排表；方法重写 | 双重稳健 ATT 结果与 Table 2--4 的 Stata 版本。 |
| F04 | `code/0_analysis/1_main_scripts/3c_run_worldtrade_analysis.do` | `code/1_figures/Figure4.R` | `replication_port/F04__est__from-do-3c_worldtrade.do`; `stata_output_port/F04__plot__from-r-Figure4.R.do` | 忠实移植；R→Stata 作图 | 世界贸易结果图。 |
| F05 | `code/0_analysis/1_main_scripts/4_run_policy_analysis.do` | `code/1_figures/Figure5.R` | `replication_port/F05__est__from-do-4_policy_analysis.do`; `stata_output_port/F05__plot__from-r-Figure5.R.do` | 忠实移植；R→Stata 作图 | 政策资本或投资效应图。 |
| T05 | `code/0_analysis/1_main_scripts/5a_run_mechanisms_lbd_analysis.do` | `code/2_tables/Table5.R` | `replication_port/T05__est__from-do-5a_mechanisms_lbd.do`; `stata_output_port/T05__table__from-r-Table5.R.do` | 忠实移植；R→Stata 排表 | 学习效应机制表。 |

`T02T04__core_csdid__from-do-3b_doublerobust.do` 已执行，但其范围仅为
`l_ship` 的核心版。完整 Table 2--4 的其余结果仍待运行。

`F05__core_policy_graphs__from-do-4_policy_analysis.do` 已执行。它复现原文
Figure 5 使用的 5 位行业规格，并以原生 Stata 图形替代 `Figure5.R`。

## 映射使用规则

1. 开始改写前，先检查 `source_audit/upstream_manifest.tsv` 中的 SHA-256 值；若哈希变化，先记录变化再改写。
2. 本地代码不得 `do` 上游脚本，以免其硬编码的输出路径写回源包；需要的逻辑将复制为本地脚本并在文件头中注明来源。
3. 每个本地输出文件沿用其 ID，例如 `output/figures/F02__from-r-Figure2__stata.pdf`。
4. `method_rewrite` 的结果只用于理解与迁移，须与 `replication_port` 的结果分开验证和解释。

## 已执行的 F02 映射

- `F02__est__from-do-1_run_growth_analysis.do` 是路径忠实移植，保留为
  来源追踪文件。它沿用上游的 `gph2xl` 导出环节；因本机未安装
  `gph2xl`，当前不执行。
- `F02__official_graphs__from-do-1_run_growth_analysis.do` 是当前执行版本。
  它保留上游的 `xtdidregress`、样本、处理变量、控制变量和聚类层级，直接
  使用 `estat trendplots`、`estat ptrends` 与 `estat grangerplot` 生成图形。
- `F02__combine__official_graphs.do` 只合并已保存的 Stata 图形，不重新估计。
  它输出趋势图和事件研究图各一张，避免把长标题缩小后重叠。
- 原计划的 `F02__plot__from-r-Figure2.R.do` 依赖 `gph2xl` 导出的 CSV，暂不
  执行。原生 Stata 图用于核对核心结果，版式不追求与 R 图逐像素一致。
