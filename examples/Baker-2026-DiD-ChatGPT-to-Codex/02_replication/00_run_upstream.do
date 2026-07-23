/*
  目的：在项目副本中运行作者的 Stata 复现代码。
  说明：不读取或写入只读源目录；所有 ado 文件安装到本项目。
*/
version 19
clear all
set more off
capture log close

global repdir "D:/github_lianxh/PXa2026a/examples/Baker-2026-DiD-ChatGPT-to-Codex/02_replication"
global rootdir "$repdir/upstream_working"
global root "$repdir/upstream_working"

capture mkdir "$repdir/ado"
capture mkdir "$repdir/ado/plus"
capture mkdir "$repdir/logs"
capture mkdir "$repdir/tables"
capture mkdir "$repdir/figures"
sysdir set PLUS "$repdir/ado/plus"
sysdir set PERSONAL "$repdir/ado"
adopath ++ "$repdir/ado"
cd "$rootdir"

log using "$repdir/logs/upstream-formal.log", replace text
about
sysdir
adopath

* 作者使用 2025-11-29 的 SSC 镜像；镜像不可用时才回退到当前 SSC。
global sscdate "2025-11-29"
global sscmirror "raw.githubusercontent.com/labordynamicsinstitute/ssc-mirror/$sscdate"
foreach pkg in drdid csdid honestdid regsave estout coefplot grc1leg2 {
    capture which `pkg'
    if _rc {
        local pletter = substr("`pkg'", 1, 1)
        capture noisily net install `pkg', ///
            from(https://${sscmirror}/fmwww.bc.edu/repec/bocode/`pletter') replace
        if _rc {
            di as error "固定日期镜像未安装 `pkg'；尝试当前 SSC。"
            capture noisily ssc install `pkg', replace
        }
    }
    di as text "PACKAGE `pkg' rc=" _rc
    capture which `pkg'
}

foreach step in 0_stata_Make_data 1_stata_adoption_table ///
    2_stata_2x2 3_stata_2xT 4_stata_GxT 5_stata_honestdid {
    capture noisily do "scripts/Stata/`step'.do"
    local step_rc = _rc
    di as result "STEP `step' rc=`step_rc'"
}

* 保留工作副本中的原始输出，并复制一份到项目级结果目录供核验。
capture copy "tables/table1_stata.tex" "$repdir/tables/table1_stata.tex", replace
forvalues n = 2/7 {
    capture copy "tables/table`n'_stata.tex" ///
        "$repdir/tables/table`n'_stata.tex", replace
}
forvalues n = 1/9 {
    capture copy "figures/figure`n'_stata.pdf" ///
        "$repdir/figures/figure`n'_stata.pdf", replace
    capture copy "figures/figure`n'_stata.emf" ///
        "$repdir/figures/figure`n'_stata.emf", replace
}
log close
