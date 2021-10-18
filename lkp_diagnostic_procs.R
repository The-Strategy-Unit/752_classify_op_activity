# THIS LIST CONTAINS OPCS-4 CODES FOR DIAGNOSTIC PROCEDURES
# (E.G. IMAGING, ENDOSCOPY, PHYSIOLOGICAL MEASUREMENTS, AND PATHOLOGY)
# A WORKING LIST. SUGGESTIONS WELCOME.

lkp_dm01 <- read_csv("lookup_diagnostic-opcs-codes-from-dm01.csv",
                     col_types = cols(procCode4Char = col_skip())) %>%
  janitor::clean_names()

lkp_diagnostic_custom <- read_csv("lookup_diagnostic-opcs-codes-custom-list.csv") %>%
  janitor::clean_names()

# CREATES A SLIGHTLY LONGER LIST THAN DM01:
# (MY ADDITIONS)
procs_dm01 <- lkp_dm01 %>%
  mutate(proc_code = str_sub(proc_code3char, 1, 2)) %>%
  # REMOVE THOSE THAT WE ALREADY HAVE IN THE CUSTOM LIST ABOVE.
  anti_join(lkp_diagnostic_custom, by = "proc_code") %>%
  select(proc_code4char_no_period, proc_code3char) %>%
  group_by(proc_code3char) %>%
  mutate(id = row_number()) %>%
  ungroup() %>%
  # FOR MY BENEFIT:
  pivot_wider(names_from = id, values_from = proc_code4char_no_period) %>%
  select(proc_code = proc_code3char) %>%
  # THESE SHOULD NOT BE TRUNCATED - LEAVE FULL CODE:
  mutate(proc_code = case_when(
    proc_code == "Q55" ~ "Q555",
    proc_code == "M47" ~ "M474",
    T ~ proc_code
  )) %>%
  pull(proc_code)

# NOTE: SHOULD NOT INCLUDE Y96
procs_custom <- lkp_diagnostic_custom %>% pull(proc_code)

# SUGGEST THESE PROCS ARE LIKELY TO BE CLASSIFIED "DIAGNOSTIC" (AS OPPOSED TO "TREATMENTS"):
proc_dim <- c(
  procs_dm01, procs_custom,
  # E9.. == Oximetry and other respiratory tests:
  "E91", "E92", "E93",
  # FOETAL SCANS:
  "R36", "R37",
  # DOPPLER ULTRASOUND/ ULTRASOUND:
  "R42", "R43",
  # BIOPSY BREAST/ OTHER:
  "B32", "X551",
  # Salpingography:
  "Q411"
)

proc_dim <- str_flatten(proc_dim, collapse = "|")
