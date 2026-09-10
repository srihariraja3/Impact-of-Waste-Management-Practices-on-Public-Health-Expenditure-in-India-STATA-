* ============================================================
* PROJECT : Impact of Waste Management Practices on Public 
*           Health Expenditure in India (NFHS-5)
* FILE    : 00_setup.do
* PURPOSE : Define all project paths, set Stata preferences,
*           create any missing folders, and confirm setup.
*
* HOW TO USE:
*   Option 1 — Run this file directly before starting work.
*   Option 2 — Every other do-file calls this file at the top
*               automatically. So you can also just run any
*               do-file and setup will happen first.
*
* IMPORTANT — EDIT THIS ONE LINE BEFORE RUNNING:
*   Find the line that says  global project  and change the
*   path to match where your project folder actually is on
*   your computer.
*
* AUTHOR  : Srihari Raja
* CREATED : September 2025
* ============================================================


* ============================================================
* STEP 1: CLEAR STATA AND CLOSE ANY OPEN LOG
* ============================================================
* We do this first so we start with a completely clean slate.
* "capture" means: try this command, but do not crash if it
* fails. (For example, if no log is open, "log close" would
* normally give an error. "capture" suppresses that error.)

clear all
set more off
capture log close


* ============================================================
* STEP 2: DEFINE THE PROJECT ROOT PATH
* ============================================================
* THIS IS THE ONLY LINE YOU NEED TO CHANGE.
* Replace the path below with the full path to your project
* folder on your computer.
* Use forward slashes even on Windows (not backslashes).
*
* Example for Windows:
*   global project "C:/Users/sriha/OneDrive/Projects/Impact of Waste Management Practices on Public Health Expenditure in India (STATA)"
*
* Note: If your folder name has spaces (like this one does),
* the quotes around the path handle that correctly.

global project "C:\Users\sriha\OneDrive\Documents\Projects\Impact of Waste Management Practices on Public Health Expenditure in India (STATA)"


* ---- Verify the path exists by moving into it ----
* If this line produces an error, your path above is wrong.
* Check the spelling and that the folder actually exists.

cd "$project"


* ============================================================
* STEP 3: DEFINE ALL SUB-FOLDER PATHS AS NAMED SHORTCUTS
* ============================================================
* Instead of typing the full path every time, we define short
* names (called "globals") for each folder.
*
* In any other do-file, you can then write:
*   use "$raw_data/raw_nfhs5_household.dta"
* instead of the full path. This makes all code portable.

global admin         "$project/01_Admin"
global raw_data      "$project/02_Raw_Data"
global ext_data      "$project/03_External_Data"
global code          "$project/04_Code"
global logs          "$project/05_Logs"
global inter_data    "$project/06_Intermediate_Data"
global final_data    "$project/07_Final_Data"
global output        "$project/08_Output"
global tables        "$project/08_Output/Tables"
global figures       "$project/08_Output/Figures"
global docs          "$project/09_Documentation"
global archive       "$project/10_Archive"



* ============================================================
* STEP 4: SET STATA PREFERENCES
* ============================================================
* These settings make Stata behave consistently every time.

* Do not pause and ask "more?" when output is long
set more off

* Allow up to 32,767 variables in memory
* (The full NFHS-5 household file has ~3,500 variables,
*  so this gives us plenty of headroom)
set maxvar 32767

* Set output width so tables display properly
set linesize 120

* Scroll back enough lines to see full output
set scrollbufsize 500000


* ============================================================
* STEP 5: START A DATED LOG FILE
* ============================================================
* The log file records everything Stata does. This is your
* permanent record of the analysis. We use a date in the
* filename so that old logs are never overwritten.
*
* All log files are saved in 05_Logs/.

* Get today's date as a clean string (e.g., 04Sep2026)
local today = string(date(c(current_date), "DMY"), "%tdDDMonCCYY")

* Build the full path for the log file
local logfile "$logs/setup_`today'.log"

* Start the log (replace means: overwrite if it already 
* exists from an earlier run today)
log using "`logfile'", replace text


* ============================================================
* STEP 6: PRINT A CONFIRMATION MESSAGE
* ============================================================
* This appears in the Stata output window and in the log.
* It confirms that setup ran correctly and shows all paths.

di ""
di "============================================================"
di "  PROJECT SETUP — COMPLETE"
di "============================================================"
di "  Project: Waste Management and Public Health Expenditure"
di "           in India (NFHS-5)"
di "  Date   : `c(current_date)'"
di "  Time   : `c(current_time)'"
di "  User   : `c(username)'"
di "============================================================"
di ""
di "  Stata version  : `c(stata_version)'"
di "  Project root   : $project"
di ""
di "  Folder paths defined:"
di "    01_Admin           : $admin"
di "    02_Raw_Data        : $raw_data"
di "    03_External_Data   : $ext_data"
di "    04_Code            : $code"
di "    05_Logs            : $logs"
di "    06_Intermediate    : $inter_data"
di "    07_Final_Data      : $final_data"
di "    08_Output          : $output"
di "    08_Output/tables   : $tables"
di "    08_Output/figures  : $figures"
di "    09_Documentation   : $docs"
di "    10_Archive         : $archive"
di ""
di "============================================================"
di "  DO-FILE EXECUTION ORDER"
di "  Run these files one at a time, in this order."
di "  Check the output after each before running the next."
di "============================================================"
di "  00_setup.do              (this file — runs automatically)"
di "  01_data_audit.do         (inspect raw NFHS-5 data)"
di "  02_state_filter.do       (filter to 10 target states)"
di "  03_clean_indicators.do   (recode sanitation variables)"
di "  04_state_aggregation.do  (collapse to state level)"
di "  05_index_construction.do (build Waste Management Index)"
di "  06_merge_external_data.do(add PHE, literacy, GDP)"
di "  07_descriptive_analysis.do(tables and figures)"
di "  08_regression_analysis.do(OLS models)"
di "  09_robustness_checks.do  (diagnostics and sensitivity)"
di "============================================================"
di ""
di "  Setup log saved to:"
di "  `logfile'"
di ""

* Close the setup log
* (Each subsequent do-file will open its own log)
log close

di "  00_setup.do finished successfully."
di "  You may now run 01_data_audit.do"
di ""






* ============================================================
* PROJECT : Impact of Waste Management Practices on Public 
*           Health Expenditure in India (NFHS-5)
* FILE    : 01_data_audit.do
* PURPOSE : Inspect the raw NFHS-5 Household Recode data.
*           Verify that key variables exist, understand their
*           coding, and produce a record before any changes
*           are made to the data.
*
* INPUT   : 02_Raw_Data/IAHR7BFL.DTA
* OUTPUT  : 05_Logs/data_audit_[date].log  (audit report)
*           No datasets are saved — this is inspection only.
*
* IMPORTANT: Do NOT change or save the data in this file.
*            This is a read-only audit.
*
* AUTHOR  : Srihari Raja
* CREATED : September 2026
* ============================================================

* ============================================================
* OPEN A LOG FILE FOR THIS AUDIT
* ============================================================
* We open a separate log for this do-file. All output from
* this audit will be saved here for your records.

local today = string(date(c(current_date), "DMY"), "%tdDDMonCCYY")
log using "$logs/data_audit_`today'.log", replace text

di ""
di "============================================================"
di "  DATA AUDIT — NFHS-5 HOUSEHOLD RECODE"
di "  Started: `c(current_date)' at `c(current_time)'"
di "============================================================"


* ============================================================
* STEP 1: LOAD THE RAW DATA
* ============================================================
* We load the full NFHS-5 Household Recode (IAHR7BFL.DTA).
* This is a large file (~700MB+) and may take 1-3 minutes
* to load. Please be patient.
*
* "use" loads a Stata .dta file into memory.
* "clear" removes whatever was in memory before loading.

di ""
di "------------------------------------------------------------"
di "  STEP 1: LOADING RAW DATA"
di "------------------------------------------------------------"
di "  Loading: $raw_data/IAHR7BFL.DTA"
di "  Please wait — this may take a few minutes..."

use "$raw_data/IAHR7BFL.DTA", clear

di "  File loaded successfully."


* ============================================================
* STEP 2: BASIC FILE INFORMATION
* ============================================================
* "describe" shows the number of observations (rows) and
* variables (columns), plus the file label if any.
* This is the first sanity check — does the file look right?

di ""
di "------------------------------------------------------------"
di "  STEP 2: BASIC FILE INFORMATION"
di "------------------------------------------------------------"

describe, short

* Also show the dataset label if one exists
di "  Dataset label: `=substr(`"`: data label'"',1,100)'"


* ============================================================
* STEP 3: CONFIRM OBSERVATION COUNT
* ============================================================
* The full NFHS-5 household recode should have 636,699
* households. If the number is different, we need to know.

di ""
di "------------------------------------------------------------"
di "  STEP 3: OBSERVATION COUNT"
di "------------------------------------------------------------"

count
di "  Total households in raw file: " r(N)
di "  Expected (all-India NFHS-5):  636,699"

if r(N) == 636699 {
    di "  STATUS: COUNT MATCHES EXPECTED. Good."
}
else {
    di "  STATUS: COUNT DOES NOT MATCH. Investigate before proceeding."
}


* ============================================================
* STEP 4: EXAMINE THE STATE VARIABLE (hv024)
* ============================================================
* hv024 is the state/union territory identifier.
* This is the most important variable for our analysis.
*
* The old project used WRONG state codes for most states.
* We must get the correct codes from the actual data.
*
* "codebook" shows: variable label, codes, value labels,
* missing values, and basic distribution.
* "tab" shows the frequency distribution (counts per state).

di ""
di "------------------------------------------------------------"
di "  STEP 4: STATE VARIABLE — hv024"
di "------------------------------------------------------------"
di "  This is the most critical variable. We need the correct"
di "  numeric code for each state."
di ""

* Check if hv024 exists
capture confirm variable hv024
if _rc != 0 {
    di "  ERROR: hv024 does NOT exist in this dataset."
    di "  This is a serious problem. Check the file."
}
else {
    di "  hv024 exists. Examining..."
    di ""
    
    * Show full codebook entry
    codebook hv024
    
    di ""
    di "  Frequency table — all values of hv024:"
    di "  (This shows all states/UTs with their numeric codes)"
    di ""
    
    * Full frequency table with value labels
    tab hv024, missing
}


* ============================================================
* STEP 5: EXAMINE THE SAMPLING WEIGHT (hv005)
* ============================================================
* hv005 is the household sampling weight.
* In NFHS-5, weights have 6 implied decimal places.
* So the actual weight = hv005 / 1,000,000.
*
* Without weights, proportions will not represent the
* actual population accurately.

di ""
di "------------------------------------------------------------"
di "  STEP 5: SAMPLING WEIGHT — hv005"
di "------------------------------------------------------------"

capture confirm variable hv005
if _rc != 0 {
    di "  ERROR: hv005 does NOT exist in this dataset."
}
else {
    di "  hv005 exists. Examining..."
    codebook hv005
    summarize hv005
    di ""
    di "  Actual weight (hv005/1000000) — range:"
    summarize hv005
    di "  Min weight: " r(min)/1000000
    di "  Max weight: " r(max)/1000000
    di "  Mean weight: " r(mean)/1000000
}


* ============================================================
* STEP 6: EXAMINE URBAN/RURAL (hv025)
* ============================================================
* hv025 distinguishes urban from rural households.
* Standard DHS codes: 1 = Urban, 2 = Rural.
* We may use this for subgroup analysis later.

di ""
di "------------------------------------------------------------"
di "  STEP 6: URBAN/RURAL VARIABLE — hv025"
di "------------------------------------------------------------"

capture confirm variable hv025
if _rc != 0 {
    di "  ERROR: hv025 does NOT exist in this dataset."
}
else {
    codebook hv025
    tab hv025, missing
}


* ============================================================
* STEP 7: EXAMINE TOILET FACILITY VARIABLE (hv205)
* ============================================================
* hv205 records the type of toilet facility used.
* The old project used codes 1-6, which were WRONG.
* NFHS-5 actually uses codes starting at 11.
* We must verify the exact codes from the actual data.

di ""
di "------------------------------------------------------------"
di "  STEP 7: TOILET FACILITY — hv205"
di "------------------------------------------------------------"
di "  FORENSIC AUDIT NOTE: The old project used codes 1-6"
di "  which produced zero 'improved toilet' households."
di "  Correct NFHS-5 codes likely start at 11."
di "  We verify here from the actual data."
di ""

capture confirm variable hv205
if _rc != 0 {
    di "  ERROR: hv205 does NOT exist in this dataset."
}
else {
    codebook hv205
    di ""
    di "  Full frequency table:"
    tab hv205, missing
}


* ============================================================
* STEP 8: EXAMINE DRINKING WATER SOURCE (hv201)
* ============================================================
* hv201 records the main source of drinking water.
* The old project used codes 10-13 for improved sources.
* We verify the actual codes and distribution.

di ""
di "------------------------------------------------------------"
di "  STEP 8: DRINKING WATER SOURCE — hv201"
di "------------------------------------------------------------"

capture confirm variable hv201
if _rc != 0 {
    di "  ERROR: hv201 does NOT exist in this dataset."
}
else {
    codebook hv201
    di ""
    di "  Full frequency table:"
    tab hv201, missing
}


* ============================================================
* STEP 9: EXAMINE hv225 — SHARED TOILET / CHILD STOOL
* ============================================================
* CRITICAL AUDIT FINDING: The old project called hv225
* "safe child stool disposal" — but in NFHS-5, hv225
* actually means "share toilet with other households."
* These are completely different concepts.
* We verify the actual meaning here.

di ""
di "------------------------------------------------------------"
di "  STEP 9: VARIABLE hv225 — ACTUAL MEANING?"
di "------------------------------------------------------------"
di "  FORENSIC AUDIT NOTE: Old project described hv225 as"
di "  'safe child stool disposal' but NFHS-5 documentation"
di "  suggests it means 'share toilet with other households'."
di "  Verify here."
di ""

capture confirm variable hv225
if _rc != 0 {
    di "  ERROR: hv225 does NOT exist in this dataset."
}
else {
    codebook hv225
    di ""
    tab hv225, missing
}


* ============================================================
* STEP 10: EXAMINE HANDWASHING FACILITY (hv209)
* ============================================================
* hv209 records whether the household has a handwashing
* facility with water and soap.
* The old project referenced this variable but it was NOT
* present in the 10-variable subset they actually worked with.

di ""
di "------------------------------------------------------------"
di "  STEP 10: HANDWASHING FACILITY — hv209"
di "------------------------------------------------------------"

capture confirm variable hv209
if _rc != 0 {
    di "  ERROR: hv209 does NOT exist in this dataset."
    di "  This variable was referenced in the old project"
    di "  but may not be present. Investigate."
}
else {
    codebook hv209
    di ""
    tab hv209, missing
}


* ============================================================
* STEP 11: EXAMINE WASTE DISPOSAL METHOD (hv226)
* ============================================================
* hv226 records how solid waste is disposed of.
* The old project used codes 1 and 3 for "safe disposal."
* We verify the actual codes.

di ""
di "------------------------------------------------------------"
di "  STEP 11: SOLID WASTE DISPOSAL — hv226"
di "------------------------------------------------------------"

capture confirm variable hv226
if _rc != 0 {
    di "  ERROR: hv226 does NOT exist in this dataset."
    di "  This variable was referenced in the old project"
    di "  but may not be present. Investigate."
}
else {
    codebook hv226
    di ""
    tab hv226, missing
}


* ============================================================
* STEP 12: EXAMINE WASTE COLLECTION FREQUENCY (hv227)
* ============================================================
* hv227 records how often solid waste is collected.
* The old project used codes 1 and 2 for "regular."
* We verify the actual codes.

di ""
di "------------------------------------------------------------"
di "  STEP 12: WASTE COLLECTION FREQUENCY — hv227"
di "------------------------------------------------------------"

capture confirm variable hv227
if _rc != 0 {
    di "  ERROR: hv227 does NOT exist in this dataset."
    di "  This variable was referenced in the old project"
    di "  but may not be present. Investigate."
}
else {
    codebook hv227
    di ""
    tab hv227, missing
}


* ============================================================
* STEP 13: LOOK FOR CHILD STOOL DISPOSAL VARIABLE
* ============================================================
* If hv225 is NOT child stool disposal, what variable is?
* In DHS surveys, child stool disposal is often recorded
* in variables like hv238, s421, or similar.
* We search for it here.

di ""
di "------------------------------------------------------------"
di "  STEP 13: SEARCHING FOR CHILD STOOL DISPOSAL VARIABLE"
di "------------------------------------------------------------"
di "  Since hv225 appears to be 'share toilet', we look for"
di "  the actual child stool disposal variable."
di ""

* Check several candidate variables
foreach var in hv238 hv239 hv240 s421 s422 sh131 {
    capture confirm variable `var'
    if _rc == 0 {
        di "  FOUND: `var' exists in the dataset."
        codebook `var'
        di ""
    }
    else {
        di "  NOT FOUND: `var'"
    }
}

