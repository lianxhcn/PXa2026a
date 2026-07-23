# 工作副本补丁记录

| 文件 | 修改 | 原因 |
|---|---|---|
| `0_stata_Make_data.do` | 移除 `exit` 与关闭 wrapper 日志的语句 | 允许外部 wrapper 连续运行并保留日志 |
| `1_stata_adoption_table.do` | 移除关闭 wrapper 日志的语句 | 保留统一日志 |
| `3_stata_2xT.do` | 移除 `exit` | 允许连续运行 |
| `5_stata_honestdid.do` | 移除 `exit` | 允许连续运行 |

所有补丁只作用于 `02_replication/upstream_working/`；`01_source_snapshot/` 和只读源目录均未修改。

