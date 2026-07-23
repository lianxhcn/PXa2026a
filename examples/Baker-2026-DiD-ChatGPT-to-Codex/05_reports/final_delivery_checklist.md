# 最终交付核对

| 项目 | 状态 | 证据或说明 |
|---|---|---|
| 源目录只读与运行前哈希 | BLOCKED | 出现 `baker_2026_did_learning_replication.log`；删除授权未执行 |
| 论文与仓库快照 | PASS | `01_source_snapshot/` |
| 项目级 ado | PASS | `02_replication/ado/plus` |
| Table 1--6 正式代码运行与核验 | PASS | `02_replication/tables/`；与快照一致 |
| Table 7 正式 bootstrap | BLOCKED | 无返回码异常退出；499 次诊断成功 |
| Figure 1--9 正式重绘核验 | BLOCKED | 依赖 Table 7 后续正式运行 |
| HonestDiD 正式输出 | BLOCKED | 依赖完整 event-study 轮次 |
| 八份学习 do-file 与总入口 | PARTIAL | 已生成；01--03 已通过 Stata smoke test，04--07 尚未完成完整运行 |
| 可迁移研究模板 | PASS | `03_learning/do/08_own_research_template.do` |
| 中文讲义 Markdown 与 Quarto 源码 | PASS | `04_lecture/` |
| 讲义 PDF | PARTIAL | 已渲染为 5 页；低于 10--15 页目标，且未完成 PNG 版面复核 |
