# Baker et al. (2026) DID 学习与 Stata 复现任务书

## 1. 任务目标

请在本地完成 Baker et al. (2026) 的 Stata 复现、分模块学习和中文讲义撰写。使用者只掌握经典 $2\times2$ DID、`reghdfe` 和基础 Stata 操作，因此所有产出应服务于以下目标：

- 理解论文提出的「以 $2\times2$ DID 为构件」的分析框架。
- 掌握常见 DID 设计的目标参数、识别假设、对照组选择和 Stata 实现。
- 能够区分简单 TWFE、事件研究、条件 DID、交错处理 DID 和 HonestDiD 的适用边界。
- 获得一套可迁移到个人实证论文的 Stata 模板。
- 形成一份约 10-15 页、最多不超过 20 页的中文讲义。

核心原则：**先明确目标参数和识别假设，再选择估计命令；不得从熟悉的回归式反推研究设计。**

## 2. 项目位置与禁止事项

### 2.1 已有文件

项目根目录：

```text
D:\github_lianxh\PXa2026a\examples\Baker-2026-DiD-Guide--by-Lian
```

原作者仓库：

```text
D:\github_lianxh\PXa2026a\examples\Baker-2026-DiD-Guide--by-Lian\jel-did-main
```

论文 PDF 位于项目根目录。提示信息中的文件名与现有目录树可能存在大小写或连字符差异，请按文件内容和实际文件名自动定位，不要因文件名差异中止任务。

### 2.2 唯一工作目录

在项目根目录中新建：

```text
D:\github_lianxh\PXa2026a\examples\Baker-2026-DiD-Guide--by-Lian\Baker-2026-DiD-ChatGPT-to-Codex
```

后续产生的副本、代码、日志、表格、图形、讲义和报告必须全部位于该目录。不得在项目根目录或原作者仓库中新增、修改或删除文件。

### 2.3 严格限制

- 不得修改 `jel-did-main` 中的任何文件。
- 不得直接在 `jel-did-main` 中运行会写出表格、图形或临时文件的脚本。
- 不得执行 `git clean`、`git reset --hard`、批量删除或覆盖原始资料。
- 不得提交、推送或改写原作者仓库的 Git 历史。
- 不得把用户编写的中文讲义、改写代码或日志混入原作者仓库副本的源代码目录。
- 原则上不使用 R。只有在 Stata 结果无法核对、且 R 输出能帮助定位问题时，才可将 R 作为诊断工具，并在报告中明确说明。
- 不得把 Stata 扩展命令安装到系统级目录。应使用项目内的本地 `ado` 目录。

## 3. 建议目录结构

创建以下结构。目录名可小幅调整，但职责必须保持清楚。

```text
Baker-2026-DiD-ChatGPT-to-Codex/
|-- README.md
|-- 00_admin/
|   |-- task-status.md
|   |-- environment.md
|   |-- source-tree.txt
|   |-- source-checksums-before.txt
|   |-- source-checksums-after.txt
|   |-- package-manifest.md
|   +-- run-manifest.csv
|-- 01_source_snapshot/
|   |-- paper/
|   +-- JEL-DiD-original/
|-- 02_replication/
|   |-- JEL-DiD-working/
|   |-- wrapper/
|   |-- logs/
|   |-- reference-outputs/
|   +-- comparison/
|-- 03_learning_stata/
|   |-- ado/
|   |-- do/
|   |-- data/
|   |-- logs/
|   |-- tables/
|   |-- figures/
|   +-- temp/
|-- 04_docs/
|   |-- 01-reading-roadmap.md
|   |-- 02-method-command-map.md
|   |-- 03-replication-report.md
|   |-- 04-troubleshooting.md
|   |-- 05-application-checklist.md
|   +-- Baker-2026-DiD-Chinese-Guide.md
|-- 05_templates/
|   |-- did-analysis-template.do
|   |-- did-data-audit-template.do
|   +-- did-reporting-template.md
+-- 99_review/
    |-- final-checklist.md
    |-- unresolved-issues.md
    +-- file-inventory.txt
```

目录职责：

- `01_source_snapshot/`：原始论文和仓库的只读快照，不在其中运行代码。
- `02_replication/JEL-DiD-working/`：原作者仓库的可执行副本，只用于基准复现。
- `03_learning_stata/`：重新编写的中文注释教学代码，与原作者脚本彻底分离。
- `04_docs/`：阅读路线、方法说明、复现报告和中文讲义。
- `05_templates/`：可迁移到用户个人论文的通用模板。

