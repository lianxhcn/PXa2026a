version 19
clear all
set more off
log using "D:/github_lianxh/PXa2026a/examples/Baker-2026-DiD-ChatGPT-to-Codex/02_replication/logs/global-package-check.log", replace text
foreach pkg in csdid drdid honestdid regsave estout coefplot grc1leg2 reghdfe ftools {
    capture noisily which `pkg'
    di as result "CHECK `pkg' rc=" _rc
}
log close
exit
