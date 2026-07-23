*--------------------------------------------------------------------------*
* Project:      Lane (2025, QJE) core Stata replication
* Purpose:      Combine validated F02 native Stata graph panels.
* Upstream:     F02__official_graphs__from-do-1_run_growth_analysis.do
* Change type:  local output repair; no estimation is run in this script.
*--------------------------------------------------------------------------*

local work_parent "D:/github_lianxh/PXa2026a/examples"
local work_root "`work_parent'/lane_2025_qje_stata_core_replication"
do "`work_root'/code/00_setup_local.do"

capture log close
log using "$LOCAL_LOGS/F02__combine__official_graphs.log", replace text

local figdir "$LOCAL_FIGURES"
local required_graphs ///
    F02__five_digit__trend_panel.gph ///
    F02__four_digit__trend_panel.gph ///
    F02__five_digit__event_panel.gph ///
    F02__four_digit__event_panel.gph

foreach graph_file of local required_graphs {
    capture confirm file "`figdir'/`graph_file'"
    if _rc {
        display as error "Required graph is missing: `graph_file'"
        log close
        exit 601
    }
}

* Separate trend and event-study panels keep Stata's original graph labels
* readable.  A four-panel composite made the default event-study title
* overlap.

graph combine ///
    "`figdir'/F02__five_digit__trend_panel.gph" ///
    "`figdir'/F02__four_digit__trend_panel.gph", ///
    rows(1) cols(2) imargin(tiny) ///
    title("Industrial policy and log output: raw trends") ///
    name(F02_official_trends, replace)

graph save "`figdir'/F02__official_trends__stata.gph", replace
graph export "`figdir'/F02__official_trends__stata.pdf", replace
graph export "`figdir'/F02__official_trends__stata.png", ///
    width(2550) replace

graph combine ///
    "`figdir'/F02__five_digit__event_panel.gph" ///
    "`figdir'/F02__four_digit__event_panel.gph", ///
    rows(1) cols(2) imargin(tiny) ///
    name(F02_official_events, replace)

graph save "`figdir'/F02__official_events__stata.gph", replace
graph export "`figdir'/F02__official_events__stata.pdf", replace
graph export "`figdir'/F02__official_events__stata.png", ///
    width(2550) replace

log close
exit 0
