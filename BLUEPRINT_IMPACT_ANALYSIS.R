#### Peter O'Brien 
### Blueprint Labs
## Data Task 
# October 2, 2021 

# This script plots and analyzes the Tennessee Promise program impact data

# Housekeeping #
rm(list = ls())
options(scipen = 999)
here::i_am("SCRIPTS/BLUEPRINT_IMPACT_ANALYSIS.R") # Establish relative wd
library(here)
library(tidyverse)
library(AER)
library(scales)
library(ggthemes)
library(broom)  
library(modelsummary) 
library(stargazer)
library(kableExtra)  
library(estimatr)
library(plm)

# Load data #

df <- read_csv(here("DATA_CLEAN/panel_data_full.csv"))

# Create comparison categories
df <- df %>% 
  mutate(inst_type = if_else(degree_bach == 0 & public == 1, "Public two-year", 
                             if_else(degree_bach == 1 & public == 1, "Public four-year",
                                     if_else(degree_bach == 0 & public == 0, "Private two-year",
                                             "Private four-year")))) # Create institution type classifiers

# Plot trends in avg state/local aid granted #

plot1 <- df %>% 
  filter(stabbr == "TN") %>% 
  group_by(year, inst_type) %>% 
  summarise(total_state_aid = sum(grant_state),
            avg_state_aid = (mean(total_state_aid) / 1000000)) %>% # Calculate avg state-level aid amounts for each institution type
  ggplot(aes(x = year, y = avg_state_aid, col = inst_type)) + 
  geom_line(size = 1.05) +
  labs(y = "Avg State Aid (millians of Dollars)", 
       x = "Year", 
       col = "Institution Type") +
  ggtitle("Figure 1: Avg State Grant Aid at Tennessee Colleges", 
          subtitle = "2010 - 2015") +
  geom_vline(xintercept = 2014,
             color = "red") + 
  theme_minimal() + 
  annotate("text",
           label = "'Tennessee Promise' Scholarships First Offered", 
           x = 2012.1,
           y =  82, 
           size = 3.5) + 
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5)) 
plot1


# Plot trends in federal funding
plot2 <- df %>% 
  filter(stabbr == "TN") %>% 
  group_by(year, inst_type) %>% 
  summarise(total_federal_aid = sum(grant_federal),
            avg_federal_aid = (mean(total_federal_aid) / 1000000)) %>% # Calculate avg fed-level aid amounts for each institution type
  ggplot(aes(x = year, y = avg_federal_aid, col = inst_type)) + 
  geom_line(size = 1.05) +
  labs(y = "Avg Federal Aid (millians of Dollars)", 
       x = "Year", 
       col = "Institution Type") +
  ggtitle("Average Federal Grant Aid at Tennessee Colleges", 
          subtitle = "2010 - 2015") +
  geom_vline(xintercept = 2014,
             color = "red") + 
  theme_minimal() + 
  annotate("text",
           label = "'Tennessee Promise' Scholarships First Offered", 
           x = 2012.1,
           y =  82, 
           size = 3.5) + 
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5)) 
plot2


# Plot trends in enrollment #

plot3 <- df %>% 
  filter(stabbr == "TN") %>% 
  group_by(year, inst_type) %>% 
  summarise(total_ft_ugrds = sum(enroll_ftug),
            avg_ft_ugrds = mean(total_ft_ugrds)) %>% # Calculate avg ft undergrad enrollment levels for each institution type
  ggplot(aes(x = year, y = avg_ft_ugrds, col = inst_type)) + 
  geom_line(size = 1.05) +
  labs(y = "Avg Number of First-time, Full-time Undergrads", 
       x = "Year", 
       col = "Institution Type") +
  ggtitle("Figure 2: Avg Number of FT, FT Undergrads at TN Colleges", 
          subtitle = "2010 - 2015") +
  scale_y_continuous(labels = comma) + 
  geom_vline(xintercept = 2014,
             color = "red") +
  theme_minimal() + 
  annotate("text",
    label = "'Tennessee Promise' Scholarships First Offered", 
    x = 2012,
    y =  28000, 
    size = 3.5) + 
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5)) 
plot3





# Estimate effect of Tennesse Promise scholarship program on enrollment at public, 2-yr colleges #



# Prep data for analysis #
df_pub_2yr <- df %>% 
  filter(inst_type == "Public two-year") # Restrict sample to institutions of interest

hist(df_pub_2yr$enroll_ftug) # Examine dependent variable


df_pub_2yr <- df_pub_2yr %>% 
  mutate(ln_enroll_ftug = log(enroll_ftug), # Log transformation of the dependent varialbe
         post = if_else(year == 2015, 1, 0), 
         tn_promise_treatment = if_else(stabbr == "TN", 1, 0)) # Setup DID approach


hist(df_pub_2yr$ln_enroll_ftug)

# Examine pre-treatment trends for both groups
df_pub_2yr %>% 
  mutate(TN_school = as.factor(if_else(stabbr == "TN", 1, 0))) %>% 
  group_by(year, TN_school) %>% 
  summarise(total_ft_ugrds = sum(enroll_ftug),
            avg_ft_ugrds = mean(total_ft_ugrds),
            ln_avg_ft_ugrds = log(avg_ft_ugrds)) %>% 
  ggplot(aes(x = year, y = ln_avg_ft_ugrds, col = TN_school)) + 
  geom_line(size = 1.05) +
  labs(y = "Avg Number of First-time, Full-time undergrads", 
       x = "Year", 
       col = "Tennessee School?") +
  ggtitle("Avg Number of FT undergrads at Public 2-Yr Colleges", 
          subtitle = "2010 - 2015") +
  scale_y_continuous(labels = comma) + 
  geom_vline(xintercept = 2014,
             color = "red") +
  theme_minimal() + 
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5)) 


# Estimate DID model

model_did <- lm(enroll_ftug ~ tn_promise_treatment * post + grant_federal, data = df_pub_2yr)
stargazer(model_did,
          style = "qje",
          title = "DID Estimates for the Tennessee Promise Scholarship Program",
          type = "text",
          column.sep.width = "-8pt",
          header = FALSE) 




model_did2 <- lm(ln_enroll_ftug ~ tn_promise_treatment * post + grant_federal, data = df_pub_2yr)

stargazer(model_did, model_did2,
          style = "qje",
          title = "DID Estimates for the Tennessee Promise Scholarship Program",
          type = "latex",
          column.sep.width = "-8pt",
          header = FALSE) 





























