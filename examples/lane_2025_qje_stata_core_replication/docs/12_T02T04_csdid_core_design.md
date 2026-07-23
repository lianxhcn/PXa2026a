# T02--T04：双重稳健 DID 核心版

## 1. 来源与范围

- 上游 Stata：`code/0_analysis/1_main_scripts/3b_run_doublerobust_analysis.do`。
- 上游 R：`code/2_tables/Table2-4.R`。它只读取 Stata 生成的 CSV，并排版为
  LaTeX 表格，不重新估计。
- 当前本地脚本：
  `code/method_rewrite/T02T04__core_csdid__from-do-3b_doublerobust.do`。

该脚本只复现最核心的结果：因变量为 `l_ship`，比较 4 位和 5 位行业面板，
并列报告 DRIPW 与回归调整 DID。它不替代原作者对多个产出、投资和贸易变量的
完整 Table 2--4 批处理。

## 2. 与上游设定的关系

处理组的首次受处理年份为：

$$
g_i=
\begin{cases}
1973, & hci_i=1 \\
0, & hci_i=0
\end{cases}
$$

上游对每个结果变量使用：

```stata
csdid y controls, ///
    time(year) ivar(id) gvar(gvar) ///
    method(dripw) wboot reps(10000) agg(event)
```

本地核心版保留面板、`gvar`、控制变量、`dripw` 与 `agg(event)`，但将自助法改为
999 次并设定随机种子 `20260723`。这样适合先核对估计逻辑和结果结构；正式逐字
复现时应将重复次数恢复为 10,000。

所有行业在同一年开始处理，因此这里的 `csdid` 可以理解为带有双重稳健结果模型和
处理模型的 DID 实现。将来迁移到分期实施政策时，`csdid` 的分组—时期 ATT 框架会
更加关键。

## 3. 已运行的平均处理效应

| 面板 | 估计量 | ATT | 标准误 | 常规近似 `p` 值 | 999 次自助法 |
|---|---:|---:|---:|---:|---:|
| 5 位行业 | DRIPW | 0.838 | 0.169 | < 0.001 | 是 |
| 5 位行业 | 回归调整 | 0.823 | 0.185 | < 0.001 | 否 |
| 4 位行业 | DRIPW | 0.592 | 0.212 | 0.005 | 是 |
| 4 位行业 | 回归调整 | 0.545 | 0.222 | 0.014 | 否 |

系数以对数发货额计。它们表明，处理组在政策后相对未处理行业的平均发货额增长显著
更快。对数系数转为百分比时，应使用 $\exp(\hat\beta)-1$，并结合估计方差说明近似方式。

## 4. 推断字段如何读取

`output/tables/T02T04__core_csdid__att.csv` 中的 `normal_approx_p`、
`normal_ci_lower` 和 `normal_ci_upper` 是 `regsave` 根据系数和标准误整理的
常规近似字段。它们方便与上游 CSV 的结构对照，但不应表述为 wild-bootstrap
百分位置信区间。

`csdid` 在运行日志中直接显示的 DRIPW 置信区间使用自助法。正式报告双重稳健
结果时，应优先核对该日志，或在完整 10,000 次版本中显式导出相应的 bootstrap
推断结果。

## 5. 输出位置

- 汇总 ATT：`output/tables/T02T04__core_csdid__att.csv`。
- 完整事件期结果：
  `data/intermediate/T02T04__core_csdid__raw_results.csv`。
- 运行日志：`logs/T02T04__core_csdid.log`。

## 6. 两期 `drdid` 教学对照

`code/method_rewrite/T02T04__drdid_two_period_demo.do` 已用 1972 年和
1979 年的 5 位行业面板运行。它得到 ATET = 1.131，标准误为 0.244，样本量为
476。这个结果只说明两期双重稳健命令在本机可运行，不能与包含完整政策动态的
`csdid` ATT 逐项比较。

本机 `drdid` 默认选择 `drimp`，不接受 `csdid` 风格的 `method(dripw)` 选项。
示例输出位于 `output/tables/T02T04__drdid__1972_1979_demo.csv`。
