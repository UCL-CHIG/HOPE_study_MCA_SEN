********************************************************************************
*time series of SEN by MCA/Non-MCA
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
log using "$logfiles\Do_06b_Table2_$S_DATE.log", replace

******************************************************************************
*ALL ELIGIBLE, Year 1 only
******************************************************************************
*Reformat SEN data for final tables
use "$savefiles\sub_cohort_all_school_years.dta", clear
label define sen 0 "None" 1 "SEN support" 2 "EHCP" 3 "Specialist school",replace
label val sen_record sen
tab sen_record, m

*keeping year 1 
keep if schoolyear_final==1
drop schoolyear_final

*max SEN per child 
bysort pupilmatchingrefanonymous: egen sen_max=max(sen_record)
count

* MCA and SEN by year
gen year = year(dob)
* needs to be academic year
replace year = year-1 if month(dob)<9
tab year
drop if year==2013
keep any_MCA no_MCA sen_max year
collapse (sum) any_MCA no_MCA, by(sen_max year)