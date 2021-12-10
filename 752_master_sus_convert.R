#####################################################
# CLASSIFYING (SUS) OUTPATIENT ACTIVITY BY FUNCTION #
#####################################################

# THIS SCRIPT HAS BEEN CONVERTED TO USE SUS QUERIES.
# NOT FULLY TESTED AS OF 2021.12.10
# SEVERAL ISSUES IN OUTPUT NOTED. 
# WILL DO AS PROOF OF CONCEPT FOR NOW. 


library(tidyverse)
library(tidytable)
library(lubridate)
library(janitor)
# OPTIONAL TIMINGS:
# library(tictoc)

# 1. LOAD REFERENCE TABLES -------------------------------------------------

source("lkp_ccg_ics.r")
source("lkp_specialty.r") # NEED TO PRODUCE THIS AS SEPARATE.
source("lkp_diagnostic_procs.r")


# 2. QUERY SUS ------------------------------------------------------------
## a. op query ------------------------------------------------------------

op_raw <- read_csv("sus_op.csv")
# NOTE: IGNORE PARSING FAILURES FOR NOW

## b. ip query ------------------------------------------------------------

ip_raw <- read_csv("sus_ip.csv")

# 5. WRANGLE --------------------------------------------------------------

## a. op ------------------------------------------------------------------

op <- op_raw %>%
  mutate.(is_consultant = ifelse.(str_detect(cons_code, "^C"), 1, 0)) %>%
  mutate.(is_consultant = ifelse.(is.na(cons_code), 0, is_consultant)) %>%
  mutate.(is_direct = ifelse.(is_direct == "Y", 1, 0)) %>%
  mutate.(date_actv = as_date(date_actv)) %>%
  mutate.(nhs_no = as.character(nhs_no)) %>%
  mutate.(tfc = as.character(tfc)) %>%
  mutate(pod = "op") %>%
  relocate(pod, .after = nhs_no)

# WILL REMOVE PROCEDURES RECORDED AS GENERIC "ASSESSENT" - "X62":
op <- op %>% 
  mutate(procs = str_remove_all(procs, "X62[0-9]{1}, ")) %>% # |X62[0-9]{1}
  mutate(procs = str_remove_all(procs, "X62[0-9]{1}")) %>% # |X62[0-9]{1}
  mutate(procs = ifelse(procs == "", NA_character_, procs)) 

op %>% count(procs, sort =T)
# VERY FEW PROCS CODED

## b. ip ------------------------------------------------------------

ip <- ip_raw %>% 
  mutate(date_actv = as_date(date_actv)) %>% 
  mutate(nhs_no = as.character(nhs_no)) %>% 
  # KNOWN ISSUE HERE WITH OBSTETRICS:
  mutate(pod = ifelse(admimeth %in% c(11, 12, 13), "el", "nel")) %>% 
  relocate(pod, .after = nhs_no) %>%
  select(-admimeth)

# BECAUSE NAs IN ADMITTED/DISCHARGED TFC MAY CAUSE PROBLEMS:
ip <- ip %>% 
  rename(tfc = tfc_admi) %>% 
  relocate(tfc, .after = pod)  

# 6. UNION  ----------------------------------------------------------------

combo <- bind_rows.(op, ip)  %>% 
  arrange.(nhs_no, tfc, date_actv)

# TODO ISSUES WITH FYEAR
# combo %>% count(fyear, sort =T)

# 7. CREATE ADDITIONAL VARIABLES (lags etc.) -----------------------------------

# TODO MAY NEED TO OPEN AND RUN THIS SCRIPT MANUALLY RATHER THAN SOURCE?
source("new_vars.r")

# ** 8. THE RULES ** -----------------------------------------------------------
source("rules_1.r")
source("rules_2.r")


# 9.SUMMARISE ------------------------------------------------------------

# op_raw %>% count(procs, sort = T)

# rules_2 %>% count(tag, sort =T)

df_summary <-
  rules_2 %>%
  # TODO CHOOSE PERIOD TO SUMMARISE:
  filter(between(date_actv, ymd("2011-04-01"), ymd("2021-03-31"))) %>%
  mutate(ym = tsibble::yearmonth(date_actv)) %>% 
  count(ym, tfc, treatment_function, tf_group, provider, site, is_consultant, practice_code, first, tag)

df_summary %>% count(tag, wt = n, sort = T)
# TODO OBVIOUSLY SEVERAL ISSUES TO BE ADDRESSED HERE
