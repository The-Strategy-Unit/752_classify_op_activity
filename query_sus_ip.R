
tb_ip   <- tbl(con_susplus, in_schema("dbo", "tbl_Data_SEM_APCS"))

# SET YOUR PARAMETERS 3 -------------------------------------------------------
base_query_ip <- tb_ip %>% 
  # THIS PERIOD SHOULD MATCH YOUR CHOSEN PERIOD FOR OP ACTIVITY:
  ## MULTI YEAR:
  filter(Der_Financial_Year %in% c("2011/12", "2012/13", "2013/14", "2014/15","2015/16",
                                   "2016/17", "2017/18", "2018/19", "2019/20", "2020/21") |
           # AND - WITH IP ACTIVITY - SIX MONTHS EITHER SIDE:
           Der_Activity_Month %in% c("201010", "201011", "201012" , "201101", "201102", "201103")|
           Der_Activity_Month %in% c("202104", "202105", "202106" , "202107", "202108", "202109")
  ) %>%
  # # SINGLE YEAR:
  # filter(Der_Financial_Year %in% c('2019/20') |
  #          # AND - WITH IP ACTIVITY - SIX MONTHS EITHER SIDE:
  #          Der_Activity_Month %in% c("201810", "201811", "201812" , "201901", "201902", "201903")|
  #          Der_Activity_Month %in% c("202004", "202005", "202006" , "202007", "202008", "202009")
  # ) %>%
  # ANALYST'S CHOICE:
  # HOW LARGE A NET TO CAST FOR EVIDENCE OF IP ACTIVITY?
  # WHILE INDIVIDUALS MAY HAVE HAD AN ADMISSION ANYWHERE IN COUNTRY -
  # VAST MAJORITY LIKELY TO COME FROM SURROUNDINGS. I'M USING THIS ASSUMPTION TO LIMIT DATE BROUGHT IN HERE. 
  filter(Der_Postcode_CCG_Code %in% local(df_ics$value[c(1, 2, 4, 11)] %>% unlist())|
           # AND FOR TRUST-BASED ANALYSES WE NEED:
           Der_Provider_Code %in% local(chosen_trusts)) %>%
  # E.G. FOR CARDIOLOGY ONLY:         
  filter(Der_Admit_Treatment_Function_Code == "320" |Der_Dischg_Treatment_Function_Code == "320") 

# RENAME VARS (MY PREFERENCE) :
ip_raw <- base_query_ip %>%
  select(
    nhs_no = Der_Pseudo_NHS_Number,
    date_actv = Admission_Date,
    admimeth = Admission_Method,
    tfc_admi = Der_Admit_Treatment_Function_Code,
    tfc_disc = Der_Dischg_Treatment_Function_Code
  ) %>% 
  # show_query()
  collect


# <SQL>
# SELECT "Der_Pseudo_NHS_Number" AS "nhs_no","Admission_Date" AS "date_actv",
#  "Admission_Method" AS "admimeth", "Der_Admit_Treatment_Function_Code" AS "tfc_admi",
#  "Der_Dischg_Treatment_Function_Code" AS "tfc_disc"
# FROM (SELECT *
#         FROM (SELECT *
#                 FROM "dbo"."tbl_Data_SEM_APCS"
#               WHERE ("Der_Financial_Year" IN ('2011/12', '2012/13', '2013/14', '2014/15', '2015/16', '2016/17', '2017/18', '2018/19', '2019/20', '2020/21') OR "Der_Activity_Month" IN ('201010', '201011', '201012', '201101', '201102', '201103') OR "Der_Activity_Month" IN ('202104', '202105', '202106', '202107', '202108', '202109'))) "q01"
#       WHERE ("Der_Postcode_CCG_Code" IN ('04X', '13P', '05P', '15E', '05A', '05R', '05H', 'B2M3M', '05F', '05J', '05T', '06D', '18C', '05C', '05L', '05Y', '06A', 'D2P2L') OR "Der_Provider_Code" IN ('RR1', 'RRK', 'RXK'))) "q02"
# WHERE ("Der_Admit_Treatment_Function_Code" = '320' OR "Der_Dischg_Treatment_Function_Code" = '320')