## 4. 启动检查与环境隔离

### 4.1 源文件保护

1. 记录原作者仓库的完整文件树。
2. 对原作者仓库全部文件计算 SHA-256 校验值，保存到 `source-checksums-before.txt`。
3. 将论文和原作者仓库分别复制到 `01_source_snapshot/`。
4. 再复制一份仓库到 `02_replication/JEL-DiD-working/`，所有基准运行仅使用该工作副本。
5. 任务结束后重新计算原作者仓库校验值，生成 `source-checksums-after.txt`，确认前后完全一致。
6. 若原作者目录包含 `.git`，同时保存任务开始和结束时的 `git status --short`；若不含 `.git`，以校验值为准。

### 4.2 Stata 环境

优先检查：

```text
D:\stata19\StataMP-64.exe
```

若路径不存在，再自动搜索本机的 Stata 18/19 可执行文件，并将最终路径写入 `00_admin/environment.md`。不要永久修改 Windows 环境变量或注册表。

为避免污染用户现有 Stata 配置，在运行脚本的包装文件中设置项目级 `PLUS` 目录，例如：

```stata
sysdir set PLUS "...\03_learning_stata\ado\plus"
```

基准复现副本和教学代码应共享同一个项目级扩展命令目录。记录以下信息：

- Stata 版本和可执行文件路径。
- 操作系统与当前代码页。
- 每个用户命令的名称、版本、安装来源和 `which` 返回结果。
- 实际运行时间、返回码和日志位置。

需要重点核对的命令至少包括：

```text
csdid
drdid
honestdid
estout
regsave
coefplot
grc1leg2
reghdfe
```

以仓库脚本实际调用为准。不要仅凭 README 猜测依赖项。

## 5. 阅读与实操顺序

不要按论文从头到尾一次性阅读。采用「读一部分、运行一部分、重写一部分」的方式。

### 5.1 第一轮：研究设计与 $2\times2$ DID

阅读：论文第 1-3 节。

需要掌握：

- Medicaid 扩张案例中的处理组、对照组、处理时点、结果变量和人口权重。
- 潜在结果、无预期效应、ATT 和平行趋势。
- 四个样本均值如何构成 DID。
- 直接均值法、长差分回归和双向固定效应回归为何在标准 $2\times2$ 情形下等价。
- 加权与不加权估计对应不同目标参数，而不仅是精度选择。

完成脚本：

```text
10_data_audit.do
20_did_2x2_manual.do
```

### 5.2 第二轮：识别威胁、协变量与双重稳健估计

阅读：论文第 4 节。

需要掌握：

- 结果趋势不平衡与样本构成不平衡的区别。
- 条件平行趋势和 overlap 条件。
- 为什么直接在 TWFE 中加入协变量通常不能自动识别 ATT。
- Regression Adjustment、IPW 和 Doubly Robust DID 的基本思路。
- 基线协变量、处理后变量和坏控制变量的边界。
- 倾向得分分布、极端权重和共同支撑的诊断方法。

完成脚本：

```text
30_covariates_ra_ipw_dr.do
```

### 5.3 第三轮：$2\times T$ 事件研究与平行趋势敏感性

阅读：论文第 5.1 节，以及与 HonestDiD 相关的讨论。

需要掌握：

- 事件时间、基准期和动态 ATT。
- 处理前系数是平行趋势的诊断信息，不是平行趋势成立的证明。
- 点置信区间与同时置信区间的区别。
- 处理后动态效应的平均方式。
- 为什么平均所有处理前期与处理后期的简单 TWFE 系数可能改变目标参数。
- HonestDiD 如何把允许的平行趋势偏离转化为稳健置信区间。

完成脚本：

```text
40_event_study_2xT.do
70_honestdid_sensitivity.do
```

### 5.4 第四轮：$G\times T$ 交错处理 DID

阅读：论文第 5.2 节。

需要掌握：

- cohort 或 treatment timing group 的定义。
- $ATT(g,t)$ 的含义。
- never-treated 与 not-yet-treated 对照组的差异。
- group-time ATT 如何按 cohort、日历时间和事件时间聚合。
- 不同聚合权重回答的政策问题不同。
- `csdid` 输出中单个 $ATT(g,t)$、整体 ATT 和事件研究结果之间的关系。
- 条件平行趋势下如何使用 DR DID。

完成脚本：

```text
50_staggered_GxT_csdid.do
```

