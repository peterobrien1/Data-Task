#### Peter O'Brien 
### Blueprint Labs
## Data Task 
# October 2, 2021 

# This script merges and preps the relevant data for the Tennessee Promise program impact analysis


# Housekeeping #
rm(list = ls())
options(scipen = 999)
here::i_am("SCRIPTS/BLUEPRINT_REGRESSION_DATA_MERGE_CLEAN.R") # Establish relative wd
library(here)
library(tidyverse)
library(lubridate)
library(zoo)
library(plm)


# Load Data #

hd2010 <- read_csv(here("DATA_RAW/schools/hd2010.csv")) 
hd2011 <- read_csv(here("DATA_RAW/schools/hd2011.csv"))
hd2012 <- read_csv(here("DATA_RAW/schools/hd2012.csv"))
hd2013 <- read_csv(here("DATA_RAW/schools/hd2013.csv"))
hd2014 <- read_csv(here("DATA_RAW/schools/hd2014.csv"))
hd2015 <- read_csv(here("DATA_RAW/schools/hd2015.csv"))
sfa10_15 <- read_csv(here("DATA_RAW/students/sfa1015.csv"))





# Prep institution data for merge #
hd_data_prep <- function(df, yr) { 
  df <- df %>% 
    filter(ugoffer == 1) %>% 
    select(unitid, ugoffer, hloffer, control, stabbr) %>% 
    filter(ugoffer != -3 |
             control != -3) %>%                # Drop missing data
    mutate(public = as.factor(if_else(control == 1, 1, 0))) %>%  # Identifies if institution is public
    mutate(degree_bach = as.factor(if_else(hloffer >= 5, 1, 0))) %>% # Identifies if institution grants bachelor's degrees
    rename(ID_IPEDS = unitid) %>% # Unique institution identifer
    select(ID_IPEDS, degree_bach, public, stabbr) %>% 
    mutate(year = as.factor(yr)) # Add year identifier
  return(df)
}

hd2010 <- hd_data_prep(df = hd2010, yr = 2010)
hd2011 <- hd_data_prep(df = hd2011, yr = 2011)
hd2012 <- hd_data_prep(df = hd2012, yr = 2012)
hd2013 <- hd_data_prep(df = hd2013, yr = 2013)
hd2014 <- hd_data_prep(df = hd2014, yr = 2014)
hd2015 <- hd_data_prep(df = hd2015, yr = 2015)

hd_df_clean <- bind_rows(hd2010, hd2011, hd2012, hd2013, hd2014, hd2015) # Combine all institution data



# Prep financial aid data for merge #
sfa <- sfa10_15 %>% 
  select(unitid, contains("scugffn"), contains("fgrnt_a"), contains("sgrnt_a")) %>% 
  pivot_longer(cols = scugffn2010:sgrnt_a2015,
               names_to = "metric_yr", 
               values_to  = "value") # Wide to long


sfa$year <-  as.factor(substr(sfa$metric_yr, 8, 11)) # Create year variable 

sfa$metric <- substr(sfa$metric_yr, 1, 7) # Create metric type variable


sfa_clean <- sfa %>% 
  select(!metric_yr) %>% 
  pivot_wider(names_from = metric,
              values_from = value) %>% # Long to wide
  mutate(grant_state = scugffn * sgrnt_a,
         grant_federal = scugffn * fgrnt_a) %>% # Calculate total aid amount metrics at the state & federal level
  rename(enroll_ftug = scugffn,
         ID_IPEDS = unitid) %>% 
  select(ID_IPEDS, year, enroll_ftug, grant_state, grant_federal)




# Merge data #
panel_data_clean <- inner_join(sfa_clean, hd_df_clean,
                               by = c("ID_IPEDS", "year"))



# Balance panel dataset #
panel_data_clean <- na.omit(panel_data_clean) # Drop missing observations
is.pbalanced(panel_data_clean) # Check for balance



panel_data_balanced <- panel_data_clean %>% 
  group_by(ID_IPEDS) %>% 
  filter(n() == 6) %>% # We only want institutions with data for all years in the sample
  ungroup()


is.pbalanced(panel_data_balanced) # Check for balance
table(panel_data_balanced$year) # Double check
table(panel_data_balanced$ID_IPEDS) # Triple



write_csv(panel_data_balanced, file.path("DATA_CLEAN/panel_data_full.csv")) 























