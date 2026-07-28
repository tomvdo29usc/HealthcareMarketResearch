/* cap input rows for the captured run */
options obs=100;

/*
  The upstream WhitePaper.sas reads two SAS-Studio datasets via
      libname SynUSA "/home/u60699928/.../SynUSA_Data";
  which are not part of this public repo. To let the disease-classification
  slice run standalone, we point SynUSA at WORK and build a small mock
  claims table with exactly the columns the DATA step reads:
      person_id year start_date diag1_v9 diag2_v9 diag3_v9 allowed_amt
  ICD-9 codes below are chosen to hit the author's cancer / heart-disease
  code ranges (and some that hit neither), so every branch is exercised.
*/
libname SynUSA (work);

data SynUSA.synusa_clms_2015_extr;
    length person_id 8 year 8 start_date 8 diag1_v9 diag2_v9 diag3_v9 $6 allowed_amt 8;
    infile datalines dsd truncover;
    input person_id year start_date : date9. diag1_v9 $ diag2_v9 $ diag3_v9 $ allowed_amt;
    format start_date date9.;
    datalines;
1001,2015,05JAN2015,1749,4019,V700,1200.50
1001,2015,12FEB2015,1749,,,3400.00
1001,2015,03MAR2015,1748,,,850.25
1002,2015,08JAN2015,4140,2724,,2200.00
1002,2015,19JAN2015,4148,,,1750.75
1003,2015,02FEB2015,1620,4141,,5600.00
1003,2015,14MAR2015,1621,4140,,4800.40
1004,2015,21JAN2015,7231,V762,,320.00
1004,2015,05APR2015,4659,,,110.10
1005,2015,11JAN2015,1533,,,2900.00
1005,2015,27FEB2015,1534,4111,,3100.60
1006,2015,04MAR2015,4271,4280,,7200.00
1006,2015,16MAR2015,4275,,,6650.00
1007,2015,09JAN2015,V202,7862,,90.00
1008,2015,13FEB2015,1830,4149,,4400.00
1008,2015,25FEB2015,1831,4148,,3950.00
;
run;
