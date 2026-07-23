# 实际排错记录

## 1. `$rootdir` 与 `$root` 不一致

作者 master 使用 `$rootdir`，数据准备脚本使用 `$root`。`02_replication/00_run_upstream.do` 同时定义二者，避免修改只读源目录。

## 2. 分步脚本中的 `exit`

`0_stata_Make_data.do`、`3_stata_2xT.do` 与 `5_stata_honestdid.do` 中的 `exit` 会终止外部 wrapper。工作副本中已改为注释；原样快照未改。数据准备与 adoption-table 脚本中关闭日志的命令也已改为保留 wrapper 日志。补丁仅发生在 `02_replication/upstream_working/`。

## 3. 固定 SSC 镜像不可访问

作者指定的 `2025-11-29` 镜像以及当前 SSC 都返回网络连接失败。为不改用户全局 ado，项目复制了本机现有的 `D:/stata/plus` 到 `02_replication/ado/plus`。诊断日志记录了可用版本：`csdid 1.72`、`honestdid 1.3.0`、`reghdfe 6.13.1`。

## 4. 正式 bootstrap 异常退出

在 Table 7 的 `drdid ... wboot(reps(25000) ...)` 处，StataNow/MP 19.5 退出且没有日志中的 `r(#)`。同一估计量在 `reps(499)` 下成功返回 `dripw=-1.226`、`reg=-1.615`、`ipw=-0.689`。该快速结果只能诊断命令和数据可运行，不能替代正式标准误或正式复现。

