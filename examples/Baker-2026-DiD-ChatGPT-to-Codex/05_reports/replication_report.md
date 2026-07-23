# 作者 Stata 代码复现报告

运行日期为 2026-07-23。环境为 Windows、StataNow/MP 19.5 (24 Sep 2025)，可执行文件为 `D:/stata19/StataMP-64.exe`。项目级 ado 位于 `02_replication/ado/plus`。

## 已验证的层次

- **代码成功运行**：数据准备、adoption table 和 2x2 脚本运行至 Table 6。
- **数值与官方一致**：Table 1--6 的工作副本输出与 `01_source_snapshot/JEL-DiD-clean/tables/` 中对应 Stata `.tex` 的 SHA-256 一致。
- **经济解释一致**：Table 2 的手工 2x2、Table 3 的回归与长差分都围绕相同的 2014 cohort 设计；这并不自动证明分期处理下 TWFE 合适。

## 未完成的正式轮

Table 7 的第一个 `drdid` 正式 wild bootstrap 使用 `reps(25000)` 时，Stata 在无返回码情况下退出；因此其后的 Figure 1--9 和 HonestDiD 没有新的正式运行证据。已保存的图表与 Table 7 快照可供阅读，但不能标为本次正式复现结果。499 次快速诊断成功，证据在 `02_replication/logs/drdid-debug-499.log`。

建议后续在同一 wrapper 中单独运行 Table 7，先检查 Stata crash report 与内存记录，再以 2,500、10,000、25,000 次递增重试；每一步均记录命令版本、随机种子和返回码。

