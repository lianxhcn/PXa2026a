/* 只用于定位正式轮在 drdid wild bootstrap 处终止的原因。 */
version 19
clear all
set more off
capture log close
global repdir "D:/github_lianxh/PXa2026a/examples/Baker-2026-DiD-ChatGPT-to-Codex/02_replication"
global root "$repdir/upstream_working"
sysdir set PLUS "$repdir/ado/plus"
sysdir set PERSONAL "$repdir/ado"
cd "$root"
log using "$repdir/logs/drdid-debug-499.log", replace text

use "data/did_jel_aca_replication_data", clear
keep if inlist(year, 2013, 2014) & inlist(yaca, 2014, 2020, 2021, 2023, .)
gen Treat = (yaca == 2014)
local covs perc_female perc_white perc_hispanic ///
    unemp_rate_pc poverty_rate median_income_k
foreach x in `covs' {
    egen `x'2013 = total(`x' * (year == 2013)), by(county_code)
    drop `x'
}
rename (perc_female2013 perc_white2013 perc_hispanic2013 ///
    unemp_rate_pc2013 poverty_rate2013 median_income_k2013) ///
    (perc_female perc_white perc_hispanic ///
    unemp_rate_pc poverty_rate median_income_k)
xtset county_code year

capture noisily drdid crude_rate_20_64 `covs', ///
    ivar(county_code) time(year) tr(Treat) all ///
    pscoretrim(0.995) ///
    wboot(reps(499) rseed(20240924) wbtype(rademacher)) ///
    cluster(county_code)
display "DRDID_DEBUG_RC=" _rc
ereturn list
log close
exit
