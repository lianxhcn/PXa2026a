/* Baker et al. (2026) DiD 学习脚本总入口。 */
version 19
clear all
set more off
global project "D:/github_lianxh/PXa2026a/examples/Baker-2026-DiD-ChatGPT-to-Codex"
global learn "$project/03_learning"
capture mkdir "$learn/logs"
capture mkdir "$learn/tables"
capture mkdir "$learn/figures"
sysdir set PLUS "$project/02_replication/ado/plus"
sysdir set PERSONAL "$project/02_replication/ado"

foreach f in 01_data_audit 02_did_2x2_byhand ///
    03_did_2x2_regression 04_weights_and_covariates ///
    05_event_study_2xT 06_staggered_GxT_csdid ///
    07_honestdid_sensitivity 08_own_research_template {
    capture noisily do "$learn/do/`f'.do"
    di as result "LEARNING_STEP `f' rc=" _rc
}