### 5.5 第五轮：TWFE 局限与个人论文迁移

阅读：论文第 5.3 节和第 6 节。

需要掌握：

- 交错处理下 TWFE 为什么会使用已经接受处理的组作为对照组。
- 动态和异质处理效应如何造成非直观权重或符号错误。
- `reghdfe` 在标准 $2\times2$ 或单一处理时点设计中仍然可用，但在交错处理设计中不能默认作为主估计量。
- 何时应报告 `csdid` 或其他 heterogeneity-robust DID 结果。
- 目标参数、对照组、权重和聚合方式应如何写进论文。

完成脚本和模板：

```text
60_twfe_vs_heterogeneity_robust.do
80_run_learning_all.do
05_templates/did-analysis-template.do
05_templates/did-data-audit-template.do
```

## 6. 基准复现任务

### 6.1 代码审计

在运行前逐个检查工作副本中的 Stata 文件：

```text
00_stata_master_did_jel.do
0_stata_make_data.do
1_stata_adoption_table.do
2_stata_2x2.do
3_stata_2xt.do
4_stata_gxt.do
5_stata_honestdid.do
```

文件名大小写以本地实际内容为准。生成 `02_replication/comparison/code-audit.md`，至少说明：

- 每个脚本读取的数据。
- 生成的主要变量。
- 调用的外部命令。
- 对应论文中的表格或图形。
- 是否依赖前一个脚本保留在内存中的数据或估计结果。
- 是否包含硬编码路径、在线下载、随机种子或可能覆盖文件的命令。

### 6.2 最小改动原则

- 不直接修改 `01_source_snapshot/JEL-DiD-original/`。
- 对工作副本的必要修改应局限于路径、输出位置和 Stata 19 兼容性。
- 每项修改都保存 unified diff，写入 `02_replication/comparison/patches.md`。
- 优先编写 wrapper do-file 设置路径和项目级 `ado`，不要大规模重写原作者脚本。
- 若必须修改工作副本中的 master do-file，保留修改前版本，并说明原因。

### 6.3 分步运行

不要一开始只运行 master 文件。按以下顺序执行并分别保存日志：

1. 数据准备。
2. adoption table。
3. $2\times2$ DID。
4. $2\times T$ 事件研究。
5. $G\times T$ 交错处理 DID。
6. HonestDiD。
7. 完整 master do-file。

每一步均需记录：

- 命令行调用方式。
- 开始和结束时间。
- Stata 返回码。
- 日志中是否出现 `r(#)`、`command not found`、缺失文件或无法写出文件。
- 新生成的表格和图形清单。

### 6.4 结果核对

仓库预期包含或生成约 7 张 Stata 表格和 9 幅 Stata 图形。以实际脚本和论文为准，逐项建立核对表：

```text
论文编号 | 输出文件 | 生成脚本 | 关键估计值 | 论文值 | 是否一致 | 备注
```

核对原则：

- 表格按论文展示精度核对系数、标准误和样本量。
- 不以 PDF 二进制哈希完全一致作为图形通过标准，因为软件版本和元数据会导致哈希变化。
- 图形检查坐标轴、事件时间、基准期、点估计、置信区间类型和总体形状。
- bootstrap 或 simultaneous bands 存在微小差异时，检查随机种子、命令版本和重复次数。
- 对所有不一致结果给出原因，不得用「可能是版本问题」笼统带过。

生成：

```text
04_docs/03-replication-report.md
02_replication/comparison/result-comparison.csv
```

## 7. 教学版 Stata 代码要求

教学脚本不是简单复制原作者代码。每个脚本必须能单独运行，并包含充分的中文注释。

### 7.1 统一规范

每个 do-file 开头包含：

- 脚本目的。
- 对应论文节次、表格和图形。
- 输入数据和输出文件。
- 所需用户命令。
- 目标参数和核心识别假设。
- 适用场景与不适用场景。

每个脚本结尾包含：

- 关键结果的 `display` 或简要表格。
- 与原作者结果的核对值。
- 一段注释说明「应看哪个系数、其含义是什么」。

所有路径用引号包围；长命令使用 `///` 换行；不得依赖交互式操作。

### 7.2 `10_data_audit.do`

至少完成：

- 描述面板单位、年份范围、样本量和是否平衡。
- 列出处理 cohort 和 never-treated 组。
- 检查处理是否单调吸收，即一旦处理后是否始终保持处理状态。
- 识别结果变量、权重变量、基线协变量和聚类变量。
- 输出 cohort-by-year 样本分布。
- 检查缺失值、重复的 unit-year 和异常权重。
- 画出各主要 cohort 的原始均值趋势。

