/*
  Disease-classification slice of WhitePaper.sas (upstream lines ~5-87).
  Classifies claims into cancer / heart-disease using the author's
  array + IN: prefix-match against ICD-9 diagnosis-code ranges, rolls up
  per person_id, then derives cancer-only / heart-disease-only / both /
  neither. Logic is the author's; only the trailing DROP TABLE cleanup
  steps are removed so the derived tables survive for the summary below.
*/

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
quit;

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

* Summarize the derived condition groups;
data condition_group;
	set disease_diagnosed;
	length conditions $20;
	if      has_cancer_only=1        then conditions="Cancer Only";
	else if has_heart_disease_only=1 then conditions="Heart Disease Only";
	else if has_both=1               then conditions="Both Conditions";
	else                                  conditions="Neither Condition";
run;

proc freq data=condition_group;
	table conditions;
run;

proc print data=disease_diagnosed;
	var person_id has_cancer_only has_heart_disease_only has_both has_neither tot_allowed_amt;
run;
