/* 问题：单一处理 cohort 的动态 ATT 如何估计与解释？
   设计：2014 扩张组对从未处理组；e=-1 是基准期。
*/
version 19
clear all
set more off
global project "D:/github_lianxh/PXa2026a/examples/Baker-2026-DiD-ChatGPT-to-Codex"
global learn "$project/03_learning"
capture log close
log using "$learn/logs/05_event_study_2xT.log", replace text
use "$learn/data/did_jel_aca_replication_data.dta", clear
keep if treat_year == 2014 | treat_year == 0
gen event_time = year - 2014
csdid crude_rate_20_64 [iw=set_wt], ///
    ivar(county_code) time(year) gvar(treat_year) ///
    notyet long2
estat event, window(-5 5)
estat event, window(-5 5) estore(es_2xt)
csdid_plot, title("2xT event study: 2014 cohort") ///
    name(es_2xt, replace)
graph export "$learn/figures/05_event_study_2xT.png", replace
display "处理前点估计是间接诊断；不显著不证明平行趋势。"
display "同时置信区间应在多期联合推断时优先报告。"
log close

