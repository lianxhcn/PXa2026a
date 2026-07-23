# DID、csdid 与 drdid：从 Lane (2025) 的复现到迁移

## 1. 先看论文里的研究设计

论文以行业 $i$ 和年份 $t$ 构成面板。`hci=1` 表示行业属于政策扶持组；
1973 年是政策启动年。最简单的处理变量为：

$$
D_{it}=1\{hci_i=1,\;t\geq 1973\}.
$$

F02 关注处理行业的产出动态，F05 关注投资和资本存量动态，T02--T04 则用双重稳健
方法汇总政策后的平均效应。对自己的论文，先把这四件事写清楚：

- 谁是处理组，谁是从未处理的对照组；
- 政策何时生效，是否分批实施；
- 因变量是水平、对数还是比例；
- 面板单位和政策冲击分别处于什么层级。

## 2. 2×2 DID 到双向固定效应

最基础的 DID 是处理组与对照组在政策前后的变化差：

$$
\widehat{DID}=\left(\bar Y_{T,post}-\bar Y_{T,pre}\right)
-\left(\bar Y_{C,post}-\bar Y_{C,pre}\right).
$$

写成面板回归后：

$$
Y_{it}=\alpha_i+\lambda_t+\beta D_{it}+\varepsilon_{it}.
$$

`\alpha_i` 控制行业不随时间变化的差异，`\lambda_t` 控制所有行业共同经历的年份冲击。
`\beta` 就是政策后处理组相对对照组的额外变化。

一个最小的 Stata 写法是：

```stata
gen post = year >= 1973
reghdfe l_ship i.hci##i.post, ///
    absorb(id year) vce(cluster id)
```

在有 `id` 和 `year` 固定效应时，`hci` 与 `post` 的主效应会被吸收；重点看
`1.hci#1.post` 的系数。标准误应按处理分配层级聚类。本项目按行业 `id` 聚类。

识别依赖的核心是平行趋势：若没有政策，处理组与对照组的平均结果变化应当相同。
它还要求政策前不存在系统性的预期反应，并且处理组的政策不会通过竞争、供应链等
渠道强烈改变对照组结果。事件研究图和制度背景可以支持这些假设，但不能证明它们。

## 3. 用 `reghdfe` 做动态 DID 图

要观察每一年相对基期的效应，可估计：

$$
Y_{it}=\alpha_i+\lambda_t+
\sum_{k\ne 1972}\beta_k
\left(hci_i\times1\{year_t=k\}\right)+\varepsilon_{it}.
$$

对应命令为：

```stata
reghdfe l_inv_tot i.hci##ib(1972).year, ///
    absorb(id year) vce(cluster id)
```

这里的 `ib(1972)` 把 1972 年固定为零点。`1.hci#1979.year` 的系数表示：1979 年
处理组相对对照组的变化，减去 1972 年处理组相对对照组的变化。

F05 使用的正是这一思路。复现脚本
`code/stata_output_port/F05__core_policy_graphs__from-do-4_policy_analysis.do`
把每年的系数和 95% 置信区间画成点图。图中应重点看：

- 1972 年之前的系数是否围绕零，没有同向的大幅偏离；
- 1973 年之后的系数何时变为正，是否持续；
- 置信区间是否穿过零；
- 1979 年之后的变化是否与制度阶段转换相一致。

处理前系数可联合检验。例如处理前只有 1970、1971 两年时：

```stata
test 1.hci#1970.year 1.hci#1971.year
```

联合检验的 `p` 值较大只表示样本没有拒绝零预趋势，不能解释为“已经证实平行趋势”。

## 4. `xtdidregress` 在 F02 中做什么

论文 F02 使用 Stata 官方 `xtdidregress`，并调用官方后估计命令生成趋势和动态图：

```stata
xtset id year
gen treat = hci == 1 & year >= 1973

xtdidregress (l_ship) (treat), ///
    group(id) time(year) vce(cluster id)

estat trendplots, ltrends noxline
estat ptrends
estat grangerplot, baseline(1972) verbose post
```

本地的 `F02__official_*` 文件就是这条路线的可运行版本。`estat ptrends` 给出处理前
趋势检验，`estat grangerplot` 给出相对 1972 年的动态系数。

`xtdidregress` 的线性趋势模型与上一节完全灵活的 `reghdfe` 年份交互式不同。两者回答
的是相近但不完全相同的问题。复现原文主结果时先保留作者的官方估计量；迁移到自己的
研究时，再根据政策时点、样本结构和识别假设选择灵活事件研究或其他估计量。

## 5. 为什么还要用 `csdid`

传统 TWFE 在行业分批受政策影响时可能把“已经处理”的行业错误地当作“尚未处理”行业的
对照组，并产生难以解释的权重。`csdid` 先估计组别—时期处理效应 $ATT(g,t)$，再按清楚
的规则聚合，适合分期实施政策。

论文中所有处理行业都在 1973 年进入处理，因此只有一个处理批次。此时 `csdid` 仍可
作为双重稳健 DID 的实现：它用从未处理行业作对照，并报告政策前后的聚合效应。

