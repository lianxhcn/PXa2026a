*--------------------------------------------------------------------------*
* Project:      Lane (2025, QJE) core Stata replication
* Purpose:      Minimal official-Stata reproduction of the F02 DID.
* Upstream:     code/0_analysis/1_main_scripts/1_run_growth_analysis.do
* Upstream SHA-256:
* 4123840186BDC03CB74BF4130FE5CFA2796AE9886F8D3A5B36AFBAA85DC25150
* Change type:  minimal smoke test; only paths and outputs differ upstream.
* Input:        $SRC_DATA/input/mms_merged_harmonized_panel_cleaned4reg_
*               5digit.dta
* Output:       local diagnostic CSV and two official Stata graphs for F02.
*--------------------------------------------------------------------------*

local work_parent "D:/github_lianxh/PXa2026a/examples"
local work_root "`work_parent'/lane_2025_qje_stata_core_replication"
do "`work_root'/code/00_setup_local.do"

capture log close
log using "$LOCAL_LOGS/F02__smoke__official_xtdidregress.log", replace text

local input_name "mms_merged_harmonized_panel_cleaned4reg_5digit.dta"
use "$SRC_DATA/input/`input_name'", clear
xtset id year
gen treat = (hci == 1 & year >= 1973)

quietly xtdidregress (l_ship) (treat), ///
    group(id) time(year) vce(cluster id)

estat trendplots, ltrends noxline
graph export "$LOCAL_FIGURES/F02__smoke__five_digit__trend.pdf", replace

quietly estat ptrends
local pretrend_f = r(F)
local pretrend_p = r(p)

estat grangerplot, baseline(1972) verbose post
graph export "$LOCAL_FIGURES/F02__smoke__five_digit__event.pdf", replace

clear
set obs 1
gen str12 panel = "five_digit"
gen str10 outcome = "l_ship"
gen double pretrend_f = `pretrend_f'
gen double pretrend_p = `pretrend_p'
gen long observations = e(N)
export delimited using ///
    "$LOCAL_INTERMEDIATE/F02__smoke__official_diagnostics.csv", replace

log close
exit 0
