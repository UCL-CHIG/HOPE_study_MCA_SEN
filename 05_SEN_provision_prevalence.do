********************************************************************************
* DO 5. SEN PROVISION PREVALENCE
********************************************************************************

********************************************************************************
* Create tables with sum of SEN records across KS1 and KS2
* Also need the number eligible (totals)
* Use this to create proportions of 
********************************************************************************

******************************************************************************
*ALL ELIGIBLE, Key stage 1 and Key stage 2 results
******************************************************************************
*Reformat SEN data for final tables
use "cohort_all_school_years.dta", clear
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
