# Raw Data Access Instructions

## NFHS-5 Household Recode (IAHR7BFL.DTA)

This folder should contain the NFHS-5 All-India Household Recode file.
It is not included in this repository because:
1. The file is approximately 700MB
2. Access requires free registration with the DHS Program

### How to download:

1. Go to: https://dhsprogram.com/data/dataset/India_Standard-DHS_2019.cfm
2. Register for a free account (select "NFHS-5 India 2019-21")
3. Request access to the Household Recode dataset
4. Download the file named IAHR7BFL.DTA (Stata format)
5. Place it in this folder: 02_Raw_Data/IAHR7BFL.DTA

### File details:
- Observations: 636,699 households
- Variables: 6,482
- File size: approximately 700MB
- Stata version: compatible with Stata 14+

Once the file is in place, run the do-files in order starting with 00_setup.do.