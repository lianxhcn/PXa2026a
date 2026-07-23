# Baker et al. (2026) DiD 学习与 Stata 复现任务书

> 本文档交给本地 Codex 执行。Codex 应直接完成文件整理、Stata 复现、中文学习代码、讲义撰写和结果核验，不要只返回建议或计划。

## 1. 任务目标

围绕 Baker et al. (2026) 的论文及其官方复现仓库，完成一套面向 DiD 初学者的本地学习项目。最终成果应同时满足三个目标：

- **完整复现**：尽可能复现作者 Stata 代码生成的 Table 1-7 和 Figure 1-9，并记录与官方结果的差异。
- **教学化改写**：将作者较长的复现代码拆成若干份可逐步执行、注释充分的 Stata 学习脚本。
- **方法迁移**：形成一份约 10-15 页、最长不超过 20 页的中文讲义，帮助只掌握经典 2×2 DiD 和 `reghdfe` 的读者理解现代 DiD 的主要方法及其适用场景。

核心方法按以下优先级处理：

- 经典 2×2 DiD、手工四均值计算与回归等价性。
- 样本权重如何改变目标参数，而不只是改变估计精度。
- 协变量调整、条件平行趋势、RA、IPW 和 doubly robust DiD。
- 2×T 事件研究、动态效应、处理前估计和同时置信区间。
- 分期处理下的 $ATT(g,t)$、对照组选择、事件时间聚合和 `csdid`。
- 传统 TWFE 在分期处理和动态异质性下的局限。
- `honestdid` 对平行趋势偏离的敏感性分析。

不要求展开论文中的全部证明、半参数效率理论或所有扩展设计。重点是模型设定、识别假设、适用条件、Stata 实现和结果解释。

## 2. 输入位置与强制约束

### 2.1 只读源目录

```text
D:\github_lianxh\PXa2026a\examples\Baker-2026-DiD-Guide--by-Lian
```

该目录及其全部内容必须视为**只读输入**。禁止在该目录内：

- 修改或格式化任何文件；
- 新建日志、临时文件、`.dta`、图形或表格；
- 安装 Stata ado 文件；
- 运行会覆盖 `figures`、`tables` 或 `data` 的脚本；
- 执行 `git clean`、`git reset`、删除、重命名或移动操作。

源目录中预计包含：

```text
baker-2026-did-guide.pdf
jel-did-main\
```

用户文字中曾将 PDF 写为 `Baker-2026-DiD-Guide.pdf`，而文件树显示为 `baker-2026-did-guide.pdf`。请自动检测实际存在的文件名，不要在源目录中重命名。

### 2.2 唯一写入目录

在上述目录的平行位置创建：

```text
D:\github_lianxh\PXa2026a\examples\Baker-2026-DiD-ChatGPT-to-Codex
```

所有复制、修改、运行、安装、日志、临时文件和最终结果都必须写入该目录。

### 2.3 Stata 环境

优先检查并使用：

```text
D:\stata19\StataMP-64.exe
```

若该文件不存在，再自动定位本机可用的 Stata 18 或 Stata 19。记录实际使用的 Stata 版本、可执行文件路径、操作系统、运行日期和主要命令版本。

不要修改用户全局 ado 环境。所有用户命令安装到本项目自己的 `ado` 目录。作者 master do-file 使用了日期固定为 `2025-11-29` 的 SSC 镜像，应优先保留这一可复现设置。

## 3. 参考资料

- Baker, A., Callaway, B., Cunningham, S., Goodman-Bacon, A., & Sant'Anna, P. H. C. (2026). Difference-in-differences designs: A practitioner's guide. *Journal of Economic Literature, 64*(2), 498-557. DOI: <https://doi.org/10.1257/jel.20251650>
- PDF: <https://psantanna.com/files/DiD_JEL.pdf>
- GitHub: <https://github.com/pedrohcgs/JEL-DiD>

