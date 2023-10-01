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
log using "$logfiles\Do_04_prepare_SEN_data_$S_DATE.log", replace

*Open sen file
use "$savefiles\bc_census_data_sen_all.dta", clear

*** decrease size of file

*Keep census data for school years 1-6, 99 (not following NC), and 100 (alt provision)
keep if ((schoolyear>0 & schoolyear<7) | schoolyear==99 | schoolyear==100)

*drop if outside follow up years, 2009/10 to 2018/19 
*first make new numeric school years
gen academic_year=""
local j "2009 2010 2011 2012 2013 2014 2015 2016 2017 2018"
foreach k of local j{
	replace academic_year="`k'" if substr(academicyear,1,4)=="`k'"
}

drop academicyear
destring academic_year,replace

drop if academic_year==. // this drops cases out of the specified years above

save "$temp\bc_census_data_sen_smaller.dta", replace

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

*school type
replace school_type=1 if ap_census==1 | pru_census==1

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
keep pupilmatchingrefanonymous academic_year sen_record_4 schoolyear school_type maxsen_academicyr

rename maxsen_academicyr sen_record
duplicates drop

save "$savefiles\bc_census_data_sen_smaller.dta", replace


erase "$temp\bc_census_data_sen_smaller.dta"