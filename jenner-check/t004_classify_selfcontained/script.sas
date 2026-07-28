/*
  Self-contained version of the disease-classification slice of
  WhitePaper.sas (upstream lines ~5-87). Everything lives in this one
  file, so it can be POSTed on its own (e.g. to /v1/quick) with no
  separate autoexec or data files. The mock claims table stands in for
  the SynUSA.synusa_clms_2015_extr extract that is not part of the repo;
  its ICD-9 codes are chosen to exercise every branch of the author's
  array + IN: prefix-match classification.
*/
options obs=100;

data claims;
    length person_id 8 year 8 start_date 8 diag1_v9 diag2_v9 diag3_v9 $6 allowed_amt 8;
    infile datalines dsd truncover;
    input person_id year start_date : date9. diag1_v9 $ diag2_v9 $ diag3_v9 $ allowed_amt;
    format start_date date9.;
    datalines;
1001,2015,05JAN2015,1749,4019,V700,1200.50
1001,2015,12FEB2015,1749,,,3400.00
1002,2015,08JAN2015,4140,2724,,2200.00
1002,2015,19JAN2015,4148,,,1750.75
1003,2015,02FEB2015,1620,4141,,5600.00
1003,2015,14MAR2015,1621,4140,,4800.40
1004,2015,21JAN2015,7231,V762,,320.00
1005,2015,11JAN2015,1533,,,2900.00
1005,2015,27FEB2015,1534,4111,,3100.60
1007,2015,09JAN2015,V202,7862,,90.00
;
run;

* Author's classification: array + IN: prefix-match against ICD-9 ranges;
data find_codes;
	set claims;
	array diag(3) diag1_v9 diag2_v9 diag3_v9;
	cancer=0;
	heart_disease = 0;
	do i=1 to 3;
		if diag(i) in:("140","141","142","143","144","145","146","147","148","149",
					   "150","151","152","153","154","155","156","157","158","159",
					   "160","161","162","163","164","165",
					   "170","171","172","173","174","175","176",
					   "179","180","181","182","183","184","185","186","187","188","189",
					   "190","191","192","193","194","195","196","197","198","199",
					   "200","201","202","203","204","205","206","207","208","209") then cancer = 1;
		else if diag(i) in:("393","394","395","396","397","398",
					        "410","411","412","413","414",
					        "415","416"
					       	"420","421","422","423","424","425","426","427","428","429") then heart_disease = 1;
	end;
	keep person_id start_date cancer heart_disease allowed_amt;
run;

proc print data=find_codes;
	var person_id start_date cancer heart_disease allowed_amt;
run;

proc freq data=find_codes;
	table cancer*heart_disease / norow nocol nopercent;
run;
