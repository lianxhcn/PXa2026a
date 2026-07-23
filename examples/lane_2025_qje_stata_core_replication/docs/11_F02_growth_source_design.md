# F02：核心增长事件研究的来源拆解

## 1. 对应关系

- 上游 Stata：`code/0_analysis/1_main_scripts/1_run_growth_analysis.do`。
- 上游 R：`code/1_figures/Figure2.R`。
- 本地目标：重现核心产出动态效应，并用 Stata 代替 R 绘制 Figure 2。

## 2. 上游估计设定

上游脚本分别使用 5 位和 4 位 KSIC 行业面板：

| 面板 | 上游输入文件 | 上游输出前缀 |
|---|---|---|
| 五位行业 | `data/input/mms_merged_harmonized_panel_cleaned4reg_5digit.dta` | `did_largerolling_mainresults_alloutput` |
| 四位行业 | `data/input/mms_merged_harmonized_panel_cleaned4reg_4digit.dta` | `did_largerolling_mainresults_alloutput_4d` |

处理变量在上游脚本中定义为：

$$
treat_{it}=1\{hci_i=1,\; year_t\geq 1973\}.
$$

核心结果图使用的因变量是 `l_ship`。上游也估计 `l_grossoutput` 和
`l_valueadded`，但它们不进入 Figure 2。每个因变量均估计无控制变量和
加入预处理行业特征与年份交互项的版本。控制变量为：

```stata
c.(l_costs_0 l_avg_size_0 l_avg_wages_0 l_y_n_0)#i.year
```

上游的忠实复现估计量为 Stata 官方 `xtdidregress`：

```stata
xtdidregress (l_ship controls) (treat), ///
    group(id) time(year) vce(cluster id)
```

随后依次调用：

1. `estat trendplots, ltrends noxline`：生成处理组和非处理组的拟合趋势；
2. `estat ptrends`：检验处理前趋势；
3. `estat grangerplot, baseline(1972) verbose post`：生成以 1972 年为基期的
   动态系数；
4. `gph2xl`：把 Stata 图形数据导出给上游 R 脚本。

## 3. 上游 R 的功能

`Figure2.R` 不重新估计模型，只读取两个 `*_all_results.csv` 文件。

- 顶行：按 HCI 组别绘制拟合的平均对数产出趋势；
- 底行：绘制 `xtdidregress` 动态系数及其置信区间；
- 左列：五位行业面板；右列：四位行业面板；
- 两张图均标出 1972 年和 1979 年的竖线；
- 最终将四个子图组合为 Figure 2。

## 4. 本地 Stata 移植设计

本地脚本分成四个层次：

1. `F02__est__from-do-1_run_growth_analysis.do`：路径忠实移植，保留上游
   `gph2xl` 环节，作为来源追踪文件；因本机未安装 `gph2xl`，目前不运行。
2. `F02__official_graphs__from-do-1_run_growth_analysis.do`：当前执行版本。
   它沿用上游官方 `xtdidregress`，以 Stata 的 `estat` 命令直接保存趋势图和
   事件研究图，不依赖 R 或 `gph2xl`。
3. `F02__combine__official_graphs.do`：只合并第 2 步保存的图形。趋势图和
   动态效应图分别输出，保留完整标题与坐标轴。
4. `F02__csdid__from-do-1_run_growth_analysis.do`：保留相同面板和因变量，
   以 `csdid` 估计组别—时期 ATT，用于讲义与方法迁移，不称为逐字复现。

## 5. 核对清单

- 输入数据的观测数、`id`、`year` 与 `hci` 是否完整；
- `treat` 是否在目标行业且 1973 年及以后取 1；
- 五位和四位面板的样本量是否与上游相符；
- 1972 年的动态系数是否被设为基期；
- 置信区间、聚类层级和控制变量版本是否一致；
- Stata 图与上游 R 图的曲线、断点和事件期是否一致。

## 6. 当前状态

已完成官方 `xtdidregress` 的四个规格，且未执行 R。预趋势联合检验的
`p` 值分别为 0.384、0.449、0.726 与 0.868；因此在这些规格下不能拒绝
处理前趋势为零的原假设，但这不是平行趋势的证明。

正式图形为：

- `output/figures/F02__official_trends__stata.pdf`；
- `output/figures/F02__official_events__stata.pdf`。

原生 Stata 图用于验证曲线和动态效应。它不复制 `Figure2.R` 的逐像素版式，
也未加入 R 图中的两条政策年份竖线。
