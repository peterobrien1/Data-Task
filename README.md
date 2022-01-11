# Data-Task
Project Name: Blueprint Labs Research Fellow Data Task

Author: Peter O'Brien 

Last Edited: 10/4/2021


Description:
This project folder contains all relevant data, scripts, and outputs for the 2021 Blueprint Labs Research Fellow Data Task. 
This analysis evaluates the impact of the "Tennessee Promise" scholarship program on first-time, full-time undergraduate enrollment 
at public, two-year colleges in Tennessee. It also provides an overview of the demographic makeup of high school students in Tennessee
in 2018. 


Contents:
1. DATA_RAW

- This folder contains four sub-folders. "codebooks" contains two spreadsheets which provide relevant data codeings and variable explanations
for the datasets found in "schools" and "students" 

- "schools" contains six datasets from the U.S. Department of Education's Integrated Postsecondary Education Data System. These data provide
institutional information for U.S. colleges for the years 2010-2015. 

- "students" contains one dataset from the U.S. DOE's IPEDS. This dataset provides both financial aid data and information 
related to the number of first-time, full-time undergraduate students enrolled at the institutional level for 
U.S. colleges. 

- "tn_demographics" contains one dataset from the Tennessee Department of Education which provides student demographic information at 
the school level in 2018. 

2. DATA_CLEAN

- This folder contains two datasets.
- "panel_data_full" contains institution-level data regarding degree-offerings, number of undergraduates, type of degree offered, and financial 
aid amounts for U.S. colleges during the period 2010-2018. It was created using the raw data found in "schools" and "students"
- "tn_hs_demographics_2018" contains institution-level data regarding student demographics for Tennessee high school students in 2018. It 
was created using the raw data found in "tn_demographics"

3. SCRIPTS

- This folder contains three programs which can be executed using R (.R scripts). 
- "BLUEPRINT_DEMOGRAPHIC_ANALYSIS" cleans the raw data found in "tn_demographics" and produces the "TN_HS_DEMOGRAPHICS_TABLE_2018" 
table found in "Tables"
- "BLUEPRINT_REGRESSION_DATA_MERGE" merges and cleans the raw data found in "schools" and "students" to produce the "panel_data_full" 
dataset found in "DATA_CLEAN"
- "BLUEPRINT_IMPACT_ANALYSIS" uses the "panel_data_full" dataset found in "DATA_CLEAN" to estimate the impact of the "Tennessee Promise" scholarship program on first-time, full-time undergraduate enrollment 
at public, two-year colleges in Tennessee. It produces the "DID_REGRESSION_OUTPUT" table found in "Tables" and the two figures found in "Figures"

4. OUTPUT

- This folder contains three sub-folders
- Figures contains two figures, "enrollment_plot" and "aid_plot", produced from the "BLUEPRINT_IMPACT_ANALYSIS" script
- Tables contains two tables, "TN_HS_DEMOGRAPHICS_TABLE_2018" and "DID_REGRESSION_OUTPUT", produced from the "BLUEPRINT_DEMOGRAPHIC_ANALYSIS" 
and "BLUEPRINT_IMPACT_ANALYSIS" scripts
- Reports contains one file, "bl_rf_datatask_obrien_report" which summarizes the analysis done in this data task
