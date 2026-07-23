# Baker et al. (2026) DID 学习与 Stata 复现

本目录与作者资料目录平行，所有新增文件都在此处。`source-snapshot/` 是只读参考副本；教学代码和运行结果位于 `dofile-replication/`。

## 运行

1. 在 Stata 中切换到 `dofile-replication/`。
2. 运行 `do baker_2026_did_learning_replication.do`。
3. 先阅读 `notes/Baker-2026-DID-中文讲义.md`，再查看 `dofile-replication/logs/` 和 `output/tables/`。

默认 `reps` 为 999，以便学习和调试。作者脚本使用 25,000 次 wild bootstrap；正式复现时可把 do-file 第 6 行的 `reps` 改为 `25000`，并保留随机种子。两种设置的点估计相同，基于 bootstrap 的置信区间会略有差别。

## 目录

- `notes/`：面向初学者的中文讲义、学习路线和应用核对表。
- `dofile-replication/`：唯一教学 do-file、从作者数据复制的输入、项目级 ado、日志与结果。
- `source-snapshot/`：论文和作者仓库的快照，仅供查阅。
- `source-checksums-before.txt`：运行前的作者代码 SHA-256 校验值。
