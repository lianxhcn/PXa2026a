# 质量记录：截至 2026-07-23

## 已检查的内容

- 上游正文核心脚本、对应 R 图形或表格脚本及其 SHA-256 清单。
- 本地 Stata 19.5 路径与外部命令依赖。
- F02 的两份输入数据、四个官方 `xtdidregress` 规格、预趋势诊断与两张最终图。

## 已生成的结果

- `output/figures/F02__official_trends__stata.pdf`：处理组与对照组趋势图。
- `output/figures/F02__official_events__stata.pdf`：动态 DID 系数与置信区间。
- `data/intermediate/F02__official_pretrend_diagnostics.csv`：四个规格的样本量和
  处理前趋势联合检验。
- `logs/F02__official_graphs__from-upstream.log` 与
  `logs/F02__combine__official_graphs.log`：可检查的 Stata 运行记录。

## 核对结论与边界

- 四个预趋势联合检验的 `p` 值均大于 0.38；这与事件图中政策前系数接近零的
  情形一致，但不能单独证明平行趋势。
- 已目视检查两张 PNG 预览：坐标轴、标题、系数点和置信区间完整可读。
- 原作者的 R 图形代码未运行；当前图形验证核心估计，不复制 R 图的逐像素样式。
- `gph2xl` 缺失，因此依赖它导出图形数据的路径忠实版本仍未运行。
- `F03`、`F04` 与 `T05` 尚未执行；T02--T04 仅完成下述核心版。

## F05 政策资本图

- 已运行 5 位行业面板的五个 `reghdfe` 动态 DID 规格，并生成
  `output/figures/F05__core_policy__stata.pdf`。
- 已目视检查 PNG：点估计、置信区间、1972 年基期和 1979 年标线清晰可读。
- 五项预趋势联合检验的 `p` 值在 0.338--0.734 之间；这支持但不证明平行趋势。
- `F03`、`F04` 与 `T05` 尚未执行；T02--T04 仍只完成 `l_ship` 核心版。

## T02T04 核心版

- 已运行 `l_ship` 的 DRIPW 和回归调整 CSDID，覆盖 4 位和 5 位行业面板。
- 4 个平均效应均已输出到
  `output/tables/T02T04__core_csdid__att.csv`；详细事件期结果保存在
  `data/intermediate/T02T04__core_csdid__raw_results.csv`。
- 该版本使用 999 次自助法，因此适合核对核心点估计和程序路径；不能代替
  原作者 10,000 次自助法的最终推断。
- `F03`、`F04` 与 `T05` 尚未执行；完整的 T02--T04 其余结果也尚未执行。
- 两期 `drdid` 教学示例已成功运行；其默认 `drimp` 设定已在脚本与讲义中注明。
