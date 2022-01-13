# USING "TIDYTABLE" PACKAGE (A TIDY INTERFACE TO "DATA.TABLE")
# https://markfairbanks.github.io/tidytable/index.html
# TO IMPROVE SPEED OF EXECUTION 

combo_plus <- combo %>%  
  left_join.(lkp_tretspef, by = "tfc") %>%
  relocate(treatment_function, .after = tfc) %>%
  relocate(tf_group, .after = treatment_function) %>%
  # GROUP:
  # group_by(nhs_no, tfc) %>% # NOW BECOMES A .by ARGUMENT PASSED TO mutate():
  mutate.(count_actv = n.(), .by = c(nhs_no, tfc)) %>%
  mutate.(n_op = sum(pod == "op"), .by = c(nhs_no, tfc)) %>%
  mutate.(has_adm = ifelse.(sum(pod != "op") > 0, 1, 0), .by = c(nhs_no, tfc)) %>%
  identity()

combo_plus <- combo_plus %>%
  ungroup %>% 
  mutate.(lag_pod = lags.(pod), .by = c(nhs_no, tfc)) %>% 
  mutate.(lead_pod = leads.(pod), .by = c(nhs_no, tfc)) %>% 
  mutate.(lag_pod_2 = lags.(pod, 2), .by = c(nhs_no, tfc)) %>% 
  mutate.(lead_pod_2 = leads.(pod, 2), .by = c(nhs_no, tfc)) %>% 
  # THIS METHOD IS MUCH FASTER THAN USING DIFFTIME WITH LAG AND LEAD:
  # (NA inserted so that vector length compatible)
  mutate.(lag_days = c(NA, diff(as.numeric(date_actv))), .by = c(nhs_no, tfc)) %>%
  mutate.(lead_days = leads.(lag_days), .by = c(nhs_no, tfc))
# toc()

combo_plus <- combo_plus %>% 
  # SO VECTORS CAN BE RECYCLED (THIS IS ODD BECAUSE OF THE WAY diff() WORKS):
  # (KEEPING THIS OPERATION IN DPLYR)
  group_by(nhs_no, tfc) %>%
  mutate(lag_days_2 = ifelse(
    count_actv > 1,
    c(NA, NA, diff(as.numeric(date_actv), lag = 2)),
    NA )) %>% 
  ungroup() %>% 
  mutate.(lead_days_2 = leads.(lag_days_2, 2), .by = c(nhs_no, tfc)) 