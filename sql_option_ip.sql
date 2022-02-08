-- SAVE RESULTS (WITH HEADERS) TO A CSV NAMED sus_ip.csv THIS WILL BE USED IN THE: 
-- "752_master_sus_convert.R" SCRIPT.
-- NOTE: THE .csv FILE SHOULD BE SAVED IN THE SAME DIRECTORY AS THE "master" SCRIPT.

SELECT 
  [NHSNumber] AS nhs_no
  ,[AdmissionDate] AS date_actv
  ,[AdmissionMethodCode] AS admimeth
  ,[TreatmentSpecialtyCode] AS tfc

-- REDIRECT TO YOUR SUS INPATIENT TABLE:
FROM [EAT_Reporting].[dbo].[tbInpatientEpisodes]

WHERE 1=1
  -- ALL ADMISSIONS WITHIN A DESIRED AREA (E.G. BLACK COUNTRY + BSOL)
  -- THIS IS JUST AN E.G.:
  AND ([CCGcode] IN ('05C00', '05L00' , '05Q00') OR ProviderCode = 'RNA00')
  -- DESIRED TIME PERIOD
  -- USE SAME AS OP QUERY
  -- (INCLUDE SIX MONTH BUFFER EITHER SIDE):
  AND ([FinancialYear] = '1819'
 	OR [MonthEndOfEpisode] IN ('201710', '201711', '201712', '201801', '201802', '201803') OR [MonthEndOfEpisode] IN ('201904', '201905', '201906', '201907', '201908', '201909'))
  -- FOR SPEED OF EXECUTION, SELECT JUST ONE TREAT. SPECIALTY:
  AND [TreatmentSpecialtyCode] = '320'
