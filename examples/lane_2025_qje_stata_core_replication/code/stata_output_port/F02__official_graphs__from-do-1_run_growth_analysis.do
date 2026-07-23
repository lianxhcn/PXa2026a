*--------------------------------------------------------------------------*
* Project:      Lane (2025, QJE) core Stata replication
* Purpose:      Recreate the Figure 2 ingredients with native Stata graphs.
* Upstream:     code/0_analysis/1_main_scripts/1_run_growth_analysis.do
* Upstream R:   code/1_figures/Figure2.R
* Change type:  Stata-native output port; no R or gph2xl dependency.
* Input:        $SRC_DATA/input/mms_merged_harmonized_panel_cleaned4reg_
*               {4digit,5digit}.dta
* Output:       $LOCAL_FIGURES/F02__{panel}__{type}_panel.gph
*               $LOCAL_INTERMEDIATE/F02__official_pretrend_diagnostics.csv
*--------------------------------------------------------------------------*

local work_parent "D:/github_lianxh/PXa2026a/examples"
local work_root "`work_parent'/lane_2025_qje_stata_core_replication"
do "`work_root'/code/00_setup_local.do"

capture log close
log using "$LOCAL_LOGS/F02__official_graphs__from-upstream.log", ///
    replace text

local figdir "$LOCAL_FIGURES"
local datadir "$SRC_DATA/input"
local basic_regressors ///
    c.(l_costs_0 l_avg_size_0 l_avg_wages_0 l_y_n_0)#i.year

tempname diagnostics_handle
tempfile diagnostics_data
postfile `diagnostics_handle' str12 panel str10 specification ///
    double pretrend_f pretrend_p long observations ///
    using "`diagnostics_data'", replace

foreach panel in five_digit four_digit {
    if "`panel'" == "five_digit" {
        local input_name ///
            "mms_merged_harmonized_panel_cleaned4reg_5digit.dta"
        local panel_title "Panel A: Five-digit panel"
    }
    else {
        local input_name ///
            "mms_merged_harmonized_panel_cleaned4reg_4digit.dta"
        local panel_title "Panel B: Four-digit panel"
    }

    foreach specification in baseline controls {
        if "`specification'" == "baseline" {
            local controls
        }
        else {
            local controls "`basic_regressors'"
        }

        use "`datadir'/`input_name'", clear
        xtset id year
        gen treat = (hci == 1 & year >= 1973)

        quietly xtdidregress (l_ship `controls') (treat), ///
            group(id) time(year) vce(cluster id)
        local nobs = e(N)

        estat trendplots, ltrends noxline
        graph save ///
            "`figdir'/F02__`panel'__`specification'__trend.gph", replace
        capture graph drop _all

        quietly estat ptrends
        local pretrend_f = r(F)
        local pretrend_p = r(p)

        estat grangerplot, baseline(1972) verbose post title("")
        graph save ///
            "`figdir'/F02__`panel'__`specification'__event.gph", replace
        capture graph drop _all

        post `diagnostics_handle' ("`panel'") ("`specification'") ///
            (`pretrend_f') (`pretrend_p') (`nobs')
    }

    graph combine ///
        "`figdir'/F02__`panel'__baseline__trend.gph" ///
        "`figdir'/F02__`panel'__controls__trend.gph", ///
        rows(1) imargin(tiny) title("`panel_title'") ///
        name(F02_trend_`panel', replace)
    graph save "`figdir'/F02__`panel'__trend_panel.gph", replace

    graph combine ///
        "`figdir'/F02__`panel'__baseline__event.gph" ///
        "`figdir'/F02__`panel'__controls__event.gph", ///
        rows(1) imargin(tiny) ///
        title("`panel_title': event-study estimates") ///
        name(F02_event_`panel', replace)
    graph save "`figdir'/F02__`panel'__event_panel.gph", replace
}

postclose `diagnostics_handle'
use "`diagnostics_data'", clear
export delimited using ///
    "$LOCAL_INTERMEDIATE/F02__official_pretrend_diagnostics.csv", replace

* The separate combine script creates final trend and event-study figures.
* Separate figure types preserve labels after graph combine.

log close
exit 0
