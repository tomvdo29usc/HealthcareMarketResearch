libname SynUSA "/home/u60699928/my_shared_file_links/u51050337/MILI_3963/SynUSA_Data";

******************************************************************************************************************************************
* Identify which claims containing heart diseases and cancer diagnosis;
data find_codes;
	set SynUSA.synusa_clms_2015_extr;	
	array diag(3) diag1_v9 diag2_v9 diag3_v9;
	cancer=0;
	heart_disease = 0;
	do i=1 to 3;
		if diag(i) in:(/*Malignant Neoplasm Of Lip, Oral Cavity, And Pharynx*/
					   "140","141","142","143","144","145","146","147","148","149",
					   /*Malignant Neoplasm Of Digestive Organs And Peritoneum*/
					   "150","151","152","153","154","155","156","157","158","159",
					   /*Malignant Neoplasm Of Respiratory And Intrathoracic Organs*/
					   "160","161","162","163","164","165",
					   /*Malignant Neoplasm Of Bone, Connective Tissue, Skin, And Breast*/
					   "170","171","172","173","174","175","176",
					   /*Malignant Neoplasm Of Genitourinary Organs*/
					   "179","180","181","182","183","184","185","186","187","188","189",
					   /*Malignant Neoplasm Of Other And Unspecified Sites*/
					   "190","191","192","193","194","195","196","197","198","199",
					   /*Malignant Neoplasm Of Lymphatic And Hematopoietic Tissue*/
					   "200","201","202","203","204","205","206","207","208","209") then cancer = 1;
		else if diag(i) in:(/*Chronic Rheumatic Heart Disease*/
		   					"393","394","395","396","397","398",
						    /*Ischemic Heart Disease*/
					        "410","411","412","413","414",
					        /*Pulmonary Heart Disease*/
					        "415","416"
					        /*Other Forms Of Heart Disease*/
					       	"420","421","422","423","424","425","426","427","428","429") then heart_disease = 1;
	end;
	keep person_id year start_date cancer heart_disease allowed_amt;
run;

* Remove duplicates for each person_id-start_date with cancer or heart disease diagnosis;
proc sql;
	create table date_list as
	select distinct
		person_id,
		start_date,
		year,
		cancer,
		heart_disease,
		allowed_amt
	from find_codes
	;
	drop table find_codes;
quit;

******************************************************************************************************************************************
* Find total time of cancer and heart disease diagnosis per patients;
proc sql;
	create table disease_count as
	select 
		person_id
		,sum(cancer) as numb_cancer
		,sum(heart_disease) as numb_heart_disease
		,sum(allowed_amt) as tot_allowed_amt
	from date_list
	group by 
		person_id
		,year
	;
quit;

******************************************************************************************************************************************
* Patient lists with cancer only, heart disease only, both disease, and neither ones;
data disease_diagnosed;
	set disease_count;
	has_cancer=0;
	has_heart_disease=0;
	has_both = 0;
	has_neither = 0;
	if numb_cancer>=2 then has_cancer=1;
	if numb_heart_disease>=2 then has_heart_disease = 1;
	
	if has_cancer=1 & has_heart_disease=1 then has_both=1;
	if has_cancer=0 & has_heart_disease=0 then has_neither=1;
	has_cancer_only = 0;
	has_heart_disease_only = 0;
	if has_cancer=1 & has_heart_disease=0 then has_cancer_only = 1;
	if has_cancer=0 & has_heart_disease=1 then has_heart_disease_only = 1;
	
	keep person_id has_cancer_only has_heart_disease_only has_both has_neither tot_allowed_amt;
run;

******************************************************************************************************************************************
* Match person_id with depression to the list of all patients in the 3 states to identify which person was not diagnosed with depression;
data SynUSA_Members;
	set SynUSA.SynUSA_memb_2015_extr;
run;

proc sql;
	create table bene_file (drop=A) as
	select 
		a.*
		,coalesce(b.has_cancer_only,0) as has_cancer_only
		,coalesce(b.has_heart_disease_only,0) as has_heart_disease_only
		,coalesce(b.has_both,0) as has_both
		,coalesce(b.has_neither,1) as has_neither /*assign no indicator or null?*/
		,coalesce(b.tot_allowed_amt,0) as tot_allowed_amt
	from SynUSA_Members a 
		left join disease_diagnosed b on (a.person_id=b.person_id)
	;
	*drop table disease_count, disease_diagnosed;
