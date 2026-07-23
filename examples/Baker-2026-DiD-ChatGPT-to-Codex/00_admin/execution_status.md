# 执行状态

- 更新：2026-07-23 02:03:52 +08:00

- 源文件 SHA-256 前后比较：BLOCKED（新增 `baker_2026_did_learning_replication.log`；删除授权未执行）
FAILED
- Table 1--6：PASS（逐字节匹配快照）。
- Table 7 与后续正式轮：BLOCKED（25,000 次 bootstrap 无返回码退出）。
- 快速诊断：PASS（499 次 `drdid`，返回码 0）。