* Also search variable labels for the phrase "stool"
di ""
di "  Searching variable labels for 'stool'..."
quietly ds, has(type numeric)
local numvars `r(varlist)'

local stool_vars ""
foreach v of local numvars {
    local lbl : variable label `v'
    if regexm(lower("`lbl'"), "stool") {
        local stool_vars "`stool_vars' `v'"
        di "  Match: `v' — label: `lbl'"
    }
}

if "`stool_vars'" == "" {
    di "  No variables with 'stool' in the label found."
}


* ============================================================
* STEP 14: LOOK FOR DISTRICT VARIABLE
* ============================================================
* We may want district-level information for future work.
* Common DHS variable names for district: shdist, shdistrict,
* v024, or similar.

di ""
di "------------------------------------------------------------"
di "  STEP 14: DISTRICT AND GEOGRAPHIC IDENTIFIERS"
di "------------------------------------------------------------"

foreach var in hv001 hv002 hv006 hv007 hv008 shdist shdistrict {
    capture confirm variable `var'
    if _rc == 0 {
        local lbl : variable label `var'
        di "  EXISTS: `var' — `lbl'"
    }
    else {
        di "  NOT FOUND: `var'"
    }
}


* ============================================================
* STEP 15: CLUSTER AND HOUSEHOLD IDENTIFIERS
* ============================================================
* hv001 = cluster/PSU number
* hv002 = household number within cluster
* Together they uniquely identify each household.

di ""
di "------------------------------------------------------------"
di "  STEP 15: CLUSTER AND HOUSEHOLD IDENTIFIERS"
di "------------------------------------------------------------"

foreach var in hv001 hv002 {
    capture confirm variable `var'
    if _rc == 0 {
        local lbl : variable label `var'
        di "  EXISTS: `var' — `lbl'"
        summarize `var'
    }
}


* ============================================================
* STEP 16: CHECK hv230a (HANDWASHING PLACE) — FROM OLD SUBSET
* ============================================================
* The old 10-variable subset contained hv230a.
* Let us check whether the full file has it and what it means.

di ""
di "------------------------------------------------------------"
di "  STEP 16: HANDWASHING PLACE — hv230a"
di "------------------------------------------------------------"

capture confirm variable hv230a
if _rc != 0 {
    di "  hv230a NOT found in this dataset."
}
else {
    codebook hv230a
    tab hv230a, missing
}


* ============================================================
* STEP 17: SUMMARY OF AUDIT FINDINGS
* ============================================================

di ""
di "============================================================"
di "  AUDIT SUMMARY"
di "============================================================"
di "  The above output shows the actual NFHS-5 coding."
di "  Key things to look for when reviewing:"
di ""
di "  1. hv024: Do all 10 target states appear?"
di "     Target states: Bihar, West Bengal, Kerala,"
di "     Uttar Pradesh, Haryana, Tamil Nadu, Punjab,"
di "     Jharkhand, Assam, Maharashtra"
di ""
di "  2. hv205: What are the code ranges?"
di "     Improved toilet codes should be 11-16, NOT 1-6."
di ""
di "  3. hv225: Is this 'share toilet' or 'child stool'?"
di "     The label and value codes will tell us."
di ""
di "  4. hv209, hv226, hv227: Do these exist?"
di "     The old project used them but the subset did not."
di ""
di "  5. Any alternative child stool disposal variable found?"
di ""
di "  Review the output above carefully, then share it with"
di "  your research assistant to design the next step."
di "============================================================"

di ""
di "  Audit complete: `c(current_date)' at `c(current_time)'"

* ============================================================
* CLOSE LOG
* ============================================================
log close

di ""
di "  Log saved to: $logs/data_audit_`today'.log"
di "  Phase 1 complete."
di "  Next step: Share the log file, then we will write"
di "  02_state_filter.do with the correct state codes."




* ============================================================
* PROJECT : Impact of Waste Management Practices on Public 
*           Health Expenditure in India (NFHS-5)
* FILE    : 00_setup.do
* PURPOSE : Define all project paths, set Stata preferences,
*           create any missing folders, and confirm setup.
*
* HOW TO USE:
*   Option 1 — Run this file directly before starting work.
*   Option 2 — Every other do-file calls this file at the top
*               automatically. So you can also just run any
*               do-file and setup will happen first.
*
* IMPORTANT — EDIT THIS ONE LINE BEFORE RUNNING:
*   Find the line that says  global project  and change the
*   path to match where your project folder actually is on
*   your computer.
*
* AUTHOR  : Srihari Raja
* CREATED : September 2025
* ============================================================


* ============================================================
* STEP 1: CLEAR STATA AND CLOSE ANY OPEN LOG
* ============================================================
* We do this first so we start with a completely clean slate.
* "capture" means: try this command, but do not crash if it
* fails. (For example, if no log is open, "log close" would
* normally give an error. "capture" suppresses that error.)

clear all
set more off
capture log close


* ============================================================
* STEP 2: DEFINE THE PROJECT ROOT PATH
* ============================================================
* THIS IS THE ONLY LINE YOU NEED TO CHANGE.
* Replace the path below with the full path to your project
* folder on your computer.
* Use forward slashes even on Windows (not backslashes).
*
* Example for Windows:
*   global project "C:/Users/sriha/OneDrive/Projects/Impact of Waste Management Practices on Public Health Expenditure in India (STATA)"
*
* Note: If your folder name has spaces (like this one does),
* the quotes around the path handle that correctly.

global project "C:\Users\sriha\OneDrive\Documents\Projects\Impact of Waste Management Practices on Public Health Expenditure in India (STATA)"


* ---- Verify the path exists by moving into it ----
* If this line produces an error, your path above is wrong.
* Check the spelling and that the folder actually exists.

cd "$project"


* ============================================================
* STEP 3: DEFINE ALL SUB-FOLDER PATHS AS NAMED SHORTCUTS
* ============================================================
* Instead of typing the full path every time, we define short
* names (called "globals") for each folder.
*
* In any other do-file, you can then write:
*   use "$raw_data/raw_nfhs5_household.dta"
* instead of the full path. This makes all code portable.

global admin         "$project/01_Admin"
global raw_data      "$project/02_Raw_Data"
global ext_data      "$project/03_External_Data"
global code          "$project/04_Code"
global logs          "$project/05_Logs"
global inter_data    "$project/06_Intermediate_Data"
global final_data    "$project/07_Final_Data"
global output        "$project/08_Output"
global tables        "$project/08_Output/Tables"
global figures       "$project/08_Output/Figures"
global docs          "$project/09_Documentation"
global archive       "$project/10_Archive"



* ============================================================
* STEP 4: SET STATA PREFERENCES
* ============================================================
* These settings make Stata behave consistently every time.

* Do not pause and ask "more?" when output is long
set more off

* Allow up to 32,767 variables in memory
* (The full NFHS-5 household file has ~3,500 variables,
*  so this gives us plenty of headroom)
set maxvar 32767

* Set output width so tables display properly
set linesize 120

* Scroll back enough lines to see full output
set scrollbufsize 500000


* ============================================================
* STEP 5: START A DATED LOG FILE
* ============================================================
* The log file records everything Stata does. This is your
* permanent record of the analysis. We use a date in the
* filename so that old logs are never overwritten.
*
* All log files are saved in 05_Logs/.

* Get today's date as a clean string (e.g., 04Sep2026)
local today = string(date(c(current_date), "DMY"), "%tdDDMonCCYY")

* Build the full path for the log file
local logfile "$logs/setup_`today'.log"

* Start the log (replace means: overwrite if it already 
* exists from an earlier run today)
log using "`logfile'", replace text


* ============================================================
* STEP 6: PRINT A CONFIRMATION MESSAGE
* ============================================================
* This appears in the Stata output window and in the log.
* It confirms that setup ran correctly and shows all paths.

di ""
di "============================================================"
di "  PROJECT SETUP — COMPLETE"
di "============================================================"
di "  Project: Waste Management and Public Health Expenditure"
di "           in India (NFHS-5)"
di "  Date   : `c(current_date)'"
di "  Time   : `c(current_time)'"
di "  User   : `c(username)'"
di "============================================================"
di ""
di "  Stata version  : `c(stata_version)'"
di "  Project root   : $project"
di ""
di "  Folder paths defined:"
di "    01_Admin           : $admin"
di "    02_Raw_Data        : $raw_data"
di "    03_External_Data   : $ext_data"
di "    04_Code            : $code"
di "    05_Logs            : $logs"
di "    06_Intermediate    : $inter_data"
di "    07_Final_Data      : $final_data"
di "    08_Output          : $output"
di "    08_Output/tables   : $tables"
di "    08_Output/figures  : $figures"
di "    09_Documentation   : $docs"
di "    10_Archive         : $archive"
di ""
di "============================================================"
di "  DO-FILE EXECUTION ORDER"
di "  Run these files one at a time, in this order."
di "  Check the output after each before running the next."
di "============================================================"
di "  00_setup.do              (this file — runs automatically)"
di "  01_data_audit.do         (inspect raw NFHS-5 data)"
di "  02_state_filter.do       (filter to 10 target states)"
di "  03_clean_indicators.do   (recode sanitation variables)"
di "  04_state_aggregation.do  (collapse to state level)"
di "  05_index_construction.do (build Waste Management Index)"
di "  06_merge_external_data.do(add PHE, literacy, GDP)"
di "  07_descriptive_analysis.do(tables and figures)"
di "  08_regression_analysis.do(OLS models)"
di "  09_robustness_checks.do  (diagnostics and sensitivity)"
di "============================================================"
di ""
di "  Setup log saved to:"
di "  `logfile'"
di ""

* Close the setup log
* (Each subsequent do-file will open its own log)
log close

di "  00_setup.do finished successfully."
di "  You may now run 01_data_audit.do"
di ""





* ============================================================
* FILE    : 01b_variable_search.do
* PURPOSE : Search for actual solid waste and handwashing
*           variables in the NFHS-5 Household Recode.
*           This is a supplementary audit — run once only.
* ============================================================

quietly do "04_Code/00_setup.do"

local today = string(date(c(current_date), "DMY"), "%tdDDMonCCYY")
log using "$logs/variable_search_`today'.log", replace text

di "Searching for waste and sanitation variables..."
di ""

* Load data
use "$raw_data/IAHR7BFL.DTA", clear

* ---- Search 1: Variables with "waste" in the label ----
di "--- Variables with WASTE in label ---"
quietly ds, has(type numeric)
foreach v of varlist _all {
    local lbl : variable label `v'
    if regexm(lower("`lbl'"), "waste") {
        di "  `v' — `lbl'"
    }
}

* ---- Search 2: Variables with "garbage" in the label ----
di ""
di "--- Variables with GARBAGE in label ---"
foreach v of varlist _all {
    local lbl : variable label `v'
    if regexm(lower("`lbl'"), "garbage") {
        di "  `v' — `lbl'"
    }
}

* ---- Search 3: Variables with "handwash" in the label ----
di ""
di "--- Variables with HANDWASH in label ---"
foreach v of varlist _all {
    local lbl : variable label `v'
    if regexm(lower("`lbl'"), "handwash") {
        di "  `v' — `lbl'"
    }
}

* ---- Search 4: Variables with "sanit" in the label ----
di ""
di "--- Variables with SANIT in label ---"
foreach v of varlist _all {
    local lbl : variable label `v'
    if regexm(lower("`lbl'"), "sanit") {
        di "  `v' — `lbl'"
    }
}

* ---- Search 5: Variables with "collect" in the label ----
di ""
di "--- Variables with COLLECT in label ---"
foreach v of varlist _all {
    local lbl : variable label `v'
    if regexm(lower("`lbl'"), "collect") {
        di "  `v' — `lbl'"
    }
}

* ---- Search 6: Examine hv230a more carefully ----
di ""
di "--- hv230a and nearby variables (hv228-hv235) ---"
foreach var in hv228 hv229 hv230 hv230a hv230b hv231 hv232 hv233 hv234 hv235 {
    capture confirm variable `var'
    if _rc == 0 {
        local lbl : variable label `var'
        di "  EXISTS: `var' — `lbl'"
        codebook `var'
    }
    else {
        di "  NOT FOUND: `var'"
    }
}

* ---- Search 7: sh-prefix variables related to sanitation ----
di ""
di "--- sh-prefix variables (NFHS-specific additions) ---"
foreach var in shws1 shws2 shws3 shws4 shws5 shsw1 shsw2 ///
               shgarbage shwaste shcollect shsanit {
    capture confirm variable `var'
    if _rc == 0 {
        local lbl : variable label `var'
        di "  EXISTS: `var' — `lbl'"
        codebook `var'
    }
    else {
        di "  NOT FOUND: `var'"
    }
}

di ""
di "Search complete."
log close




* ============================================================
* PROJECT : Impact of Waste Management Practices on Public 
*           Health Expenditure in India (NFHS-5)
* FILE    : 02_state_filter.do
* PURPOSE : Filter the full NFHS-5 Household Recode to keep
*           only the 10 target states.
*
* INPUT   : 02_Raw_Data/IAHR7BFL.DTA
* OUTPUT  : 06_Intermediate_Data/nfhs5_10states.dta
*
* KEY CORRECTION FROM OLD PROJECT:
*   The old project used wrong hv024 codes for 8 of 10 states.
*   This file uses codes verified from the actual data.
*
* CORRECT hv024 CODES (verified from data audit):
*   Punjab       =  3   (old project used 33 — WRONG)
*   Haryana      =  6   (old project used 36 — WRONG)
*   Uttar Pradesh=  9   (old project used 27 — WRONG)
*   Bihar        = 10   (old project used 10 — correct)
*   Assam        = 18   (old project used 28 — WRONG)
*   West Bengal  = 19   (old project used 35 — WRONG)
*   Jharkhand    = 20   (old project used 29 — WRONG)
*   Maharashtra  = 27   (old project used 21 — WRONG)
*   Kerala       = 32   (old project used 32 — correct)
*   Tamil Nadu   = 33   (old project used  5 — WRONG)
*
* AUTHOR  : Srihari Raja
* CREATED : September 2026
* ============================================================


* ============================================================
* PRELIMINARY: RUN SETUP
* ============================================================

local today = string(date(c(current_date), "DMY"), "%tdDDMonCCYY")
log using "$logs/state_filter_`today'.log", replace text

di ""
di "============================================================"
di "  STATE FILTER — 02_state_filter.do"
di "  Started: `c(current_date)' at `c(current_time)'"
di "============================================================"


* ============================================================
* STEP 1: LOAD RAW DATA
* ============================================================
* We load the full file again. We only keep the variables
* we actually need — this makes the file much smaller and
* faster to work with in all later steps.
*
* "keep" after loading tells Stata to discard all other
* variables from memory (the raw file on disk is unchanged).

di ""
di "------------------------------------------------------------"
di "  STEP 1: LOADING RAW DATA AND KEEPING NEEDED VARIABLES"
di "------------------------------------------------------------"
di "  Loading full file — please wait..."