本地文件优先于在线下载。只有本地文件缺失或损坏时，才从上述官方地址补充下载，并在报告中注明。

## 4. 项目目录结构

创建并维护下列结构。允许增加必要的临时子目录，但不要改变一级目录含义。

```text
Baker-2026-DiD-ChatGPT-to-Codex\
|-- README.md
|-- 00_admin\
|   |-- source_inventory.md
|   |-- source_hash_before.csv
|   |-- source_hash_after.csv
|   |-- environment_report.md
|   |-- package_versions.txt
|   |-- patch_log.md
|   +-- execution_status.md
|-- 01_source_snapshot\
|   |-- paper\
|   +-- JEL-DiD-clean\
|-- 02_replication\
|   |-- upstream_working\
|   |-- ado\
|   |-- logs\
|   |-- tables\
|   |-- figures\
|   |-- temp\
|   +-- validation\
|-- 03_learning\
|   |-- data\
|   |-- do\
|   |-- logs\
|   |-- tables\
|   |-- figures\
|   +-- notes\
|-- 04_lecture\
|   |-- Baker-2026-DiD-Chinese-Guide.qmd
|   |-- Baker-2026-DiD-Chinese-Guide.md
|   |-- Baker-2026-DiD-Chinese-Guide.pdf
|   +-- references.md
+-- 05_reports\
    |-- replication_report.md
    |-- output_validation.csv
    |-- method_command_map.md
    |-- troubleshooting.md
    |-- application_checklist.md
    +-- final_delivery_checklist.md
```

`01_source_snapshot\JEL-DiD-clean` 是源仓库的原样副本，复制完成后不再修改。真正运行和必要修补只在 `02_replication\upstream_working` 中进行。

## 5. 执行流程

## 5.1 阶段 0：保护源目录并盘点输入

1. **创建写入目录**：建立第 4 节所列目录。
2. **生成输入清单**：列出源目录中的文件、大小、修改时间和相对路径，写入 `00_admin\source_inventory.md`。
3. **计算源文件哈希**：对源目录全部文件计算 SHA-256，保存为 `source_hash_before.csv`。
4. **复制输入**：
   - 将实际存在的论文 PDF 复制到 `01_source_snapshot\paper`；
   - 将 `jel-did-main` 完整复制到 `01_source_snapshot\JEL-DiD-clean`；
   - 再将 clean snapshot 复制到 `02_replication\upstream_working`。
5. **检查关键文件**：确认 PDF、Stata master do-file、6 份分步 do-file、主数据 CSV、官方表格和图形均存在。
6. **记录异常**：文件缺失、文件名与任务书不一致或目录大小异常时，写入 `execution_status.md`，不要在源目录中修复。

## 5.2 阶段 1：检查 Stata 与项目级 ado 环境

在 `00_admin\environment_report.md` 中记录：

- Stata 版本和可执行文件路径；
- `sysdir` 和 `adopath`；
- 当前工作目录；
- `csdid`、`drdid`、`honestdid`、`regsave`、`estout`、`coefplot`、`grc1leg2` 的版本和来源；
- 如学习脚本使用 `reghdfe`，同时记录 `reghdfe` 和 `ftools` 的版本；
- Quarto 或 Pandoc 是否可用，用于渲染中文讲义。

作者 master do-file会把 ado 文件安装到项目目录，并从固定日期的 SSC 镜像安装以下命令：

```text
csdid drdid honestdid regsave estout coefplot grc1leg2
```

执行时应把 PLUS 和 PERSONAL 指向：

```text
02_replication\ado
```

不得覆盖用户全局 PLUS 目录。若固定镜像暂时无法访问，按以下顺序处理：

1. 重试固定镜像；
2. 检查本机现有命令能否满足相同版本或兼容版本；
3. 将命令安装到项目级 ado；
4. 只有固定镜像不可用时才使用当前 SSC，并在 `patch_log.md` 和 `replication_report.md` 中明确注明版本变化。

