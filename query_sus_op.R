
tb_op <- tbl(con_susplus, in_schema("dbo", "tbl_Data_SEM_OPA"))


# SET YOUR PARAMETERS 2 ----------------------------------------------
base_query_op <- tb_op %>% 
  ## MULTI YEAR STUDY PERIOD:
  filter(Der_Financial_Year %in% c("2011/12", "2012/13", "2013/14", "2014/15","2015/16",
                                   "2016/17", "2017/18", "2018/19", "2019/20", "2020/21") |
           # AND (AT LEAST) SIX MONTHS BUFFER EITHER SIDE TO INCORPORATE SURROUNDING CONTACTS:
           Der_Activity_Month %in% c("201010", "201011", "201012" , "201101", "201102", "201103")|
           Der_Activity_Month %in% c("202104", "202105", "202106" , "202107", "202108", "202109")
  ) %>%
  ## SINGLE YEAR STUDY PERIOD:
  # filter(Der_Financial_Year %in% c("2019/20") |
  #          # AND BUFFER EITHER SIDE TO LOOK AT SURROUNDING CONTACTS:
  #          Der_Financial_Year %in% c("2018/19") | # BACK A YEAR (RECOMMENDED)
  #          Der_Activity_Month %in% c("202004", "202005", "202006", "202007", "202008", "202009")) %>% 
  ## FOR PROVIDER-BASED ANALYSES:
  filter(Der_Provider_Code %in% local(chosen_trusts)) %>%
  ## ALTERNATIVELY, FOR CCG/ ICS:
  # filter(Der_Postcode_CCG_Code %in% local(chosen_ccgs)) %>% # OR:
  # filter(Der_Postcode_CCG_Code %in% local(chosen_ics)) %>%
  ## E.G. FOR CARDIOLOGY ONLY:         
  filter(Treatment_Function_Code == "320") 


# RENAME VARS (MY PREFERENCE) :
op_raw <-
  base_query_op %>%
  select(
    fyear = Der_Financial_Year,
    # PATIENT DETAILS:
    nhs_no = Der_Pseudo_NHS_Number,
    # age = Der_Age_At_CDS_Activity_Date,
    # sex = Sex,
    # REFERRAL DETAILS:
    refsorc = OPA_Referral_Source,
    is_direct = Direct_Access_Referral_Ind,
    practice_code = GP_Practice_Code, # For practice/ PCN analyses
    priority = Priority_Type,
    # APPOINTMENT DETAILS:
    date_actv = Appointment_Date,
    cons_code = Consultant_Code, # EG. FOR CONS/NON-CONS BREAKDOWN
    tfc = Treatment_Function_Code,
    first = First_Attendance,
    procs = Der_Procedure_All,
    # LOCATION DETAILS:
    ccg = Der_Postcode_CCG_Code,
    provider = Der_Provider_Code,
    site = Der_Provider_Site_Code
    # Der_Postcode_Sector,
  ) %>%
  # show_query() # GIVES SQL EQUIVALENT
  collect()

# <SQL>
# SELECT "Der_Financial_Year" AS "fyear", "Der_Pseudo_NHS_Number" AS "nhs_no",
#  "OPA_Referral_Source" AS "refsorc", "Direct_Access_Referral_Ind" AS "is_direct",
#  "GP_Practice_Code" AS "practice_code", "Priority_Type" AS "priority",
#  "Appointment_Date" AS "date_actv", "Consultant_Code" AS "cons_code", 
#  "Treatment_Function_Code" AS "tfc", "First_Attendance" AS "first",
#  "Der_Procedure_All" AS "procs", "Der_Postcode_CCG_Code" AS "ccg",
#  "Der_Provider_Code" AS "provider", "Der_Provider_Site_Code" AS "site"
# FROM (SELECT *
#         FROM (SELECT *
#                 FROM "dbo"."tbl_Data_SEM_OPA"
#               WHERE ("Der_Financial_Year" IN ('2011/12', '2012/13', '2013/14', '2014/15', '2015/16', '2016/17', '2017/18', '2018/19', '2019/20', '2020/21') OR "Der_Activity_Month" IN ('201010', '201011', '201012', '201101', '201102', '201103') OR "Der_Activity_Month" IN ('202104', '202105', '202106', '202107', '202108', '202109'))) "q01"
#       WHERE ("Der_Provider_Code" IN ('RR1', 'RRK', 'RXK'))) "q02"
# WHERE ("Treatment_Function_Code" = '320')