use "$raw_data/IAHR7BFL.DTA", clear

di "  Loaded. Obs = " _N

* Keep only the variables we will use in this project.
* This reduces memory from ~6,482 variables to ~20.
* The raw file on disk is NEVER changed.

keep  hv001      /// cluster number (PSU)
      hv002      /// household number
      hv024      /// state
      hv025      /// urban/rural
      hv005      /// sampling weight
      hv201      /// drinking water source
      hv205      /// toilet facility type
      hv225      /// share toilet with other households
      hv230a     /// place where members wash hands
      hv230b     /// water present at handwashing place
      hv232      /// soap/detergent present
      sh56a      /// kitchen waste: let out into drain/sewer
      sh56b      /// kitchen waste: open drain
      sh56c      /// kitchen waste: closed drain
      sh56d      /// kitchen waste: reuse for garden/farming
      sh56e      /// kitchen waste: reuse for domestic purposes
      sh56f      /// kitchen waste: manual collection
      sh56x      /// kitchen waste: other

di "  Variables reduced to " c(k) " columns."
di "  Observations still = " _N " (no rows dropped yet)"


* ============================================================
* STEP 2: RECORD PRE-FILTER COUNTS
* ============================================================
* Before filtering, record how many households exist in each
* of our 10 target states. This is our reference point.

di ""
di "------------------------------------------------------------"
di "  STEP 2: PRE-FILTER STATE COUNTS (ALL-INDIA)"
di "------------------------------------------------------------"
di "  Counts for our 10 target states before filtering:"
di ""

* Show counts for each target state specifically
foreach code in 3 6 9 10 18 19 20 27 32 33 {
    count if hv024 == `code'
    local statename ""
    if `code' ==  3  local statename "Punjab"
    if `code' ==  6  local statename "Haryana"
    if `code' ==  9  local statename "Uttar Pradesh"
    if `code' == 10  local statename "Bihar"
    if `code' == 18  local statename "Assam"
    if `code' == 19  local statename "West Bengal"
    if `code' == 20  local statename "Jharkhand"
    if `code' == 27  local statename "Maharashtra"
    if `code' == 32  local statename "Kerala"
    if `code' == 33  local statename "Tamil Nadu"
    di "  hv024=`code'  `statename':  " r(N) " households"
}

di ""
count
di "  Total all-India: " r(N) " households"


* ============================================================
* STEP 3: FILTER TO 10 TARGET STATES
* ============================================================
* We now drop all households outside our 10 states.
* "keep if" means: keep rows where the condition is true.
* All other rows are removed from memory.
*
* IMPORTANT: The raw file on disk is NEVER changed.
* We will save the filtered data as a NEW file.

di ""
di "------------------------------------------------------------"
di "  STEP 3: FILTERING TO 10 TARGET STATES"
di "------------------------------------------------------------"

keep if inlist(hv024, 3, 6, 9, 10, 18, 19, 20, 27, 32, 33)

di "  Filtering complete."
di "  Observations after filter: " _N


* ============================================================
* STEP 4: CREATE A CLEAN STATE NAME VARIABLE
* ============================================================
* We add a text variable with the state name.
* This makes all later output readable — instead of seeing
* "hv024 = 9" we will see "Uttar Pradesh".

di ""
di "------------------------------------------------------------"
di "  STEP 4: CREATING STATE NAME VARIABLE"
di "------------------------------------------------------------"

gen state_name = ""
replace state_name = "Punjab"         if hv024 ==  3
replace state_name = "Haryana"        if hv024 ==  6
replace state_name = "Uttar Pradesh"  if hv024 ==  9
replace state_name = "Bihar"          if hv024 == 10
replace state_name = "Assam"          if hv024 == 18
replace state_name = "West Bengal"    if hv024 == 19
replace state_name = "Jharkhand"      if hv024 == 20
replace state_name = "Maharashtra"    if hv024 == 27
replace state_name = "Kerala"         if hv024 == 32
replace state_name = "Tamil Nadu"     if hv024 == 33

label var state_name "State name (10 study states)"

* Verify no state_name is blank
count if state_name == ""
if r(N) > 0 {
    di "  WARNING: " r(N) " observations have a blank state name."
    di "  Check hv024 codes."
}
else {
    di "  All observations have a state name assigned. Good."
}


* ============================================================
* STEP 5: POST-FILTER VERIFICATION
* ============================================================
* Confirm everything looks right before saving.

di ""
di "------------------------------------------------------------"
di "  STEP 5: POST-FILTER VERIFICATION"
di "------------------------------------------------------------"
di ""
di "  Household counts by state after filtering:"
di ""

tab state_name, missing

di ""
di "  Urban/rural breakdown across 10 states:"
tab hv025, missing

di ""
di "  Sampling weight — quick check:"
summarize hv005
di "  Mean weight (divided by 1m): " r(mean)/1000000
di "  Min weight (divided by 1m):  " r(min)/1000000
di "  Max weight (divided by 1m):  " r(max)/1000000

di ""
count if hv005 == . 
di "  Households with missing weight: " r(N)
if r(N) > 0 {
    di "  WARNING: Missing weights found. Investigate."
}
else {
    di "  No missing weights. Good."
}


* ============================================================
* STEP 6: SAVE INTERMEDIATE DATASET
* ============================================================
* We save the filtered dataset as a new .dta file.
* This is what all later do-files will load.
* The raw file is NEVER modified.

di ""
di "------------------------------------------------------------"
di "  STEP 6: SAVING INTERMEDIATE DATASET"
di "------------------------------------------------------------"

* Add a note explaining what this file is
note: Created by 02_state_filter.do on `c(current_date)'
note: Contains `=_N' households from 10 study states
note: Filtered from full NFHS-5 Household Recode (IAHR7BFL.DTA)
note: Variables kept: identifiers, weight, sanitation indicators
note: hv024 codes verified from actual data — NOT from old project

save "$inter_data/nfhs5_10states.dta", replace

di "  Saved: $inter_data/nfhs5_10states.dta"
di "  Observations: " _N
di "  Variables: " c(k)


* ============================================================
* STEP 7: FINAL SUMMARY
* ============================================================

di ""
di "============================================================"
di "  STEP 7: SUMMARY"
di "============================================================"
di ""
di "  Raw file loaded:    636,699 households (all India)"
di "  After filtering:    " _N " households (10 states)"

* Calculate how many were dropped
local kept = _N
local dropped = 636699 - `kept'
di "  Households dropped: `dropped' (outside 10 states)"
di ""
di "  States included:"
di "    Punjab (hv024=3), Haryana (hv024=6)"
di "    Uttar Pradesh (hv024=9), Bihar (hv024=10)"
di "    Assam (hv024=18), West Bengal (hv024=19)"
di "    Jharkhand (hv024=20), Maharashtra (hv024=27)"
di "    Kerala (hv024=32), Tamil Nadu (hv024=33)"
di ""
di "  Output file: 06_Intermediate_Data/nfhs5_10states.dta"
di ""
di "  NEXT STEP: Run 03_clean_indicators.do"
di "============================================================"

log close
di "  Phase 2 complete."




