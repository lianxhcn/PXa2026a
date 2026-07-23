*--------------------------------------------------------------------------*
* Project:      Lane (2025, QJE) core Stata replication
* Purpose:      Verify a two-period DRDID teaching example.
* Upstream:     Method counterpart to 3b_run_doublerobust_analysis.do
* Change type:  Teaching example; not a paper-result replication.
* Scope:        Five-digit panel, l_ship, 1972 compared with 1979.
*--------------------------------------------------------------------------*

version 18.0
local work_parent "D:/github_lianxh/PXa2026a/examples"
local work_root "`work_parent'/lane_2025_qje_stata_core_replication"
do "`work_root'/code/00_setup_local.do"

capture log close
log using "$LOCAL_LOGS/T02T04__drdid_two_period_demo.log", replace text

local input_file ///
    "$SRC_DATA/input/mms_merged_harmonized_panel_cleaned4reg_5digit.dta"
local controlset l_costs_0 l_avg_size_0 l_avg_wages_0 l_y_n_0
tempfile result

use "`input_file'", clear
keep if inlist(year, 1972, 1979)

drdid l_ship `controlset', ///
    ivar(id) time(year) tr(hci)

regsave using "`result'", ci tstat pval ///
    addlabel(outcome,l_ship, comparison,1972_to_1979, ///
    estimator,drdid_drimp_default) replace

use "`result'", clear
export delimited using ///
    "$LOCAL_TABLES/T02T04__drdid__1972_1979_demo.csv", replace

log close
exit 0