### 7.3 `20_did_2x2_manual.do`

使用 2014 扩张组和论文定义的未扩张对照组，至少完成：

- 手工计算四个均值和 DID。
- 用一阶差分回归复现同一估计值。
- 用 `reghdfe` 或等价固定效应回归复现。
- 分别报告不加权和人口加权结果。
- 明确解释两种权重对应的目标总体。
- 对照论文的相关表格与图形。

### 7.4 `30_covariates_ra_ipw_dr.do`

至少完成：

- 基线协变量的处理组与对照组平衡检查。
- outcome regression 的 RA DID。
- propensity score 及其分布图。
- IPW DID。
- `drdid` 的 doubly robust DID。
- 加权与不加权版本。
- 共同支撑、极端倾向得分和 trimming 的诊断。
- 对比「直接在 TWFE 中加入协变量」与目标 ATT 估计量的差异。

不得把处理后的协变量作为默认控制变量。若原作者代码使用变量变化量或特殊设定，应按论文说明其识别含义。

### 7.5 `40_event_study_2xT.do`

至少完成：

- 仅保留一个处理 cohort 与合适对照组。
- 构造事件时间，并明确基准期。
- 用直接 $2\times2$ 构件或作者命令估计各期 ATT。
- 在该简单 $2\times T$ 设计中，用 `reghdfe` 事件研究作为等价性演示。
- 报告处理前系数的联合检验，但明确说明不拒绝不等于证明平行趋势成立。
- 尽可能同时报告 pointwise 和 simultaneous confidence intervals。
- 计算处理后平均效应，并说明平均范围。

### 7.6 `50_staggered_GxT_csdid.do`

至少完成：

- 使用 `csdid` 估计 $ATT(g,t)$。
- 分别尝试论文使用的 never-treated 或 not-yet-treated 对照组设定。
- 报告 group、calendar、event 和 simple aggregation。
- 输出可读的 $ATT(g,t)$ 表格。
- 绘制总体事件研究图和按 cohort 展示的动态效应图。
- 使用论文中的协变量设定复现 DR DID 版本。
- 解释每一种 aggregation 的样本权重和政策含义。

命令语法必须以本地安装版本的帮助文件和原作者脚本为准。不得根据记忆编造选项。

### 7.7 `60_twfe_vs_heterogeneity_robust.do`

至少完成：

- 用 `reghdfe` 估计传统 TWFE 平均处理效应。
- 用传统 TWFE 事件研究估计动态系数。
- 与 `csdid` 的整体 ATT 和事件研究结果并列比较。
- 说明已经处理组充当对照组的位置。
- 说明结果接近时也不能据此证明 TWFE 估计对象正确。
- 若现有包和数据允许，可把 Goodman-Bacon decomposition 作为附加诊断；不得把该扩展变成主线任务。

### 7.8 `70_honestdid_sensitivity.do`

基于原作者代码和 `honestdid` 帮助文件，至少完成：

- 明确输入的是哪组事件研究估计量及其协方差矩阵。
- 复现原作者敏感性分析。
- 给出允许平行趋势偏离程度变化时的稳健区间。
- 解释 breakdown value 或最接近的稳健性指标。
- 说明 HonestDiD 是敏感性分析，不是修复所有识别问题的万能估计量。

## 8. 中文讲义要求

主文件：

```text
04_docs/Baker-2026-DiD-Chinese-Guide.md
```

若本机 Quarto 或 Pandoc 环境可用，同时生成 HTML 和 PDF。PDF 应控制在约 10-15 页，最多 20 页。若无法稳定生成 PDF，不要临时安装大型 TeX 发行版；保留排版完整的 Markdown 和 HTML，并在报告中说明。

### 8.1 讲义定位

- 面向只理解经典 $2\times2$ DID、会执行 `reghdfe` 的初学者。
- 不写成论文逐段翻译，也不展开冗长证明。
- 重点解释「研究问题对应哪个 ATT」「平行趋势针对谁和谁」「对照组怎样选」「命令估计了什么」。
- 每种方法都必须说明适用条件、适用场景、常见误用和 Stata 实现。
- 公式只保留理解方法所需的最小集合。
- Stata 示例优先引用本项目教学脚本中的实际代码，不提供未经运行的伪命令。