## 5.3 阶段 2：运行作者 Stata 复现代码

### 5.3.1 建立外部 wrapper

不要直接修改 clean snapshot。创建：

```text
02_replication\00_run_upstream.do
```

该 wrapper 至少完成以下工作：

- `clear all`、`set more off`；
- 设置 `global rootdir` 为 `02_replication\upstream_working`；
- 同时设置 `global root` 为同一路径；
- 切换到 working copy；
- 设置项目级 `PLUS` 和 `PERSONAL`；
- 建立文本 log；
- 顺序调用作者的 master do-file或各分步 do-file；
- 捕获 `_rc`，将每一步成功或失败写入日志；
- 所有输出复制或定向到 `02_replication\tables`、`figures` 和 `logs`。

需要说明的是，作者的 master do-file定义了 `$rootdir`，而 `0_stata_Make_data.do` 中使用了 `$root`。wrapper 同时定义两者，以避免在源文件中直接改动。若仍需修改 working copy，必须逐项记录原行、新行和理由。

### 5.3.2 两轮运行

1. **快速检查轮**：用于发现路径、变量名、命令版本和图形导出问题。耗时较长的 wild bootstrap 可在独立 debug 副本中暂时降至 `499` 或 `999` 次，不得覆盖正式脚本。
2. **正式复现轮**：恢复作者设置，包括 `reps(25000)`、`rseed(20240924)` 和相同 bootstrap 类型。最终报告只使用正式轮结果。

作者代码预计依次运行：

```text
0_stata_Make_data.do
1_stata_adoption_table.do
2_stata_2x2.do
3_stata_2xT.do
4_stata_GxT.do
5_stata_honestdid.do
```

### 5.3.3 预期输出

正式轮应检查以下结果：

- Table 1：Medicaid expansion adoption timing；
- Table 2：手工计算的加权和未加权 2×2 DiD；
- Table 3：2×2 DiD 的回归、固定效应和 long difference 等价性；
- Table 4：协变量平衡；
- Table 5：常规回归中不同协变量控制方式；
- Table 6：outcome regression 和 propensity score 模型；
- Table 7：RA、IPW 和 doubly robust DiD；
- Figure 1：propensity score 分布；
- Figure 2：2014 扩张组与未扩张组的死亡率趋势；
- Figure 3：无协变量的 2×T event study；
- Figure 4：RA、IPW、DR 三种协变量调整 event study；
- Figure 5：各处理时点组的原始趋势；
- Figure 6：按 calendar time 展示的 $ATT(g,t)$；
- Figure 7：按 event time 展示的组别效应；
- Figure 8：无协变量的 G×T 聚合 event study；
- Figure 9：加入协变量和 doubly robust 调整的 G×T event study；
- HonestDiD 输出：相对偏离界限下的稳健置信区间。

Windows 下若 PDF 导出失败而脚本生成 EMF，应保留 EMF，同时在写入目录内转换一份 PDF 或 PNG 供讲义使用。不要写回源仓库。

## 5.4 阶段 3：核验复现结果

建立 `05_reports\output_validation.csv`，至少包括：

```text
output_id, output_type, official_file, reproduced_file, status, numeric_tolerance, notes
```

核验规则：

- 表格的系数、标准误、样本量和主要统计量逐项比较；
- 非 bootstrap 结果原则上应在显示精度内一致；
- bootstrap 结果在种子、版本和重复次数相同时应高度接近，若不一致需说明命令版本和随机数实现差异；
- 图形不以文件哈希作为一致标准，应核对数据点、横纵轴、基准期、置信区间类型和注释数字；
- 官方图形与 Stata 图形在字体、颜色或 PDF 元数据上的差异不视为实质失败；
- 每个失败项必须给出错误位置、原因判断、已尝试修复和是否影响实质结论。

复现完成后，再次计算源目录 SHA-256，保存为 `source_hash_after.csv`，与运行前清单比较。只要有任何源文件变化，必须立即停止后续写入并在报告中标记为失败，随后从原始备份恢复。

