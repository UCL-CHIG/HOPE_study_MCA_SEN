********************************************************************************
* DO 5. SEN PROVISION PREVALENCE
********************************************************************************

********************************************************************************
* Create tables with sum of SEN records across KS1 and KS2
* Also need the number eligible (totals)
* Use this to create proportions of 
********************************************************************************

********************************************************************************
* PREPARE SEN DATA
********************************************************************************
*Create labelled sen_provision variable
	*N - None
	*A - School Action
	*P - School Action Plus
	*K - SEN Support
	*S - Statement
	*E or e - EHCP
gen sen_record=.
replace sen_record=0 if sen_provision=="N"
replace sen_record=1 if sen_provision=="A"
replace sen_record=2 if sen_provision=="P"
replace sen_record=3 if sen_provision=="K"
replace sen_record=4 if sen_provision=="S"
replace sen_record=5 if sen_provision=="E"
replace sen_record=5 if sen_provision=="e"
replace sen_record=0 if sen_provision==""
label define sen 0 "None" 1 "SchoolAction" 2 "SchoolAction+" 3 "SENsupport" 4 "Statement" 5 "EHCP"
label val sen_record sen
tab sen_record sen_provision, m
drop sen_provision

*Create sen variable with 4 levels
gen sen_record_4=.
replace sen_record_4=0 if sen_record==0
replace sen_record_4=1 if sen_record>0 & sen_record<4
replace sen_record_4=2 if sen_record>=4
replace sen_record_4=3 if school_type==1 | school_type==2
label define sensum 0 "None" 1 "SEN support" 2 "EHCP" 3 "specialist school", replace
label val sen_record_4 sensum
tab sen_record sen_record_4, m
order pupilmatchingrefanonymous academic_year sen_record sen_record_4

*keep only highest evidence per academic year
bysort pupilmatchingrefanonymous academic_year: egen maxsen_academicyr=max(sen_record_4)
label val maxsen sensum

rename maxsen_academicyr sen_record
duplicates drop

******************************************************************************
*ALL ELIGIBLE, Key stage 1 and Key stage 2 results
******************************************************************************
*Reformat SEN data for final tables
label define sen 0 "None" 1 "SEN support" 2 "EHCP" 3 "Specialist school" ,replace
label val sen_record sen
tab sen_record, m

*Gen key stages
gen key_stage=.
replace key_stage=1 if (schoolyear==1 | schoolyear==2)
replace key_stage=2 if (schoolyear==3 | schoolyear==4 | schoolyear==5 | schoolyear==6)
bysort pupilmatchingrefanonymous key_stage: egen sen_max=max(sen_record)

keep pupilmatchingrefanonymous key_stage sen_max no_MCA any_MCA nerv_all iso_nerv nerv_microceph nerv_hydroceph nerv_bifida eye_all iso_eye eye_anomicro eye_cataract eye_glaucoma efn_all iso_efn heart_all iso_heart heart_severe resp_all iso_resp resp_choanal oro_all iso_oro oro_lip oro_pal oro_both dig_all iso_dig dig_oatresia dig_intestinal dig_hirsch dig_batresia dig_cdh_full dig_arm_full abdo_all iso_abdo abdo_omphal abdo_gastro urin_all iso_urin urin_exstrophy genital_all iso_genital genital_hypospadia genital_indsex limb_all iso_limb limb_reduct chrom_all iso_chrom chrom_21 chrom_turn

duplicates drop

order pupilmatchingrefanonymous key_stage sen_max no_MCA any_MCA nerv_all iso_nerv nerv_microceph nerv_hydroceph nerv_bifida eye_all iso_eye eye_anomicro eye_cataract eye_glaucoma efn_all iso_efn heart_all iso_heart heart_severe resp_all iso_resp resp_choanal oro_all iso_oro oro_lip oro_pal oro_both dig_all iso_dig dig_oatresia dig_intestinal dig_hirsch dig_batresia dig_cdh_full dig_arm_full abdo_all iso_abdo abdo_omphal abdo_gastro urin_all iso_urin urin_exstrophy genital_all iso_genital genital_hypospadia genital_indsex limb_all iso_limb limb_reduct chrom_all iso_chrom chrom_21 chrom_turn

*count ks1
preserve
keep if key_stage==1
count
collapse (sum) no_MCA any_MCA nerv_all iso_nerv nerv_microceph nerv_hydroceph nerv_bifida eye_all iso_eye eye_anomicro eye_cataract eye_glaucoma efn_all iso_efn heart_all iso_heart heart_severe resp_all iso_resp resp_choanal oro_all iso_oro oro_lip oro_pal oro_both dig_all iso_dig dig_oatresia dig_intestinal dig_hirsch dig_batresia dig_cdh_full dig_arm_full abdo_all iso_abdo abdo_omphal abdo_gastro urin_all iso_urin urin_exstrophy genital_all iso_genital genital_hypospadia genital_indsex limb_all iso_limb limb_reduct chrom_all iso_chrom chrom_21 chrom_turn, by(sen_max)
export excel using "SEN_prev_raw.xlsx", firstrow(variables) sheet(ks1_sen) replace
restore

*count ks1 or ks2 (sensitivity analyses)
preserve
bysort pupilmatchingrefanonymous (sen_max):  keep if _n==_N
drop key_stage
collapse (sum) no_MCA any_MCA nerv_all iso_nerv nerv_microceph nerv_hydroceph nerv_bifida eye_all iso_eye eye_anomicro eye_cataract eye_glaucoma efn_all iso_efn heart_all iso_heart heart_severe resp_all iso_resp resp_choanal oro_all iso_oro oro_lip oro_pal oro_both dig_all iso_dig dig_oatresia dig_intestinal dig_hirsch dig_batresia dig_cdh_full dig_arm_full abdo_all iso_abdo abdo_omphal abdo_gastro urin_all iso_urin urin_exstrophy genital_all iso_genital genital_hypospadia genital_indsex limb_all iso_limb limb_reduct chrom_all iso_chrom chrom_21 chrom_turn, by(sen_max)
export excel using "SEN_prev_raw.xlsx", firstrow(variables) sheet(ks1_ks2_sen, replace) 
restore
