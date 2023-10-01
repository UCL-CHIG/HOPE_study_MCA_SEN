********************************************************************************
* CALCULATE SURVIVAL BY ANOMALY TYPE AT START OF KS1, START OF KS2, END OF KS2
* ACCOUNT FOR FOLLOW-UP TIME BY CALCULATING KAPLAN MEIER SURVIVOR FUNCTION
********************************************************************************
*Use data file containing all infants born in the study period
*This includes EVERYONE even if they did not go on to get linked to NPD


*### housekeeping ###*
clear all
capture log close
capture macro drop _all

**set up filepaths
global data 
global dofiles 
global logfiles 
global savefiles
global temp 
global results 

*check directory
dir

*log output
capture log close
log using "$logfiles\Do_02_survival_$S_DATE.log", replace

use "$savefiles\full_cohort.dta", clear

*Generate variable indicating study end 31st August 2019
gen study_end=mdy(08,31,2019)
format %td study_end

/*Adjust date of death where it conflicts with date of birth
*Make DOD occur 1 day after DOB if DOD same or earlier than DOB
*Birth and death dates were compared to confirm this is reasonable
gen dod_adj=dod
replace dod_adj=(dob+1) if (dod-dob)<1
format %td dod_adj
*/ 
*Generate start of follow-up (use date of birth) for all survival
gen date0=dob
format %td date0

/*
**** follow up to Ks1 / Ks2 - no longer using
*Need to first convert DOB to birth year according to the academic year - NOT calendar year
gen birthyr_academic=.
forvalues k = 2(1)13{
	replace birthyr_academic=(2000+`k') if (dob>=mdy(09,01,(2000+`k')) & dob<=mdy(08,31,(2001+`k')))
}
gen academicyr_1_start=mdy(9, 1, (birthyr_academic+6))
gen academicyr_3_start=mdy(9, 1, (birthyr_academic+8))
gen time_to_event_ks1=min(dod_adj, academicyr_1_start, study_end) //end of follow up ks1
replace time_to_event_ks2=min(dod_adj, academicyr_3_start, study_end) //end of follow up ks2
*/

*** follow up to age 5 and 7 instead
** event
gen death=0
replace death=1 if dod_adj!=. & (dod_adj-date0)<(5*365.25) //follow up for deaths up to start of KS1
replace death=2 if dod_adj!=. & (dod_adj-date0)>=(5*365.25) & (dod_adj-date0)<(7*365.25) //follow up for deaths up to start of KS2
tab death // all remaining deaths are after age 7

** gen age 5/7 variables
gen age_5=dob+(365.25*5)
gen age_7=dob+(365.25*7)

** time to event
gen time_to_event_age5=min(dod_adj, study_end, age_5)
gen time_to_event_age7=min(dod_adj, study_end, age_7)

gen no_MCA=1 if any_MCA!=1 // create no anomaly group

** RESULTS : Table 1
* Age 5/7 together
stset time_to_event_age7, id(encrypted_hesid) failure(death==1,2) scale(365.25) origin(date0)

foreach var of varlist any_MCA no_MCA nerv_all iso_nerv nerv_microceph nerv_hydroceph nerv_bifida eye_all iso_eye eye_anomicro eye_cataract eye_glaucoma efn_all iso_efn heart_all iso_heart heart_severe resp_all iso_resp resp_choanal oro_all iso_oro oro_lip oro_pal oro_both dig_all iso_dig dig_oatresia dig_intestinal dig_hirsch dig_batresia dig_cdh_full dig_arm_full abdo_all iso_abdo abdo_omphal abdo_gastro urin_all iso_urin urin_exstrophy genital_all iso_genital genital_hypospadia genital_indsex limb_all iso_limb limb_reduct chrom_all iso_chrom chrom_21 chrom_turn{
		
preserve
sts graph, by(`var') 
graph save "$results\st_graph_`var'_survival.gph", replace
sts list, survival risktable(5 7) by(`var') saving("$temp\file_`var'_survival.dta", replace)
clear

use "$temp\file_`var'_survival.dta"

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
save "$temp\file_`var'_survival.dta", replace
restore
}


*** for TABLE 1: add number at risk and deaths
foreach var of varlist any_MCA no_MCA nerv_all iso_nerv nerv_microceph nerv_hydroceph nerv_bifida eye_all iso_eye eye_anomicro eye_cataract eye_glaucoma efn_all iso_efn heart_all iso_heart heart_severe resp_all iso_resp resp_choanal oro_all iso_oro oro_lip oro_pal oro_both dig_all iso_dig dig_oatresia dig_intestinal dig_hirsch dig_batresia dig_cdh_full dig_arm_full abdo_all iso_abdo abdo_omphal abdo_gastro urin_all iso_urin urin_exstrophy genital_all iso_genital genital_hypospadia genital_indsex limb_all iso_limb limb_reduct chrom_all iso_chrom chrom_21 chrom_turn{

preserve
gen count=1
gen death_5=1 if dod_adj!=. & (dod_adj-date0)<(5*365.25)
gen death_7=1 if dod_adj!=. & (dod_adj-date0)<(7*365.25) 
collapse (sum) count death_5 death_7, by(`var')
keep if `var'==1
drop `var'
gen anomaly="`var'"
merge 1:1 anomaly using "$temp\file_`var'_survival.dta"
drop _merge
save "$temp\file_`var'.dta", replace
restore
}


use "$temp\file_any_MCA.dta", clear

local varlist no_MCA nerv_all iso_nerv nerv_microceph nerv_hydroceph nerv_bifida eye_all iso_eye eye_anomicro eye_cataract eye_glaucoma efn_all iso_efn heart_all iso_heart heart_severe resp_all iso_resp resp_choanal oro_all iso_oro oro_lip oro_pal oro_both dig_all iso_dig dig_oatresia dig_intestinal dig_hirsch dig_batresia dig_cdh_full dig_arm_full abdo_all iso_abdo abdo_omphal abdo_gastro urin_all iso_urin urin_exstrophy genital_all iso_genital genital_hypospadia genital_indsex limb_all iso_limb limb_reduct chrom_all iso_chrom chrom_21 chrom_turn
	
foreach var of local varlist{
append  using "$temp\file_`var'.dta"
}

order anomaly count death_5 survivor_5 lb_5 ub_5 death_7 survivor_7 lb_7 ub_7
export excel using "$results\Table 1_raw.xls",  firstrow(variables) replace

	
local varlist any_MCA no_MCA nerv_all iso_nerv nerv_microceph nerv_hydroceph nerv_bifida eye_all iso_eye eye_anomicro eye_cataract eye_glaucoma efn_all iso_efn heart_all iso_heart heart_severe resp_all iso_resp resp_choanal oro_all iso_oro oro_lip oro_pal oro_both dig_all iso_dig dig_oatresia dig_intestinal dig_hirsch dig_batresia dig_cdh_full dig_arm_full abdo_all iso_abdo abdo_omphal abdo_gastro urin_all iso_urin urin_exstrophy genital_all iso_genital genital_hypospadia genital_indsex limb_all iso_limb limb_reduct chrom_all iso_chrom chrom_21 chrom_turn

foreach var of local varlist{
erase "$temp\file_`var'_survival.dta"
erase "$temp\file_`var'.dta"
}