/* 问题：如果处理后趋势偏离与处理前偏离同量级，结论是否稳健？
   HonestDiD 是敏感性分析，不替代研究设计与对照组选择。
*/
version 19
clear all
set more off
global project "D:/github_lianxh/PXa2026a/examples/Baker-2026-DiD-ChatGPT-to-Codex"
global learn "$project/03_learning"
capture log close
log using "$learn/logs/07_honestdid_sensitivity.log", replace text
use "$learn/data/did_jel_aca_replication_data.dta", clear
keep if treat_year == 2014 | treat_year == 0
csdid crude_rate_20_64 [iw=set_wt], ///
    ivar(county_code) time(year) gvar(treat_year) notyet long2
estat event, window(-6 4) estore(event_for_hd)
estimates restore event_for_hd
ereturn list
honestdid, type(relative_magnitude) pre(3/6) post(7) mvec(1)
display "pre() 与 post() 必须按 e(b) 的实际列位置重新核对。"
log close

