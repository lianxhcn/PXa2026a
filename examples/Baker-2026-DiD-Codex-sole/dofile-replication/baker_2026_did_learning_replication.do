version 19.0
clear all
set more off

* These explicit paths keep all writes inside this work directory.
local base "D:/github_lianxh/PXa2026a/examples"
local root "`base'/Baker-2026-DiD-Codex-sole/dofile-replication"
local reps 999
local seed 20240924

capture log close teaching
capture mkdir "`root'/ado"
capture mkdir "`root'/ado/plus"
capture mkdir "`root'/output"
capture mkdir "`root'/output/figures"
capture mkdir "`root'/output/tables"
capture mkdir "`root'/logs"
sysdir set PLUS "`root'/ado/plus"
log using "`root'/logs/baker_2026_did_learning.log", ///
    replace text name(teaching)

* Community commands are installed locally, only when absent.
foreach pkg in require ftools reghdfe drdid csdid honestdid estout {
    capture which `pkg'
    if _rc ssc install `pkg'
}

* 1. Build the analysis data from the author-supplied raw CSV.
insheet using "`root'/data/author-data/county_mortality_data.csv", clear
drop if inlist(state, "District of Columbia", "Delaware", ///
    "Massachusetts", "New York", "Vermont")
gen treat_year = real(yaca)
replace treat_year = 0 if missing(treat_year)
destring yaca deaths population_20_64 crude_rate_20_64, replace force
destring population_total population_20_64_hispanic, replace force
destring population_20_64_female population_20_64_white, replace force
destring unemployed labor_force unemp_rate poverty_rate, replace force
destring median_income, replace force
gen perc_white = 100 * population_20_64_white / population_20_64
gen perc_hispanic = 100 * population_20_64_hispanic / population_20_64
gen perc_female = 100 * population_20_64_female / population_20_64
gen unemp_rate_pc = 100 * unemp_rate
gen median_income_k = median_income / 1000
drop if missing(crude_rate_20_64, population_20_64, perc_white, ///
    perc_hispanic, perc_female, unemp_rate_pc, poverty_rate, ///
    median_income_k)
bysort county_code: keep if _N == 11
replace treat_year = 0 if treat_year > 2019
bysort county_code: egen set_wt = max(cond(year == 2013, ///
    population_20_64, .))
label var crude_rate_20_64 "Mortality rate, age 20--64"
save "`root'/data/did_jel_aca_replication_data.dta", replace

* 2. Classic 2x2 DID: 2014 adopters versus never/later adopters.
preserve
keep if inlist(year, 2013, 2014) & ///
    inlist(yaca, 2014, 2020, 2021, 2023, .)
gen Treat = yaca == 2014
gen Post = year == 2014
collapse (mean) crude_rate_20_64 [aw = set_wt], by(Treat Post)
export delimited using "`root'/output/tables/2x2_weighted_means.csv", ///
    replace
restore

keep if inlist(year, 2013, 2014) & ///
    inlist(yaca, 2014, 2020, 2021, 2023, .)
gen Treat = yaca == 2014
gen Post = year == 2014
reghdfe crude_rate_20_64 i.Treat##i.Post [aw = set_wt], ///
    absorb(county_code year) vce(cluster county_code)
estimates store twfe_2x2
preserve
keep county_code year crude_rate_20_64 Treat set_wt
reshape wide crude_rate_20_64, i(county_code) j(year)
gen delta_y = crude_rate_20_642014 - crude_rate_20_642013
reg delta_y Treat [aw = set_wt], vce(cluster county_code)
estimates store long_difference
esttab twfe_2x2 long_difference using ///
    "`root'/output/tables/2x2_regressions.csv", replace csv se
restore

* 3. Conditional 2x2 DID: covariates are fixed at the pre-treatment year.
local covs perc_female perc_white perc_hispanic unemp_rate_pc ///
    poverty_rate median_income_k
foreach x of local covs {
    bysort county_code: egen base_`x' = max(cond(year == 2013, `x', .))
}
drdid crude_rate_20_64 base_perc_female base_perc_white ///
    base_perc_hispanic base_unemp_rate_pc base_poverty_rate ///
    base_median_income_k [iw = set_wt], ///
    ivar(county_code) time(year) tr(Treat) all ///
    pscoretrim(0.995) cluster(county_code) ///
    wboot(reps(`reps') rseed(`seed') wbtype(rademacher))
estimates store drdid_2x2

* 4. Two groups, many periods: event-time effects for 2014 adopters.
use "`root'/data/did_jel_aca_replication_data.dta", clear
keep if inlist(yaca, 2014, 2020, 2021, 2023, .)
csdid crude_rate_20_64 [iw = set_wt], ///
    ivar(county_code) time(year) gvar(treat_year) long2 never ///
    wboot(reps(`reps') rseed(`seed') wbtype(rademacher)) agg(event)
estat event, window(-5 5)
estimates store event_2xt

* 5. Staggered adoption: ATT(g,t), then calendar and event aggregation.
use "`root'/data/did_jel_aca_replication_data.dta", clear
csdid crude_rate_20_64 [iw = set_wt], ///
    ivar(county_code) time(year) gvar(treat_year) long2 notyet ///
    wboot(reps(`reps') rseed(`seed') wbtype(rademacher))
estat simple
estat group
estat calendar
estat event, window(-5 5)
estimates store staggered_csdid

* 6. Sensitivity: deviations from parallel trends of relative size M = 1.
use "`root'/data/did_jel_aca_replication_data.dta", clear
keep if inlist(yaca, 2014, 2020, 2021, 2023, .)
csdid crude_rate_20_64 [iw = set_wt], ///
    ivar(county_code) time(year) gvar(treat_year) long2 never ///
    wboot(reps(`reps') rseed(`seed') wbtype(rademacher)) agg(event)
estat event, window(-5 0) post
honestdid, type(relative_magnitude) pre(3/6) post(7) mvec(1)

display "Completed. Read output, logs, and the Chinese guide before reuse."
log close teaching
