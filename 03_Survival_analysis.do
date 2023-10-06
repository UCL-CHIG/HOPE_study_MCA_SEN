*****************************************************************************
*         DO FILE 3. CALCULATE SURVIVAL AT 5 and 7	         *
* by MCAs (with at least 200 cases) using the Kaplan Meier survivor function
*****************************************************************************

*Use data file containing all infants born in the study period (the birth cohort)
*This includes EVERYONE even if they did not go on to get linked to NPD

*# DATASETS AND VARIABLES

/* This code uses the following datasets:
1.	HES APC birth records, including MCAs created in do file 2
2.	Linked to HES/ ONS mortality records, including approximate date of death created in do file 1
*/

********************************************************************************

*open file created in do files 1 & 2
use [open file]

*** create follow up to age 5 and 7 years
gen death=0
replace death=1 if dod!=. & (dod-date0)<(5*365.25) //follow up for deaths up to start of KS1
replace death=2 if dod!=. & (dod-date0)>=(5*365.25) & (dod-date0)<(7*365.25) //follow up for deaths up to start of KS2
tab death // all remaining deaths are after age 7

** gen age 5/7 variables
gen age_5=dob_adm+(365.25*5)
gen age_7=dob_adm+(365.25*7)

** time to event
gen time_to_event_age5=min(dod_approx, study_end, age_5)
gen time_to_event_age7=min(dod_approx, study_end, age_7)

gen no_MCA=1 if any_MCA!=1 // create no anomaly group

** RESULTS : Table 1
stset time_to_event_age7, id(encrypted_hesid) failure(death==1,2) scale(365.25) origin(date0)
foreach var of varlist any_MCA no_MCA nerv_all iso_nerv nerv_microceph nerv_hydroceph nerv_bifida eye_all iso_eye eye_anomicro eye_cataract eye_glaucoma efn_all iso_efn heart_all iso_heart heart_severe resp_all iso_resp resp_choanal oro_all iso_oro oro_lip oro_pal oro_both dig_all iso_dig dig_oatresia dig_intestinal dig_hirsch dig_batresia dig_cdh_full dig_arm_full abdo_all iso_abdo abdo_omphal abdo_gastro urin_all iso_urin urin_exstrophy genital_all iso_genital genital_hypospadia genital_indsex limb_all iso_limb limb_reduct chrom_all iso_chrom chrom_21 chrom_turn{		
preserve
sts graph, by(`var') 
graph save “graph_`var'_survival.gph"
sts list, survival risktable(5 7) by(`var') saving("file_`var'_survival.dta")
clear

use "file_`var'_survival.dta"
local j "5 7"
foreach name of varlist survivor lb ub {
	foreach k of local j{
	gen `name'1=`name'*100 if `var'==1 & time==`k'
	egen `name'_`k'=max(`name'1)
	drop `name'1
}	
}
gen anomaly="`var'"
keep anomaly survivor_5 lb_5 ub_5 survivor_7 lb_7 ub_7
duplicates drop
save "file_`var'_survival.dta", replace
restore
}

*** For table1: add number at risk and deaths
foreach var of varlist any_MCA no_MCA nerv_all iso_nerv nerv_microceph nerv_hydroceph nerv_bifida eye_all iso_eye eye_anomicro eye_cataract eye_glaucoma efn_all iso_efn heart_all iso_heart heart_severe resp_all iso_resp resp_choanal oro_all iso_oro oro_lip oro_pal oro_both dig_all iso_dig dig_oatresia dig_intestinal dig_hirsch dig_batresia dig_cdh_full dig_arm_full abdo_all iso_abdo abdo_omphal abdo_gastro urin_all iso_urin urin_exstrophy genital_all iso_genital genital_hypospadia genital_indsex limb_all iso_limb limb_reduct chrom_all iso_chrom chrom_21 chrom_turn{
preserve
gen count=1
gen death_5=1 if dod_adj!=. & (dod_adj-date0)<(5*365.25)
gen death_7=1 if dod_adj!=. & (dod_adj-date0)<(7*365.25) 
collapse (sum) count death_5 death_7, by(`var')
keep if `var'==1
drop `var'
gen anomaly="`var'"
merge 1:1 anomaly using "file_`var'_survival.dta"
drop _merge
save "file_`var'.dta", replace
restore
}

**append all results and export to excel
use "file_any_MCA.dta", clear
local varlist no_MCA nerv_all iso_nerv nerv_microceph nerv_hydroceph nerv_bifida eye_all iso_eye eye_anomicro eye_cataract eye_glaucoma efn_all iso_efn heart_all iso_heart heart_severe resp_all iso_resp resp_choanal oro_all iso_oro oro_lip oro_pal oro_both dig_all iso_dig dig_oatresia dig_intestinal dig_hirsch dig_batresia dig_cdh_full dig_arm_full abdo_all iso_abdo abdo_omphal abdo_gastro urin_all iso_urin urin_exstrophy genital_all iso_genital genital_hypospadia genital_indsex limb_all iso_limb limb_reduct chrom_all iso_chrom chrom_21 chrom_turn	
foreach var of local varlist{
	append  using "$temp\file_`var'.dta"
}
order anomaly count death_5 survivor_5 lb_5 ub_5 death_7 survivor_7 lb_7 ub_7
export excel using “Table 1_raw.xls",  firstrow(variables) replace

**erase files	
local varlist any_MCA no_MCA nerv_all iso_nerv nerv_microceph nerv_hydroceph nerv_bifida eye_all iso_eye eye_anomicro eye_cataract eye_glaucoma efn_all iso_efn heart_all iso_heart heart_severe resp_all iso_resp resp_choanal oro_all iso_oro oro_lip oro_pal oro_both dig_all iso_dig dig_oatresia dig_intestinal dig_hirsch dig_batresia dig_cdh_full dig_arm_full abdo_all iso_abdo abdo_omphal abdo_gastro urin_all iso_urin urin_exstrophy genital_all iso_genital genital_hypospadia genital_indsex limb_all iso_limb limb_reduct chrom_all iso_chrom chrom_21 chrom_turn
foreach var of local varlist{
	erase "file_`var'_survival.dta"
	erase "file_`var'.dta"
}