### 8.2 建议结构

```text
# 从经典 DID 到交错处理：Baker et al. (2026) 学习精要

## 1. 为什么不能把所有 DID 都交给一条 TWFE 回归
## 2. Medicaid 案例的数据结构与研究问题
## 3. $2\times2$ DID：目标参数、平行趋势与四个均值
## 4. 权重改变的不是标准误，而是研究对象
## 5. 协变量：RA、IPW 与 Doubly Robust DID
## 6. $2\times T$ 事件研究：动态效应、pre-trends 与同时置信区间
## 7. $G\times T$ 交错处理：$ATT(g,t)$ 与聚合
## 8. TWFE 的局限：`reghdfe` 什么时候能用，什么时候不宜作为主结果
## 9. HonestDiD：如何报告对平行趋势偏离的敏感性
## 10. 一套可迁移到个人论文的 DID 工作流
```

### 8.3 每种方法的统一说明模板

每节至少回答：

- **目标参数**：估计的是哪个 ATT。
- **比较对象**：处理组与哪类对照组比较。
- **核心假设**：无预期效应、平行趋势、条件平行趋势或 overlap。
- **估计方法**：手工均值、回归、`drdid`、`csdid` 或 `honestdid`。
- **适用场景**：单一时点、多个时期、交错处理、需要协变量调整等。
- **常见误区**：错误对照组、处理后控制、只看 pre-trend 显著性、忽略权重含义等。
- **结果解读**：指出应查看的系数、聚合结果、事件时间和置信区间。

### 8.4 讲义中的核心判断

讲义应清楚表达以下判断：

- 标准 $2\times2$ DID 中，手工均值、差分回归和恰当的 TWFE 可以得到同一估计值。
- 权重进入目标参数定义；加权和不加权结果通常回答不同问题。
- 协变量调整需要围绕条件平行趋势构造估计量，简单加入控制变量不必然得到目标 ATT。
- pre-trend 不显著不能证明平行趋势成立，估计精度和偏离幅度同样重要。
- 交错处理设计的基本对象是 $ATT(g,t)$，其聚合方式必须与研究问题一致。
- 交错处理且处理效应异质或动态变化时，不应默认把传统 TWFE 作为主估计量。
- HonestDiD 用于量化结论对平行趋势偏离的敏感程度。

## 9. 可迁移模板要求

### 9.1 `did-data-audit-template.do`

应允许用户只修改以下宏或局部宏：

```text
数据路径
面板单位变量
时间变量
结果变量
处理状态变量
首次处理年份变量
权重变量
聚类变量
协变量列表
```

自动输出：重复值、缺失值、处理 cohort、never-treated、处理单调性、事件时间支持范围和 cohort-by-year 样本量。

### 9.2 `did-analysis-template.do`

按设计自动分支或明确提示用户选择：

- 经典 $2\times2$ DID。
- 单一处理时点的 $2\times T$ 事件研究。
- 交错处理的 $G\times T$ DID。
- 是否需要协变量调整。
- never-treated 或 not-yet-treated 对照组。
- 权重和聚类层级。
- 是否进行 HonestDiD 敏感性分析。

模板应包含中文注释和占位符，但不能伪装成对所有数据都自动正确的黑箱程序。

### 9.3 `did-reporting-template.md`

提供论文写作框架，至少包括：

- 处理时点与样本构造。
- 目标参数。
- 对照组选择。
- 平行趋势假设。
- 权重含义。
- 标准误聚类依据。
- 主估计量与聚合方式。
- pre-trend 和 simultaneous confidence band。
- HonestDiD 或其他敏感性分析。
- TWFE 结果若保留，应定位为对照或传统基准，而非自动作为首选结果。

## 10. 常见问题与处理规则

### 10.1 路径和文件名

- Windows 路径全部加双引号。
- 使用程序自动发现实际文件名，处理大小写和下划线差异。
- 不在原始目录中创建临时文件。

### 10.2 Stata 扩展命令

- 使用项目级 `ado` 安装目录。
- 安装失败时，先检查代理、SSL、SSC 和 GitHub 访问，再尝试作者指定的 `net install` 来源。
- 不得在未验证来源的情况下下载同名命令。
- 将 `which command` 和版本信息写入 package manifest。

### 10.3 Stata 19 兼容性

- 若旧脚本在 Stata 19 报错，优先用最小兼容性补丁。
- 保留原始脚本、补丁 diff 和修订原因。
- 不因图形主题、字体或排序差异重写估计部分。

