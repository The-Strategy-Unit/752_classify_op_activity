#####################################################
# CLASSIFYING (SUS) OUTPATIENT ACTIVITY BY FUNCTION #
#####################################################

# THIS SCRIPT HAS BEEN CONVERTED TO USE SUS QUERIES.
# BASIC TESTING OF ALGORITHM v1.0 AS OF 2022.01.13
# FOR PROVIDER LEVEL ANALYSIS, WE RECOMMEND THAT 
# ALGORITHM BE ADAPTED TO MATCH LOCAL PROCESSES/PRACTICES. 


library(tidyverse)
library(tidytable)
library(lubridate)
library(janitor)
# OPTIONAL TIMINGS:
# library(tictoc)


# 0. CSV EXAMPLE WANTED? ---------------------------------------------------
# (e.g. for further exploration in Excel)
output_csv <- FALSE 


# 1. LOAD REFERENCE TABLES -------------------------------------------------

source("lkp_ccg_ics.r")
source("lkp_specialty.r") # NEED TO PRODUCE THIS AS SEPARATE.
source("lkp_diagnostic_procs.r")


# 2. LOAD SUS QUERIES ----------------------------------------------------
## a. op  ----------------------------------------------------------------

op_raw <- read_csv(
  "sus_op.csv",
  na = "NULL",
  col_types = cols(
    fyear = col_character(),
    nhs_no = col_character(),
    is_direct = col_character(),
    priority = col_character(),
    first = col_character(),
    procs = col_character()
  )
) %>%
  mutate(date_actv = as_date(date_actv)) %>%
  mutate.(tfc = as.character(tfc))


## b. ip  -----------------------------------------------------------------

ip_raw <- read_csv("sus_ip.csv",
                   col_types = cols(nhs_no = col_character()),
                   na = "NULL") %>% 
  mutate(date_actv = as_date(date_actv)) %>% 
  mutate.(tfc = as.character(tfc))

# 5. WRANGLE --------------------------------------------------------------

## a. op ------------------------------------------------------------------

op <- op_raw %>%
  mutate.(is_consultant = ifelse.(str_detect(cons_code, "^C"), 1, 0)) %>%
  mutate.(is_consultant = ifelse.(is.na(cons_code), 0, is_consultant)) %>%
  mutate.(is_direct = ifelse.(is_direct == "Y", 1, 0)) %>%
  mutate(pod = "op") %>%
  relocate(pod, .after = nhs_no)

# WILL REMOVE PROCEDURES RECORDED AS GENERIC "ASSESSENT" - "X62":
op <- op %>% 
  mutate(procs = str_remove_all(procs, "X62[0-9]{1}, ")) %>% # |X62[0-9]{1}
  mutate(procs = str_remove_all(procs, "X62[0-9]{1}")) %>% # |X62[0-9]{1}
  mutate(procs = ifelse(procs == "", NA_character_, procs)) 

# op %>% count(procs, sort =T)
# MY EXAMPLE: VERY FEW PROCS CODED

## b. ip ------------------------------------------------------------

ip <- ip_raw %>% 
  # TODO KNOWN ISSUE HERE WITH OBSTETRICS - WHERE TO ASSIGN:
  mutate(pod = ifelse(admimeth %in% c(11, 12, 13), "el", "nel")) %>% 
  relocate(pod, .after = nhs_no) %>%
  select(-admimeth)

ip <- ip %>% 
  relocate(tfc, .after = pod)  

# 6. UNION  ----------------------------------------------------------------

combo <- bind_rows.(op, ip)  %>% 
  arrange.(nhs_no, tfc, date_actv)

# 7. CREATE ADDITIONAL VARIABLES (lags etc.) -----------------------------------

source("new_vars.r")

# ** 8. THE RULES ** -----------------------------------------------------------
source("rules_1.r")
source("rules_2.r")



# 9.SUMMARISE ------------------------------------------------------------

# rules_2 %>% count(tag, sort =T) %>% mutate(p = n/sum(n))

df_summary <-
  rules_2 %>%
  # TODO CHOOSE PERIOD TO SUMMARISE (BE SURE TO REMOVE BUFFER SET IN SQL CODE):
  filter(between(date_actv, ymd("2018-04-01"), ymd("2019-03-31"))) %>%
  mutate(ym = tsibble::yearmonth(date_actv)) %>% 
  count(ym, tfc, treatment_function, tf_group, provider, site, is_consultant, practice_code, first, tag)

df_summary %>% count(tag, wt = n, sort = T) %>% mutate(p = n/sum(n))

if (output_csv == TRUE) {
  df_summary %>% write_excel_csv("output_example.csv")
  }

