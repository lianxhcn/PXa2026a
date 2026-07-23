/* 问题：条件平行趋势下如何用协变量调整 2x2 DID？
   估计：RA、IPW 与 DR；只使用处理前（2013 年）协变量。
   注意：处理后协变量可能是坏控制；DR 仍依赖 outcome 或 propensity 模型正确。
*/
version 19
clear all
set more off
global project "D:/github_lianxh/PXa2026a/examples/Baker-2026-DiD-ChatGPT-to-Codex"
global learn "$project/03_learning"
capture log close
log using "$learn/logs/04_weights_and_covariates.log", replace text
use "$learn/data/did_jel_aca_replication_data.dta", clear
keep if inlist(year, 2013, 2014) & inlist(yaca, 2014, 2020, 2021, 2023, .)
gen treat = yaca == 2014
local x perc_female perc_white perc_hispanic ///
    unemp_rate_pc poverty_rate median_income_k
foreach v in `x' {
    egen `v'2013 = max(cond(year == 2013, `v', .)), by(county_code)
}
keep county_code year crude_rate_20_64 treat set_wt `x'2013
rename (*2013) (`x')
xtset county_code year

* 499 次仅用于教学快速检查；正式复现见 02_replication。
drdid crude_rate_20_64 `x', ivar(county_code) time(year) tr(treat) ///
    all pscoretrim(0.995) wboot(reps(499) rseed(20240924)) ///
    cluster(county_code)
matrix b = e(b)
matrix list b
logit treat `x' if year == 2013
predict pscore if e(sample), pr
summ pscore, detail
twoway (histogram pscore if treat == 1, fcolor(none) lcolor(red)) ///
    (histogram pscore if treat == 0, fcolor(none) lcolor(blue)), ///
    legend(order(1 "2014 扩张" 2 "对照组")) ///
    name(pscore, replace)
graph export "$learn/figures/04_pscore_overlap.png", replace
display "先看倾向得分是否重叠，再解释 IPW 和 DR 的估计量。"
log close

