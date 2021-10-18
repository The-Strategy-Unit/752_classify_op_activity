# INCLUDING 2020 AND 2021 CODES 

ics_midlands_list <- list(
  bsol = c('04X', '13P', '05P', '15E'),
  cov  = c('05A', '05R', '05H', "B2M3M"),
  derb = c('03X', '03Y', '04J', '04R', "15M"),
  herf = c('05F', '05J', '05T', '06D', '18C'),
  leic = c('03W', '04C', '04V')     ,
  linc = c('03T', '04D', '99D', '04Q', '71E'),
  nham = c('03V', '04G', '04E', '78H'),
  nott = c('04H', '04K', '04L', '04M','04N', "52R") ,
  shrp = c('05N', '05X', "M2L0M")             ,
  staf = c('04Y', '05D', '05G', '05Q', '05V', '05W') ,
  bcwb = c('05C', '05L', '05Y', '06A', "D2P2L") # NOTE: 05L IS S&WB. AND WB NOW BSOL
)

df_ics <- enframe(ics_midlands_list)