quit;

******************************************************************************************************************************************
* Identify places patients went to receive care;
data physicians;
	set SynUSA.synusa_clms_2015_extr;
	* Primary Care providers include spec_cd=
	*  01 General practice
	*  08 Family medicine
	*  11 Internal medicine
	*  37 Pediatrics
	*  38 Geriatric medicine
	* Again, I'm not including ob/gyn;	
	if spec_cd in("01","08","11","37","38") & allowed_amt > 0.01 then primary_care=1; 
	else primary_care=0;
	
	* Cardiology providers include spec_cd=
	*  06 Cardilogy
	*  77 Vascular Surgery
	*  78 Cardiac Surgery
	*  21 Cardiac Electrophysiology;
	if spec_cd in("06","77","78","21") & allowed_amt > 0.01 then cardiologist=1;
	else cardiologist=0;
	
	* Oncology providers include spec_cd=
	*  83 Hematology/oncology
	*  90 Medical Oncology
	*  91 Surgical Oncology
	*  92 Radiation Oncology
	*  98 Gynecologist/oncologist;
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
	drop table physicians;
quit;

* Find total visits of primary care, cardiologist, oncologist, and others by each person_id;
proc sql;
	create table P_visits as
	select
		person_id
		,sum(primary_care) as tot_primary_care
		,sum(cardiologist) as tot_cardiologist
		,sum(oncologist) as tot_oncologist
		,sum(others) as tot_others
	from P_claims
	group by person_id
	;
	drop table P_claims;
quit;

******************************************************************************************************************************************
* Do the similar to facility claims;
data facilities;
	set SynUSA.synusa_clms_2015_extr;
	
	* Inpatient pos_cd=
	*  21 Inpatient Hospital;
	if pos_cd in("21") & allowed_amt > 0.01 then inpatient=1; 
	else inpatient=0;
	
	* Outpatient pos_cd=
	*  22 On-campus Outpatient Hospital
	*  24 Ambulatory Surgical Center
	*  62 Comprehensive Outpatient Rehabilitation Facility
	*  65 End-Stage Renal Disease Treatment Facility;
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
	drop table facilities;
quit;

proc sql;
	create table F_visits as
	select
		person_id
		,sum(inpatient) as tot_inpatient
		,sum(outpatient) as tot_outpatient
	from F_claims
	group by person_id
	;
	drop table F_claims;
quit;

******************************************************************************************************************************************
* Merge profession and facility visit data to bene_file;
proc sql;
	create table final_file as
	select distinct
		a.*
		,coalesce(b.tot_primary_care,0) as tot_primary_care
		,coalesce(b.tot_cardiologist,0) as tot_cardiologist
		,coalesce(b.tot_oncologist,0) as tot_oncologist
		,coalesce(b.tot_others,0) as tot_others
		,coalesce(c.tot_inpatient,0) as tot_inpatient
		,coalesce(c.tot_outpatient,0) as tot_outpatient
	from bene_file a
		left join P_visits b on (a.person_id=b.person_id)
		left join F_visits c on (a.person_id=c.person_id)
	order by person_id
	;
quit;

******************************************************************************************************************************************
* Create data for proc means analysis;
proc sql;
	create table analysis_file as 
	select
		*
		,case 
			when has_heart_disease_only=1 then "Heart Disease Only"
			when has_cancer_only=1 then "Cancer Only"
			when has_both=1 then "Both Conditions"
			when has_neither=1 then "Neither Condition"
		 end as conditions
	from final_file;
run;

******************************************************************************************************************************************
* See gender percentage;
proc freq data=final_file;
	table female;
	run;
	
* See age categories percentage;
proc freq data=final_file;
	table age_cat;
	run;

******************************************************************************************************************************************
* Find out how average care utilization and different place of care visits differ from condition group;
proc sort data=analysis_file;
	by conditions;
run;

proc means data = analysis_file mean;
	var has_cancer_only has_heart_disease_only has_both has_neither tot_allowed_amt tot_primary_care tot_cardiologist
		tot_oncologist tot_others tot_inpatient tot_outpatient;
	by conditions;
	output out=results_by_condition
		mean=cancer heart_disease both_condition neither avg_allowed_amt avg_pc_vst avg_cardiologist_vst
			 avg_oncologist_vst avg_others_vst avg_inpatient avg_outpatient;
