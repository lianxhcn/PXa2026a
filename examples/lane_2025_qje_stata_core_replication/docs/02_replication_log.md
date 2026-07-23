# 复现日志

## 2026-07-22：工作区初始化

- 建立独立工作区，位置为
  `D:/github_lianxh/PXa2026a/examples/lane_2025_qje_stata_core_replication/`。
- 原作者源包保持只读，位置为 `D:/github_lianxh/PXa2026a/examples/Lane_2025_QJE_paper_codes/replicationpackage/`。
- 记录正文核心脚本与 R 输出脚本的 SHA-256 哈希，见 `source_audit/upstream_manifest.tsv`。
- 未运行论文估计、R 脚本或绘图代码。
- 启动过本地 Stata 依赖检查，但命令未在 64 秒内返回，且未生成日志；
  未终止系统中已有的 Stata 进程，以免影响用户正在进行的工作。

## 2026-07-23：工作区迁移与 F02 官方估计

- 用户指定的工作区现为
  `D:/github_lianxh/PXa2026a/examples/lane_2025_qje_stata_core_replication/`。
  原工作区文件已复制并逐文件核对；旧副本因系统文件锁暂时保留，不再使用。
- 本机 Stata 19.5 可由 `$env:STATA_EXE` 调用。`reghdfe`、`ppmlhdfe`、
  `csdid`、`drdid`、`binscatter`、`estout`、`regsave`、`erepost` 与 `estfe`
  可用；`gph2xl` 不可用。
- 已运行
  `code/stata_output_port/F02__official_graphs__from-do-1_run_growth_analysis.do`。
  它只读取上游的 4 位、5 位行业数据，所有输出写入本工作区。
- 已运行 `code/stata_output_port/F02__combine__official_graphs.do`，得到独立的
  趋势图和事件研究图。R 脚本未运行。

| 日期 | 模块 | 命令或脚本 | 输入 | 输出 | 核对结果 | 问题与处理 |
|---|---|---|---|---|---|---|
| 2026-07-23 | F02 | `F02__official_graphs__from-do-1_run_growth_analysis.do` | 4 位、5 位行业面板 | 四个 `xtdidregress` 规格与预趋势 CSV | 观测数依次为 4,721、4,046、1,751、1,711；预趋势 `p` 值均大于 0.38 | 未使用 R，也未依赖 `gph2xl`。 |
| 2026-07-23 | F02 | `F02__combine__official_graphs.do` | 已保存的 `.gph` 图形 | 两张 PDF、PNG 与 GPH 图形 | 趋势图、事件研究图均已人工检查，标题与置信区间可读 | 图形采用 Stata 官方默认样式，不追求 R 图的逐像素版式。 |
| 2026-07-23 | T02T04 核心版 | `T02T04__core_csdid__from-do-3b_doublerobust.do` | 4 位、5 位行业面板 | `l_ship` 的 DRIPW 与回归调整 ATT | DRIPW ATT 为 0.838 和 0.592 | 自助法为 999 次，不是原作者的 10,000 次完整批处理。 |
| 2026-07-23 | `drdid` 教学 | `T02T04__drdid_two_period_demo.do` | 5 位行业的 1972、1979 两期样本 | 两期双重稳健 ATET 表 | ATET 为 1.131，标准误为 0.244 | 本机默认使用 `drimp`；该示例不是原文主结果。 |
| 2026-07-23 | F05 | `F05__core_policy_graphs__from-do-4_policy_analysis.do` | 5 位行业政策面板 | 5 个动态 DID 规格和政策资本图 | 五项预趋势 `p` 值都大于 0.33，图形已人工检查 | 仅运行进入原文 Figure 5 的 5 位行业面板；未运行 R。 |

## 后续记录格式

| 日期 | 模块 | 命令或脚本 | 输入 | 输出 | 核对结果 | 问题与处理 |
|---|---|---|---|---|---|---|
| YYYY-MM-DD | F02 | `...` | `...` | `...` | `...` | `...` |
