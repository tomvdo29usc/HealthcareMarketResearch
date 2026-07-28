/* cap input rows for the captured run */
options obs=100;

/*
  The upstream WhitePaper.sas builds analysis_file from the SynUSA claims and
  member extracts, then runs PROC FREQ on female / age_cat and PROC ANOVA of
  tot_allowed_amt by condition. Those raw datasets are not in this public repo,
  so we build a small mock analysis_file directly with exactly the columns
  this slice reads: female age_cat conditions tot_allowed_amt. Several rows per
  condition group keep the ANOVA classes non-degenerate, and the allowed-amount
  levels mirror the paper's finding that diagnosed patients cost more.
*/
data analysis_file;
    length conditions $20 age_cat $5;
    infile datalines dsd truncover;
    input female age_cat $ conditions $ tot_allowed_amt;
    datalines;
1,45-64,Cancer Only,14200
0,65+,Cancer Only,15900
1,35-44,Cancer Only,12800
0,45-64,Cancer Only,16750
1,65+,Heart Disease Only,17100
0,45-64,Heart Disease Only,15400
1,65+,Heart Disease Only,18900
0,35-44,Heart Disease Only,13200
1,65+,Both Conditions,26700
0,65+,Both Conditions,29100
1,45-64,Both Conditions,24300
0,45-64,Both Conditions,31500
1,19-34,Neither Condition,2600
0,35-44,Neither Condition,2400
1,45-64,Neither Condition,2900
0,65+,Neither Condition,3100
1,00-18,Neither Condition,1800
0,19-34,Neither Condition,2200
;
run;
