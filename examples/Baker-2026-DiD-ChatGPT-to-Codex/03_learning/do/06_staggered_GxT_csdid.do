/* 问题：分期处理下，哪一个 ATT(g,t) 与哪类对照组比较？
   对照：not-yet-treated；不会把已处理单位无意识地作为对照。
*/
version 19
clear all
set more off
global project "D:/github_lianxh/PXa2026a/examples/Baker-2026-DiD-ChatGPT-to-Codex"
global learn "$project/03_learning"
capture log close
log using "$learn/logs/06_staggered_GxT_csdid.log", replace text
use "$learn/data/did_jel_aca_replication_data.dta", clear
local x perc_female perc_white perc_hispanic ///
    unemp_rate_pc poverty_rate median_income_k
csdid crude_rate_20_64 `x' [iw=set_wt], ///
    ivar(county_code) time(year) gvar(treat_year) ///
    long2 notyet method(dripw) pscoretrim(0.995)
estat simple
estat group
estat calendar
estat event, window(-5 5) estore(es_gxt)
csdid_plot, title("Staggered DID: aggregated event-time ATT") ///
    name(es_gxt, replace)
graph export "$learn/figures/06_staggered_event_study.png", replace
display "agg(event) 在每个 event time 的 cohort 权重可能不同。"
log close
