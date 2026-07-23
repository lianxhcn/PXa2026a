# Baker et al. (2026) DiD 学习与 Stata 复现

本目录是只读源项目 `../Baker-2026-DiD-Guide--by-Lian` 的独立工作区。论文 PDF、源仓库快照、可运行副本、教学脚本和报告均位于本目录；运行后发现源目录新增一个日志文件，当前尚未恢复为哈希一致状态。

## 入口与运行顺序

1. 阅读 `04_lecture/Baker-2026-DiD-Chinese-Guide.qmd` 或 `.md`。
2. 查看 `05_reports/replication_report.md`，先确认哪些结果已经正式复现。
3. 运行 `03_learning/do/00_master_learning.do`。教学脚本使用 `03_learning/data/did_jel_aca_replication_data.dta`。
4. 运行 `02_replication/00_run_upstream.do` 可重试作者的正式轮；它把 ado 安装限制在 `02_replication/ado`。

## 当前状态

- 源目录清单与运行前哈希：`00_admin/source_inventory.md`、`source_hash_before.csv`；新增日志的删除需要工作区外授权。
- 作者数据准备及 Table 1--6 已运行；生成的 Table 1--6 与快照中的官方 Stata `.tex` 文件逐字节一致。
- 正式轮在 Table 7 的 `drdid` 25,000 次 wild bootstrap 处异常退出，没有给出 Stata 返回码。相同数据、命令和项目级 ado 在 499 次快速诊断中成功，见 `02_replication/logs/drdid-debug-499.log`。因此 Table 7、Figure 1--9 和 HonestDiD 不能标为正式复现成功。
- 讲义、学习脚本和可迁移模板已生成；所有结论均区分已运行结果与方法说明。

## 目录说明

- `01_source_snapshot/`：论文及作者仓库的只读快照。
- `02_replication/`：可写的作者代码副本、项目级 ado、日志和表格。
- `03_learning/`：带中文注释的独立学习脚本、数据与输出。
- `04_lecture/`：中文讲义源码与 Markdown。
- `05_reports/`：复现核验、命令地图、排错与应用清单。
