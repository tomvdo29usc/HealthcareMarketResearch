/* cap input rows for the captured run */
options obs=100;

/*
  The upstream WhitePaper.sas reads its claims from SynUSA via
      libname SynUSA "/home/u60699928/.../SynUSA_Data";
  not present in this public repo. We point SynUSA at WORK and build a
  small mock claims table with exactly the columns this slice reads:
      bene_cat person_id start_date allowed_amt spec_cd pos_cd claim_type
  Values below cover the author's provider-specialty codes (primary care
  01/08/11/37/38, cardiology 06/77/78/21, oncology 83/90/91/92/98) and
  place-of-service codes (inpatient 21, outpatient 22/24/62/65), across a
  mix of professional (P) and facility (F) claims.
*/
libname SynUSA (work);

data SynUSA.synusa_clms_2015_extr;
    length bene_cat $20 person_id 8 start_date 8 allowed_amt 8 spec_cd $2 pos_cd $2 claim_type $1;
    infile datalines dsd truncover;
    input bene_cat $ person_id start_date : date9. allowed_amt spec_cd $ pos_cd $ claim_type $;
    format start_date date9.;
    datalines;
Cancer Only,1001,05JAN2015,1200.50,11,11,P
Cancer Only,1001,12FEB2015,3400.00,90,11,P
Cancer Only,1001,03MAR2015,850.25,83,11,P
Cancer Only,1001,20MAR2015,5000.00,,22,F
Heart Disease Only,1002,08JAN2015,2200.00,06,11,P
Heart Disease Only,1002,19JAN2015,1750.75,08,11,P
Heart Disease Only,1002,25JAN2015,9000.00,,21,F
Both Conditions,1003,02FEB2015,5600.00,90,11,P
Both Conditions,1003,14MAR2015,4800.40,06,11,P
Both Conditions,1003,20MAR2015,7000.00,,24,F
Neither Condition,1004,21JAN2015,320.00,37,11,P
Neither Condition,1004,05APR2015,110.10,99,11,P
Neither Condition,1005,11JAN2015,2900.00,38,11,P
Cancer Only,1006,04MAR2015,7200.00,91,11,P
Cancer Only,1006,16MAR2015,6650.00,,62,F
Heart Disease Only,1007,09JAN2015,90.00,77,11,P
Both Conditions,1008,13FEB2015,4400.00,92,11,P
Both Conditions,1008,25FEB2015,3950.00,78,11,P
;
run;