处理批次变量必须这样构造：从未处理组取 0，处理组取其首次处理年份。

```stata
gen gvar = 0
replace gvar = 1973 if hci == 1

csdid l_ship l_costs_0 l_avg_size_0 l_avg_wages_0 l_y_n_0, ///
    time(year) ivar(id) gvar(gvar) ///
    method(dripw) wboot reps(10000) agg(event)
```

`ivar(id)` 是行业编号，`time(year)` 是时间变量，`gvar(gvar)` 是首次处理年。
`agg(event)` 把 $ATT(g,t)$ 按相对处理时间聚合，得到事件研究结果。完整复现时应保留
原文的 10,000 次自助法；本项目的核心运行版先用 999 次，目的是快速核对程序和点估计。

## 6. 双重稳健的含义与边界

`method(dripw)` 同时使用两类模型：

- 结果模型：给定协变量后，未处理状态下 $Y$ 如何变化；
- 处理模型：给定协变量后，行业进入处理组的概率如何变化。

在常规的双重稳健条件下，只要两者中至少有一个正确设定，处理效应估计仍可一致。这不
意味着可以随意选择控制变量或忽略共同支持。若结果模型和处理模型都错，双重稳健也会
失效；若处理组和对照组的协变量几乎不重叠，任何加权方法都会不稳定。

本地核心版的 ATT 文件为
`output/tables/T02T04__core_csdid__att.csv`。其中 5 位行业的 DRIPW 平均效应为
0.838，4 位行业为 0.592，均针对 `l_ship`。对数系数转为百分比时可用：

$$
100\times\left[\exp(\hat\beta)-1\right].
$$

这个变换给出条件均值在对数模型下的常用近似解释；正式报告时还应说明是否做了方差
校正。该 ATT CSV 中 `normal_approx_*` 字段来自 `regsave` 的常规近似整理，不应称为
wild-bootstrap 百分位置信区间。DRIPW 的自助法输出应以 Stata 运行日志为准。

## 7. `drdid` 适合什么问题

`drdid` 是两期、两组 DID 的双重稳健工具。若只比较一个明确的政策前期和一个明确的
政策后期，可以把数据保留为两期面板：

```stata
keep if inlist(year, 1972, 1979)
drdid l_ship l_costs_0 l_avg_size_0 l_avg_wages_0 l_y_n_0, ///
    ivar(id) time(year) tr(hci)
```

这里 `tr(hci)` 是是否属于处理组，`time(year)` 只有一个政策前期和一个政策后期。
本机的 `drdid` 版本使用默认的 `drimp` 估计量，不接受 `csdid` 的
`method(dripw)` 选项。它们都属于双重稳健 DID，但不是同一个命令选项。
这段代码是两期模板；使用前应以本机 `help drdid` 核对当前版本的可选项。若政策有多个
处理批次或你关心完整动态路径，应优先用 `csdid`；若只关心动态 TWFE 系数图，则
`reghdfe` 更直观。

## 8. 迁移到自己的论文：一份操作顺序

1. 检查 `id`—`year` 是否唯一，处理时点是否确实在每个行业内单调。
2. 先画处理组和对照组的原始均值趋势，再做事件研究图。
3. 对同期统一实施政策，用 `reghdfe` 做透明的基准和动态图。
4. 对分期政策，用 `csdid` 报告 $ATT(g,t)$、事件时间聚合和整体 ATT。
5. 只有一个前后比较时，才考虑用 `drdid` 做 2×2 双重稳健估计。
6. 聚类层级应与政策分配和误差相关结构一致；处理组很少时，常规聚类推断可能不可靠。
7. 报告基期、处理组定义、控制变量、样本筛选、预趋势检验和置信区间的构造方式。

## 9. 常见错误

- 把从未处理组的 `gvar` 写成缺失值。`csdid` 通常需要它取 0。
- 把政策发生年同时当作基期和处理后期。应明确参照年，并核对事件时间定义。
- 用 `reghdfe` 的 TWFE 系数解释分期政策的平均效应，却没有检查负权重问题。
- 只看单个处理前系数，不做联合检验，也不解释制度背景。
- 把 `regsave` 整理的普通置信区间误写成 bootstrap 区间。
- 从对数系数直接说“增长了 $\beta\%$”。应使用指数变换并说明解释口径。

## 10. 本项目中该从哪里开始

先运行 `code/00_setup_local.do`，再按以下顺序阅读和执行：

1. `code/stata_output_port/F02__official_graphs__from-do-1_run_growth_analysis.do`；
2. `code/stata_output_port/F05__core_policy_graphs__from-do-4_policy_analysis.do`；
3. `code/method_rewrite/T02T04__core_csdid__from-do-3b_doublerobust.do`。

运行后的重点文件是 F02、F05 的 PDF 图，以及 T02T04 的 ATT CSV。具体结果、
源文件对应关系和本地改写边界见 `docs/11_F02_growth_source_design.md`、
`docs/12_T02T04_csdid_core_design.md` 与 `docs/13_F05_policy_capital_design.md`。
