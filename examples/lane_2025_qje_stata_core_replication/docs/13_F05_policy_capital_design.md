# F05：政策资本与投资动态效应

## 1. 对应关系

- 上游 Stata：`code/0_analysis/1_main_scripts/4_run_policy_analysis.do`。
- 上游 R：`code/1_figures/Figure5.R`。
- 本地 Stata：
  `code/stata_output_port/F05__core_policy_graphs__from-do-4_policy_analysis.do`。

原文 Figure 5 展示 5 位行业面板的五个资本与投资结果。因此本地复现保留该面板，
不执行原脚本中未进入 Figure 5 的 4 位行业补充规格。

## 2. 估计设定

对每个结果变量，原文和本地脚本均估计：

$$
Y_{it}=\sum_{t\ne 1972}\beta_t
\left(HCI_i\times 1\{year=t\}\right)+\mu_i+\lambda_t+\varepsilon_{it}.
$$

对应 Stata 命令为：

```stata
reghdfe y i.hci##ib(1972).year, ///
    absorb(id year) vce(cluster id)
```

行业固定效应为 `id`，年份固定效应为 `year`，标准误按行业聚类。1972 年是政策前
基期；图中的两条竖线分别标记 1972 年和 1979 年。

## 3. 已运行的结果

| 结果变量 | 观测数 | 处理前趋势联合检验 `p` 值 |
|---|---:|---:|
| `l_costs` | 4,726 | 0.491 |
| `l_m_n` | 4,719 | 0.734 |
| `l_inv_tot` | 4,713 | 0.597 |
| `l_i_n` | 4,696 | 0.338 |
| `l_stock_tot` | 4,220 | 0.713 |

五个规格都不能拒绝处理前系数联合为零的原假设。政策后，中间投入、总投资和资本存量
的系数明显转正；以全图的点估计看，资本存量和总投资的增长尤为清楚。处理前趋势检验
和事件图只能提供识别假设的支持性证据，不能单独证明平行趋势。

## 4. R→Stata 的替换

上游 R 脚本读取 Stata 的 `regsave` CSV，再用 `ggplot2` 绘制误差棒、系数点、
1972/1979 年标线并组合五个子图。本地脚本直接从 `regsave` 结果提取
`hci × year` 系数，用 Stata 的 `rcap`、`scatter` 和 `graph combine` 完成同一工作。

图形验证估计结果和动态轨迹，不追求与 R 的字体、配色或间距逐像素相同。

## 5. 输出位置

- 图形：`output/figures/F05__core_policy__stata.pdf`。
- 可检查 PNG：`output/figures/F05__core_policy__stata.png`。
- 动态系数：`data/intermediate/F05__core_policy_event_results.csv`。
- 预趋势诊断：
  `data/intermediate/F05__core_policy_pretrend_diagnostics.csv`。
- Stata 日志：`logs/F05__core_policy_graphs.log`。
