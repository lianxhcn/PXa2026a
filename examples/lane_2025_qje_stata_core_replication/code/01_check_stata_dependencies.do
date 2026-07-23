*--------------------------------------------------------------------------*
* Project:      Lane (2025, QJE) core Stata replication
* Purpose:      Check required Stata commands without running any analysis.
* Upstream:     setup/setup.do in the upstream source package.
* Change type:  local infrastructure; no upstream files are modified.
*--------------------------------------------------------------------------*

local work_parent "D:/github_lianxh/PXa2026a/examples"
local work_root "`work_parent'/lane_2025_qje_stata_core_replication"
do "`work_root'/code/00_setup_local.do"

capture log close
log using "$LOCAL_LOGS/01_check_stata_dependencies.log", replace text

local required_cmds ///
    reghdfe ppmlhdfe ftools csdid drdid binscatter estout regsave ///
    erepost gph2xl estfe

local missing_cmds
local missing_count = 0
foreach cmd of local required_cmds {
    capture which `cmd'
    if _rc {
        display as error "Missing Stata command: `cmd'"
        local missing_cmds "`missing_cmds' `cmd'"
        local missing_count = `missing_count' + 1
    }
    else {
        display as text "Found Stata command: `cmd'"
    }
}

if `missing_count' > 0 {
    display as error "Missing commands:`missing_cmds'"
    log close
    exit 499
}

display as result "All required Stata commands are available."
log close
exit 0
