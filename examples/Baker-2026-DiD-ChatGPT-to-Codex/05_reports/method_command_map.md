# DID 方法与 Stata 命令对照

| 研究设计与目标参数 | 建议命令 | 比较对象与关键假设 | 容易误用的位置 |
|---|---|---|---|
| 标准 $2\times2$ 的 ATT | `summarize`、`collapse` | 处理组与未处理组；无预期效应、平行趋势 | 把四均值的权重当成无关紧要的精度设置 |
| 2x2 回归等价性 | `reg`、`xtreg, fe`、`reghdfe` | 平衡面板和固定权重下，交互项对应同一 ATT | 把这一等价性推广到分期处理 |
| 条件 2x2 ATT | `drdid` | 条件平行趋势与 overlap；协变量应在处理前确定 | 直接给 TWFE 加控制变量后宣称识别 ATT |
| 单 cohort 的动态 ATT | `csdid`、`estat event` | 一个处理 cohort 与合适未处理对照组 | 用处理前不显著替代平行趋势论证 |
| 分期处理的 $ATT(g,t)$ | `csdid` | never-treated 或 not-yet-treated 对照组 | 让 already-treated 单位充当对照、忽略聚合权重 |
| 平行趋势敏感性 | `honestdid` | 已估计 event-study 的系数与协方差矩阵 | 不核对 `pre()`、`post()` 与实际系数列位置 |

`csdid` 的 `ivar()`、`time()`、`gvar()` 分别是面板单位、日历时间和首次处理时间。`gvar=0` 在本例中表示 never-treated。`agg(event)` 或 `estat event` 的对象是按事件时间聚合后的效应，其参与聚合的 cohort 会随事件时间变化。

