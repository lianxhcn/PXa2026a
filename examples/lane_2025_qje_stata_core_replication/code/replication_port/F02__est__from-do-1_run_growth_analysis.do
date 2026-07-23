*--------------------------------------------------------------------------*
* Project:      Lane (2025, QJE) core Stata replication
* Purpose:      Faithfully reproduce the source growth DID analysis for F02.
* Upstream:     code/0_analysis/1_main_scripts/1_run_growth_analysis.do
* Upstream SHA-256:
* 4123840186BDC03CB74BF4130FE5CFA2796AE9886F8D3A5B36AFBAA85DC25150
* Change type:  path_port only; all estimation settings follow the upstream.
* Input:        $SRC_DATA/input/mms_merged_harmonized_panel_cleaned4reg_
*               {4digit,5digit}.dta
* Output:       $LOCAL_INTERMEDIATE/F02__*.csv
*--------------------------------------------------------------------------*

local work_parent "D:/github_lianxh/PXa2026a/examples"
local work_root "`work_parent'/lane_2025_qje_stata_core_replication"
do "`work_root'/code/00_setup_local.do"

capture log close
log using "$LOCAL_LOGS/F02__est__from-do-1_run_growth_analysis.log", ///
    replace text

local outdir "$LOCAL_INTERMEDIATE"

capture program drop f02_prep_data
program define f02_prep_data
    args filenameargument
    use "`filenameargument'", clear
    xtset id year
    gen treat = (hci == 1 & year >= 1973)
end

capture program drop f02_export_reg_results
program define f02_export_reg_results, rclass
    args tmpmargindataset tmpdiddataset outputfilenameprefix

    use "`tmpdiddataset'", clear
    append using "`tmpmargindataset'"
    drop if missing(year)

    outsheet using ///
        "$LOCAL_INTERMEDIATE/`outputfilenameprefix'_all_results.csv", ///
        comma replace
end

capture program drop f02_add_metadata
program define f02_add_metadata
    args estimatename regressortype

    estadd local id_fe Yes, replace
    estadd local year_fe Yes, replace

    if "`regressortype'" == "basic_regressors" {
        estadd local control_indicator Yes, replace
    }
    else {
        estadd local control_indicator No, replace
    }

    estadd scalar N_cluster = e(N_clust), replace
end

capture program drop f02_append_plot_data
program define f02_append_plot_data
    args tmpmargin tmpdid variable regressorset modelnumber ///
        tmpmargindataset tmpdiddataset

    use "`tmpmargin'", clear
    gen outcome = "`variable'"
    gen command = "margins"
    gen regressortype = "`regressorset'"
    gen modelnumber = `modelnumber'
    rename v_t year
    rename v_mu coef
    rename set hci

    if `modelnumber' == 1 {
        save "`tmpmargindataset'"
    }
    else {
        append using "`tmpmargindataset'"
        save "`tmpmargindataset'", replace
    }

    use "`tmpdid'", clear
    gen outcome = "`variable'"
    gen command = "xtdidregress"
    gen regressortype = "`regressorset'"
    gen modelnumber = `modelnumber'
    rename *000 ci_lower
    rename *001 ci_upper
    rename *002 year
    rename *003 coef

    if `modelnumber' == 1 {
        save "`tmpdiddataset'"
    }
    else {
        append using "`tmpdiddataset'"
        save "`tmpdiddataset'", replace
    }
end

local basic_regressors ///
    c.(l_costs_0 l_avg_size_0 l_avg_wages_0 l_y_n_0)#i.year
local outcomevariablelist l_ship l_grossoutput l_valueadded
local estoutoptions ///
    cells(b(star fmt(3)) se(par fmt(3))) ///
    starlevels(* 0.10 ** 0.05 *** .01) ///
    stats(id_fe year_fe control_indicator r2 N N_cluster Fs ps, ///
        fmt(%9.3f %9.3f %9.3f 3 0 0 %9.3f) ///
        labels("Industry Effects" "Year Effects" "Controls" ///
        "\\(R^2\\)" Observations Clusters ///
        "Joint Test of Pre-Trend (F-Test)" ///
        "Joint Test of Pre-Trend (p-values)")) ///
    numbers noomitted nobaselevels ///
    mlabels(none) ///
    collabels(none)

* I. Five-digit panel: core output regressions in the paper.
local inputfile ///
    "$SRC_DATA/input/mms_merged_harmonized_panel_cleaned4reg_5digit.dta"
