/* 问题：2014 年扩张与未扩张州之间的 2x2 ATT 是多少？
   对照：2014 扩张组与 2019 年前未扩张组；时期为 2013、2014。
   假设：这两个组在无扩张时具有平行趋势，且不存在预期效应。
*/
version 19
clear all
set more off
global project "D:/github_lianxh/PXa2026a/examples/Baker-2026-DiD-ChatGPT-to-Codex"
global learn "$project/03_learning"
capture log close
log using "$learn/logs/02_did_2x2_byhand.log", replace text
use "$learn/data/did_jel_aca_replication_data.dta", clear
keep if inlist(year, 2013, 2014) & inlist(yaca, 2014, 2020, 2021, 2023, .)
gen treat = yaca == 2014
gen post = year == 2014

preserve
    collapse (mean) mean_y=crude_rate_20_64 [aw=set_wt], by(treat post)
    gen estimand = "population-weighted county mean"
    tempfile weighted
    save `weighted'
restore
preserve
    collapse (mean) mean_y=crude_rate_20_64, by(treat post)
    gen estimand = "unweighted county mean"
    append using `weighted'
    sort estimand treat post
    export delimited using "$learn/tables/02_four_means.csv", replace
restore

preserve
    keep if inlist(year, 2013, 2014)
    collapse (mean) y=crude_rate_20_64, by(treat year)
    reshape wide y, i(treat) j(year)
    gen change = y2014 - y2013
    quietly summarize change if treat == 1
    scalar change_treated = r(mean)
    quietly summarize change if treat == 0
    scalar change_control = r(mean)
    scalar did = change_treated - change_control
    list, noobs
    display "Unweighted DiD = " did
restore
display "看 did：它是处理组变化减去对照组变化。"
display "加权与未加权回答的是不同目标总体，不能只解释为精度差异。"
log close
