-- SAVE RESULTS (WITH HEADERS) TO A .csv NAMED sus_op.csv. THIS WILL BE USED IN THE: 
-- "752_master_sus_convert.R" SCRIPT.
-- NOTE: THE .csv FILE SHOULD BE SAVED IN THE SAME DIRECTORY AS THE "master" SCRIPT.

SELECT 
    [FinancialYear] AS fyear
   ,[NHSNumber] AS nhs_no
   ,[OPReferralSourceCode] AS refsorc
   ,[DirectAccessReferralIndicatorCode] AS is_direct
   ,[SusDerivedGpPractice] AS practice_code
   ,[PriorityTypeCode] AS priority
   ,[AppointmentDate] AS date_actv
   ,[ConsultantCode] AS cons_code 
   ,[TreatmentSpecialtyCode] AS tfc
   ,[FirstAttendanceCode] AS first
   ,[ProcedureCode] AS procs
   ,[CCGCode] AS ccg
   ,[ProviderCode] AS provider
   ,[SiteCode] AS site

-- REDIRECT TO YOUR SUS OUTPATIENT TABLE:
FROM [EAT_Reporting].[dbo].[tbOutpatient] sus_op

-- FOR DIRECT ACCESS FLAG ONLY (NOT ESSENTIAL - COULD BE EXCLUDED IF UNAVAILABLE):
LEFT JOIN [EAT_Reporting].[dbo].[tbOPExtra] sus_op_extra
	ON sus_op.EpisodeId = sus_op_extra.EpisodeId

WHERE 1=1
  -- DESIRED PROVIDER CODE:
  AND ProviderCode = 'RNA00'
  -- DESIRED TIME PERIOD (INCLUDE SIX MONTH BUFFER EITHER SIDE):
  AND ([FinancialYear] = '1819'
 	OR [AttendanceMonth] IN ('201710', '201711', '201712', '201801', '201802', '201803') OR [AttendanceMonth] IN ('201904', '201905', '201906', '201907', '201908', '201909'))
  -- FOR SPEED OF EXECUTION (IN THIS EXAMPLE) SELECT JUST ONE TREAT. SPECIALTY:
  AND [TreatmentSpecialtyCode] = '320'
  AND IsDNA = 0

