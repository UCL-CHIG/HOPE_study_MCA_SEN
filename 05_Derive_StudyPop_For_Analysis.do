********************************************************************************
* Append HES data to NPD data and create final cohort*
********************************************************************************

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
log using "$logfiles\Do_05_final_study_population_$S_DATE.log", replace

*Open full birth cohort first for dates
use "$savefiles\full_cohort.dta", clear
count
keep pupilmatchingrefanonymous dob dod_adj

* FLOWCHART exclusions - N deaths before start of Year 1
*Need to first convert DOB to birth year according to the academic year
gen birthyr_academic=.
forvalues k = 2(1)13{
	replace birthyr_academic=(2000+`k') if (dob>=mdy(09,01,(2000+`k')) & dob<=mdy(08,31,(2001+`k')))
}
gen academicyr_1_start=mdy(9, 1, (birthyr_academic+6))
format academicyr_1_start %td
count if dod_adj<academicyr_1_start & dod_adj!=. //FLOWCHART FIGURE 1 exclusion: death before school start
drop if dod_adj<academicyr_1_start & dod_adj!=. 
count

*drop unlinked children
count if pupilmatchingrefanonymous==""  //FLOWCHART FIGURE 1 exclusion: no linkage
drop if pupilmatchingrefanonymous==""
count

********************************************************************************
* IN THIS STAGE BRING IN CENSUS DATA FROM YRS 1 TO 6
********************************************************************************
merge 1:m pupilmatchingrefanonymous using "$savefiles\bc_census_data_sen_smaller.dta"

count if _merge==1 // flowchat figure 1: number not present in censuses during study period
*saving to investigate the reasons why
preserve 
keep if _merge==1
drop _merge
keep pupilmatchingrefanonymous dob dod_adj
duplicates drop
save "$savefiles\bc_linked_not_in_followup.dta",replace
restore
drop if _merge==1
drop _merge

*potential linkage error - present in school census after death
gen deathyr_academic=.
forvalues k = 2(1)13{
	replace deathyr_academic=(2000+`k') if (dod_adj>=mdy(09,01,(2000+`k')) & dod_adj<=mdy(08,31,(2001+`k')))
}
gen error=1 if deathyr_academic>academic_year & deathyr_academic!=. 
codebook pupilmatchingrefanonymous if error==1 // flowchat figure 1: potential linkage error
bysort pupilmatchingrefanonymous: egen error_drop=max(error)
drop if error_drop==1 
drop error*

*Generate expected school year variable
*This also creates school year for children not following NC, based on dob
gen exp_schoolyear=(academic_year-birthyr_academic)-5
tab exp_schoolyear school_type 
* drop children not following NC if outside schools years of study (we haven't been able to tell school years until now)
* need to preserve id if no longer in main dataset at all
gen tag=1 if schoolyear>6 & (exp_schoolyear<1 | exp_schoolyear>6)
bysort pupilmatchingrefanonymous:egen sum_tag=sum(tag)
bysort pupilmatchingrefanonymous: gen count=_N
count if count==sum_tag // very few!
preserve
keep if count==sum_tag
codebook pupilmatchingrefanonymous // add this number to flowchart 
keep pupilmatchingrefanonymous dob dod_adj
duplicates drop
gen nonNC_outside_study=1
append using "$savefiles\bc_linked_not_in_followup.dta"
save "$savefiles\bc_linked_not_in_followup.dta", replace
restore
codebook pupilmatchingrefanonymous
drop if tag==1 // dropping all errors
codebook pupilmatchingrefanonymous // only a few less pupils in data
drop *tag count

*now check how many children outside expected school year
tab exp_schoolyear schoolyear
tab exp_schoolyear
*only concerned if 2 or more years outside
gen flag=1 if ((schoolyear-exp_schoolyear)<-1 | (schoolyear-exp_schoolyear)>1) & schoolyear<99
bysort pupilmatchingrefanonymous:egen sum_flag=sum(flag)
bysort pupilmatchingrefanonymous: gen count=_N
count if count==sum_flag // number to exclude as not present in any expected year
br if count==sum_flag
preserve
keep if count==sum_flag
codebook pupilmatchingrefanonymous // add this number to flowchart 
keep pupilmatchingrefanonymous dob dod_adj
save "$savefiles\bc_linked_not_in_exp_school_year.dta",replace
restore

codebook pupilmatchingrefanonymous
drop if flag==1 // dropping all errors
codebook pupilmatchingrefanonymous // N for flowchart
drop *flag count

*create final school years
gen schoolyear_final=exp_schoolyear if schoolyear>98 
replace schoolyear_final=schoolyear if schoolyear<99
*count number not following NC
codebook pupilmatchingrefanonymous if schoolyear==99 | schoolyear==100 // FLOWCHART number not following NC at least once
bysort pupilmatchingrefanonymous:egen min_SY=min(schoolyear)  
codebook pupilmatchingrefanonymous if min_SY==99 | min_SY==100 // FLOWCHART number not following NC at any point
drop schoolyear exp_schoolyear min_SY

*need to make sure the follow-up Years are still correct; with pupils in different Years then expected based on age
tab birthyr_academic schoolyear
codebook pupilmatchingrefanonymous if birthyr_academic+schoolyear_final>2013 // number of records beyond followup Years
gen flag_fu=1 if birthyr_academic+schoolyear_final>2013
bysort pupilmatchingrefanonymous: egen flag_fu_total=sum(flag_fu)
bysort pupilmatchingrefanonymous: gen count=_N
count if count==flag_fu_total // number of children dropped if follow up Years dropped
*add these to the number excluded due to primary school censuses not in follow up period
preserve
keep if count==flag_fu_total
keep pupilmatchingrefanonymous dob dod_adj
duplicates drop
gen FU_beyond_Years=1
append using "$savefiles\bc_linked_not_in_followup.dta"
save "$savefiles\bc_linked_not_in_followup.dta", replace
restore
drop if flag_fu==1 // dropped records outside follow up Years
drop flag* count

*figure out duplicates across school years
duplicates tag pupilmatchingrefanonymous schoolyear_final, gen(tag)
tab tag
tab school_type full_sen_record if tag>0

drop tag

save  "$savefiles\sub_cohort_all_school_years.dta", replace // save temporarily
clear

* ### explore excluded children ###
*do "$dofiles\05b_ExploreExcludedChildren.do"

use "$savefiles\sub_cohort_all_school_years.dta", clear
*merge MCA data back in
merge m:m pupilmatchingrefanonymous using "$savefiles\full_cohort.dta", keepusing(any_MCA nerv_all iso_nerv nerv_microceph nerv_hydroceph nerv_bifida eye_all iso_eye eye_anomicro eye_cataract eye_glaucoma efn_all iso_efn heart_all iso_heart heart_severe resp_all iso_resp resp_choanal oro_all iso_oro oro_lip oro_pal oro_both dig_all iso_dig dig_oatresia dig_intestinal dig_hirsch dig_batresia dig_cdh_full dig_arm_full abdo_all iso_abdo abdo_omphal abdo_gastro urin_all iso_urin urin_exstrophy genital_all iso_genital genital_hypospadia genital_indsex limb_all iso_limb limb_reduct chrom_all iso_chrom chrom_21 chrom_turn)

drop if _merge==2
drop _merge
gen no_MCA=1 if any_MCA!=1 // create no anomaly group

*Final N for flowchart
bysort pupilmatchingrefanonymous:gen count=1 if _n==1
tab any_MCA if count==1
drop count

save  "$savefiles\sub_cohort_all_school_years.dta", replace