run;

* ANOVA test amt to condition --> all are stat sig;
proc anova data=analysis_file;
	class conditions;
	model tot_allowed_amt = conditions;
	mean conditions;
run;

* ANOVA test all number of visits to conditions --> all are stat sig;
proc anova data=analysis_file;
	class conditions;
	model tot_primary_care = conditions;
run;

proc anova data=analysis_file;
	class conditions;
	model tot_oncologist = conditions;
run;

proc anova data=analysis_file;
	class conditions;
	model tot_cardiologist = conditions;
run;

proc anova data=analysis_file;
	class conditions;
	model tot_others = conditions;
run;

proc anova data=analysis_file;
	class conditions;
	model tot_inpatient = conditions;
run;

proc anova data=analysis_file;
	class conditions;
	model tot_outpatient = conditions;
run;

* Export to Excel;
proc export data=results_by_condition
	dbms=xlsx 
	outfile="/home/u60699928/WhitePaper/results_by_condition"
	replace; 
run;

* Find out how average care utilization and different place of care visits differ between age cat;
proc sort data=analysis_file;
	by age_cat;
run;
proc means data = analysis_file mean;
	var has_cancer_only has_heart_disease_only has_both has_neither tot_allowed_amt tot_primary_care tot_cardiologist
		tot_oncologist tot_others tot_inpatient tot_outpatient;
	by age_cat;
	output out=cancer_by_agecat
		mean=cancer heart_disease both_condition neither avg_allowed_amt avg_pc_vst avg_cardiologist_vst
			 avg_oncologist_vst avg_others_vst avg_inpatient avg_outpatient;
	where has_cancer_only =1;
run;

proc export data=cancer_by_agecat
	dbms=csv 
	outfile="/home/u60699928/WhitePaper/cancer_by_ages"
	replace; 
run;

proc means data = analysis_file mean;
	var has_cancer_only has_heart_disease_only has_both has_neither tot_allowed_amt tot_primary_care tot_cardiologist
		tot_oncologist tot_others tot_inpatient tot_outpatient;
	by age_cat;
	output out=HD_by_agecat
		mean=cancer heart_disease both_condition neither avg_allowed_amt avg_pc_vst avg_cardiologist_vst
			 avg_oncologist_vst avg_others_vst avg_inpatient avg_outpatient;
	where has_heart_disease_only =1;
run;

proc export data=HD_by_agecat
	dbms=csv 
	outfile="/home/u60699928/WhitePaper/HD_by_ages"
	replace; 
run;

proc means data = analysis_file mean;
	var has_cancer_only has_heart_disease_only has_both has_neither tot_allowed_amt tot_primary_care tot_cardiologist
		tot_oncologist tot_others tot_inpatient tot_outpatient;
	by age_cat;
	output out=both_by_agecat
		mean=cancer heart_disease both_condition neither avg_allowed_amt avg_pc_vst avg_cardiologist_vst
			 avg_oncologist_vst avg_others_vst avg_inpatient avg_outpatient;
	where has_both =1;
run;

proc export data=both_by_agecat
	dbms=csv 
	outfile="/home/u60699928/WhitePaper/both_by_ages"
	replace; 
run;

proc means data = analysis_file mean;
	var has_cancer_only has_heart_disease_only has_both has_neither tot_allowed_amt tot_primary_care tot_cardiologist
		tot_oncologist tot_others tot_inpatient tot_outpatient;
	by age_cat;
	output out=neither_by_agecat
		mean=cancer heart_disease both_condition neither avg_allowed_amt avg_pc_vst avg_cardiologist_vst
			 avg_oncologist_vst avg_others_vst avg_inpatient avg_outpatient;
	where has_neither =1;
run;

proc export data=neither_by_agecat
	dbms=csv 
	outfile="/home/u60699928/WhitePaper/neither_by_ages"
	replace; 
run;

* ANOVA test amt to age categories --> none is stat sig;
proc anova data=analysis_file;
	class age_cat;
	model tot_allowed_amt = age_cat;
	where has_cancer_only = 1;
run;

proc anova data=analysis_file;
	class age_cat;
	model tot_allowed_amt = age_cat;
	where has_heart_disease_only = 1;
run;

proc anova data=analysis_file;
	class age_cat;
	model tot_allowed_amt = age_cat;
	where has_both = 1;
