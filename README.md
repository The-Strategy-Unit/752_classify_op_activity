# Classifying Outpatient Activity by Function
This repository contains the SQL code, R code, and reference tables used in the Midlands Decision Support Network (MDSN) project, "Classifying Outpatient Activity by Function".

## New - To use on SUS tables with SQL 

1. Extract these files to folder on local machine. 
2. Modify (as necessary) and run: sql_option_op.sql and sql_option_ip.sql. 
3. Run 752_master_sql_option.R script.

Outputs a demo csv file (when this parameter set is set as TRUE in 752_master_sql_option.R).


## For NCDR
"Master.R" contains instructions and executes other necessary scripts. 

##

Given the relative simplicity of the algorithm, we suggest it could - with moderate effort - be re-written in SQL or in Python. See <https://www.midlandsdecisionsupport.nhs.uk/wp-content/uploads/2021/10/dsu_classify_op_appendix_v0.1.pdf> for methods.