## 5.5 阶段 4：制作教学化 Stata 脚本

在 `03_learning\do` 中创建以下脚本。每个脚本必须可以独立执行，也可以由 master 脚本顺序运行。

```text
00_master_learning.do
01_data_audit.do
02_did_2x2_byhand.do
03_did_2x2_regression.do
04_weights_and_covariates.do
05_event_study_2xT.do
06_staggered_GxT_csdid.do
07_honestdid_sensitivity.do
08_own_research_template.do
```

每个 do-file 均需包含：

- 本节要回答的实证问题；
- 输入数据和关键变量；
- 目标参数；
- 识别假设；
- 逐段中文注释；
- 运行后应查看的系数、表格或图形；
- 结果如何解释；
- 常见错误及检查方法；
- log、表格和图形的明确输出位置。

### 5.5.1 `01_data_audit.do`

完成以下检查：

- 面板单位、年份范围、重复值和缺失值；
- 平衡面板筛选导致的样本变化；
- `treat_year=0` 是否表示 never treated；
- 各处理时点的县数、州数和人口权重；
- `set_wt` 是否固定为 2013 年成年人口；
- outcome、协变量和处理变量的描述性统计；
- 对照组在每个年份是否仍处于未处理状态。

### 5.5.2 `02_did_2x2_byhand.do`

使用 2013-2014 年和 2014 扩张组对比未扩张组，完成：

- 四个组别-时期均值；
- 处理组变化、对照组变化及二者之差；
- 未加权和人口加权估计；
- 将四均值结果保存为一张简明表格；
- 用注释解释为什么两种权重对应不同目标总体。

### 5.5.3 `03_did_2x2_regression.do`

对比以下估计：

- `reg y i.treat##i.post`；
- `xtreg, fe`；
- long difference 回归；
- 若本地 `reghdfe` 可用，增加 `reghdfe y treat_post, absorb(id year) vce(cluster id)`。

明确验证经典 2×2、平衡面板和固定权重条件下的点估计等价性。解释交互项系数、聚类标准误和为何这种等价性不能直接推广到 staggered DiD。

### 5.5.4 `04_weights_and_covariates.do`

包含四部分：

- 协变量基期水平与变化量的平衡检查；
- 基期协变量控制与 time-varying covariates 控制的差异；
- `drdid` 或作者代码对应的 RA、IPW 和 DR 估计；
- propensity score 重叠、极端权重和 trimming 检查。

必须说明：处理后的 time-varying covariates 可能是坏控制；权重会改变所估计的目标总体；DR 的「双重稳健」并不意味着任意模型设定都不会出错。

### 5.5.5 `05_event_study_2xT.do`

只保留单一处理时点组和从未处理组，使用 `csdid` 复现简单 event study。需展示：

- event time 的构造；
- 基准期 $e=-1$；
- 每个 post-treatment $ATT(t)$；
- pre-period estimates 作为间接诊断，而不是对平行趋势的直接证明；
- pointwise confidence interval 与 simultaneous confidence interval 的区别；
- post-period 平均效应的含义。

可增加一份传统 TWFE event-study 作为数值对照，但必须标注：此处只有一个处理时点，不能把该结果误当成 staggered design 下 TWFE 始终有效的证据。

### 5.5.6 `06_staggered_GxT_csdid.do`

使用全体分期处理样本，重点展示：

- `ivar()`、`time()`、`gvar()` 的含义；
- never-treated 与 not-yet-treated 对照组；
- $ATT(g,t)$ 的组别-时间含义；
- calendar-time 图、group-specific event-time 图和聚合 event study；
- `agg(event)` 的加权对象会随 event time 改变；
- 处理效应动态异质时，传统 TWFE 可能使用 already-treated units 作为对照，并产生难以解释的加权。

核心命令应围绕作者使用的形式展开：