local outputfilenameprefix F02__five_digit
tempfile tmpmargindataset
tempfile tmpdiddataset
local modelnumber = 1

foreach variable of local outcomevariablelist {
    foreach regressorset in "" "basic_regressors" {
        tempfile tmpmargin`modelnumber'
        tempfile tmpdid`modelnumber'
        f02_prep_data "`inputfile'"

        quietly xtdidregress (`variable' ``regressorset'') (treat), ///
            group(id) time(year) vce(cluster id)
        estimates store did`modelnumber'_`variable'_5d
        f02_add_metadata did`variable'_`modelnumber' "`regressorset'"

        estat trendplots, ltrends noxline
        gph2xl, saving(`tmpmargin`modelnumber'') list
        capture serset clear
        capture graph drop _all

        quietly estat ptrends
        local pre_ftest = r(F)
        local pre_testprob = r(p)
        estadd scalar Fs = `pre_ftest', replace
        estadd scalar ps = `pre_testprob', replace

        estat grangerplot, baseline(1972) verbose post
        estat summarize
        estimates store event`modelnumber'_`variable'_5d
        f02_add_metadata did`variable'_`modelnumber' "`regressorset'"
        estadd scalar Fs = `pre_ftest', replace
        estadd scalar ps = `pre_testprob', replace

        gph2xl, saving(`tmpdid`modelnumber'') list
        capture serset clear
        capture graph drop _all

        f02_append_plot_data ///
            "`tmpmargin`modelnumber''" "`tmpdid`modelnumber''" ///
            "`variable'" "`regressorset'" `modelnumber' ///
            "`tmpmargindataset'" "`tmpdiddataset'"
        local modelnumber = `modelnumber' + 1
    }
}

estout event*_5d ///
    using "`outdir'/`outputfilenameprefix'_results_estout.csv", ///
    replace `estoutoptions' keep(_l*)
estout did*_5d ///
    using "`outdir'/`outputfilenameprefix'_prepost_estout.csv", ///
    replace `estoutoptions' keep(*.treat)
f02_export_reg_results ///
    "`tmpmargindataset'" "`tmpdiddataset'" "`outputfilenameprefix'"

* II. Four-digit panel: the parallel specification in the paper.
local inputfile ///
    "$SRC_DATA/input/mms_merged_harmonized_panel_cleaned4reg_4digit.dta"
local outputfilenameprefix F02__four_digit
tempfile tmpmargindataset
tempfile tmpdiddataset
local modelnumber = 1

foreach variable of local outcomevariablelist {
    foreach regressorset in "" "basic_regressors" {
        tempfile tmpmargin`modelnumber'
        tempfile tmpdid`modelnumber'
        f02_prep_data "`inputfile'"

        quietly xtdidregress (`variable' ``regressorset'') (treat), ///
            group(id) time(year) vce(cluster id)
        estimates store did`modelnumber'_`variable'_4d
        f02_add_metadata did`variable'_`modelnumber' "`regressorset'"

        estat trendplots, ltrends noxline
        gph2xl, saving(`tmpmargin`modelnumber'') list
        capture serset clear
        capture graph drop _all

        quietly estat ptrends
        local pre_ftest = r(F)
        local pre_testprob = r(p)
        estadd scalar Fs = `pre_ftest', replace
        estadd scalar ps = `pre_testprob', replace

        estat grangerplot, baseline(1972) verbose post
        estat summarize
        estimates store event`modelnumber'_`variable'_4d
        f02_add_metadata did`variable'_`modelnumber' "`regressorset'"
        estadd scalar Fs = `pre_ftest', replace
        estadd scalar ps = `pre_testprob', replace

        gph2xl, saving(`tmpdid`modelnumber'') list
        capture serset clear
        capture graph drop _all

        f02_append_plot_data ///
            "`tmpmargin`modelnumber''" "`tmpdid`modelnumber''" ///
            "`variable'" "`regressorset'" `modelnumber' ///
            "`tmpmargindataset'" "`tmpdiddataset'"
        local modelnumber = `modelnumber' + 1
    }
}

estout event*_4d ///
    using "`outdir'/`outputfilenameprefix'_results_estout.csv", ///
    replace `estoutoptions' keep(_l*)
estout did*_4d ///
    using "`outdir'/`outputfilenameprefix'_prepost_estout.csv", ///
    replace `estoutoptions' keep(*.treat)
f02_export_reg_results ///
    "`tmpmargindataset'" "`tmpdiddataset'" "`outputfilenameprefix'"

log close
exit 0
