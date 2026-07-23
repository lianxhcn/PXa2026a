/* 快速语法检查：只运行不含 bootstrap 的前三个教学模块。 */
version 19
clear all
set more off
global project "D:/github_lianxh/PXa2026a/examples/Baker-2026-DiD-ChatGPT-to-Codex"
global learn "$project/03_learning"
foreach f in 01_data_audit 02_did_2x2_byhand 03_did_2x2_regression {
    capture noisily do "$learn/do/`f'.do"
    display "SMOKETEST `f' rc=" _rc
}
exit