run;

proc anova data=analysis_file;
	class age_cat;
	model tot_allowed_amt = age_cat;
	where has_neither = 1;
run;


*********************************************************************
* Find out how average allowed amount differ between insurance group;
proc sort data=analysis_file;
	by ins_type;
run;

proc means data = analysis_file mean;
	var has_cancer_only has_heart_disease_only has_both has_neither tot_allowed_amt tot_primary_care tot_cardiologist
		tot_oncologist tot_others tot_inpatient tot_outpatient;
	by ins_type;
	output out=cancer_by_instype
		mean=has_cancer_only has_heart_disease_only has_both has_neither avg_allowed_amt avg_pc_vst avg_cardiologist_vst
			 avg_oncologist_vst avg_others_vst avg_inpatient avg_outpatient;
	where has_cancer_only =1;
run;

proc means data = analysis_file mean;
	var has_cancer_only has_heart_disease_only has_both has_neither tot_allowed_amt tot_primary_care tot_cardiologist
		tot_oncologist tot_others tot_inpatient tot_outpatient;
	by ins_type;
	output out=HD_by_instype
		mean=has_cancer_only has_heart_disease_only has_both has_neither avg_allowed_amt avg_pc_vst avg_cardiologist_vst
			 avg_oncologist_vst avg_others_vst avg_inpatient avg_outpatient;
	where has_heart_disease_only =1;
run;

proc means data = analysis_file mean;
	var has_cancer_only has_heart_disease_only has_both has_neither tot_allowed_amt tot_primary_care tot_cardiologist
		tot_oncologist tot_others tot_inpatient tot_outpatient;
	by ins_type;
	output out=HD_by_instype
		mean=has_cancer_only has_heart_disease_only has_both has_neither avg_allowed_amt avg_pc_vst avg_cardiologist_vst
			 avg_oncologist_vst avg_others_vst avg_inpatient avg_outpatient;
	where has_both =1;
run;

proc means data = analysis_file mean;
	var has_cancer_only has_heart_disease_only has_both has_neither tot_allowed_amt tot_primary_care tot_cardiologist
		tot_oncologist tot_others tot_inpatient tot_outpatient;
	by ins_type;
	output out=HD_by_instype
		mean=has_cancer_only has_heart_disease_only has_both has_neither avg_allowed_amt avg_pc_vst avg_cardiologist_vst
			 avg_oncologist_vst avg_others_vst avg_inpatient avg_outpatient;
	where has_neither =1;
run;

* ANOVA test amt to insurance types --> all are stat sig;
proc anova data=analysis_file;
	class ins_type;
	model tot_allowed_amt = ins_type;
	where has_cancer_only = 1;
run;

proc anova data=analysis_file;
	class ins_type;
	model tot_allowed_amt = ins_type;
	where has_heart_disease_only = 1;
run;

proc anova data=analysis_file;
	class ins_type;
	model tot_allowed_amt = ins_type;
	where has_both = 1;
run;

proc anova data=analysis_file;
	class ins_type;
	model tot_allowed_amt = ins_type;
	where has_neither = 1;
run;

* Find out how average care utilization and different place of care visits differ from states;
proc sort data=analysis_file;
	by state;
run;

proc means data = analysis_file mean;
	var has_cancer_only has_heart_disease_only has_both has_neither tot_allowed_amt tot_primary_care tot_cardiologist
		tot_oncologist tot_others tot_inpatient tot_outpatient;
	by state;
	output out=cancer_by_states
		mean=cancer heart_disease both_condition neither avg_allowed_amt avg_pc_vst avg_cardiologist_vst
			 avg_oncologist_vst avg_others_vst avg_inpatient avg_outpatient;
	where has_cancer_only =1;
run;

proc export data=cancer_by_states
	dbms=xlsx 
	outfile="/home/u60699928/WhitePaper/cancer_by_states"
	replace; 
run;

proc means data = analysis_file mean;
	var has_cancer_only has_heart_disease_only has_both has_neither tot_allowed_amt tot_primary_care tot_cardiologist
		tot_oncologist tot_others tot_inpatient tot_outpatient;
	by state;
	output out=HD_by_states
		mean=cancer heart_disease both_condition neither avg_allowed_amt avg_pc_vst avg_cardiologist_vst
			 avg_oncologist_vst avg_others_vst avg_inpatient avg_outpatient;
	where has_heart_disease_only =1;
