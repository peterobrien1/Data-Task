#### Peter O'Brien 
### Blueprint Labs
## Data Task 
# October 2, 2021 

# This script merges, cleans, and presents relevant demographic data for Tennessee high school students


# Housekeeping #
options(scipen = 999)
here::i_am("SCRIPTS/BLUEPRINT_DEMOGRAPHIC_ANALYSIS.R") # Establish relative wd
library(here)
library(tidyverse)
library(htmlTable)


# Load raw data: 2018 TN school districts demographic profiles #
df_raw <- read_csv(here("DATA_RAW/tn_demographics/TN_SCHOOLS_ENROLLMENT.csv")) # Source: Tennessee Department of Education
glimpse(df_raw)


# Prep data for summary
unique(df_raw$grades_served)
hs_only <- df_raw %>% 
  filter(grades_served == "Grades 9-12" |
           grades_served == "Grades 11-12" |
           grades_served == "Grades 10-12") # We only want schools with only hs age students 

hs_only_wide <- hs_only %>% 
  select(district_number, school_name, subgroup, value) %>% 
  pivot_wider(names_from = subgroup, values_from = value) %>% # Convert df from long to wide
  select(`All Students`, Female, `Black/Hispanic/Native`, `American Indian or Alaskan Native`, Asian, White, `English Learners`, `Economically Disadvantaged`) # Only keep variables of interest
  
hs_only_wide %>% 
  summarize(total_students = sum(`All Students`)) # Calculate total number of TN HS students

hs_summary_demographics <- hs_only_wide %>%
  select(!`All Students`) %>% 
  map(~tidy(round(summary(.x), digits = 1))) %>%  # Compute summary statistics for each column
  do.call(rbind, .) 


# Create demographic summary table
htmlTable(hs_summary_demographics, 
          rnames = c("Female (%)", "Black/Hispanic/Native (%)", "American Indian (%)", "Asian (%)", "White (%)", "ESL (%)", "Economically Disadvantaged (%)"),
          header = c("Minimum", "Q1", "Median", "Mean", "Q3", "Maximum"),
          caption = "Table 2: 2018 Tennesee High School Student Demographics (n = 260,558)",
          tfoot = "Source: Tennessee Department of Education 2018 Report Card Data") 


write_csv(hs_only_wide, file.path("DATA_RAW/tn_hs_demographics_2018.csv")) 
  
  
  
  
  
  
  
  