```stata
csdid outcome [iw=weight], ///
    ivar(id) time(year) gvar(treat_year) ///
    long2 notyet agg(event)
```

加入协变量时，以作者的 doubly robust 规格为主：

```stata
csdid outcome covariates [iw=weight], ///
    ivar(id) time(year) gvar(treat_year) ///
    method(dripw) long2 notyet ///
    pscoretrim(0.995) agg(event)
```

代码中使用实际变量名，并详细说明每个选项。不要机械照抄示意命令。

### 5.5.7 `07_honestdid_sensitivity.do`

复现作者思路：

- 先运行并 post event-study 结果；
- 明确 `pre()` 与 `post()` 对应的系数位置；
- 运行 relative magnitude、$M=1$ 的敏感性分析；
- 将常规置信区间和 robust confidence interval 并列报告；
- 解释该分析回答的是「允许处理后平行趋势偏离相对处理前偏离有多大时，结论仍成立」。

不得只报告 `honestdid` 命令输出，要把参数位置和经济含义写清楚。

### 5.5.8 `08_own_research_template.do`

制作一个不包含本论文专用变量名的可迁移模板。模板顶部统一定义：

```stata
local y        "outcome"
local id       "unit_id"
local t        "year"
local g        "first_treat_year"
local x        "x1 x2 x3"
local w        "weight"
local cluster  "cluster_id"
```

模板应包含：

- 数据结构检查；
- 2×2 或单一处理时点的判断；
- staggered treatment 的判断；
- never-treated 和 not-yet-treated 是否可用；
- 无协变量与 DR 估计；
- event study；
- 聚合效应；
- overlap 检查；
- HonestDiD 接口；
- 最终结果表和图。

所有占位符必须明显标注，避免用户误运行后把示例变量当成真实变量。

## 5.6 阶段 5：撰写中文讲义

主文件：

```text
04_lecture\Baker-2026-DiD-Chinese-Guide.qmd
```

同时输出 Markdown 和 PDF。PDF 目标长度为 10-15 页，最长不得超过 20 页。若因本机缺少中文 LaTeX 环境无法生成 PDF，必须保留可正常渲染的 `.qmd` 和 `.md`，并在报告中给出缺失组件及一条可复现的解决命令。

### 5.6.1 面向读者

读者只理解经典 2×2 DiD，会执行 Stata 代码并熟悉 `reghdfe`，但尚不熟悉现代 staggered DiD。文字采用中文学术讲义风格，朴实、直接，避免堆砌证明和文献史。

### 5.6.2 建议结构

1. **论文解决的实际困难**：为何从 2×2 直接推广到 TWFE 会出问题。
2. **统一视角**：复杂 DiD 是许多可解释的 2×2 building blocks 的组合。
3. **经典 2×2 DiD**：ATT、平行趋势、无预期效应、四均值和回归等价性。
4. **权重**：县平均效应与人口平均效应为何不同。
5. **协变量**：条件平行趋势、RA、IPW、DR、重叠和坏控制。
6. **2×T event study**：动态效应、处理前系数、同时置信区间和 HonestDiD。
7. **G×T staggered DiD**：$ATT(g,t)$、对照组选择和聚合方式。
8. **传统 TWFE 的边界**：何时 `reghdfe` 足够，何时不能只看 TWFE 系数。
9. **Stata 操作路径**：从数据检查到 `csdid` 和 `honestdid`。
10. **应用到自己论文**：一份可执行的设计与报告清单。

### 5.6.3 必须讲清楚的公式

只保留少量核心公式，并配合文字解释。

经典 2×2 DiD：

$$
\operatorname{ATT}=\left[E(Y_{i,1}\mid D_i=1)-E(Y_{i,0}\mid D_i=1)\right]-\left[E(Y_{i,1}\mid D_i=0)-E(Y_{i,0}\mid D_i=0)\right]
$$

传统 TWFE：

$$
Y_{it}=\alpha_i+\lambda_t+\beta D_{it}+\varepsilon_{it}
$$