* ============================================================
* PROJECT : Impact of Waste Management Practices on Public 
*           Health Expenditure in India (NFHS-5)
* FILE    : 03_clean_indicators.do
* PURPOSE : Recode NFHS-5 variables into clean binary 
*           sanitation indicators using verified codes.
*
* INPUT   : 06_Intermediate_Data/nfhs5_10states.dta
* OUTPUT  : 06_Intermediate_Data/nfhs5_indicators.dta
*
* INDICATORS CREATED:
*   improved_toilet    — hv205, WHO/JMP codes 11,12,13,21,22,41
*   improved_water     — hv201, WHO/JMP improved sources
*   handwashing_facility — hv230a + hv230b + hv232 (all three)
*   safe_waste_disposal  — sh56a/sh56c/sh56f (any safe method)
*   private_toilet     — hv225==0 (does not share toilet)
*
* CORRECTIONS FROM OLD PROJECT:
*   improved_toilet: old codes 1-6 were wrong (don't exist)
*   improved_water:  old codes 10-13 missed tube wells
*   handwashing:     hv209 is "has refrigerator" NOT handwashing
*   safe_waste:      hv226 is "cooking fuel" NOT waste disposal
*   child_stool:     hv225 is "shares toilet" NOT child stool
*   waste_collection: hv227 is "mosquito bed net" NOT collection
*
* AUTHOR  : Srihari Raja
* CREATED : September 2026
* ============================================================


* ============================================================
* PRELIMINARY: RUN SETUP
* ============================================================

local today = string(date(c(current_date), "DMY"), "%tdDDMonCCYY")
log using "$logs/clean_indicators_`today'.log", replace text

di ""
di "============================================================"
di "  CLEAN INDICATORS — 03_clean_indicators.do"
di "  Started: `c(current_date)' at `c(current_time)'"
di "============================================================"


* ============================================================
* STEP 1: LOAD FILTERED DATA
* ============================================================
* We load the 10-state file saved by 02_state_filter.do.
* This is fast because it is much smaller than the full file.

di ""
di "------------------------------------------------------------"
di "  STEP 1: LOADING FILTERED DATA"
di "------------------------------------------------------------"

use "$inter_data/nfhs5_10states.dta", clear

di "  Loaded. Observations: " _N
di "  Variables: " c(k)


* ============================================================
* STEP 2: INDICATOR 1 — IMPROVED TOILET (hv205)
* ============================================================
* WHO/JMP definition of improved sanitation facilities:
*   11 = Flush to piped sewer system
*   12 = Flush to septic tank
*   13 = Flush to pit latrine
*   21 = Ventilated improved pit latrine (VIP)
*   22 = Pit latrine with slab
*   41 = Composting toilet
*
* NOT improved:
*   14 = Flush to somewhere else
*   15 = Flush, don't know where
*   23 = Pit latrine without slab / open pit
*   31 = No facility / bush / field
*   51 = Dry toilet (scavenging-based)
*   96 = Other
*
* NOTE: The old project used codes 1-6. These do not exist
* in NFHS-5. Every household would have been coded 0.
* We use the correct codes verified from the data audit.

di ""
di "------------------------------------------------------------"
di "  STEP 2: INDICATOR 1 — IMPROVED TOILET (hv205)"
di "------------------------------------------------------------"

* Start with missing for all
gen improved_toilet = .
label var improved_toilet "Improved toilet facility (WHO/JMP definition)"

* Code 0 for all non-missing hv205
replace improved_toilet = 0 if hv205 != .

* Code 1 for improved facilities (WHO/JMP codes)
replace improved_toilet = 1 if inlist(hv205, 11, 12, 13, 21, 22, 41)

* Verification
di "  Distribution of improved_toilet:"
tab improved_toilet, missing

di ""
di "  Cross-check against hv205 categories:"
tab hv205 improved_toilet, missing

* Quick sanity check
count if improved_toilet == 1
di "  Households with improved toilet: " r(N)
di "  Percentage: " string(r(N)/_N*100, "%6.1f") "%"


* ============================================================
* STEP 3: INDICATOR 2 — IMPROVED WATER SOURCE (hv201)
* ============================================================
* WHO/JMP improved water sources:
*   11 = Piped into dwelling
*   12 = Piped to yard/plot
*   13 = Piped to neighbour
*   14 = Public tap/standpipe
*   21 = Tube well or borehole  <-- CRITICAL: old project missed this
*   31 = Protected well
*   41 = Protected spring
*   51 = Rainwater
*   91 = Bottled water
*   92 = Community RO plant
*
* NOT improved:
*   32 = Unprotected well
*   42 = Unprotected spring
*   61 = River/dam/lake/pond/stream (surface water)
*   71 = Tanker truck
*   72 = Cart with small tank
*   96 = Other
*
* NOTE: Tube well (code 21) is the dominant improved source
* in rural India (~33% of all households) but the old project
* excluded it by using codes 10-13 only. This was a major error.

di ""
di "------------------------------------------------------------"
di "  STEP 3: INDICATOR 2 — IMPROVED WATER SOURCE (hv201)"
di "------------------------------------------------------------"

gen improved_water = .
label var improved_water "Improved drinking water source (WHO/JMP definition)"

replace improved_water = 0 if hv201 != .
replace improved_water = 1 if inlist(hv201, 11, 12, 13, 14, 21, 31, 41, 51, 91, 92)

* Verification
di "  Distribution of improved_water:"
tab improved_water, missing

di ""
di "  Cross-check against hv201 categories:"
tab hv201 improved_water, missing

count if improved_water == 1
di "  Households with improved water: " r(N)
di "  Percentage: " string(r(N)/_N*100, "%6.1f") "%"


* ============================================================
* STEP 4: INDICATOR 3 — HANDWASHING FACILITY (hv230a/b/hv232)
* ============================================================
* A "basic handwashing facility" requires ALL THREE:
*   (a) A designated place for handwashing (hv230a = 1)
*   (b) Water available at that place  (hv230b = 1)
*   (c) Soap or detergent present      (hv232 = 1)
*
* This follows WHO/UNICEF JMP criteria for a basic
* handwashing facility with soap and water.
*
* hv230a codes:
*   1 = observed (place exists and was seen)
*   3 = not observed: not in dwelling
*   4 = not observed: no permission to see
*   5 = not observed: other reason
*
* We only count code 1 (observed) as having a facility.
* Codes 3,4,5 mean the interviewer could not confirm it.
*
* hv230b: 1 = water available, 0 = water not available
* hv232:  1 = soap/detergent present, 0 = not present
*
* Missing logic:
*   If hv230a != 1, the facility was not confirmed — code 0
*   If hv230a == 1 but hv230b or hv232 is missing — code missing

di ""
di "------------------------------------------------------------"
di "  STEP 4: INDICATOR 3 — HANDWASHING FACILITY"
di "------------------------------------------------------------"
di "  Requires: place observed + water present + soap present"

* Step 4a: Check distributions of component variables
di ""
di "  hv230a (handwashing place):"
tab hv230a, missing

di ""
di "  hv230b (water at handwashing place):"
tab hv230b, missing

di ""
di "  hv232 (soap present):"
tab hv232, missing

* Step 4b: Build the composite indicator
* First, identify households where handwashing place is NOT observed
* These automatically score 0 (no functional facility)

gen handwashing_facility = .
label var handwashing_facility "Functional handwashing facility: place + water + soap"

* No facility confirmed: place not observed in any sense
replace handwashing_facility = 0 if hv230a != 1

* Place was observed: now check water and soap
* Both water (hv230b=1) and soap (hv232=1) must be present
replace handwashing_facility = 1 if hv230a == 1 & hv230b == 1 & hv232 == 1

* Place observed but water or soap missing/absent
replace handwashing_facility = 0 if hv230a == 1 & (hv230b == 0 | hv232 == 0)

* If place observed but water or soap is system-missing (.)
* leave as missing (we cannot confirm the facility)

* Verification
di ""
di "  Distribution of handwashing_facility:"
tab handwashing_facility, missing

count if handwashing_facility == 1
di "  Households with functional handwashing facility: " r(N)
di "  Percentage: " string(r(N)/_N*100, "%6.1f") "%"


* ============================================================
* STEP 5: INDICATOR 4 — SAFE KITCHEN WASTE DISPOSAL (sh56a-x)
* ============================================================
* sh56a to sh56x are multiple-response binary variables.
* Each records whether the household uses that disposal method.
* A household can use more than one method.
*
* We classify as SAFE if the household uses any of:
*   sh56a = 1  (let out into drain/sewer)
*   sh56c = 1  (closed drain)
*   sh56f = 1  (manual collection — formal pickup service)
*
* We classify as UNSAFE if ONLY:
*   sh56b = 1  (open drain)
*   sh56d = 1  (reuse for garden — not unsafe, but not formal)
*   sh56e = 1  (reuse for domestic purposes)
*   sh56x = 1  (other)
*
* If a household uses BOTH safe and unsafe methods,
* we classify as safe (1) — safe method present.
*
* Note on sh56d and sh56e: Garden/domestic reuse is not
* unsafe in a public health sense, but it is not "formal
* collection." We keep it as 0 unless also using a safe method.
* This is a conservative classification.

di ""
di "------------------------------------------------------------"
di "  STEP 5: INDICATOR 4 — SAFE KITCHEN WASTE DISPOSAL"
di "------------------------------------------------------------"

* Check all sh56 variables first
di "  Distribution of sh56 waste disposal variables:"
foreach var in sh56a sh56b sh56c sh56d sh56e sh56f sh56x {
    di ""
    di "  `var' — `: variable label `var'':"
    tab `var', missing
}

* Build the indicator
gen safe_waste_disposal = .
label var safe_waste_disposal "Safe kitchen waste disposal (drain/sewer/closed/collection)"

* Code 0 for all observations first
* (assumes unsafe unless proven safe)
replace safe_waste_disposal = 0

* Code 1 if any safe method is used
replace safe_waste_disposal = 1 if sh56a == 1  // drain/sewer
replace safe_waste_disposal = 1 if sh56c == 1  // closed drain
replace safe_waste_disposal = 1 if sh56f == 1  // manual collection

* Verification
di ""
di "  Distribution of safe_waste_disposal:"
tab safe_waste_disposal, missing

count if safe_waste_disposal == 1
di "  Households with safe waste disposal: " r(N)
di "  Percentage: " string(r(N)/_N*100, "%6.1f") "%"


* ============================================================
* STEP 6: INDICATOR 5 — PRIVATE TOILET ACCESS (hv225)
* ============================================================
* hv225 = "share toilet with other households"
*   0 = No  (household does NOT share — private access)
*   1 = Yes (household shares with other households)
*   . = Missing (asked only of households with a toilet)
*
* The 115,137 households with hv205=31 (no facility/open
* defecation) have hv225 missing because the question was
* not asked. They have NO toilet, so they cannot have
* private toilet access.
*
* We code:
*   1 = private toilet (hv225=0: has toilet and does not share)
*   0 = shared toilet  (hv225=1: has toilet but shares it)
*   0 = no toilet      (hv225=. : no facility at all)
*
* This means "0" captures two different situations:
* sharing a toilet, and having no toilet at all.
* The indicator measures "has own private toilet facility."
*
* NOTE: The old project coded hv225==1 as "safe" which is
* backwards — sharing a toilet is LESS sanitary, not more.

di ""
di "------------------------------------------------------------"
di "  STEP 6: INDICATOR 5 — PRIVATE TOILET ACCESS (hv225)"
di "------------------------------------------------------------"

di "  Original hv225 distribution:"
tab hv225, missing

gen private_toilet = .
label var private_toilet "Has private toilet (does not share, no open defecation)"

* Households with a toilet that they do not share = 1
replace private_toilet = 1 if hv225 == 0

* Households that share their toilet = 0
replace private_toilet = 0 if hv225 == 1

* Households with NO toilet (hv225 missing because hv205=31) = 0
* (They have no private toilet access)
replace private_toilet = 0 if hv225 == . & hv205 == 31

* Note: a small number may have hv225 missing for other reasons
* Check how many are still missing after the above
count if private_toilet == .
di "  Observations still missing after recoding: " r(N)

di ""
di "  Distribution of private_toilet:"
tab private_toilet, missing

count if private_toilet == 1
di "  Households with private toilet: " r(N)
di "  Percentage: " string(r(N)/_N*100, "%6.1f") "%"


* ============================================================
* STEP 7: SUMMARY TABLE — ALL FIVE INDICATORS
* ============================================================
* Print a clean summary showing the percentage of households
* with each indicator = 1, for all 10 states together.
* This is our first real result.

di ""
di "------------------------------------------------------------"
di "  STEP 7: SUMMARY — ALL FIVE INDICATORS (POOLED)"
di "------------------------------------------------------------"
di "  Percentage of households scoring 1 on each indicator:"
di "  (All 10 states combined, unweighted at this stage)"
di ""

foreach var in improved_toilet improved_water ///
               handwashing_facility safe_waste_disposal ///
               private_toilet {
    quietly count if `var' == 1
    local n1 = r(N)
    quietly count if `var' != .
    local ntot = r(N)
    local pct = `n1'/`ntot'*100
    di "  `var':  " string(`pct', "%5.1f") "% (" `n1' " of " `ntot' ")"
}

di ""
di "  Note: These are UNWEIGHTED proportions across all 10 states."
di "  Weighted state-level proportions are in 04_state_aggregation.do"


* ============================================================
* STEP 8: CHECK MISSING VALUES
* ============================================================
* Before saving, check how many missing values each
* indicator has. A large number of missing values could
* affect the aggregation in the next step.

di ""
di "------------------------------------------------------------"
di "  STEP 8: MISSING VALUE COUNTS"
di "------------------------------------------------------------"

foreach var in improved_toilet improved_water ///
               handwashing_facility safe_waste_disposal ///
               private_toilet {
    count if `var' == .
    di "  Missing in `var': " r(N) " (" ///
       string(r(N)/_N*100, "%5.2f") "%)"
}


* ============================================================
* STEP 9: SAVE DATASET WITH INDICATORS
* ============================================================

di ""
di "------------------------------------------------------------"
di "  STEP 9: SAVING DATASET WITH INDICATORS"
di "------------------------------------------------------------"

note: Updated by 03_clean_indicators.do on `c(current_date)'
note: Five binary sanitation indicators added
note: All indicators verified against NFHS-5 documentation
note: Codes verified from actual data, not from old project

save "$inter_data/nfhs5_indicators.dta", replace

di "  Saved: $inter_data/nfhs5_indicators.dta"
di "  Observations: " _N
di "  Variables: " c(k)


* ============================================================
* STEP 10: FINAL SUMMARY
* ============================================================

di ""
di "============================================================"
di "  PHASE 3 COMPLETE"
di "============================================================"
di ""
di "  Five verified indicators created:"
di "  1. improved_toilet    (hv205, codes 11,12,13,21,22,41)"
di "  2. improved_water     (hv201, WHO/JMP improved sources)"
di "  3. handwashing_facility (hv230a=1 + hv230b=1 + hv232=1)"
di "  4. safe_waste_disposal (sh56a=1 OR sh56c=1 OR sh56f=1)"
di "  5. private_toilet     (hv225=0: has toilet, does not share)"
di ""
di "  Output: 06_Intermediate_Data/nfhs5_indicators.dta"
di ""
di "  NEXT STEP: Run 04_state_aggregation.do"
di "============================================================"

log close
di "Phase 3 complete."




* ============================================================
* PROJECT : Impact of Waste Management Practices on Public 
*           Health Expenditure in India (NFHS-5)
* FILE    : 04_state_aggregation.do
* PURPOSE : Collapse household-level indicators to state-level
*           weighted proportions using NFHS-5 survey weights.
*
* INPUT   : 06_Intermediate_Data/nfhs5_indicators.dta
* OUTPUT  : 06_Intermediate_Data/state_level_wm.dta
*
* WHY WEIGHTS MATTER:
*   NFHS-5 uses stratified probability sampling. Each household
*   has a weight (hv005/1,000,000) representing how many
*   real households it stands for. Without weights, richer/
*   urban areas (which are often oversampled) would dominate
*   the state-level estimate. Weighted collapse gives us
*   the true population proportion for each state.
*
* AUTHOR  : Srihari Raja
* CREATED : September 2026
* ============================================================


* ============================================================
* PRELIMINARY: RUN SETUP
* ============================================================

local today = string(date(c(current_date), "DMY"), "%tdDDMonCCYY")
log using "$logs/state_aggregation_`today'.log", replace text

di ""
di "============================================================"
di "  STATE AGGREGATION — 04_state_aggregation.do"
di "  Started: `c(current_date)' at `c(current_time)'"
di "============================================================"


* ============================================================
* STEP 1: LOAD INDICATOR DATA
* ============================================================

di ""
di "------------------------------------------------------------"
di "  STEP 1: LOADING INDICATOR DATA"
di "------------------------------------------------------------"

use "$inter_data/nfhs5_indicators.dta", clear

di "  Loaded. Observations: " _N
di "  Variables: " c(k)


* ============================================================
* STEP 2: CREATE THE SURVEY WEIGHT VARIABLE
* ============================================================
* hv005 has 6 implied decimal places in NFHS-5.
* The actual decimal weight = hv005 / 1,000,000.
* This is standard DHS practice — the old project got this right.

di ""
di "------------------------------------------------------------"
di "  STEP 2: CREATING SURVEY WEIGHT VARIABLE"
di "------------------------------------------------------------"

gen weight = hv005 / 1000000
label var weight "Household sampling weight (hv005/1,000,000)"

summarize weight
di "  Min weight:  " r(min)
di "  Max weight:  " r(max)
di "  Mean weight: " r(mean)
di "  (Mean should be close to 1.0 for all-India; "
di "   higher here because we kept only 10 of 36 states)"


* ============================================================
* STEP 3: VERIFY PRE-COLLAPSE DATA
* ============================================================
* Before collapsing, confirm the household counts per state.
* These should match what we saw in Phase 2.

di ""
di "------------------------------------------------------------"
di "  STEP 3: PRE-COLLAPSE HOUSEHOLD COUNTS BY STATE"
di "------------------------------------------------------------"

tab state_name, missing


* ============================================================
* STEP 4: COLLAPSE TO STATE LEVEL
* ============================================================
* "collapse (mean) ... [w=weight], by(state_name)" computes
* the weighted mean of each indicator for each state.
*
* For a binary variable (0/1), the weighted mean equals
* the weighted proportion of households with the value 1.
* We then multiply by 100 to express as a percentage.
*
* The [w=weight] tells Stata to use our weight variable.
* "by(state_name)" means: compute separately for each state.
*
* After collapse, we will have exactly 10 observations —
* one row per state.

di ""
di "------------------------------------------------------------"
di "  STEP 4: COLLAPSING TO STATE LEVEL (WEIGHTED)"
di "------------------------------------------------------------"
di "  Computing weighted proportions by state..."
di "  This may take a moment..."

collapse (mean) improved_toilet    ///
               improved_water      ///
               handwashing_facility ///
               safe_waste_disposal  ///
               private_toilet       ///
         [w=weight], by(state_name)

di "  Collapse complete."
di "  Observations after collapse: " _N
di "  (Should be exactly 10 — one per state)"

* Confirm we have exactly 10 states
if _N != 10 {
    di "  WARNING: Expected 10 states but got " _N
    di "  Check state_name variable."
}
else {
    di "  Confirmed: 10 states. Good."
}


* ============================================================
* STEP 5: CONVERT PROPORTIONS TO PERCENTAGES
* ============================================================
* After collapse, each variable holds a proportion (0 to 1).
* We multiply by 100 to get percentages (0 to 100).
* This makes the index and tables easier to read and interpret.

di ""
di "------------------------------------------------------------"
di "  STEP 5: CONVERTING TO PERCENTAGES (x100)"
di "------------------------------------------------------------"

foreach var in improved_toilet improved_water ///
               handwashing_facility safe_waste_disposal ///
               private_toilet {
    replace `var' = `var' * 100
    format `var' %6.2f
}

* Rename for clarity — add "pct_" prefix to show these are percentages
rename improved_toilet     pct_improved_toilet
rename improved_water      pct_improved_water
rename handwashing_facility pct_handwashing
rename safe_waste_disposal  pct_safe_waste
rename private_toilet       pct_private_toilet

* Add labels
label var pct_improved_toilet  "% HH with improved toilet (WHO/JMP)"
label var pct_improved_water   "% HH with improved water source (WHO/JMP)"
label var pct_handwashing      "% HH with functional handwashing facility"
label var pct_safe_waste       "% HH with safe kitchen waste disposal"
label var pct_private_toilet   "% HH with private (non-shared) toilet"

di "  Variables renamed with pct_ prefix."


* ============================================================
* STEP 6: DISPLAY STATE-LEVEL RESULTS TABLE
* ============================================================
* This is our first real state-level result.
* Each row is a state; each column is a sanitation indicator.

di ""
di "------------------------------------------------------------"
di "  STEP 6: STATE-LEVEL WEIGHTED PROPORTIONS (%)"
di "------------------------------------------------------------"
di ""
di "  State-level sanitation indicators (weighted, %):"
di ""

* Sort by state name for readability
sort state_name

list state_name pct_improved_toilet pct_improved_water ///
     pct_handwashing pct_safe_waste pct_private_toilet, ///
     separator(0) noobs


* ============================================================
* STEP 7: CHECK FOR UNUSUAL VALUES
* ============================================================
* All percentages should be between 0 and 100.
* Any value outside this range indicates a problem.

di ""
di "------------------------------------------------------------"
di "  STEP 7: RANGE CHECK — ALL VALUES SHOULD BE 0 TO 100"
di "------------------------------------------------------------"

foreach var in pct_improved_toilet pct_improved_water ///
               pct_handwashing pct_safe_waste pct_private_toilet {
    summarize `var'
    if r(min) < 0 | r(max) > 100 {
        di "  WARNING: `var' has values outside [0,100]!"
    }
    else {
        di "  `var': min=" string(r(min),"%5.1f") ///
           "  max=" string(r(max),"%5.1f") "  — OK"
    }
}


* ============================================================
* STEP 8: SAVE STATE-LEVEL DATASET
* ============================================================

di ""
di "------------------------------------------------------------"
di "  STEP 8: SAVING STATE-LEVEL DATASET"
di "------------------------------------------------------------"

note: Created by 04_state_aggregation.do on `c(current_date)'
note: 10 state-level observations, weighted proportions
note: Weights: hv005/1,000,000 (standard DHS practice)
note: All percentages are survey-weighted population estimates

save "$inter_data/state_level_wm.dta", replace

di "  Saved: $inter_data/state_level_wm.dta"
di "  Observations: " _N
di "  Variables: " c(k)


* ============================================================
* STEP 9: SUMMARY TABLE FOR REVIEW
* ============================================================

di ""
di "============================================================"
di "  STEP 9: FINAL SUMMARY"
di "============================================================"
di ""
di "  Weighted state-level proportions produced for 10 states."
di "  Variables created:"
di "    pct_improved_toilet   — % with improved toilet (WHO/JMP)"
di "    pct_improved_water    — % with improved water (WHO/JMP)"
di "    pct_handwashing       — % with handwashing: place+water+soap"
di "    pct_safe_waste        — % with safe kitchen waste disposal"
di "    pct_private_toilet    — % with private (unshared) toilet"
di ""
di "  Output: 06_Intermediate_Data/state_level_wm.dta"
di "  Observations: 10 (one per state)"
di ""
di "  NEXT STEP: Run 05_index_construction.do"
di "============================================================"

log close
di "Phase 4 complete."




* ============================================================
* PROJECT : Impact of Waste Management Practices on Public 
*           Health Expenditure in India (NFHS-5)
* FILE    : 05_index_construction.do
* PURPOSE : Construct the Waste Management Index (WMI) from
*           the five verified state-level sanitation indicators.
*           Create state rankings and performance categories.
*           Produce bar chart of WMI by state.
*
* INPUT   : 06_Intermediate_Data/state_level_wm.dta
* OUTPUT  : 06_Intermediate_Data/state_level_wm.dta (updated)
*           08_Output/figures/fig_wmi_ranking.png
*           08_Output/tables/table_wmi_components.csv
*
* INDEX METHOD:
*   WMI = simple average of 5 indicator percentages
*   Range: 0 to 100 (higher = better sanitation)
*   Indicators: improved_toilet, improved_water, handwashing,
*               safe_waste, private_toilet
*
* AUTHOR  : Srihari Raja
* CREATED : September 2026
* ============================================================


* ============================================================
* PRELIMINARY: RUN SETUP
* ============================================================

local today = string(date(c(current_date), "DMY"), "%tdDDMonCCYY")
log using "$logs/index_construction_`today'.log", replace text

di ""
di "============================================================"
di "  INDEX CONSTRUCTION — 05_index_construction.do"
di "  Started: `c(current_date)' at `c(current_time)'"
di "============================================================"


* ============================================================
* STEP 1: LOAD STATE-LEVEL DATA
* ============================================================

di ""
di "------------------------------------------------------------"
di "  STEP 1: LOADING STATE-LEVEL DATA"
di "------------------------------------------------------------"

use "$inter_data/state_level_wm.dta", clear

di "  Loaded. Observations: " _N " (should be 10)"
di "  Variables: " c(k)

* Confirm all five indicators are present
foreach var in pct_improved_toilet pct_improved_water ///
               pct_handwashing pct_safe_waste pct_private_toilet {
    capture confirm variable `var'
    if _rc != 0 {
        di "  ERROR: `var' not found. Check state_level_wm.dta"
    }
}
di "  All five indicator variables confirmed present."


* ============================================================
* STEP 2: CONSTRUCT THE WASTE MANAGEMENT INDEX
* ============================================================
* Simple average of all five indicator percentages.
* Each indicator is already expressed as % (0-100).
*
* WMI = (toilet + water + handwashing + waste + private) / 5
*
* This is transparent and reproducible. Every indicator
* is given equal weight — no arbitrary prioritisation.

di ""
di "------------------------------------------------------------"
di "  STEP 2: CONSTRUCTING WASTE MANAGEMENT INDEX (WMI)"
di "------------------------------------------------------------"

gen wmi = (pct_improved_toilet  + ///
           pct_improved_water    + ///
           pct_handwashing       + ///
           pct_safe_waste        + ///
           pct_private_toilet)   / 5

label var wmi "Waste Management Index (simple avg of 5 indicators, 0-100)"
format wmi %6.2f

di "  WMI created. Summary:"
summarize wmi

di ""
di "  WMI by state:"
sort wmi
list state_name wmi, separator(0) noobs


* ============================================================
* STEP 3: CREATE STATE RANKINGS
* ============================================================
* We rank states from highest (best) to lowest (worst) WMI.
* Rank 1 = best performing state.

di ""
di "------------------------------------------------------------"
di "  STEP 3: STATE RANKINGS ON WMI"
di "------------------------------------------------------------"

* Sort descending and assign rank
gsort -wmi
gen wmi_rank = _n
label var wmi_rank "State rank on WMI (1 = best)"

di "  State rankings (1 = best WMI, 10 = worst WMI):"
di ""
list state_name wmi wmi_rank, separator(0) noobs


* ============================================================
* STEP 4: CREATE PERFORMANCE CATEGORIES
* ============================================================
* We classify states into three tiers based on WMI score:
*   Good     : WMI >= 75
*   Moderate : WMI >= 55 and < 75
*   Poor     : WMI < 55
*
* These thresholds are chosen to reflect natural groupings
* in the data. We will verify they make intuitive sense.
* Note: The old project used 33/67 thresholds which placed
* all states in "Moderate" — not a useful classification.

di ""
di "------------------------------------------------------------"
di "  STEP 4: PERFORMANCE CATEGORIES"
di "------------------------------------------------------------"

gen wmi_category = ""
replace wmi_category = "Good"     if wmi >= 75
replace wmi_category = "Moderate" if wmi >= 55 & wmi < 75
replace wmi_category = "Poor"     if wmi <  55
label var wmi_category "WMI performance category"

di "  Category distribution:"
tab wmi_category

di ""
di "  States by category:"
sort wmi_category wmi_rank
list state_name wmi wmi_rank wmi_category, separator(0) noobs


* ============================================================
* STEP 5: DISPLAY FULL SUMMARY TABLE
* ============================================================
* Show all five components plus the WMI in one table.
* This is the core descriptive result of the project.

di ""
di "------------------------------------------------------------"
di "  STEP 5: COMPLETE STATE-LEVEL TABLE"
di "------------------------------------------------------------"
di ""
di "  All indicators and WMI by state (sorted by WMI rank):"
di ""

sort wmi_rank
list state_name pct_improved_toilet pct_improved_water ///
     pct_handwashing pct_safe_waste pct_private_toilet ///
     wmi wmi_rank wmi_category, separator(0) noobs


* ============================================================
* STEP 6: LOG-TRANSFORM NOTE (FOR LATER REGRESSION)
* ============================================================
* We add a log-transformed WMI for optional use in regression.
* The main WMI (0-100 scale) will be the primary regressor.
* We note this here so it is documented.

di ""
di "------------------------------------------------------------"
di "  STEP 6: PREPARING FOR REGRESSION"
di "------------------------------------------------------------"
di "  WMI range: " string(wmi[10],"%5.2f") " to " string(wmi[1],"%5.2f")
di "  WMI will enter regression as the key independent variable."
di "  The dependent variable (PHE) will be log-transformed."
di "  WMI itself stays in its natural 0-100 scale."


* ============================================================
* STEP 7: EXPORT COMPONENT TABLE AS CSV
* ============================================================
* Save a clean table for documentation and potential use
* in the written report.

di ""
di "------------------------------------------------------------"
di "  STEP 7: EXPORTING COMPONENT TABLE"
di "------------------------------------------------------------"

sort wmi_rank

* Export to CSV
export delimited state_name pct_improved_toilet pct_improved_water ///
    pct_handwashing pct_safe_waste pct_private_toilet ///
    wmi wmi_rank wmi_category ///
    using "$tables/table_wmi_components.csv", replace

di "  Exported: $tables/table_wmi_components.csv"


* ============================================================
* STEP 8: BAR CHART — WMI RANKING BY STATE
* ============================================================
* A horizontal bar chart showing WMI for each state,
* sorted from highest to lowest.
* This is Figure 1 of the project.

di ""
di "------------------------------------------------------------"
di "  STEP 8: FIGURE — WMI RANKING BY STATE"
di "------------------------------------------------------------"

* Sort so highest WMI appears at top of chart
gsort -wmi

graph hbar wmi, over(state_name, sort(wmi) descending ///
        label(labsize(small))) ///
    bar(1, color(teal)) ///
    ytitle("Waste Management Index (0-100)", size(small)) ///
    title("Waste Management Index by State", size(medium)) ///
    subtitle("NFHS-5 (2019-21), Survey-Weighted Estimates", ///
             size(small)) ///
    note("Index = simple average of 5 indicators:" ///
         "improved toilet, improved water, handwashing," ///
         "safe waste disposal, private toilet access." ///
         "Source: NFHS-5 Household Recode (IAHR7BFL)", ///
         size(vsmall)) ///
    yline(75, lpattern(dash) lcolor(green) lwidth(thin)) ///
    yline(55, lpattern(dash) lcolor(orange) lwidth(thin)) ///
    graphregion(color(white)) ///
    plotregion(color(white))

graph export "$figures/fig01_wmi_ranking.png", ///
    replace width(1600) height(1200)

di "  Figure saved: $figures/fig01_wmi_ranking.png"


* ============================================================
* STEP 9: RADAR/COMPONENT COMPARISON — SIMPLE VERSION
* ============================================================
* A grouped bar chart comparing all 5 components across states.
* This shows which dimensions drive WMI differences.
* We show the top 3 and bottom 3 states for clarity.

di ""
di "------------------------------------------------------------"
di "  STEP 9: COMPONENT COMPARISON CHART (TOP 3 vs BOTTOM 3)"
di "------------------------------------------------------------"

* Keep only top 3 and bottom 3 for readability
* (Sorted by wmi_rank: rank 1,2,3 = best; 8,9,10 = worst)
preserve
    keep if wmi_rank <= 3 | wmi_rank >= 8

    * Reshape to long format for grouped bar chart
    reshape long pct_, i(state_name wmi_rank) ///
        j(indicator) string

    label var pct_ "Percentage of households (%)"

    * Shorten indicator names for the chart legend
    replace indicator = "Toilet"       if indicator == "improved_toilet"
    replace indicator = "Water"        if indicator == "improved_water"
    replace indicator = "Handwashing"  if indicator == "handwashing"
    replace indicator = "Waste"        if indicator == "safe_waste"
    replace indicator = "Private WC"  if indicator == "private_toilet"

    graph bar pct_, over(indicator, label(labsize(vsmall)) ///
            relabel(1 "Toilet" 2 "Water" 3 "Handwash" ///
                    4 "Waste" 5 "Private WC")) ///
        over(state_name, sort(wmi_rank) ///
             label(labsize(vsmall) angle(45))) ///
        bar(1, color(teal%80)) ///
        ytitle("% of Households", size(small)) ///
        title("Sanitation Indicators: Top 3 vs Bottom 3 States", ///
              size(medium)) ///
        subtitle("NFHS-5 (2019-21), Survey-Weighted", size(small)) ///
        note("Top 3 by WMI: shown left. Bottom 3 by WMI: shown right." ///
             "Source: NFHS-5 Household Recode", size(vsmall)) ///
        legend(size(vsmall) rows(1)) ///
        graphregion(color(white)) ///
        plotregion(color(white))

    graph export "$figures/fig02_component_comparison.png", ///
        replace width(1800) height(1200)
    
    di "  Figure saved: $figures/fig02_component_comparison.png"
restore


* ============================================================
* STEP 10: SAVE UPDATED DATASET
* ============================================================

di ""
di "------------------------------------------------------------"
di "  STEP 10: SAVING UPDATED DATASET"
di "------------------------------------------------------------"

sort wmi_rank

note: Updated by 05_index_construction.do on `c(current_date)'
note: WMI = simple average of 5 sanitation indicator percentages
note: Rankings and categories added

save "$inter_data/state_level_wm.dta", replace

di "  Saved: $inter_data/state_level_wm.dta"
di "  Now contains: 10 obs, WMI, ranks, categories, components"


* ============================================================
* STEP 11: FINAL SUMMARY
* ============================================================

di ""
di "============================================================"
di "  PHASE 5 COMPLETE"
di "============================================================"
di ""
di "  Waste Management Index constructed."
di ""
di "  Final state rankings:"
list state_name wmi wmi_rank wmi_category, separator(0) noobs
di ""
di "  Files created:"
di "    06_Intermediate_Data/state_level_wm.dta (updated)"
di "    08_Output/tables/table_wmi_components.csv"
di "    08_Output/figures/fig01_wmi_ranking.png"
di "    08_Output/figures/fig02_component_comparison.png"
di ""
di "  NEXT STEP: Run 06_merge_external_data.do"
di "  (We need to source and add public health expenditure,"
di "   literacy rate, and GDP per capita data)"
di "============================================================"

log close
di "Phase 5 complete."




* ============================================================
* PROJECT : Impact of Waste Management Practices on Public 
*           Health Expenditure in India (NFHS-5)
* FILE    : 06_merge_external_data.do
* PURPOSE : Import external datasets (PHE, literacy, GDP),
*           merge with NFHS-5 state-level indicators,
*           create the final analysis dataset.
*
* INPUT   : 06_Intermediate_Data/state_level_wm.dta
*           03_External_Data/public_health_expenditure.csv
*           03_External_Data/literacy_rates.csv
*           03_External_Data/gdp_per_capita.csv
*
* OUTPUT  : 07_Final_Data/final_analysis.dta
*           08_Output/tables/table_external_data.csv
*
* IMPORTANT — CREATE CSV FILES FIRST:
*   Before running this do-file, you must create the three
*   CSV files in 03_External_Data/ as documented in the
*   project notes. See methodology_notes.md for sources.
*
* AUTHOR  : Srihari Raja
* CREATED : September 2026
* ============================================================


* ============================================================
* PRELIMINARY: RUN SETUP
* ============================================================

local today = string(date(c(current_date), "DMY"), "%tdDDMonCCYY")
log using "$logs/merge_external_`today'.log", replace text

di ""
di "============================================================"
di "  MERGE EXTERNAL DATA — 06_merge_external_data.do"
di "  Started: `c(current_date)' at `c(current_time)'"
di "============================================================"


* ============================================================
* STEP 1: LOAD STATE-LEVEL WMI DATA
* ============================================================

di ""
di "------------------------------------------------------------"
di "  STEP 1: LOADING STATE-LEVEL WMI DATA"
di "------------------------------------------------------------"

use "$inter_data/state_level_wm.dta", clear

di "  Loaded. Observations: " _N
di "  Variables: " c(k)
list state_name wmi wmi_rank, separator(0) noobs


* ============================================================
* STEP 2: IMPORT AND MERGE PUBLIC HEALTH EXPENDITURE
* ============================================================
* We import the PHE CSV, then merge it to the WMI data
* using state_name as the key.
*
* "merge 1:1" means: each state appears exactly once in 
* both datasets (one-to-one match on state_name).
* After merging, _merge==3 means the state was found in both.
* _merge==1 means it was only in the WMI data (no PHE match).
* _merge==2 means it was only in the PHE data (no WMI match).
* We want all _merge==3.

di ""
di "------------------------------------------------------------"
di "  STEP 2: IMPORTING PUBLIC HEALTH EXPENDITURE DATA"
di "------------------------------------------------------------"

* Save current data temporarily
preserve

    * Import PHE CSV
    import delimited "$ext_data/public_health_expenditure.csv", ///
        varnames(1) clear
    
    di "  PHE data imported:"
    list, separator(0) noobs
    
    * Keep only the variables we need for merging
    keep state_name phe_per_capita phe_year phe_source
    
    * Save as temporary dta for merging
    tempfile phe_data
    save `phe_data'

restore

* Merge PHE into WMI data
merge 1:1 state_name using `phe_data'

di ""
di "  Merge result (_merge):"
tab _merge

* Check: all 10 states should match (all _merge == 3)
count if _merge != 3
if r(N) > 0 {
    di "  WARNING: " r(N) " states did not match."
    di "  Check spelling of state names in the CSV file."
    list state_name _merge if _merge != 3
}
else {
    di "  All 10 states matched successfully. Good."
}

drop _merge


* ============================================================
* STEP 3: IMPORT AND MERGE LITERACY RATES
* ============================================================

di ""
di "------------------------------------------------------------"
di "  STEP 3: IMPORTING LITERACY RATE DATA"
di "------------------------------------------------------------"

preserve

    import delimited "$ext_data/literacy_rates.csv", ///
        varnames(1) clear
    
    di "  Literacy data imported:"
    list, separator(0) noobs
    
    keep state_name literacy_rate literacy_year literacy_source
    
    tempfile lit_data
    save `lit_data'

restore

merge 1:1 state_name using `lit_data'

di ""
di "  Merge result (_merge):"
tab _merge

count if _merge != 3
if r(N) > 0 {
    di "  WARNING: " r(N) " states did not match."
    list state_name _merge if _merge != 3
}
else {
    di "  All 10 states matched. Good."
}

drop _merge


* ============================================================
* STEP 4: IMPORT AND MERGE GDP PER CAPITA
* ============================================================

di ""
di "------------------------------------------------------------"
di "  STEP 4: IMPORTING GDP PER CAPITA DATA"
di "------------------------------------------------------------"

preserve

    import delimited "$ext_data/gdp_per_capita.csv", ///
        varnames(1) clear
    
    di "  GDP data imported:"
    list, separator(0) noobs
    
    keep state_name gdp_per_capita gdp_year gdp_source
    
    tempfile gdp_data
    save `gdp_data'

restore

merge 1:1 state_name using `gdp_data'

di ""
di "  Merge result (_merge):"
tab _merge

count if _merge != 3
if r(N) > 0 {
    di "  WARNING: " r(N) " states did not match."
    list state_name _merge if _merge != 3
}
else {
    di "  All 10 states matched. Good."
}

drop _merge


* ============================================================
* STEP 5: CREATE TRANSFORMED VARIABLES FOR REGRESSION
* ============================================================
* The dependent variable is PHE per capita.
* We log-transform it because PHE is right-skewed.
* Log(PHE) also allows percentage interpretation of coefficients.
*
* We also log-transform GDP per capita for the same reason.
* Literacy rate stays in its natural percentage form.

di ""
di "------------------------------------------------------------"
di "  STEP 5: CREATING TRANSFORMED VARIABLES"
di "------------------------------------------------------------"

* Log of PHE (natural log)
gen ln_phe = ln(phe_per_capita)
label var ln_phe "Natural log of PHE per capita (INR)"
format ln_phe %6.3f

* Log of GDP per capita
gen ln_gdp = ln(gdp_per_capita)
label var ln_gdp "Natural log of GDP per capita (INR, current prices 2019-20)"
format ln_gdp %6.3f

* Confirm no missing values
di "  Missing values check:"
foreach var in phe_per_capita ln_phe literacy_rate gdp_per_capita ln_gdp {
    count if `var' == .
    di "    `var': " r(N) " missing"
}

di ""
di "  PHE per capita (INR) — summary:"
summarize phe_per_capita
di "  ln(PHE) — summary:"
summarize ln_phe
di "  Literacy rate (%) — summary:"
summarize literacy_rate
di "  GDP per capita (INR) — summary:"
summarize gdp_per_capita
di "  ln(GDP) — summary:"
summarize ln_gdp


* ============================================================
* STEP 6: VIEW THE COMPLETE MERGED DATASET
* ============================================================

di ""
di "------------------------------------------------------------"
di "  STEP 6: COMPLETE FINAL DATASET"
di "------------------------------------------------------------"
di "  All variables for the 10 states:"
di ""

sort wmi_rank

list state_name wmi wmi_rank phe_per_capita ln_phe ///
     literacy_rate gdp_per_capita, separator(0) noobs


* ============================================================
* STEP 7: QUICK CHECKS — DO THE NUMBERS MAKE SENSE?
* ============================================================
* Before saving, verify that the data patterns are sensible.

di ""
di "------------------------------------------------------------"
di "  STEP 7: SENSE CHECKS"
di "------------------------------------------------------------"

* Check 1: Kerala should have highest PHE
quietly summarize phe_per_capita
di "  Highest PHE state:"
list state_name phe_per_capita if phe_per_capita == r(max), noobs

di "  Lowest PHE state:"
list state_name phe_per_capita if phe_per_capita == r(min), noobs

* Check 2: Kerala should have highest literacy
quietly summarize literacy_rate  
di "  Highest literacy state:"
list state_name literacy_rate if literacy_rate == r(max), noobs

di "  Lowest literacy state:"
list state_name literacy_rate if literacy_rate == r(min), noobs

* Check 3: Simple correlation between WMI and ln_phe
di ""
di "  Correlation between WMI and ln(PHE):"
correlate wmi ln_phe
di "  (Negative = higher WMI associated with lower PHE)"
di "  (Positive = higher WMI associated with higher PHE)"
di "  NOTE: Kerala is high on both WMI and PHE, so the"
di "  direction of this correlation is not straightforward."

* Check 4: Correlation between WMI and literacy
di ""
di "  Correlation between WMI and literacy rate:"
correlate wmi literacy_rate


* ============================================================
* STEP 8: EXPORT EXTERNAL DATA TABLE
* ============================================================

di ""
di "------------------------------------------------------------"
di "  STEP 8: EXPORTING EXTERNAL DATA TABLE"
di "------------------------------------------------------------"

sort wmi_rank

export delimited state_name wmi wmi_rank phe_per_capita ///
    ln_phe literacy_rate gdp_per_capita ln_gdp ///
    using "$tables/table_external_data.csv", replace

di "  Exported: $tables/table_external_data.csv"


* ============================================================
* STEP 9: SAVE FINAL ANALYSIS DATASET
* ============================================================

di ""
di "------------------------------------------------------------"
di "  STEP 9: SAVING FINAL ANALYSIS DATASET"
di "------------------------------------------------------------"

note: Created by 06_merge_external_data.do on `c(current_date)'
note: Final dataset for regression analysis
note: n=10 states. Variables: WMI components, PHE, literacy, GDP
note: PHE source: RBI State Finances / NHA 2019-21 average
note: Literacy: Census of India 2011
note: GDP: RBI Handbook of Statistics, NSDP per capita 2019-20

save "$final_data/final_analysis.dta", replace

di "  Saved: $final_data/final_analysis.dta"
di "  Observations: " _N
di "  Variables: " c(k)


* ============================================================
* STEP 10: FINAL SUMMARY
* ============================================================

di ""
di "============================================================"
di "  PHASE 6 COMPLETE"
di "============================================================"
di ""
di "  Final analysis dataset created with:"
di "  - 10 state-level observations"
di "  - 5 NFHS-5 sanitation indicators (survey-weighted)"
di "  - Waste Management Index (WMI, 0-100)"
di "  - Public health expenditure per capita (INR, 2019-21)"
di "  - ln(PHE) for regression"
di "  - Literacy rate (%, Census 2011)"
di "  - GDP per capita (INR, current prices 2019-20)"
di "  - ln(GDP) for regression"
di ""
di "  Output: 07_Final_Data/final_analysis.dta"
di ""
di "  NEXT STEP: Run 07_descriptive_analysis.do"
di "============================================================"

log close
di "Phase 6 complete."




* ============================================================
* PROJECT : Impact of Waste Management Practices on Public 
*           Health Expenditure in India (NFHS-5)
* FILE    : 07_descriptive_analysis.do
* PURPOSE : Produce all descriptive tables and figures.
*           Explore the data before regression analysis.
*
* INPUT   : 07_Final_Data/final_analysis.dta
* OUTPUT  : 08_Output/tables/table_descriptive_stats.csv
*           08_Output/tables/table_correlation_matrix.csv
*           08_Output/figures/fig03_phe_by_state.png
*           08_Output/figures/fig04_scatter_wmi_phe.png
*           08_Output/figures/fig05_scatter_wmi_lnphe.png
*           08_Output/figures/fig06_indicators_heatmap.png
*
* AUTHOR  : Srihari Raja
* CREATED : September 2026
* ============================================================


* ============================================================
* PRELIMINARY: RUN SETUP
* ============================================================

local today = string(date(c(current_date), "DMY"), "%tdDDMonCCYY")
log using "$logs/descriptive_analysis_`today'.log", replace text

di ""
di "============================================================"
di "  DESCRIPTIVE ANALYSIS — 07_descriptive_analysis.do"
di "  Started: `c(current_date)' at `c(current_time)'"
di "============================================================"


* ============================================================
* STEP 1: LOAD FINAL DATA
* ============================================================

di ""
di "------------------------------------------------------------"
di "  STEP 1: LOADING FINAL ANALYSIS DATA"
di "------------------------------------------------------------"

use "$final_data/final_analysis.dta", clear

di "  Loaded. Observations: " _N
di "  Variables: " c(k)


* ============================================================
* STEP 2: SUMMARY STATISTICS TABLE
* ============================================================
* A clean summary of all key variables.
* This becomes Table 1 in the written report.

di ""
di "------------------------------------------------------------"
di "  STEP 2: SUMMARY STATISTICS"
di "------------------------------------------------------------"
di ""
di "  Key variables — summary statistics:"
di ""

summarize wmi pct_improved_toilet pct_improved_water ///
          pct_handwashing pct_safe_waste pct_private_toilet ///
          phe_per_capita ln_phe literacy_rate ///
          gdp_per_capita ln_gdp, separator(0)

* Export a clean descriptive stats table
* We manually build it for better formatting

di ""
di "  Detailed summary for report (mean, SD, min, max):"

foreach var in wmi pct_improved_toilet pct_improved_water ///
               pct_handwashing pct_safe_waste pct_private_toilet ///
               phe_per_capita literacy_rate gdp_per_capita {
    quietly summarize `var'
    local lbl : variable label `var'
    di "  `var' | mean=" string(r(mean),"%7.2f") ///
       " sd=" string(r(sd),"%6.2f") ///
       " min=" string(r(min),"%7.2f") ///
       " max=" string(r(max),"%7.2f")
}

* Export summary stats to CSV
* We use a loop to build a clean exportable dataset
preserve
    * Build a summary table manually
    local vars wmi pct_improved_toilet pct_improved_water ///
               pct_handwashing pct_safe_waste pct_private_toilet ///
               phe_per_capita ln_phe literacy_rate gdp_per_capita ln_gdp
    
    local nv : word count `vars'
    local i = 1
    
    * Create empty dataset for the table
    clear
    set obs `nv'
    gen variable = ""
    gen mean = .
    gen sd = .
    gen min = .
    gen max = .
    
    * Reload data to compute stats
    use "$final_data/final_analysis.dta", clear
    
    local i = 1
    foreach v of local vars {
        quietly summarize `v'
        local mean_`i' = r(mean)
        local sd_`i'   = r(sd)
        local min_`i'  = r(min)
        local max_`i'  = r(max)
        local nm_`i'   = "`v'"
        local i = `i' + 1
    }
    
    * Build the summary table
    clear
    set obs `nv'
    gen str30 variable = ""
    gen mean = .
    gen sd   = .
    gen min  = .
    gen max  = .
    
    forvalues i = 1/`nv' {
        replace variable = "`nm_`i''" in `i'
        replace mean = `mean_`i'' in `i'
        replace sd   = `sd_`i''   in `i'
        replace min  = `min_`i''  in `i'
        replace max  = `max_`i''  in `i'
    }
    
    export delimited using "$tables/table_descriptive_stats.csv", replace
    di "  Exported: $tables/table_descriptive_stats.csv"
restore


* ============================================================
* STEP 3: FULL CORRELATION MATRIX
* ============================================================
* Shows relationships between all key variables.
* This becomes Table 2 in the written report.

di ""
di "------------------------------------------------------------"
di "  STEP 3: CORRELATION MATRIX"
di "------------------------------------------------------------"
di ""
di "  Pearson correlation matrix (n=10 states):"
di ""

correlate wmi pct_improved_toilet pct_improved_water ///
          pct_handwashing pct_safe_waste pct_private_toilet ///
          phe_per_capita ln_phe literacy_rate ln_gdp

di ""
di "  Key correlations with ln(PHE):"
foreach var in wmi pct_improved_toilet pct_improved_water ///
               pct_handwashing pct_safe_waste pct_private_toilet ///
               literacy_rate ln_gdp {
    quietly correlate `var' ln_phe
    di "  `var' vs ln_phe: r = " string(r(rho), "%6.3f")
}


* ============================================================
* STEP 4: FIGURE 3 — PHE BY STATE (BAR CHART)
* ============================================================
* Shows the huge variation in state health spending.
* Kerala at ~7,400 vs Bihar at ~887 is a 8.4x difference.

di ""
di "------------------------------------------------------------"
di "  STEP 4: FIGURE 3 — PHE BY STATE"
di "------------------------------------------------------------"

sort phe_per_capita

graph hbar phe_per_capita, ///
    over(state_name, sort(phe_per_capita) descending ///
         label(labsize(small))) ///
    bar(1, color(sienna)) ///
    ytitle("Public Health Expenditure per capita (INR)", size(small)) ///
    title("Public Health Expenditure by State", size(medium)) ///
    subtitle("Average 2019-21, Government Health Spending", ///
             size(small)) ///
    note("Source: RBI State Finances / National Health Accounts." ///
         "INR = Indian Rupees. Values are 2019-21 averages.", ///
         size(vsmall)) ///
    graphregion(color(white)) ///
    plotregion(color(white))

graph export "$figures/fig03_phe_by_state.png", ///
    replace width(1600) height(1200)

di "  Figure saved: fig03_phe_by_state.png"


* ============================================================
* STEP 5: FIGURE 4 — SCATTER: WMI vs PHE (RAW SCALE)
* ============================================================
* This is the core bivariate picture.
* We label each state so the reader can see who is where.

di ""
di "------------------------------------------------------------"
di "  STEP 5: FIGURE 4 — SCATTER: WMI vs PHE"
di "------------------------------------------------------------"

* Sort so labels are readable
sort state_name

twoway (scatter phe_per_capita wmi, ///
            mlabel(state_name) ///
            mlabsize(vsmall) ///
            mlabposition(12) ///
            mcolor(teal) ///
            msize(medlarge)) ///
       (lfit phe_per_capita wmi, ///
            lcolor(sienna) ///
            lpattern(dash)), ///
    title("Waste Management vs Public Health Expenditure", ///
          size(medium)) ///
    subtitle("10 Indian States, NFHS-5 (2019-21)", size(small)) ///
    xtitle("Waste Management Index (0-100)", size(small)) ///
    ytitle("PHE per capita (INR)", size(small)) ///
    note("PHE = government public health expenditure per capita." ///
         "WMI = survey-weighted average of 5 sanitation indicators." ///
         "Dashed line = linear fit.", ///
         size(vsmall)) ///
    legend(off) ///
    graphregion(color(white)) ///
    plotregion(color(white))

graph export "$figures/fig04_scatter_wmi_phe.png", ///
    replace width(1600) height(1200)

di "  Figure saved: fig04_scatter_wmi_phe.png"


* ============================================================
* STEP 6: FIGURE 5 — SCATTER: WMI vs ln(PHE)
* ============================================================
* This is what the regression uses.
* The log scale compresses Kerala's outlier effect somewhat.

di ""
di "------------------------------------------------------------"
di "  STEP 6: FIGURE 5 — SCATTER: WMI vs ln(PHE)"
di "------------------------------------------------------------"

twoway (scatter ln_phe wmi, ///
            mlabel(state_name) ///
            mlabsize(vsmall) ///
            mlabposition(12) ///
            mcolor(teal) ///
            msize(medlarge)) ///
       (lfit ln_phe wmi, ///
            lcolor(sienna) ///
            lpattern(dash)), ///
    title("Waste Management vs ln(Public Health Expenditure)", ///
          size(medium)) ///
    subtitle("10 Indian States, NFHS-5 (2019-21)", size(small)) ///
    xtitle("Waste Management Index (0-100)", size(small)) ///
    ytitle("ln(PHE per capita)", size(small)) ///
    note("PHE log-transformed. WMI = survey-weighted avg of 5 indicators." ///
         "Dashed line = linear fit. n=10 states.", ///
         size(vsmall)) ///
    legend(off) ///
    graphregion(color(white)) ///
    plotregion(color(white))

graph export "$figures/fig05_scatter_wmi_lnphe.png", ///
    replace width(1600) height(1200)

di "  Figure saved: fig05_scatter_wmi_lnphe.png"


* ============================================================
* STEP 7: FIGURE 6 — INDICATORS PROFILE CHART
* ============================================================
* Dot plot showing all 5 indicators for all 10 states.
* States sorted by WMI rank. Better than the old bar chart.

di ""
di "------------------------------------------------------------"
di "  STEP 7: FIGURE 6 — INDICATORS PROFILE CHART"
di "------------------------------------------------------------"

* Reshape to long format for dot plot
preserve
    keep state_name wmi_rank pct_improved_toilet pct_improved_water ///
         pct_handwashing pct_safe_waste pct_private_toilet
    
    reshape long pct_, i(state_name wmi_rank) j(indicator) string
    
    * Clean up indicator names for the chart
    gen ind_label = ""
    replace ind_label = "Improved Toilet"  if indicator == "improved_toilet"
    replace ind_label = "Improved Water"   if indicator == "improved_water"
    replace ind_label = "Handwashing"      if indicator == "handwashing"
    replace ind_label = "Safe Waste"       if indicator == "safe_waste"
    replace ind_label = "Private Toilet"   if indicator == "private_toilet"
    
    * Create numeric state rank variable for ordering
    sort wmi_rank
    
    graph dot pct_, over(ind_label, sort(1)) ///
        over(state_name, sort(wmi_rank) ///
             label(labsize(vsmall))) ///
        title("Sanitation Indicators by State", size(medium)) ///
        subtitle("Sorted by Waste Management Index rank (best to worst)", ///
                 size(small)) ///
        ytitle("% of Households", size(small)) ///
        note("Survey-weighted estimates. NFHS-5 Household Recode (2019-21)." ///
             "States ordered left to right by WMI rank (Haryana=best, Jharkhand=worst).", ///
             size(vsmall)) ///
        graphregion(color(white))
    
    graph export "$figures/fig06_indicators_profile.png", ///
        replace width(2000) height(1400)
    
    di "  Figure saved: fig06_indicators_profile.png"
restore


* ============================================================
* STEP 8: COMPLETE DATA TABLE FOR REPORT
* ============================================================
* Export the full state-level table as CSV.
* This is the master data table for the written report.

di ""
di "------------------------------------------------------------"
di "  STEP 8: EXPORTING COMPLETE DATA TABLE"
di "------------------------------------------------------------"

sort wmi_rank

* Display for the log
list state_name wmi wmi_rank wmi_category ///
     phe_per_capita literacy_rate gdp_per_capita, ///
     separator(0) noobs

* Export
export delimited state_name wmi wmi_rank wmi_category ///
    pct_improved_toilet pct_improved_water pct_handwashing ///
    pct_safe_waste pct_private_toilet ///
    phe_per_capita ln_phe literacy_rate gdp_per_capita ln_gdp ///
    using "$tables/table_complete_data.csv", replace

di "  Exported: $tables/table_complete_data.csv"


* ============================================================
* STEP 9: KEY DESCRIPTIVE FINDINGS SUMMARY
* ============================================================

di ""
di "============================================================"
di "  STEP 9: KEY DESCRIPTIVE FINDINGS"
di "============================================================"
di ""
di "  WMI range: " string(wmi[10],"%5.2f") " to " string(wmi[1],"%5.2f")
di "  PHE range: " string(phe_per_capita[1],"%7.1f") " to " ///
                   string(phe_per_capita[10],"%7.1f") " INR per capita"
di ""
di "  Highest WMI: Haryana (83.78)"
di "  Lowest WMI:  Jharkhand (55.86)"
di "  Highest PHE: Kerala (INR 7,437.5)"
di "  Lowest PHE:  Bihar (INR 887.0)"
di ""
di "  KEY FINDING: WMI and ln(PHE) are POSITIVELY correlated"
di "  (r = +0.67). States with better sanitation also tend to"
di "  have higher public health spending. This reflects that"
di "  both are driven by overall state development level."
di "  Kerala is high on both WMI and PHE."
di "  Bihar is low on WMI but also low on PHE."
di "  This positive correlation is an important contextual"
di "  finding that the regression must address."
di ""
di "  NEXT STEP: Run 08_regression_analysis.do"
di "============================================================"

log close
di "Phase 7 complete."




* ============================================================
* PROJECT : Impact of Waste Management Practices on Public 
*           Health Expenditure in India (NFHS-5)
* FILE    : 07_descriptive_analysis.do
* PURPOSE : Produce all descriptive tables and figures.
*           Explore the data before regression analysis.
*
* INPUT   : 07_Final_Data/final_analysis.dta
* OUTPUT  : 08_Output/tables/table_descriptive_stats.csv
*           08_Output/tables/table_correlation_matrix.csv
*           08_Output/figures/fig03_phe_by_state.png
*           08_Output/figures/fig04_scatter_wmi_phe.png
*           08_Output/figures/fig05_scatter_wmi_lnphe.png
*           08_Output/figures/fig06_indicators_heatmap.png
*
* AUTHOR  : Srihari Raja
* CREATED : September 2026
* ============================================================


* ============================================================
* PRELIMINARY: RUN SETUP
* ============================================================

local today = string(date(c(current_date), "DMY"), "%tdDDMonCCYY")
log using "$logs/descriptive_analysis_`today'.log", replace text

di ""
di "============================================================"
di "  DESCRIPTIVE ANALYSIS — 07_descriptive_analysis.do"
di "  Started: `c(current_date)' at `c(current_time)'"
di "============================================================"


* ============================================================
* STEP 1: LOAD FINAL DATA
* ============================================================

di ""
di "------------------------------------------------------------"
di "  STEP 1: LOADING FINAL ANALYSIS DATA"
di "------------------------------------------------------------"

use "$final_data/final_analysis.dta", clear

di "  Loaded. Observations: " _N
di "  Variables: " c(k)


* ============================================================
* STEP 2: SUMMARY STATISTICS TABLE
* ============================================================
* A clean summary of all key variables.
* This becomes Table 1 in the written report.

di ""
di "------------------------------------------------------------"
di "  STEP 2: SUMMARY STATISTICS"
di "------------------------------------------------------------"
di ""
di "  Key variables — summary statistics:"
di ""

summarize wmi pct_improved_toilet pct_improved_water ///
          pct_handwashing pct_safe_waste pct_private_toilet ///
          phe_per_capita ln_phe literacy_rate ///
          gdp_per_capita ln_gdp, separator(0)

* Export a clean descriptive stats table
* We manually build it for better formatting

di ""
di "  Detailed summary for report (mean, SD, min, max):"

foreach var in wmi pct_improved_toilet pct_improved_water ///
               pct_handwashing pct_safe_waste pct_private_toilet ///
               phe_per_capita literacy_rate gdp_per_capita {
    quietly summarize `var'
    local lbl : variable label `var'
    di "  `var' | mean=" string(r(mean),"%7.2f") ///
       " sd=" string(r(sd),"%6.2f") ///
       " min=" string(r(min),"%7.2f") ///
       " max=" string(r(max),"%7.2f")
}

* Export summary stats to CSV
* We use a loop to build a clean exportable dataset
preserve
    * Build a summary table manually
    local vars wmi pct_improved_toilet pct_improved_water ///
               pct_handwashing pct_safe_waste pct_private_toilet ///
               phe_per_capita ln_phe literacy_rate gdp_per_capita ln_gdp
    
    local nv : word count `vars'
    local i = 1
    
    * Create empty dataset for the table
    clear
    set obs `nv'
    gen variable = ""
    gen mean = .
    gen sd = .
    gen min = .
    gen max = .
    
    * Reload data to compute stats
    use "$final_data/final_analysis.dta", clear
    
    local i = 1
    foreach v of local vars {
        quietly summarize `v'
        local mean_`i' = r(mean)
        local sd_`i'   = r(sd)
        local min_`i'  = r(min)
        local max_`i'  = r(max)
        local nm_`i'   = "`v'"
        local i = `i' + 1
    }
    
    * Build the summary table
    clear
    set obs `nv'
    gen str30 variable = ""
    gen mean = .
    gen sd   = .
    gen min  = .
    gen max  = .
    
    forvalues i = 1/`nv' {
        replace variable = "`nm_`i''" in `i'
        replace mean = `mean_`i'' in `i'
        replace sd   = `sd_`i''   in `i'
        replace min  = `min_`i''  in `i'
        replace max  = `max_`i''  in `i'
    }
    
    export delimited using "$tables/table_descriptive_stats.csv", replace
    di "  Exported: $tables/table_descriptive_stats.csv"
restore


* ============================================================
* STEP 3: FULL CORRELATION MATRIX
* ============================================================
* Shows relationships between all key variables.
* This becomes Table 2 in the written report.

di ""
di "------------------------------------------------------------"
di "  STEP 3: CORRELATION MATRIX"
di "------------------------------------------------------------"
di ""
di "  Pearson correlation matrix (n=10 states):"
di ""

correlate wmi pct_improved_toilet pct_improved_water ///
          pct_handwashing pct_safe_waste pct_private_toilet ///
          phe_per_capita ln_phe literacy_rate ln_gdp

di ""
di "  Key correlations with ln(PHE):"
foreach var in wmi pct_improved_toilet pct_improved_water ///
               pct_handwashing pct_safe_waste pct_private_toilet ///
               literacy_rate ln_gdp {
    quietly correlate `var' ln_phe
    di "  `var' vs ln_phe: r = " string(r(rho), "%6.3f")
}


* ============================================================
* STEP 4: FIGURE 3 — PHE BY STATE (BAR CHART)
* ============================================================
* Shows the huge variation in state health spending.
* Kerala at ~7,400 vs Bihar at ~887 is a 8.4x difference.

di ""
di "------------------------------------------------------------"
di "  STEP 4: FIGURE 3 — PHE BY STATE"
di "------------------------------------------------------------"

sort phe_per_capita

graph hbar phe_per_capita, ///
    over(state_name, sort(phe_per_capita) descending ///
         label(labsize(small))) ///
    bar(1, color(sienna)) ///
    ytitle("Public Health Expenditure per capita (INR)", size(small)) ///
    title("Public Health Expenditure by State", size(medium)) ///
    subtitle("Average 2019-21, Government Health Spending", ///
             size(small)) ///
    note("Source: RBI State Finances / National Health Accounts." ///
         "INR = Indian Rupees. Values are 2019-21 averages.", ///
         size(vsmall)) ///
    graphregion(color(white)) ///
    plotregion(color(white))

graph export "$figures/fig03_phe_by_state.png", ///
    replace width(1600) height(1200)

di "  Figure saved: fig03_phe_by_state.png"


* ============================================================
* STEP 5: FIGURE 4 — SCATTER: WMI vs PHE (RAW SCALE)
* ============================================================
* This is the core bivariate picture.
* We label each state so the reader can see who is where.

di ""
di "------------------------------------------------------------"
di "  STEP 5: FIGURE 4 — SCATTER: WMI vs PHE"
di "------------------------------------------------------------"

* Sort so labels are readable
sort state_name

twoway (scatter phe_per_capita wmi, ///
            mlabel(state_name) ///
            mlabsize(vsmall) ///
            mlabposition(12) ///
            mcolor(teal) ///
            msize(medlarge)) ///
       (lfit phe_per_capita wmi, ///
            lcolor(sienna) ///
            lpattern(dash)), ///
    title("Waste Management vs Public Health Expenditure", ///
          size(medium)) ///
    subtitle("10 Indian States, NFHS-5 (2019-21)", size(small)) ///
    xtitle("Waste Management Index (0-100)", size(small)) ///
    ytitle("PHE per capita (INR)", size(small)) ///
    note("PHE = government public health expenditure per capita." ///
         "WMI = survey-weighted average of 5 sanitation indicators." ///
         "Dashed line = linear fit.", ///
         size(vsmall)) ///
    legend(off) ///
    graphregion(color(white)) ///
    plotregion(color(white))

graph export "$figures/fig04_scatter_wmi_phe.png", ///
    replace width(1600) height(1200)

di "  Figure saved: fig04_scatter_wmi_phe.png"


* ============================================================
* STEP 6: FIGURE 5 — SCATTER: WMI vs ln(PHE)
* ============================================================
* This is what the regression uses.
* The log scale compresses Kerala's outlier effect somewhat.

di ""
di "------------------------------------------------------------"
di "  STEP 6: FIGURE 5 — SCATTER: WMI vs ln(PHE)"
di "------------------------------------------------------------"

twoway (scatter ln_phe wmi, ///
            mlabel(state_name) ///
            mlabsize(vsmall) ///
            mlabposition(12) ///
            mcolor(teal) ///
            msize(medlarge)) ///
       (lfit ln_phe wmi, ///
            lcolor(sienna) ///
            lpattern(dash)), ///
    title("Waste Management vs ln(Public Health Expenditure)", ///
          size(medium)) ///
    subtitle("10 Indian States, NFHS-5 (2019-21)", size(small)) ///
    xtitle("Waste Management Index (0-100)", size(small)) ///
    ytitle("ln(PHE per capita)", size(small)) ///
    note("PHE log-transformed. WMI = survey-weighted avg of 5 indicators." ///
         "Dashed line = linear fit. n=10 states.", ///
         size(vsmall)) ///
    legend(off) ///
    graphregion(color(white)) ///
    plotregion(color(white))

graph export "$figures/fig05_scatter_wmi_lnphe.png", ///
    replace width(1600) height(1200)

di "  Figure saved: fig05_scatter_wmi_lnphe.png"


* ============================================================
* STEP 7: FIGURE 6 — INDICATORS PROFILE CHART
* ============================================================
* Dot plot showing all 5 indicators for all 10 states.
* States sorted by WMI rank. Better than the old bar chart.

di ""
di "------------------------------------------------------------"
di "  STEP 7: FIGURE 6 — INDICATORS PROFILE CHART"
di "------------------------------------------------------------"

* Reshape to long format for dot plot
preserve
    keep state_name wmi_rank pct_improved_toilet pct_improved_water ///
         pct_handwashing pct_safe_waste pct_private_toilet
    
    reshape long pct_, i(state_name wmi_rank) j(indicator) string
    
    * Clean up indicator names for the chart
    gen ind_label = ""
    replace ind_label = "Improved Toilet"  if indicator == "improved_toilet"
    replace ind_label = "Improved Water"   if indicator == "improved_water"
    replace ind_label = "Handwashing"      if indicator == "handwashing"
    replace ind_label = "Safe Waste"       if indicator == "safe_waste"
    replace ind_label = "Private Toilet"   if indicator == "private_toilet"
    
    * Create numeric state rank variable for ordering
    sort wmi_rank
    
    graph dot pct_, over(ind_label, sort(1)) ///
        over(state_name, sort(wmi_rank) ///
             label(labsize(vsmall))) ///
        title("Sanitation Indicators by State", size(medium)) ///
        subtitle("Sorted by Waste Management Index rank (best to worst)", ///
                 size(small)) ///
        ytitle("% of Households", size(small)) ///
        note("Survey-weighted estimates. NFHS-5 Household Recode (2019-21)." ///
             "States ordered left to right by WMI rank (Haryana=best, Jharkhand=worst).", ///
             size(vsmall)) ///
        graphregion(color(white))
    
    graph export "$figures/fig06_indicators_profile.png", ///
        replace width(2000) height(1400)
    
    di "  Figure saved: fig06_indicators_profile.png"
restore


* ============================================================
* STEP 8: COMPLETE DATA TABLE FOR REPORT
* ============================================================
* Export the full state-level table as CSV.
* This is the master data table for the written report.

di ""
di "------------------------------------------------------------"
di "  STEP 8: EXPORTING COMPLETE DATA TABLE"
di "------------------------------------------------------------"

sort wmi_rank

* Display for the log
list state_name wmi wmi_rank wmi_category ///
     phe_per_capita literacy_rate gdp_per_capita, ///
     separator(0) noobs

* Export
export delimited state_name wmi wmi_rank wmi_category ///
    pct_improved_toilet pct_improved_water pct_handwashing ///
    pct_safe_waste pct_private_toilet ///
    phe_per_capita ln_phe literacy_rate gdp_per_capita ln_gdp ///
    using "$tables/table_complete_data.csv", replace

di "  Exported: $tables/table_complete_data.csv"


* ============================================================
* STEP 9: KEY DESCRIPTIVE FINDINGS SUMMARY
* ============================================================

di ""
di "============================================================"
di "  STEP 9: KEY DESCRIPTIVE FINDINGS"
di "============================================================"
di ""
di "  WMI range: " string(wmi[10],"%5.2f") " to " string(wmi[1],"%5.2f")
di "  PHE range: " string(phe_per_capita[1],"%7.1f") " to " ///
                   string(phe_per_capita[10],"%7.1f") " INR per capita"
di ""
di "  Highest WMI: Haryana (83.78)"
di "  Lowest WMI:  Jharkhand (55.86)"
di "  Highest PHE: Kerala (INR 7,437.5)"
di "  Lowest PHE:  Bihar (INR 887.0)"
di ""
di "  KEY FINDING: WMI and ln(PHE) are POSITIVELY correlated"
di "  (r = +0.67). States with better sanitation also tend to"
di "  have higher public health spending. This reflects that"
di "  both are driven by overall state development level."
di "  Kerala is high on both WMI and PHE."
di "  Bihar is low on WMI but also low on PHE."
di "  This positive correlation is an important contextual"
di "  finding that the regression must address."
di ""
di "  NEXT STEP: Run 08_regression_analysis.do"
di "============================================================"

log close
di "Phase 7 complete."





* ============================================================
* PROJECT : Impact of Waste Management Practices on Public 
*           Health Expenditure in India (NFHS-5)
* FILE    : 09_robustness_checks.do
* PURPOSE : Diagnostic tests, sensitivity analyses, and
*           improved Figure 6 (indicators profile chart).
*
* INPUT   : 07_Final_Data/final_analysis.dta
* OUTPUT  : 08_Output/figures/fig06_indicators_improved.png
*           08_Output/figures/fig08_residuals.png
*           08_Output/tables/table_sensitivity.csv
*           05_Logs/robustness_checks_[date].log
*
* ROBUSTNESS CHECKS:
*   1. Alternative index: weighted WMI
*   2. Alternative DV: PHE in levels (not log)
*   3. Influential observation check (Cook's D)
*   4. Residual plot from Model 2
*   5. Improved Figure 6 — indicators heatmap table
*
* AUTHOR  : Srihari Raja
* CREATED : September 2026
* ============================================================


* ============================================================
* PRELIMINARY: RUN SETUP
* ============================================================

local today = string(date(c(current_date), "DMY"), "%tdDDMonCCYY")
log using "$logs/robustness_checks_`today'.log", replace text

di ""
di "============================================================"
di "  ROBUSTNESS CHECKS — 09_robustness_checks.do"
di "  Started: `c(current_date)' at `c(current_time)'"
di "============================================================"


* ============================================================
* STEP 1: LOAD FINAL DATA
* ============================================================

use "$final_data/final_analysis.dta", clear

di "  Loaded: " _N " observations, " c(k) " variables."


* ============================================================
* STEP 2: IMPROVED FIGURE 6 — INDICATORS TABLE CHART
* ============================================================
* The original Fig 6 had overlapping labels.
* We replace it with a clean dot plot using abbreviated labels
* and explicit value labels on each point.

di ""
di "------------------------------------------------------------"
di "  STEP 2: IMPROVED FIGURE 6 — INDICATORS PROFILE"
di "------------------------------------------------------------"

* Sort by WMI rank for the chart
sort wmi_rank

* We build a simple, clean horizontal bar chart
* showing all 5 indicators, one set of bars per state.
* States are sorted from best (top) to worst (bottom).

* Reshape to long format
preserve
    keep state_name wmi_rank ///
         pct_improved_toilet pct_improved_water ///
         pct_handwashing pct_safe_waste pct_private_toilet
    
    * Create a numeric state ID for ordering
    gen state_id = 11 - wmi_rank
    * (Reverse so rank 1 = highest number = top of chart)
    
    reshape long pct_, i(state_name wmi_rank state_id) ///
                       j(indicator) string
    
    * Create short readable labels
    gen ind_short = ""
    replace ind_short = "1. Toilet"       if indicator == "improved_toilet"
    replace ind_short = "2. Water"        if indicator == "improved_water"
    replace ind_short = "3. Handwashing"  if indicator == "handwashing"
    replace ind_short = "4. Waste"        if indicator == "safe_waste"
    replace ind_short = "5. Private WC"   if indicator == "private_toilet"
    
    * Encode ind_short as numeric for ordering
    encode ind_short, gen(ind_num)
    
    * Build the chart — separate connected dots per state
    * Using twoway scatter with different symbols per indicator
    
    twoway ///
        (scatter state_id pct_ if ind_short == "1. Toilet", ///
            msymbol(circle) mcolor(teal) msize(medium)) ///
        (scatter state_id pct_ if ind_short == "2. Water", ///
            msymbol(diamond) mcolor(sienna) msize(medium)) ///
        (scatter state_id pct_ if ind_short == "3. Handwashing", ///
            msymbol(square) mcolor(navy) msize(medium)) ///
        (scatter state_id pct_ if ind_short == "4. Waste", ///
            msymbol(triangle) mcolor(purple) msize(medium)) ///
        (scatter state_id pct_ if ind_short == "5. Private WC", ///
            msymbol(plus) mcolor(dkgreen) msize(medium)), ///
    ylabel(1 "Jharkhand" 2 "Bihar" 3 "Assam" 4 "West Bengal" ///
           5 "Uttar Pradesh" 6 "Maharashtra" 7 "Tamil Nadu" ///
           8 "Punjab" 9 "Kerala" 10 "Haryana", ///
           labsize(small) angle(0)) ///
    xlabel(0(20)100, labsize(small)) ///
    xline(50, lpattern(dot) lcolor(gs12)) ///
    xline(75, lpattern(dot) lcolor(gs12)) ///
    xtitle("% of Households", size(small)) ///
    ytitle("State (sorted best to worst by WMI)", size(small)) ///
    title("Sanitation Indicators by State", size(medium)) ///
    subtitle("NFHS-5 (2019-21), Survey-Weighted Estimates", ///
             size(small)) ///
    legend(order(1 "Improved Toilet" 2 "Improved Water" ///
                 3 "Handwashing (place+water+soap)" ///
                 4 "Safe Waste Disposal" ///
                 5 "Private Toilet Access") ///
           size(vsmall) rows(2) position(6)) ///
    note("Vertical dotted lines at 50% and 75% for reference." ///
         "Source: NFHS-5 Household Recode (IAHR7BFL).", ///
         size(vsmall)) ///
    graphregion(color(white)) ///
    plotregion(color(white))
    
    graph export "$figures/fig06_indicators_improved.png", ///
        replace width(1800) height(1400)
    
    di "  Improved Figure 6 saved: fig06_indicators_improved.png"
restore


* ============================================================
* STEP 3: RESIDUAL DIAGNOSTIC PLOT (MODEL 2)
* ============================================================

di ""
di "------------------------------------------------------------"
di "  STEP 3: RESIDUAL DIAGNOSTIC PLOT (MODEL 2)"
di "------------------------------------------------------------"

regress ln_phe wmi literacy_rate ln_gdp

predict resid_m2, residuals
predict fitted_m2, xb

di "  Residual summary:"
summarize resid_m2
di "  Mean should be ~0: " string(r(mean), "%8.6f")

twoway ///
    (scatter resid_m2 fitted_m2, ///
        mlabel(state_name) ///
        mlabsize(vsmall) ///
        mlabposition(12) ///
        mcolor(teal) ///
        msize(medlarge)), ///
    yline(0, lcolor(gs8) lpattern(dash)) ///
    title("Residual Plot — Model 2", size(medium)) ///
    subtitle("ln(PHE) ~ WMI + literacy + ln(GDP)", size(small)) ///
    xtitle("Fitted values (ln PHE)", size(small)) ///
    ytitle("Residuals", size(small)) ///
    note("Points above zero: actual PHE > predicted." ///
         "Points below zero: actual PHE < predicted." ///
         "Ideally, residuals should show no systematic pattern.", ///
         size(vsmall)) ///
    legend(off) ///
    graphregion(color(white)) ///
    plotregion(color(white))

graph export "$figures/fig08_residuals.png", ///
    replace width(1600) height(1200)

di "  Figure saved: fig08_residuals.png"

sort wmi_rank
list state_name fitted_m2 ln_phe resid_m2, separator(0) noobs


* ============================================================
* STEP 4: COOK'S DISTANCE — INFLUENTIAL OBSERVATIONS
* ============================================================
* Cook's D measures how much the regression results would
* change if we dropped each observation.
* A commonly used threshold: Cook's D > 4/n = 4/10 = 0.4
* Values above this suggest a potentially influential point.

di ""
di "------------------------------------------------------------"
di "  STEP 4: COOK'S DISTANCE (INFLUENTIAL OBSERVATIONS)"
di "------------------------------------------------------------"

* Rerun to get Cook's D
regress ln_phe wmi literacy_rate ln_gdp
predict cooksd, cooksd

local threshold = 4/10
di "  Threshold for concern: 4/n = " string(`threshold', "%5.2f")
di ""
di "  Cook's D by state:"

sort wmi_rank
list state_name cooksd, separator(0) noobs

di ""
count if cooksd > `threshold' & cooksd != .
di "  States with Cook's D > 0.4: " r(N)

list state_name cooksd wmi ln_phe if cooksd > `threshold' & cooksd != ., ///
     separator(0) noobs


* ============================================================
* STEP 5: SENSITIVITY CHECK 1 — ALTERNATIVE WMI WEIGHTING
* ============================================================
* Our main WMI uses equal weights for all 5 indicators.
* As a robustness check, we construct a weighted version
* that prioritises toilet (30%) and water (25%) access,
* then handwashing (20%), waste disposal (15%), private (10%).
* These weights reflect relative disease burden evidence.
* We test whether regression results change substantially.

di ""
di "------------------------------------------------------------"
di "  STEP 5: SENSITIVITY — WEIGHTED WMI"
di "------------------------------------------------------------"

* Construct weighted WMI
gen wmi_weighted = (0.30 * pct_improved_toilet + ///
                    0.25 * pct_improved_water   + ///
                    0.20 * pct_handwashing       + ///
                    0.15 * pct_safe_waste        + ///
                    0.10 * pct_private_toilet)

label var wmi_weighted "Weighted WMI (toilet 30%, water 25%, handwash 20%, waste 15%, private 10%)"

di "  Comparison: Simple vs Weighted WMI:"
sort wmi_rank
list state_name wmi wmi_weighted, separator(0) noobs

quietly correlate wmi wmi_weighted
di "  Correlation between simple and weighted WMI: r = " ///
   string(r(rho), "%6.4f")

* Run bivariate regression with weighted WMI
di ""
di "  Bivariate regression with WEIGHTED WMI:"
regress ln_phe wmi_weighted

local b_wt  = _b[wmi_weighted]
local se_wt = _se[wmi_weighted]
local p_wt  = 2*ttail(e(df_r), abs(_b[wmi_weighted]/_se[wmi_weighted]))
local r2_wt = e(r2)

di "  β(weighted WMI) = " string(`b_wt',  "%8.4f")
di "  SE              = " string(`se_wt', "%8.4f")
di "  p-value         = " string(`p_wt',  "%8.3f")
di "  R-squared       = " string(`r2_wt', "%8.3f")
di ""
di "  Compare to simple WMI bivariate: β=0.0391, p=0.034"
di "  If results are similar, the index construction is robust."


* ============================================================
* STEP 6: SENSITIVITY CHECK 2 — PHE IN LEVELS (NOT LOG)
* ============================================================
* Our main models use ln(PHE) as the dependent variable.
* We check whether using PHE in levels changes the conclusion.

di ""
di "------------------------------------------------------------"
di "  STEP 6: SENSITIVITY — PHE IN LEVELS (NOT LOG-TRANSFORMED)"
di "------------------------------------------------------------"

regress phe_per_capita wmi

local b_lev  = _b[wmi]
local se_lev = _se[wmi]
local p_lev  = 2*ttail(e(df_r), abs(_b[wmi]/_se[wmi]))
local r2_lev = e(r2)

di "  Bivariate regression: PHE (levels) ~ WMI"
di "  β(WMI)    = " string(`b_lev',  "%8.2f")
di "  SE        = " string(`se_lev', "%8.2f")
di "  p-value   = " string(`p_lev',  "%8.3f")
di "  R-squared = " string(`r2_lev', "%8.3f")
di ""
di "  Interpretation: Each 1-unit increase in WMI is associated"
di "  with a " string(`b_lev', "%6.1f") " INR change in PHE per capita."


* ============================================================
* STEP 7: EXPORT SENSITIVITY RESULTS TABLE
* ============================================================

di ""
di "------------------------------------------------------------"
di "  STEP 7: EXPORTING SENSITIVITY TABLE"
di "------------------------------------------------------------"

preserve
    clear
    set obs 4
    
    gen str40 specification = ""
    gen       beta_wmi      = .
    gen       se_wmi        = .
    gen       pvalue        = .
    gen       r_squared     = .
    gen       n_obs         = .
    gen str10 dv            = ""
    gen str30 notes         = ""
    
    replace specification = "Model 1: Bivariate (main)"     in 1
    replace beta_wmi      = 0.0391                          in 1
    replace se_wmi        = 0.0154                          in 1
    replace pvalue        = 0.034                           in 1
    replace r_squared     = 0.448                           in 1
    replace n_obs         = 10                              in 1
    replace dv            = "ln(PHE)"                       in 1
    replace notes         = "Main result"                   in 1
    
    replace specification = "Model 2: Controlled (main)"   in 2
    replace beta_wmi      = 0.0142                          in 2
    replace se_wmi        = 0.0300                          in 2
    replace pvalue        = 0.652                           in 2
    replace r_squared     = 0.620                           in 2
    replace n_obs         = 10                              in 2
    replace dv            = "ln(PHE)"                       in 2
    replace notes         = "Main result"                   in 2
    
    replace specification = "Sensitivity: Weighted WMI"    in 3
    replace beta_wmi      = `b_wt'                          in 3
    replace se_wmi        = `se_wt'                         in 3
    replace pvalue        = `p_wt'                          in 3
    replace r_squared     = `r2_wt'                         in 3
    replace n_obs         = 10                              in 3
    replace dv            = "ln(PHE)"                       in 3
    replace notes         = "Alternative index weights"     in 3
    
    replace specification = "Sensitivity: PHE in levels"   in 4
    replace beta_wmi      = `b_lev'                         in 4
    replace se_wmi        = `se_lev'                        in 4
    replace pvalue        = `p_lev'                         in 4
    replace r_squared     = `r2_lev'                        in 4
    replace n_obs         = 10                              in 4
    replace dv            = "PHE levels"                    in 4
    replace notes         = "Untransformed DV"              in 4
    
    export delimited using "$tables/table_sensitivity.csv", replace
    di "  Exported: $tables/table_sensitivity.csv"
restore


* ============================================================
* STEP 8: FINAL PROJECT SUMMARY
* ============================================================

di ""
di "============================================================"
di "  FINAL PROJECT SUMMARY"
di "============================================================"
di ""
di "  DATA:"
di "  Source: NFHS-5 Household Recode (IAHR7BFL.DTA)"
di "  Sample: 286,668 households across 10 Indian states"
di "  Aggregated to 10 state-level observations"
di ""
di "  INDICATORS (verified from actual NFHS-5 coding):"
di "  1. Improved toilet     (hv205: codes 11,12,13,21,22,41)"
di "  2. Improved water      (hv201: WHO/JMP improved sources)"
di "  3. Handwashing facility (hv230a=1 + hv230b=1 + hv232=1)"
di "  4. Safe waste disposal  (sh56a OR sh56c OR sh56f)"
di "  5. Private toilet       (hv225=0: does not share)"
di ""
di "  WMI RANKINGS (survey-weighted):"
di "  1. Haryana (83.8)   6. Uttar Pradesh (71.3)"
di "  2. Kerala  (83.2)   7. West Bengal   (65.8)"
di "  3. Punjab  (81.1)   8. Assam         (64.2)"
di "  4. Tamil Nadu (76.4) 9. Bihar        (56.2)"
di "  5. Maharashtra (74.5) 10. Jharkhand  (55.9)"
di ""
di "  KEY REGRESSION FINDING:"
di "  WMI is positively associated with ln(PHE) in the"
di "  bivariate model (β=0.039, p=0.034, R²=0.45)."
di "  This association disappears after controlling for"
di "  literacy and GDP per capita (β=0.014, p=0.652)."
di "  Excluding Kerala further reduces β to near zero."
di ""
di "  INTERPRETATION:"
di "  Both sanitation quality and public health spending"
di "  are driven by overall state development level."
di "  No independent association between WMI and PHE"
di "  is detectable after controlling for development."
di ""
di "  LIMITATIONS:"
di "  - n=10 states: extremely small for regression"
di "  - Cross-sectional: cannot establish causality"
di "  - PHE source: 2019-21 includes COVID-affected year"
di "  - Multicollinearity between WMI and controls"
di "============================================================"
di ""
di "  All do-files complete. Project files saved in:"
di "  07_Final_Data/final_analysis.dta"
di "  08_Output/tables/ (5 CSV tables)"
di "  08_Output/figures/ (8 PNG figures)"
di "============================================================"

log close
di "Phase 9 complete. Project pipeline finished."