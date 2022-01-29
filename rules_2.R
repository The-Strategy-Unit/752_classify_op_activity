# "RULES 2" DEALS WITH ALL FUNCTIONS NOT DEFINED BY AN ADMISSION:

rules_2 <- rules_1 %>% 
  # REMOVE NON-OP ACTIVITY
  filter(pod == "op") %>% 
  mutate(tag = case_when(
    is_direct == 1 ~ "direct_access",
    # ADM BOUNCE = ATTENDANCES THAT HAVE "BOUNCED" HAVING NOT BEEN LABELLED IN RULES 1 (ADMISSIONS RELATED)
    adm_bounce == 1 & (!is.na(procs)) ~ "proc_tbc", # check against priority type and diagnostic list.
    adm_bounce == 1 & is.na(procs) ~ "p_hold", # placeholder - for next level check whether previous procedure (thus discuss results)
    T ~ tag
  )) %>% 
  # FOLLOWING OPERATION IS DONE ON GROUPED DF SO WE DON'T PULL THROUGH FROM OTHER SPECIALTIES / PATIENTS: 
  # TODO THIS OPERATION IS SLOW - COULD BE RE-WRITTEN IN TIDYTABLE FORM. OR LOOK AT OTHER WAYS TO SPEED UP 
  group_by(nhs_no, tfc) %>% 
  mutate(tag = case_when(
    tag == "p_hold" & lag(tag) == "proc_tbc" ~ "discuss_results",
    tag == "p_hold" & (lag(tag) != "proc_tbc"| is.na(lag(tag))) & n_op < 2 ~ "initial_opinion",
    tag == "p_hold" & (lag(tag) != "proc_tbc"| is.na(lag(tag))) & n_op >= 2 & first %in% c(1,3) ~ "initial_opinion",
    tag == "p_hold" & (lag(tag) != "proc_tbc"| is.na(lag(tag))) & n_op >= 2 & ((!first %in% c(1,3))|is.na(first)) ~ "structured_review",
    T ~ tag
  )) %>%   
  ungroup %>% 
  mutate(tag = case_when(is_direct == 1 ~ "direct_access", T ~ tag)) %>% 
  # "URGENT" TRUMPS MOST LABELS BUT NOT PRE-OP:
  mutate(tag = case_when(
    priority %in% c("2", "3") & tag != "pre_op" ~ "urgent_investigation",
                         T~ tag
  )) %>% 
  mutate(proc_dom = str_sub(procs, 1, 4)) %>% 
  mutate(tag = case_when(
    tag == "proc_tbc" & (!priority %in% c("2", "3")) & str_detect(proc_dom, proc_dim)  ~ "diagnostic",
    tag == "proc_tbc" & (!priority %in% c("2", "3")) & (!str_detect(proc_dom, proc_dim)) ~ "treatment",
    T~ tag)) 