组别-时间平均处理效应：

$$
\operatorname{ATT}(g,t)=E\left[Y_{it}(g)-Y_{it}(\infty)\mid G_i=g\right]
$$

事件时间聚合：

$$
\operatorname{ATT}^{es}(e)=\sum_g w_{g,e}\operatorname{ATT}(g,g+e)
$$

讲义必须解释公式中的目标总体、对照组和权重，而不是只给符号定义。

### 5.6.4 图表选择

从复现结果中选择约 4-6 幅最有教学价值的图表，优先包括：

- Table 2 或 Table 3：2×2 手工与回归；
- Figure 2：原始趋势；
- Figure 3：2×T event study；
- Figure 6 或 Figure 7：$ATT(g,t)$；
- Figure 8 或 Figure 9：聚合 staggered event study；
- HonestDiD 的敏感性结果。

每幅图下方写明「看哪一个点、哪一条区间、如何解释」。不要把全部 16 个官方输出机械塞入讲义。

### 5.6.5 Stata 命令对照

讲义中增加一张方法-命令表，至少包含：

- 手工 2×2：`summarize`、`collapse`；
- 经典回归 DiD：`reg`、`xtreg`、`reghdfe`；
- 2×2 covariate-adjusted DiD：`drdid`；
- staggered DiD：`csdid`；
- 结果聚合：`agg(event)` 或相应 `estat`；
- 敏感性分析：`honestdid`。

对每个命令说明适用设计、核心输出和最常见误用。

## 6. 建议阅读顺序

阅读与代码应交替进行，不要从头到尾先读完再运行。

1. **第一轮：建立框架**
   - Introduction；
   - Section 2 的 Medicaid 示例；
   - Section 3.1 和 3.3；
   - 同时运行 `01_data_audit.do`、`02_did_2x2_byhand.do` 和 `03_did_2x2_regression.do`。
2. **第二轮：权重与协变量**
   - Section 3 中关于 weights 的讨论；
   - Section 4.1-4.4；
   - 同时运行 `04_weights_and_covariates.do`。
3. **第三轮：多时期但单一处理时点**
   - Section 5.1；
   - 同时运行 `05_event_study_2xT.do` 和 `07_honestdid_sensitivity.do`。
4. **第四轮：分期处理**
   - Section 5.2；
   - 同时运行 `06_staggered_GxT_csdid.do`。
5. **第五轮：理解 TWFE 边界**
   - Section 5.3 和 Conclusion；
   - 对比 `reghdfe` 的 TWFE 结果与 `csdid` 的 $ATT(g,t)$ 和 event-time aggregation。

论文中处理可逆、连续处理、triple differences、重复截面等扩展只在讲义末尾列为「后续阅读」，本项目不展开复现。

## 7. 常见问题与处理规则

将实际遇到的问题补充到 `05_reports\troubleshooting.md`。至少检查以下事项。

### 7.1 路径变量不一致

作者 master 使用 `$rootdir`，数据脚本使用 `$root`。在 wrapper 中同时定义，禁止直接修改源目录。

### 7.2 数据文件名和变量名

确认 `county_mortality_data.csv` 能生成 `did_jel_aca_replication_data.dta`。若 `crude_rate` 与 `crude_rate_20_64` 同时或仅有一个存在，先检查数据字典和作者脚本上下文，再在 working copy 中最小修补，不得凭猜测改变量。

### 7.3 包版本导致语法差异

`csdid` 的 posted results、矩阵列名、`long2`、`notyet`、`never`、`agg(event)` 或 `wboot()` 可能对版本敏感。优先使用作者固定镜像；若改用新版本，保存 `which`、`help` 和返回结果结构，并相应调整结果提取代码。

### 7.4 bootstrap 耗时

快速轮可以降低重复次数，正式轮必须恢复 `25000`。不得把 debug 结果当成最终结果。

### 7.5 图形格式

