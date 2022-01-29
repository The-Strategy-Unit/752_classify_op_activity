# "RULES 1" IS ALL ABOUT ADMISSIONS, AND HOW THEY INFLUENCE FUNCTION:

rules_1 <-
  combo_plus %>%
  mutate(tag = case_when(
    has_adm == 1 & ((lag_days > lead_days)|is.na(lag_days)) & lead_pod == "el" & lead_days < 90 ~ "pre_op", # MEANING LEAD DAYS IS LOWEST, LEAD APPOINTMENT IS CLOSEST. BUT WHAT ABOUT NAS. 
    has_adm == 1 & ((lag_days < lead_days)|is.na(lead_days)) & lag_pod == "el" & lag_days < 60 ~ "post_op",
    has_adm == 1 & ((lag_days < lead_days)|is.na(lead_days)) & lag_pod == "nel" & lag_days < 180 ~ "review_nel",
    T ~ NA_character_
  )) %>%
  # CASES WHEN: NEL IS CLOSEST FOLLOWNG OP -- or -- OP IS CLOSEST:
  # THEN USE NEXT CLOSEST ACTIVITY:
  mutate(tag = case_when(
    has_adm == 1 & ((lag_days > lead_days)|is.na(lag_days)) & lead_pod == "nel"  ~ "p_hold_nel_aft",
    has_adm == 1 & ((lag_days > lead_days)|is.na(lag_days)) & lead_pod == "op"  ~ "p_hold_op_aft",
    has_adm == 1 & ((lag_days < lead_days)|is.na(lead_days)) & lag_pod == "op"  ~ "p_hold_op_bef",
    T ~ tag
  )) %>%
  # CASES WHEN: NEL OCCUPIES LEAD POSITION 1. THUS EXAMINE LEAD POSITION 2
  mutate(tag = case_when(
    tag == "p_hold_nel_aft" & ((lag_days > lead_days_2)|is.na(lag_days)) & lead_pod_2 == "el" & lead_days_2 < 90 ~ "pre_op",
    tag == "p_hold_nel_aft" & ((lag_days < lead_days_2)|is.na(lead_days_2)) & lag_pod == "el" & lag_days < 60 ~ "post_op",
    tag == "p_hold_nel_aft" & ((lag_days < lead_days_2)|is.na(lead_days)) & lag_pod == "nel" & lag_days < 180 ~ "review_nel",
    T ~ tag
  )) %>%
  # CASES WHEN: OP OCCUPIES LEAD POSITION 1. THUS COMPARE LAG TO LEAD POSITION 2
  mutate(tag = case_when(
    tag == "p_hold_op_aft" & ((lag_days < lead_days_2)|is.na(lead_days_2)) & lag_pod == "nel" & lag_days < 180 ~ "review_nel",
    tag == "p_hold_op_aft" & ((lag_days < lead_days_2)|is.na(lead_days_2)) & lag_pod == "el" & lag_days < 60 ~ "post_op",
    T ~ tag
  )) %>%
  # CASES WHEN: OP OCCUPIES LAG POSITION 1. THUS COMPARE LEAD TO LAG POSITION 2
  mutate(tag = case_when(
    tag == "p_hold_op_bef" & ((lag_days_2 > lead_days)|is.na(lag_days_2)) & lead_pod == "el" & lead_days < 90 ~ "pre_op",
    T ~ tag
  )) %>%
  # FOR THE REMAINING CASES WITH ADM, THE FUNCTION IS NOT DEFINED BY THE ADMISSION:
  # THUS TREAT THEM SAME AS ALL (SO FAR) UNLABELLED APPOINTMENTS:
  mutate(tag = ifelse(str_detect(tag, "p_hold"), NA, tag)) %>% 
  mutate(adm_bounce = ifelse(is.na(tag), 1, 0))

