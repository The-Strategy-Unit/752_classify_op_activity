
# LOOKUP FOR TFC:

lkp_tretspef <- read_rds("lkp_tretspef.rds")

# SOURCE:
# 
# con_reference <- dbConnect(odbc(),
#   Driver = "SQL Server",
#   Server = "PRODNHSESQL101",
#   Database = "NHSE_Reference",
#   Trusted_Connection = "True"
# )
# #
# tb_tretspef <- tbl(con_reference, in_schema("dbo", "tbl_Ref_DataDic_ZZZ_TreatmentFunction"))
# 
# lkp_tretspef <- tb_tretspef %>% collect()
# 
# lkp_tretspef <- lkp_tretspef %>%
#   select(tfc = Treatment_Function_Code, treatment_function = Treatment_Function_Desc_Short, tf_group = Treatment_Function_Group) %>%
#   mutate(treatment_function = str_remove(treatment_function, "[0-9]{3}: ")) %>%
#   mutate(tf_group = str_remove(tf_group, " specialties| Specialties")) %>%
#   mutate(treatment_function = str_trim(treatment_function))
