/*
  Descriptive + hypothesis-testing slice of WhitePaper.sas
  (upstream lines ~259-289). PROC FREQ reports gender and age-category
  distributions; PROC ANOVA tests whether total allowed amount differs
  across the four condition groups. This is the statistical core the
  paper leans on ("multiple ANOVA tests to ensure statistical
  significance"). Statements are the author's; only the data source is
  the bundled mock analysis_file.
*/

* See gender percentage;
proc freq data=analysis_file;
	table female;
run;

* See age categories percentage;
proc freq data=analysis_file;
	table age_cat;
run;

* Find out how average care utilization differs by condition group;
proc sort data=analysis_file;
	by conditions;
run;

proc means data=analysis_file mean;
	var tot_allowed_amt;
	by conditions;
run;

* ANOVA test amt to condition --> all are stat sig;
proc anova data=analysis_file;
	class conditions;
	model tot_allowed_amt = conditions;
	means conditions;
run;
