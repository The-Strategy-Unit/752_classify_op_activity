#####################################################
# CLASSIFYING (SUS) OUTPATIENT ACTIVITY BY FUNCTION #
#####################################################

# HERE WE CONNECT R DIRECTLY TO SUS VIA NCDR.
# ALTERNATIVELY, QUERIES IN SECTION 4 COULD BE 
# PERFORMED SEPARATELY - WITHOUT A DIRECT CONNECTION. 
# (BASIC SQL EQUIVALENTS APPEAR AT BOTTOM OF QUERY 
# SCRIPTS). THE USER WOULD THEN PICK UP AGAIN FROM SECTION 5.

# Note: Execution times quoted for activity
# of: 3 providers, over 10 years.
# Run on NCDR data science server.

library(tidyverse)
library(tidytable)
library(lubridate)
library(janitor)
# FOR DB CONNECTION:
library(dbplyr)
library(odbc)
library(DBI)
# OPTIONAL TIMINGS:
# library(tictoc)


# 1. DB SETUP -------------------------------------------------------------

con_susplus <- dbConnect(odbc(),
                         Driver = "SQL Server",
                         Server = "PRODNHSESQL101",
                         Database = "NHSE_SUSPlus_Live",
                         Trusted_Connection = "True"
)


# 2. LOAD REFERENCE TABLES -------------------------------------------------

source("lkp_ccg_ics.r")
source("lkp_specialty.r") # NEED TO PRODUCE THIS AS SEPARATE.
source("lkp_diagnostic_procs.r")

# 3. SET YOUR PARAMETERS (1 of 3) ------------------------------------------

chosen_trusts <- c("RR1", "RRK", "RXK")
# chosen_ccgs <- c("04X", "13P", "05P", "15E") # OR:
# chosen_ics <- df_ics$value[1]

# 4. QUERY SUS ------------------------------------------------------------
## a. op query ------------------------------------------------------------

# TODO SET YOUR PARAMATERS (2 of 3) IN THIS SCRIPT:
source("query_sus_op.r")
# exeution time: ~ 2.5 mins

## b. ip query ------------------------------------------------------------
# TODO: SET YOUR PARAMETERS (3 of 3) IN THIS SCRIPT:
source("query_sus_ip.r")
# exeution time: ~ 4 mins

# 5. WRANGLE --------------------------------------------------------------

## a. op ------------------------------------------------------------------

op <- op_raw %>%
  mutate.(is_consultant = ifelse.(str_detect(cons_code, "^C"), 1, 0)) %>%
  mutate.(is_consultant = ifelse.(is.na(cons_code), 0, is_consultant)) %>%
  mutate.(is_direct = ifelse.(is_direct == "Y", 1, 0)) %>%
  mutate.(date_actv = as_date(date_actv)) %>%
  mutate.(nhs_no = as.character(nhs_no)) %>%
  mutate(pod = "op") %>%
  relocate(pod, .after = nhs_no)

# WILL REMOVE PROCEDURES RECORDED AS GENERIC "ASSESSENT" - "X62":
op <- op %>% 
  mutate(procs = str_remove_all(procs, "X62[0-9]{1}, ")) %>% # |X62[0-9]{1}
  mutate(procs = str_remove_all(procs, "X62[0-9]{1}")) %>% # |X62[0-9]{1}
  mutate(procs = ifelse(procs == "", NA_character_, procs)) 


## b. ip ------------------------------------------------------------

ip <- ip_raw %>% 
  mutate(date_actv = as_date(date_actv)) %>% 
  mutate(nhs_no = as.character(nhs_no)) %>% 
  mutate(pod = ifelse(admimeth %in% c(11, 12, 13), "el", "nel")) %>% 
  relocate(pod, .after = nhs_no) %>%
  select(-admimeth)

# BECAUSE NAs IN ADMITTED/DISCHARGED TFC MAY CAUSE PROBLEMS:
ip <- ip %>% 
  mutate(tfc_admi = ifelse(is.na(tfc_admi), "X", tfc_admi)) %>%
  mutate(tfc_disc = ifelse(tfc_disc == tfc_admi, NA, tfc_disc)) %>% 
  # BACK TO NA:
  mutate(tfc_admi = ifelse(tfc_admi == "X", NA, tfc_admi)) %>% 
  pivot_longer(cols = starts_with("tfc"), names_to = "io", values_to = "tfc", values_drop_na = T) %>% 
  relocate(tfc, .after = pod)  

# 6. UNION  ----------------------------------------------------------------

combo <- bind_rows.(op, ip)  %>% 
  arrange.(nhs_no, tfc, date_actv)


# 7. CREATE ADDITIONAL VARIABLES (lags etc.) -----------------------------------

source("new_vars.r")
# exeution time: ~ 2 mins

# ** 8. THE RULES ** -----------------------------------------------------------
source("rules_1.r")
source("rules_2.r")
# exeution time: ~ 4 mins


# 9.SUMMARISE ------------------------------------------------------------

df_summary <-
  rules_2 %>%
  # TODO CHOOSE PERIOD TO SUMMARISE:
  filter(between(date_actv, ymd("2011-04-01"), ymd("2021-03-31"))) %>%
  mutate(ym = tsibble::yearmonth(date_actv)) %>% 
  count(ym, tfc, treatment_function, tf_group, provider, site, is_consultant, practice_code, first, tag)

