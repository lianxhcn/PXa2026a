# 项目范围与执行顺序

## 1. 目标

本项目有两个并行目标：

1. 用 Stata 复现 Lane (2025, QJE) 的正文核心结果，优先核对政策冲击后的动态 DID 和政策效果图。
2. 将论文的识别策略改写为初学者可理解、可迁移到其他面板数据的 `reghdfe`、`csdid` 和 `drdid` 模板。

## 2. 本轮纳入内容

| ID | 原作者 Stata 分析 | 原作者 R 输出 | 本轮目标 |
|---|---|---|---|
| F02 | `1_run_growth_analysis.do` | `Figure2.R` | 重现核心产出/增长动态效应图。 |
| F03 | `2a_run_devoutcomes_analysis.do`、`2b_run_koreatrade_analysis.do` | `Figure3.R` | 重现生产率与韩国贸易结果。 |
| T02T04 | `3b_run_doublerobust_analysis.do` | `Table2-4.R` | 复现双重稳健 DID 的主要表格，并形成 `csdid` / `drdid` 讲义示例。 |
| F04 | `3c_run_worldtrade_analysis.do` | `Figure4.R` | 重现世界贸易结果图。 |
| F05 | `4_run_policy_analysis.do` | `Figure5.R` | 重现政策资本或投资效应图。 |
| T05 | `5a_run_mechanisms_lbd_analysis.do` | `Table5.R` | 重现行业层面的学习效应机制表。 |

## 3. 本轮不纳入内容

- 正文 Figure 1：背景图，不是核心 DID 结果。
- Figure 6--7、Table 7--8：产业关联扩展，后续按需要加入。
- 全部附录和补充附录。
- 依赖 `data/input/mms_TFP_micro.dta` 的工厂微观数据模块；该受限数据不在上游源包中。

## 4. 执行次序

1. 审计上游文件及本机依赖，建立可追溯来源映射。
2. 从 F02 开始，在本工作区输出中间结果和 Stata 图形。
3. 依次完成 F03、T02T04、F04、F05 和 T05。
4. 对每个结果核对样本、处理定义、事件期、固定效应、聚类方式、系数和置信区间。
5. 在结果稳定后，再将核心估计改写为可迁移的 `reghdfe`、`csdid`、`drdid` 版本。

## 5. 成功标准

- 原作者源包未产生任何新文件或修改。
- 所有本地脚本均能说明其来源和输出位置。
- Stata 图表包含与上游 R 图一致的核心系数、事件期和置信区间；字体、颜色和排版可合理不同。
- 方法改写版明确区分“忠实复现”与“为迁移而重写”，不把二者混为一谈。
