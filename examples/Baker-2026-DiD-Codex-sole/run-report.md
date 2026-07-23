# 本轮运行记录

## 已完成

- 已将论文、作者 Stata/R 仓库和数据副本置于 `source-snapshot/` 或 `dofile-replication/data/author-data/`。
- 已运行单一教学 do-file，并在 `dofile-replication/logs/baker_2026_did_learning.log` 留下完整 Stata 输出。
- 已成功完成数据构造、加权 2×2 均值、`reghdfe`、长差分、`drdid`、两组多期 `csdid`、交错处理 `csdid` 和 HonestDiD。
- 运行使用 999 次 wild bootstrap；作者原始脚本使用 25,000 次，因此 bootstrap 区间不应逐位比较。

## 可核对的输出

- `output/tables/2x2_weighted_means.csv`：四个处理组 × 时期加权均值。
- `output/tables/2x2_regressions.csv`：2×2 FE 与长差分回归。
- `logs/baker_2026_did_learning.log`：DR DID、事件研究、交错处理聚合和 HonestDiD 的全部输出。

## 关键结果的阅读提示

- 2×T 事件研究的 `Post_avg` 约为 −0.70，渐近标准误约为 2.02；这是本案例的估计输出，不是一般结论。
- 交错处理的 event-time 聚合 `Post_avg` 约为 0.09，渐近标准误约为 1.89。它与 2×T 的数字不同，因为处理 cohort、对照组与聚合权重不同。
- HonestDiD 的相对幅度示例取 $M=1$。原区间约为 [−5.48, 0.36]，敏感性区间约为 [−11.28, 5.53]。$M$ 必须结合自己的制度背景选择。

## 隔离核验

`source-checksums-before.txt` 与 `source-checksums-after.txt` 的逐文件 SHA-256 比较结果为 0 个差异。作者源目录未被修改。
