/* 问题：四均值、回归、固定效应和长差分何时等价？
   在平衡 2x2 面板中，交互项与长差分中的 treat 系数对应同一 ATT。
*/
version 19
clear all
set more off
global project "D:/github_lianxh/PXa2026a/examples/Baker-2026-DiD-ChatGPT-to-Codex"
global learn "$project/03_learning"
capture log close
log using "$learn/logs/03_did_2x2_regression.log", replace text
use "$learn/data/did_jel_aca_replication_data.dta", clear
keep if inlist(year, 2013, 2014) & inlist(yaca, 2014, 2020, 2021, 2023, .)
gen treat = yaca == 2014
gen post = year == 2014
reg crude_rate_20_64 i.treat##i.post, vce(cluster county_code)
estimates store reg_2x2
xtset county_code year
xtreg crude_rate_20_64 c.treat#c.post i.year, fe ///
    vce(cluster county_code)
estimates store fe_2x2
preserve
    keep county_code year crude_rate_20_64 treat set_wt
    reshape wide crude_rate_20_64, i(county_code) j(year)
    gen long_diff = crude_rate_20_642014 - crude_rate_20_642013
    reg long_diff treat, vce(cluster county_code)
    estimates store long_diff
restore
capture which reghdfe
if !_rc {
    reghdfe crude_rate_20_64 c.treat#c.post, ///
        absorb(county_code year) vce(cluster county_code)
    estimates store reghdfe_2x2
}
estimates table reg_2x2 fe_2x2 long_diff, b(%9.3f) se(%9.3f)
display "应比较 Treat#Post（或 long_diff 中 treat）的点估计。"
log close

