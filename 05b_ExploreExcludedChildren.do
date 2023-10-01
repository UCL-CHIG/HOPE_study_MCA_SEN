***************************************************************************
* EXAMINE CHILDREN EXCLUDED BECAUSE NOT IN CENSUS FOR YEARS 1 TO 6
***************************************************************************

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
log using "$logfiles\Do_05b_exploring_excluded_children_$S_DATE.log", replace

use "$savefiles\bc_linked_not_in_followup.dta"
codebook pupilmatchingrefanonymous

*individuals who only contribute to pre-primary school
*Add in EYC data
merge 1:m pupilmatchingrefanonymous using "$temp\bc_eyc_0820.dta"
drop if _merge==2
keep pupilmatchingrefanonymous eyc_census dob dod_adj academicyear_EYC
duplicates drop
tab eyc_census
codebook pupilmatchingrefanonymous if eyc_census==1
*Add in other census data
merge m:m pupilmatchingrefanonymous using "$savefiles\bc_census_data_sen_all.dta"
drop if _merge==2
replace schoolyear=0 if schoolyear==. & eyc_census==1
drop _merge
gen birthyr_academic=.
forvalues k = 2(1)13{
	replace birthyr_academic=(2000+`k') if (dob>=mdy(09,01,(2000+`k')) & dob<=mdy(08,31,(2001+`k')))
}
order birthyr_academic, after(dob)
gen academicyr_1_start=mdy(9, 1, (birthyr_academic+6))
format academicyr_1_start %td
order academicyr_1_start, after(dob)

*gen numeric academic year
gen academic_year=substr(academicyear,1,4)
destring academic_year, replace
gen exp_schoolyear=(academic_year-birthyr_academic)-5
replace schoolyear=exp_schoolyear if schoolyear>=99 | schoolyear==. //putting in expected school year for children not following NC

bysort pup: egen max_school=max(schoolyear)
codebook pup if max<=0 // FLOWCHART only contributed to pre-primary
drop if max<=0
codebook pup 
drop if schoolyear<=0
codebook pup 

*Exclude individuals who only contribute to highschool
bysort pup: egen min_school=min(schoolyear)
codebook pup if (min>=7 & min<=13) & max<90  
drop if (min>=7 & min<=13) & max<90 
codebook pup 
drop if schoolyear>=7 & schoolyear<=13
codebook pup

*Exclude those who only contributed to pandemic year 2019/2020
replace academic_year=academicyear_EYC if academic_year==.
bysort pupi: egen maxac=max(academic_year)
bysort pup: egen minac=min(academic_year)
codebook pup if minac==2019 & maxac==2019 
drop if minac==2019 & maxac==2019
codebook pup 
drop if academic_year==2019
codebook pup 
drop maxac minac

tab birthyr