Windows 上 PDF 导出失败时允许生成 EMF，但最终讲义使用写入目录内转换的 PDF 或 PNG。记录转换工具和命令。

### 7.6 权重类型

作者在普通回归中使用 `[aw=set_wt]`，在 `csdid` 中使用 `[iw=set_wt]`。不要擅自统一。讲义中解释二者在命令语法和目标参数上的含义，并核对命令帮助文件支持的权重类型。

### 7.7 never treated 编码

数据构造脚本把未处理组设为 `treat_year=0`。运行 `csdid` 前验证该编码与当前命令版本一致。

### 7.8 对照组选择

- `never`：只使用从未处理单位；
- `notyet`：允许尚未处理单位在相应时期作为对照；
- already-treated units 不应被无意识地作为对照。

每次估计均在日志中写明实际对照组。

### 7.9 协变量与重叠

检查 propensity score 分布、极端值、`pscoretrim(0.995)` 删除的观测数量和被删样本特征。不要把缺乏 overlap 简单解释为软件问题。

### 7.10 pre-trend 解读

处理前系数接近 0 不能证明平行趋势成立；显著不为 0 也可能受到低精度、多重检验和基准期选择影响。报告 pointwise 与 simultaneous inference，并用 HonestDiD 补充敏感性分析。

### 7.11 聚类层级

作者按 county 聚类。讲义中说明聚类层级应与处理分配或误差相关结构匹配；迁移到用户研究时，不得机械沿用 county。

### 7.12 样本筛选

记录删除早期采用州、协变量缺失、非完整 11 年面板及 2019 年后采用者重新编码所造成的样本变化。生成一张 sample flow 表。

## 8. 最终交付物

Codex 完成后，用户应能直接查看以下核心文件：

1. `04_lecture\Baker-2026-DiD-Chinese-Guide.pdf`
2. `04_lecture\Baker-2026-DiD-Chinese-Guide.md`
3. `03_learning\do\00_master_learning.do`
4. `03_learning\do\08_own_research_template.do`
5. `05_reports\replication_report.md`
6. `05_reports\method_command_map.md`
7. `05_reports\troubleshooting.md`
8. `05_reports\application_checklist.md`
9. `05_reports\final_delivery_checklist.md`

`README.md` 应作为总入口，说明：

- 项目目的；
- 输入源目录和只读规则；
- 一键运行顺序；
- 快速轮与正式轮的区别；
- 讲义、代码、日志和结果的位置；
- 当前完成状态和未解决问题。

## 9. 验收标准

只有同时满足以下条件，任务才算完成：

- 源目录运行前后 SHA-256 完全一致；
- 全部写操作位于 `Baker-2026-DiD-ChatGPT-to-Codex`；
- Stata 作者代码至少完成一轮正式复现，或对无法完成的步骤给出可验证的错误证据；
- Table 1-7、Figure 1-9 均有明确核验状态；
- 学习脚本可从 master 顺序运行，且每个模块有独立 log；
- 讲义长度不超过 20 页，重点放在适用条件、Stata 实现和结果解读；
- 讲义明确区分 2×2、2×T 和 G×T；
- 讲义明确解释权重、协变量、对照组和聚合方式如何改变目标参数；
- 讲义明确说明 staggered treatment 下传统 TWFE 的局限；
- 提供可迁移到用户自身论文的 Stata 模板和应用清单；
- `final_delivery_checklist.md` 逐项列出完成、部分完成或失败，不使用含糊表述。

## 10. 执行纪律

- 直接完成任务，不要只生成新的计划文档。
- 遇到普通路径、编码、包安装或版本问题时自行诊断和修复，不必频繁询问用户。
- 只有在源文件缺失、Stata 无法定位、权限完全阻断或需要用户凭据时才暂停并请求用户处理。
- 所有补丁必须最小化、可追踪、可撤销。
- 不删除失败日志和中间诊断结果。
- 最终报告必须区分「代码成功运行」「数值与官方一致」「经济解释一致」三个层次。
