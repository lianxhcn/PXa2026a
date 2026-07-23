*--------------------------------------------------------------------------*
* Project:      Lane (2025, QJE) core Stata replication
* Purpose:      Configure a source-read-only, local-output-only workspace.
* Upstream:     No single upstream file. This is a local safety wrapper.
* Change type:  local infrastructure
*--------------------------------------------------------------------------*

version 18.0
clear all
set more off
set linesize 120

* Use forward slashes to work consistently in Stata on Windows.
local source_parent ///
    "D:/github_lianxh/PXa2026a/examples/Lane_2025_QJE_paper_codes"
global SOURCE_ROOT "`source_parent'/replicationpackage"
local work_parent "D:/github_lianxh/PXa2026a/examples"
global WORK_ROOT "`work_parent'/lane_2025_qje_stata_core_replication"

* Read only from SOURCE_ROOT. Generated files use only the paths below.
global SRC_DATA "$SOURCE_ROOT/data"
global SRC_CODE "$SOURCE_ROOT/code"
global LOCAL_DATA "$WORK_ROOT/data"
global LOCAL_INTERMEDIATE "$WORK_ROOT/data/intermediate"
global LOCAL_FIGURES "$WORK_ROOT/output/figures"
global LOCAL_TABLES "$WORK_ROOT/output/tables"
global LOCAL_LOGS "$WORK_ROOT/logs"

* Stop if either root is missing or if they accidentally coincide.
capture confirm file "$SOURCE_ROOT/README.md"
if _rc {
    display as error "Upstream source package was not found: $SOURCE_ROOT"
    exit 601
}

capture confirm file "$WORK_ROOT/README.md"
if _rc {
    display as error "Local work package was not found: $WORK_ROOT"
    exit 601
}

if "$SOURCE_ROOT" == "$WORK_ROOT" {
    display as error "SOURCE_ROOT and WORK_ROOT must differ."
    exit 498
}

* The paths already exist after initialization. These guards support reruns.
foreach dir in "$LOCAL_DATA" "$LOCAL_INTERMEDIATE" ///
    "$LOCAL_FIGURES" "$LOCAL_TABLES" "$LOCAL_LOGS" {
    capture mkdir "`dir'"
}

cd "$WORK_ROOT"
capture log close
log using "$LOCAL_LOGS/00_setup_local.log", replace text

display as text "Source package (read only): $SOURCE_ROOT"
display as text "Local work package:        $WORK_ROOT"
display as text "All generated artifacts remain under: $WORK_ROOT"

* Do not source upstream master.R or master do-files in this project.
* Their hard-coded output paths can write into the original source package.
