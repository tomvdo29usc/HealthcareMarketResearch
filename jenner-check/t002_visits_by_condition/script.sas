/*
  Care-utilization slice of WhitePaper.sas (upstream lines ~112-282).
  Buckets each claim into primary-care / cardiologist / oncologist / others
  by spec_cd, and inpatient / outpatient by pos_cd, screening P vs F claims,
  then rolls visits up per person with PROC SQL (max within a start_date,
  sum across dates) and summarizes visit counts by condition with PROC MEANS.
  The author's classification and rollup logic is unchanged; trailing
  DROP TABLE cleanup is removed so the derived tables survive.
*/

* Identify places patients went to receive care;
data physicians;
	set SynUSA.synusa_clms_2015_extr;
	if spec_cd in("01","08","11","37","38") & allowed_amt > 0.01 then primary_care=1;
	else primary_care=0;

	if spec_cd in("06","77","78","21") & allowed_amt > 0.01 then cardiologist=1;
	else cardiologist=0;

	if spec_cd in("83","90","91","92","98") & allowed_amt > 0.01 then oncologist=1;
	else oncologist=0;

	if (primary_care=0 & cardiologist=0 & oncologist=0) & allowed_amt > 0.01 then others = 1;
	else others = 0;

	* Remember to screen for professional claims only;
	if claim_type="P";
run;

proc sql;
	create table P_claims as
	select bene_cat
		,person_id
		,start_date
		,max(primary_care) as primary_care
		,max(cardiologist) as cardiologist
		,max(oncologist) as oncologist
		,max(others) as others
	from physicians
	group by bene_cat, person_id, start_date
	;
quit;

* Find total visits of primary care, cardiologist, oncologist, and others by each person_id;
proc sql;
	create table P_visits as
	select
		bene_cat
		,person_id
		,sum(primary_care) as tot_primary_care
		,sum(cardiologist) as tot_cardiologist
		,sum(oncologist) as tot_oncologist
		,sum(others) as tot_others
	from P_claims
	group by bene_cat, person_id
	;
quit;

* Do the similar to facility claims;
data facilities;
	set SynUSA.synusa_clms_2015_extr;

	if pos_cd in("21") & allowed_amt > 0.01 then inpatient=1;
	else inpatient=0;

	if pos_cd in("22","24","62","65") & allowed_amt > 0.01 then outpatient=1;
	else outpatient = 0;
	* Remember to screen for facility claims only;
	if claim_type="F";
run;

proc sql;
	create table F_claims as
	select bene_cat
		,person_id
		,start_date
		,max(inpatient) as inpatient
		,max(outpatient) as outpatient
	from facilities
	group by bene_cat, person_id, start_date
	;
quit;

proc sql;
	create table F_visits as
	select
		bene_cat
		,person_id
		,sum(inpatient) as tot_inpatient
		,sum(outpatient) as tot_outpatient
	from F_claims
	group by bene_cat, person_id
	;
quit;

* Merge professional and facility visit data per person;
proc sql;
	create table analysis_file as
	select
		coalesce(a.bene_cat, b.bene_cat) as conditions length=20
		,coalesce(a.person_id, b.person_id) as person_id
		,coalesce(a.tot_primary_care,0) as tot_primary_care
		,coalesce(a.tot_cardiologist,0) as tot_cardiologist
		,coalesce(a.tot_oncologist,0) as tot_oncologist
		,coalesce(a.tot_others,0) as tot_others
		,coalesce(b.tot_inpatient,0) as tot_inpatient
		,coalesce(b.tot_outpatient,0) as tot_outpatient
	from P_visits a
		full join F_visits b on (a.person_id=b.person_id)
	order by conditions, person_id
	;
quit;

* Find out how average care utilization differs by condition group;
proc sort data=analysis_file;
	by conditions;
run;

proc means data=analysis_file mean;
	var tot_primary_care tot_cardiologist tot_oncologist tot_others tot_inpatient tot_outpatient;
	by conditions;
run;