### 10.4 结果差异

按以下顺序排查：

1. 样本筛选与年份范围。
2. treatment cohort 和对照组定义。
3. 权重变量和权重类型。
4. 基准期和事件时间窗口。
5. 协变量取值时点。
6. 聚类层级。
7. 命令版本和默认 trimming。
8. bootstrap 种子、重复次数和 simultaneous band 设置。
9. 数据排序、缺失值和 singleton 处理。

### 10.5 聚类标准误

严格复现作者代码，同时在讲义中区分：

- 复现所使用的聚类层级。
- 政策实际赋值层级。
- 个人论文中应依据处理赋值和误差相关结构选择聚类层级。

不要机械照搬 county 或 state 聚类设置。

### 10.6 图形核对

- 不使用 OCR 作为主要核对方法。
- 优先读取生成图形所使用的估计结果矩阵或数据文件。
- 图形 PDF 只检查页面、坐标、图例、基准线和关键数值。

## 11. 最终交付物

任务完成时，至少应包含以下文件：

```text
README.md
00_admin/environment.md
00_admin/package-manifest.md
00_admin/run-manifest.csv
04_docs/01-reading-roadmap.md
04_docs/02-method-command-map.md
04_docs/03-replication-report.md
04_docs/04-troubleshooting.md
04_docs/05-application-checklist.md
04_docs/Baker-2026-DiD-Chinese-Guide.md
03_learning_stata/do/10_data_audit.do
03_learning_stata/do/20_did_2x2_manual.do
03_learning_stata/do/30_covariates_ra_ipw_dr.do
03_learning_stata/do/40_event_study_2xT.do
03_learning_stata/do/50_staggered_GxT_csdid.do
03_learning_stata/do/60_twfe_vs_heterogeneity_robust.do
03_learning_stata/do/70_honestdid_sensitivity.do
03_learning_stata/do/80_run_learning_all.do
05_templates/did-analysis-template.do
05_templates/did-data-audit-template.do
05_templates/did-reporting-template.md
99_review/final-checklist.md
99_review/unresolved-issues.md
99_review/file-inventory.txt
```

若成功渲染，再提供：

```text
04_docs/Baker-2026-DiD-Chinese-Guide.html
04_docs/Baker-2026-DiD-Chinese-Guide.pdf
```

## 12. 验收标准

只有同时满足以下条件，任务才算完成：

- 原作者仓库在任务前后的校验值完全一致。
- 所有新增内容均位于 `Baker-2026-DiD-ChatGPT-to-Codex`。
- 基准复现按模块和 master do-file 均完成，或对无法完成的步骤给出可验证的错误原因。
- Stata 日志中没有被忽略的 `r(#)` 错误。
- 论文主要 Stata 表格和图形均有逐项核对记录。
- 教学版 do-files 可以从干净 Stata 会话中运行。
- 讲义篇幅不超过 20 页，并覆盖核心方法、适用条件、Stata 实现和常见误区。
- `reghdfe`、`drdid`、`csdid`、`honestdid` 的角色和边界说明准确。
- 模板不依赖本案例特有变量名，用户可通过修改集中参数迁移到自己的数据。
- `README.md` 清楚说明执行顺序、入口文件和各目录用途。
- `final-checklist.md` 对本任务书中的每项要求逐条标记为 `PASS`、`PARTIAL` 或 `BLOCKED`，不得只写笼统总结。

## 13. 执行纪律

- 按阶段推进，每完成一个阶段即更新 `00_admin/task-status.md`。
- 遇到单个命令或图形失败时，先完成不依赖该步骤的其他任务，不要整体停工。
- 不向用户展示冗长的中间思考过程。最终只需汇报完成内容、关键差异、未解决问题和入口文件。
- 对不确定的信息必须查阅论文、仓库脚本或 Stata 帮助文件，不得凭经验补写。
- 所有结论以实际运行结果为准，不得把 README 中的描述当作已经验证的事实。

## 14. 核心资料

- Baker, A., Callaway, B., Cunningham, S., Goodman-Bacon, A., & Sant'Anna, P. H. C. (2026). Difference-in-differences designs: A practitioner's guide. *Journal of Economic Literature, 64*(2), 498-557. DOI: `10.1257/jel.20251650`.
- 论文 PDF：<https://psantanna.com/files/DiD_JEL.pdf>
- 复现仓库：<https://github.com/pedrohcgs/JEL-DiD>

