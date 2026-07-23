# 本地改动记录

## 规则

- 上游源包不做任何修改。
- 每一次本地改写均记录上游来源、改写原因、估计影响和输出影响。
- `path_port` 只调整路径、日志和输出位置，不改变估计设定。
- `r_to_stata_output_port` 只替换 R 的作图或排表过程，不重新估计模型。
- `method_rewrite` 使用 `reghdfe`、`csdid` 或 `drdid` 重新实现，必须单独验证并说明与上游方法的关系。

## 2026-07-22：初始化

- 新建独立工作区和来源映射文件。
- 未复制、修改或执行任何上游文件。
- 新建本地 `00_setup_local.do` 与 `01_check_stata_dependencies.do`；二者仅在
  本工作区写入日志，不调用上游总控脚本。

## 2026-07-23：工作区迁移、依赖检查与 F02

- 按用户指定，将工作区切换到
  `D:/github_lianxh/PXa2026a/examples/lane_2025_qje_stata_core_replication/`。
  已逐文件核对复制结果；上游源包未写入。
- 运行本地依赖检查。除 `gph2xl` 外，F02 及后续计划需要的 Stata 外部命令
  均可调用。
- 新增 `F02__official_graphs__from-do-1_run_growth_analysis.do`：保留上游
  `xtdidregress` 的样本、处理定义、控制变量和聚类层级，改为直接保存原生
  Stata 图形。估计影响为无；输出影响为不再生成给 R 使用的 CSV。
- 新增 `F02__combine__official_graphs.do`：只合并本地 `.gph` 图形。趋势图与
  事件研究图分开输出，避免缩小后标题重叠。估计影响为无。
- 保留 `F02__est__from-do-1_run_growth_analysis.do` 与
  `F02__plot__from-r-Figure2.R.do` 作为来源追踪文件；它们需要 `gph2xl`，
  当前不执行。

## 2026-07-23：T02T04 双重稳健核心版

- 新增并运行 `T02T04__core_csdid__from-do-3b_doublerobust.do`。它保留上游
  `csdid` 的样本、首次处理年份、控制变量、DRIPW 与回归调整估计量。
- 改写范围缩小为 `l_ship` 和 4 位、5 位面板；不运行上游的全部多结果变量循环。
- 上游的 `wboot reps(10000)` 改为 `reps(999)`，并固定随机种子。点估计的
  定义不变；bootstrap 推断的精度和最终区间不能视为逐字复现。
- 本地 ATT 表把 `regsave` 整理的常规近似推断字段明确命名，避免与日志中的
  wild-bootstrap 置信区间混淆。
- 新增并运行 `T02T04__drdid_two_period_demo.do`，验证本机 `drdid` 的两期
  语法。该命令默认选择 `drimp`；它是教学对照，不对应上游完整动态结果。

## 2026-07-23：F05 政策资本图

- 新增并运行 `F05__core_policy_graphs__from-do-4_policy_analysis.do`。它保留
  上游 Figure 5 的 5 位行业数据、五个结果变量、`reghdfe` 设定、1972 年基期、
  行业和年份固定效应及行业聚类标准误。
- R 的 `ggplot2` 和 `ggarrange` 步骤改为 Stata 的 `rcap`、`scatter` 与
  `graph combine`。估计影响为无；图形版式不同。
- 未运行原上游脚本的 4 位行业政策补充规格，因为它们不进入 Figure 5。
