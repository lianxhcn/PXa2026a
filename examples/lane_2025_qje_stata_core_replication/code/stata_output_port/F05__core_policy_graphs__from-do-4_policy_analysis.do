*--------------------------------------------------------------------------*
* Project:      Lane (2025, QJE) core Stata replication
* Purpose:      Recreate Figure 5 policy-capital event-study ingredients.
* Upstream:     code/0_analysis/1_main_scripts/4_run_policy_analysis.do
* Upstream R:   code/1_figures/Figure5.R
* Change type:  Stata-native output port; core five-digit panel only.
*--------------------------------------------------------------------------*

version 18.0
local work_parent "D:/github_lianxh/PXa2026a/examples"
local work_root "`work_parent'/lane_2025_qje_stata_core_replication"
do "`work_root'/code/00_setup_local.do"

capture log close
log using "$LOCAL_LOGS/F05__core_policy_graphs.log", replace text

local input_file "$SRC_DATA/input/mms_policy_5digit.dta"
local outcomes l_costs l_m_n l_inv_tot l_i_n l_stock_tot
tempfile raw_results
tempname diagnostics_handle
tempfile diagnostics_data
local write_mode "replace"

postfile `diagnostics_handle' str12 outcome double pretrend_f pretrend_p ///
    long observations using "`diagnostics_data'", replace

use "`input_file'", clear

foreach outcome of local outcomes {
    reghdfe `outcome' i.hci##ib(1972).year, ///
        absorb(id year) vce(cluster id)
    local observations = e(N)

    quietly levelsof year if year < 1972 & !missing(`outcome'), ///
        local(pre_years) clean
    local pretrend_terms
    foreach pre_year of local pre_years {
        local pretrend_terms ///
            `pretrend_terms' 1.hci#`pre_year'.year
    }
    test `pretrend_terms'
    local pretrend_f = r(F)
    local pretrend_p = r(p)

    regsave using "`raw_results'", ci ///
        addlabel(outcome,`outcome', command,`e(cmd)') `write_mode'
    local write_mode "append"

    post `diagnostics_handle' ("`outcome'") ///
        (`pretrend_f') (`pretrend_p') (`observations')
}

postclose `diagnostics_handle'
use "`diagnostics_data'", clear
export delimited using ///
    "$LOCAL_INTERMEDIATE/F05__core_policy_pretrend_diagnostics.csv", replace

use "`raw_results'", clear
save "$LOCAL_INTERMEDIATE/F05__core_policy_raw_results.dta", replace
export delimited using ///
    "$LOCAL_INTERMEDIATE/F05__core_policy_raw_results.csv", replace

keep if regexm(var, "^1.*hci#[0-9][0-9][0-9][0-9].*year$")
gen year = real(regexs(1)) if regexm(var, "([0-9][0-9][0-9][0-9])")
drop if missing(year)
sort outcome year
export delimited using ///
    "$LOCAL_INTERMEDIATE/F05__core_policy_event_results.csv", replace

foreach outcome of local outcomes {
    preserve
    keep if outcome == "`outcome'"
    sort year

    if "`outcome'" == "l_costs" {
        local graph_title "A. Intermediate Outlays"
    }
    else if "`outcome'" == "l_m_n" {
        local graph_title "B. Outlays per Worker"
    }
    else if "`outcome'" == "l_inv_tot" {
        local graph_title "C. Total Investment"
    }
    else if "`outcome'" == "l_i_n" {
        local graph_title "D. Investment per Worker"
    }
    else {
        local graph_title "E. Capital Stock"
    }

    twoway ///
        (rcap ci_lower ci_upper year, lcolor(gs10)) ///
        (scatter coef year, mcolor(navy) msymbol(O)), ///
        yline(0, lcolor(gs8) lpattern(dash)) ///
        xline(1972 1979, lcolor(gs8) lpattern(dot)) ///
        xlabel(1970 1979 1986, labsize(vsmall)) ///
        xtitle("") ytitle("") legend(off) ///
        title("`graph_title'", size(small)) ///
        name(F05_`outcome', replace)
    graph save ///
        "$LOCAL_FIGURES/F05__`outcome'__event.gph", replace
    restore
}

graph combine ///
    "$LOCAL_FIGURES/F05__l_costs__event.gph" ///
    "$LOCAL_FIGURES/F05__l_m_n__event.gph" ///
    "$LOCAL_FIGURES/F05__l_inv_tot__event.gph" ///
    "$LOCAL_FIGURES/F05__l_i_n__event.gph" ///
    "$LOCAL_FIGURES/F05__l_stock_tot__event.gph", ///
    rows(2) cols(3) imargin(tiny) ///
    title("Industrial policy and capital responses") ///
    name(F05_policy_capital, replace)

graph save "$LOCAL_FIGURES/F05__core_policy__stata.gph", replace
graph export "$LOCAL_FIGURES/F05__core_policy__stata.pdf", replace
graph export "$LOCAL_FIGURES/F05__core_policy__stata.png", ///
    width(2550) replace

log close
exit 0
