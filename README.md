# Impact of Waste Management Practices on Public Health Expenditure in India

**Author:** Srihari Raja  
**Course:** Economics of Health and Environment  
**Data:** NFHS-5 (2019-21), National Family Health Survey  
**Completed:** September 2026  

---

## Research Question

To what extent is waste management and sanitation performance associated with 
state-level public health expenditure across India's major states?

---

## Data Sources

| Dataset | Source | Role |
|---------|--------|------|
| NFHS-5 Household Recode (IAHR7BFL.DTA) | DHS Program / IIPS | Primary microdata |
| Public Health Expenditure | RBI State Finances / National Health Accounts | Dependent variable |
| Literacy Rate | Census of India 2011 | Control variable |
| GDP per capita | RBI Handbook of Statistics on Indian States | Control variable |

**Registration required:** NFHS-5 microdata available at dhsprogram.com  
**States covered:** Bihar, West Bengal, Kerala, Uttar Pradesh, Haryana, Tamil Nadu, Punjab, Jharkhand, Assam, Maharashtra

---

## Project Structure
01_Admin/ Project documentation and logs
02_Raw_Data/ Raw NFHS-5 Household Recode (not uploaded — too large)
03_External_Data/ PHE, literacy, and GDP CSV files with sources
04_Code/ All Stata do-files (run in numbered order)
05_Logs/ Stata output logs for every do-file
06_Intermediate_Data/ Filtered and cleaned intermediate datasets
07_Final_Data/ Final 10-state analysis dataset
08_Output/ Tables (CSV) and figures (PNG)
09_Documentation/ NFHS-5 manuals and questionnaires
10_Archive/ Original college project files (preserved unchanged)


---

## How to Reproduce This Analysis

**Requirements:** Stata 16 or later. NFHS-5 Household Recode file (IAHR7BFL.DTA).

**Step 1:** Place IAHR7BFL.DTA in `02_Raw_Data/`

**Step 2:** Open `04_Code/00_setup.do` and update the `global project` path to match your computer.

**Step 3:** Run do-files in this exact order, checking output after each:

| File | Purpose | Output |
|------|---------|--------|
| `00_setup.do` | Define paths, start log | Log file |
| `01_data_audit.do` | Inspect raw NFHS-5 variables | Audit log |
| `02_state_filter.do` | Filter to 10 states (verified codes) | nfhs5_10states.dta |
| `03_clean_indicators.do` | Recode sanitation variables | nfhs5_indicators.dta |
| `04_state_aggregation.do` | Survey-weighted state proportions | state_level_wm.dta |
| `05_index_construction.do` | Build WMI, rank states | state_level_wm.dta (updated), fig01, fig02 |
| `06_merge_external_data.do` | Add PHE, literacy, GDP | final_analysis.dta |
| `07_descriptive_analysis.do` | Tables and figures | fig03-06, tables |
| `08_regression_analysis.do` | OLS models | fig07, regression table |
| `09_robustness_checks.do` | Diagnostics and sensitivity | fig06 (improved), fig08 |

---

## Key Findings

**WMI Rankings (survey-weighted, 0-100 scale):**
1. Haryana (83.8) — Good
2. Kerala (83.2) — Good
3. Punjab (81.1) — Good
4. Tamil Nadu (76.4) — Good
5. Maharashtra (74.5) — Moderate
6. Uttar Pradesh (71.3) — Moderate
7. West Bengal (65.8) — Moderate
8. Assam (64.2) — Moderate
9. Bihar (56.2) — Moderate
10. Jharkhand (55.9) — Moderate

**Regression Results:**
- Bivariate: WMI positively associated with ln(PHE), β=+0.039, p=0.034, R²=0.45
- Controlled (literacy + ln GDP): association disappears, β=+0.014, p=0.652
- Sensitivity (excluding Kerala): β near zero, p=0.868
- **Conclusion:** The bivariate association between sanitation and health spending is explained by overall state development level, not by sanitation independently.

---

## Important Corrections from Original Project

This rebuilt analysis corrects several critical errors in the original college project:

| Error | Original | Corrected |
|-------|---------|-----------|
| State codes | 8 of 10 states had wrong hv024 codes | Verified from actual data |
| Toilet variable | Used codes 1-6 (do not exist in NFHS-5) | Correct codes 11,12,13,21,22,41 |
| Handwashing | hv209 is "has refrigerator" | Used hv230a+hv230b+hv232 |
| Waste disposal | hv226 is "cooking fuel" | Used sh56a/sh56c/sh56f |
| Waste collection | hv227 is "mosquito bed net" | No equivalent variable found |
| Child stool | hv225 is "shares toilet" | Repurposed as private toilet indicator |
| Improved water | Excluded tube wells (code 21) | Included all WHO/JMP improved sources |

---

## Limitations

- **n=10 states:** Very small sample for regression analysis. All results are descriptive associations.
- **Cross-sectional:** Cannot establish causality.
- **COVID-19:** PHE data covers 2019-21, including pandemic-affected expenditure.
- **Multicollinearity:** WMI, literacy, and GDP are all highly correlated (r=0.74–0.87).
- **External PHE source:** Original source document not recovered; values consistent with RBI/NHA data.

---

## Outputs Produced

**Figures (08_Output/Figures/):**
- fig01: WMI ranking by state (bar chart)
- fig02: Component comparison — top 3 vs bottom 3 states
- fig03: Public health expenditure by state
- fig04: WMI vs PHE scatter plot
- fig05: WMI vs ln(PHE) scatter plot
- fig06: Sanitation indicators by state (dot plot)
- fig07: Actual vs predicted ln(PHE) — Model 2
- fig08: Residual plot — Model 2

**Tables (08_Output/Tables/):**
- table_wmi_components.csv
- table_external_data.csv
- table_descriptive_stats.csv
- table_complete_data.csv
- table_regression_results.csv
- table_sensitivity.csv
