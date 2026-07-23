*--------------------------------------------------------------------------*
* Project:      Lane (2025, QJE) core Stata replication
* Purpose:      Estimate core CSDID results for log shipments.
* Upstream:     3b_run_doublerobust_analysis.do in the main-scripts folder
* Change type:  Focused method rewrite; not a full Table 2--4 replication.
* Scope:        l_ship in 4- and 5-digit panels; DRIPW and regression DID
* Difference:   DR bootstrap uses 999 replications; upstream uses 10,000.
*--------------------------------------------------------------------------*

version 18.0
local work_parent "D:/github_lianxh/PXa2026a/examples"
local work_root "`work_parent'/lane_2025_qje_stata_core_replication"
do "`work_root'/code/00_setup_local.do"

capture log close
log using "$LOCAL_LOGS/T02T04__core_csdid.log", replace text

local datadir "$SRC_DATA/input"
local controlset l_costs_0 l_avg_size_0 l_avg_wages_0 l_y_n_0
local bootstrap_reps 999
local bootstrap_seed 20260723
tempfile raw_results
local write_mode "replace"

foreach panel in five_digit four_digit {
    if "`panel'" == "five_digit" {
        local input_file ///
            "mms_merged_harmonized_panel_cleaned4reg_5digit.dta"
    }
    else {
        local input_file ///
            "mms_merged_harmonized_panel_cleaned4reg_4digit.dta"
    }

    use "`datadir'/`input_file'", clear
    gen gvar = 0
    replace gvar = 1973 if hci == 1

    csdid l_ship `controlset', ///
        time(year) ivar(id) gvar(gvar) ///
        method(dripw) wboot reps(`bootstrap_reps') ///
        rseed(`bootstrap_seed') agg(event) replace
    regsave using "`raw_results'", ci tstat pval ///
        addlabel(panel,`panel', estimator,dripw, outcome,l_ship, ///
        bootstrap_reps,`bootstrap_reps') `write_mode'
    local write_mode "append"

    csdid l_ship `controlset', ///
        time(year) ivar(id) gvar(gvar) ///
        method(reg) agg(event) replace
    regsave using "`raw_results'", ci tstat pval ///
        addlabel(panel,`panel', estimator,reg, outcome,l_ship, ///
        bootstrap_reps,0) append
}

use "`raw_results'", clear
save "$LOCAL_INTERMEDIATE/T02T04__core_csdid__raw_results.dta", replace
export delimited using ///
    "$LOCAL_INTERMEDIATE/T02T04__core_csdid__raw_results.csv", replace

gen str16 estimate_type = lower(var)
keep if estimate_type == "post_avg"
rename pval normal_approx_p
rename ci_lower normal_ci_lower
rename ci_upper normal_ci_upper
keep panel estimator outcome bootstrap_reps coef stderr tstat ///
    normal_approx_p normal_ci_lower normal_ci_upper
order panel estimator outcome bootstrap_reps coef stderr tstat ///
    normal_approx_p normal_ci_lower normal_ci_upper
sort panel estimator
export delimited using ///
    "$LOCAL_TABLES/T02T04__core_csdid__att.csv", replace

log close
exit 0