run;

proc export data=HD_by_states
	dbms=csv 
	outfile="/home/u60699928/WhitePaper/HD_by_states"
	replace; 
run;

proc means data = analysis_file mean;
	var has_cancer_only has_heart_disease_only has_both has_neither tot_allowed_amt tot_primary_care tot_cardiologist
		tot_oncologist tot_others tot_inpatient tot_outpatient;
	by state;
	output out=both_by_states
		mean=cancer heart_disease both_condition neither avg_allowed_amt avg_pc_vst avg_cardiologist_vst
			 avg_oncologist_vst avg_others_vst avg_inpatient avg_outpatient;
	where has_both =1;
run;

proc export data=both_by_states
	dbms=csv 
	outfile="/home/u60699928/WhitePaper/both_by_states"
	replace; 
run;

proc means data = analysis_file mean;
	var has_cancer_only has_heart_disease_only has_both has_neither tot_allowed_amt tot_primary_care tot_cardiologist
		tot_oncologist tot_others tot_inpatient tot_outpatient;
	by state;
	output out=neither_by_states
		mean=cancer heart_disease both_condition neither avg_allowed_amt avg_pc_vst avg_cardiologist_vst
			 avg_oncologist_vst avg_others_vst avg_inpatient avg_outpatient;
	where has_neither =1;
run;

proc export data=neither_by_states
	dbms=csv 
	outfile="/home/u60699928/WhitePaper/neither_by_states"
	replace; 
run;

* ANOVA test amt to state --> all are stat sig;
proc anova data=analysis_file;
	class state;
	model tot_allowed_amt = state;
	where has_cancer_only = 1;
run;

proc anova data=analysis_file;
	class state;
	model tot_allowed_amt = state;
	where has_heart_disease_only = 1;
run;

proc anova data=analysis_file;
	class state;
	model tot_allowed_amt = state;
	where has_both = 1;
run;

proc anova data=analysis_file;
	class state;
	model tot_allowed_amt = state;
	where has_neither = 1;
run;

* Create data for regression analysis (non reported);
proc sql;
	create table reg_file (drop=ins_type female region) as
	select
		*
		,case
			when female=1 then 1
			when female=0 then 0
		 end as sex
		,case
			when age_cat="00-18" then 1
			else 0
		 end as age_00_18
		,case
			when age_cat="19-34" then 1
			else 0
		 end as age_19_34
		,case
			when age_cat="35-44" then 1
			else 0
		 end as age_35_44
		,case
			when age_cat="45-64" then 1
			else 0
		 end as age_45_64
		,case
			when age_cat="65+" then 1
			else 0
		 end as age_65plus
		,case
			when ins_type="ESI" then 1
			else 0
		 end as ins_ESI
		,case
			when ins_type="NONGROUP" then 1
			else 0
		 end as ins_NONGROUP
		,case
			when ins_type="MEDICAID" then 1
			else 0
		 end as ins_MEDICAID
		,case
			when region="MIDWEST" then 1
			else 0
		 end as region_MIDWEST
		,case
			when region="NOREAST" then 1
			else 0
		 end as region_NOREAST
		,case
			when region="SOUTH" then 1
			else 0
		 end as region_SOUTH
		,case
			when region="WEST" then 1
			else 0
		 end as region_WEST
	from final_file
	;
quit;

proc univariate data=reg_file;
	var tot_allowed_amt;
	histogram tot_allowed_amt;
run;

proc reg data=reg_file;
	model tot_allowed_amt=sex age_19_34 age_35_44 age_45_64 age_65plus ins_ESI ins_MEDICAID hhincomefpl has_cancer_only
	has_heart_disease_only has_both 
	region_MIDWEST region_NOREAST region_SOUTH;
run;

* --> The histogram looks skewed --> Do log transform

* Calculate log for tot_allowed_amt;
proc sql;
	create table log_reg_data as
	select 
		*,
		log(tot_allowed_amt+1) as log_tot_allowed_amt
	from reg_file
	;
quit;

proc univariate data=log_reg_data;
	var log_tot_allowed_amt;
	histogram log_tot_allowed_amt;
run;

* Run regression;
proc reg data=log_reg_data;
	model log_tot_allowed_amt= has_cancer_only has_heart_disease_only has_both;
run;