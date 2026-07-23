*--------------------------------------------------------------------------*
* Project:      Lane (2025, QJE) core Stata replication
* Purpose:      Replace Figure2.R with a Stata graph using local CSV files.
* Upstream R:   code/1_figures/Figure2.R
* Upstream SHA-256:
* 8E2DB99731EF4D2F0BD1AFFA8A04FC5BA9A49629ABBD058A552833FD6BCCC4DB
* Change type:  r_to_stata_output_port; no model is estimated in this file.
* Input:        $LOCAL_INTERMEDIATE/F02__{five,four}_digit_all_results.csv
* Output:       $LOCAL_FIGURES/F02__from-r-Figure2__stata.{pdf,png,gph}
*--------------------------------------------------------------------------*

local work_parent "D:/github_lianxh/PXa2026a/examples"
local work_root "`work_parent'/lane_2025_qje_stata_core_replication"
do "`work_root'/code/00_setup_local.do"

capture log close
log using "$LOCAL_LOGS/F02__plot__from-r-Figure2.R.log", replace text

local idir "$LOCAL_INTERMEDIATE"
local fdir "$LOCAL_FIGURES"
local file5 "`idir'/F02__five_digit_all_results.csv"
local file4 "`idir'/F02__four_digit_all_results.csv"

foreach file in "`file5'" "`file4'" {
    capture confirm file "`file'"
    if _rc {
        display as error "Required F02 input does not exist: `file'"
        log close
        exit 601
    }
}

capture program drop f02_make_trend_graph
program define f02_make_trend_graph
    args infile paneltitle graphname

    import delimited using "`infile'", clear varnames(1)
    keep if outcome == "l_ship" & command == "margins"
    drop if missing(year) | missing(coef)
    gen spec = cond(regressortype == "", "Baseline", "Controls")

    quietly summarize year
    local minyear = r(min)
    local maxyear = r(max)

    twoway ///
        (line coef year if hci == 0, sort ///
            lcolor(black) lwidth(medthick)) ///
        (line coef year if hci == 1, sort ///
            lcolor(maroon) lwidth(medthick)), ///
        by(spec, cols(1) note("") imargin(small)) ///
        xline(1972 1979, lpattern(dash) lcolor(gs8)) ///
        xlabel(`minyear' 1972 1979 `maxyear') ///
        ytitle("Average log output (fitted values)") ///
        xtitle("") ///
        title("`paneltitle'") ///
        legend(order(1 "Non-targeted industries" 2 "Targeted (HCI)")) ///
        name(`graphname', replace)
end

capture program drop f02_make_event_graph
program define f02_make_event_graph
    args infile graphname

    import delimited using "`infile'", clear varnames(1)
    keep if outcome == "l_ship" & command == "xtdidregress"
    drop if missing(year) | missing(coef)
    gen spec = cond(regressortype == "", "Baseline", "Controls")

    quietly summarize year
    local minyear = r(min)
    local maxyear = r(max)

    twoway ///
        (rarea ci_lower ci_upper year, sort color(gs12%45) lcolor(none)) ///
        (line coef year, sort lcolor(black) lwidth(medthick)), ///
        by(spec, cols(1) note("") imargin(small)) ///
        yline(0, lcolor(gs8) lwidth(vthin)) ///
        xline(1972 1979, lpattern(dash) lcolor(gs8)) ///
        xlabel(`minyear' 1972 1979 `maxyear') ///
        ytitle("Estimated differences (coefficients)") ///
        xtitle("Year") ///
        legend(off) ///
        name(`graphname', replace)
end

f02_make_trend_graph "`file5'" "Panel A: Five-digit panel" f02_trend5
f02_make_trend_graph "`file4'" "Panel B: Four-digit panel" f02_trend4
f02_make_event_graph "`file5'" f02_event5
f02_make_event_graph "`file4'" f02_event4

graph combine f02_trend5 f02_trend4 f02_event5 f02_event4, ///
    rows(2) cols(2) xcommon imargin(tiny) ///
    title("Industrial policy and log output") ///
    name(f02_mainoutputplot, replace)

graph save "$fdir/F02__from-r-Figure2__stata.gph", replace
graph export "$fdir/F02__from-r-Figure2__stata.pdf", replace
graph export "$fdir/F02__from-r-Figure2__stata.png", ///
    width(2550) replace

log close
exit 0
