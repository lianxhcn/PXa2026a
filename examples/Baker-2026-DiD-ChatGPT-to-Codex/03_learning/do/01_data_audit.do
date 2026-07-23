/* 问题：本例的数据结构、处理 cohort 与权重是否适合 DID？
   目标：识别面板单位、年份、首次处理年份及从未处理组。
   假设：处理一旦开始后保持处理；treat_year=0 表示从未处理。
*/
version 19
clear all
set more off
global project "D:/github_lianxh/PXa2026a/examples/Baker-2026-DiD-ChatGPT-to-Codex"
global learn "$project/03_learning"
capture log close
log using "$learn/logs/01_data_audit.log", replace text
use "$learn/data/did_jel_aca_replication_data.dta", clear

isid county_code year, sort
xtset county_code year
summ year treat_year set_wt crude_rate_20_64
misstable summarize crude_rate_20_64 treat_year set_wt
bys county_code: gen panel_n = _N
tab panel_n
tab treat_year
assert treat_year >= 0 if !missing(treat_year)
by county_code (year): gen treated = year >= treat_year & treat_year > 0
by county_code (year): assert treated >= treated[_n-1] if _n > 1
preserve
    keep county_code state treat_year year set_wt
    collapse (count) counties=county_code (mean) mean_weight=set_wt, ///
        by(treat_year year)
    export delimited using "$learn/tables/cohort_year_counts.csv", replace
restore
preserve
    keep if year == 2013
    collapse (count) counties=county_code (mean) population=set_wt, ///
        by(treat_year)
    export delimited using "$learn/tables/cohort_counts_2013.csv", replace
restore
display "检查结果：处理变量为首次扩张年份；0 是 never-treated。"
log close

