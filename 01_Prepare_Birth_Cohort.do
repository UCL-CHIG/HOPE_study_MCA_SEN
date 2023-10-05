*****************************************************************************
*                    DO FILE 1. PREPARE FULL BIRTH COHORT                   *
*     Uses: 
*
*****************************************************************************

*### housekeeping ###*
clear all
capture log close
capture macro drop _all

**set up filepaths
global data [add_filepath]
global dofiles [add_filepath]
global logfiles [add_filepath]
global savefiles [add_filepath]
global temp [add_filepath]
global results [add_filepath]

*check directory
dir

*log output
capture log close
log using "$logfiles\Do_01_birth_cohort_$S_DATE.log", replace

*****************************************************************************
*# DEFINE MCAS
*****************************************************************************
do "$dofiles\01b_Define_MCAs.do"
clear

*****************************************************************************
*# FLOWCHART NUMBERS AND EXCLUSIONS
*****************************************************************************

*****************************************************************************
*      IMPORT LINKAGE FILE, MORTALITY AND ADMISSIONS DATA                   *
*****************************************************************************

*Import NPD HES Linkage Spine (One to One)
import delimited "$data\NPD_HES_Linkage_Spine.csv", varnames(1) 
save "$temp\hes_npd_spine.dta", replace
clear

*Import death data
import delimited "$data\HES_Death_Dates.csv", varnames(1)
keep encrypted_hesid dod_month dod_year
gen dod_day=15
gen dod=mdy(dod_month, dod_day, dod_year)
format %td dod
duplicates drop
bysort encrypt: gen death_record=_N
tab death_record // death records with conflicting dates
save "$temp\deaths.dta", replace
clear

*Import baby tail data to consolidate birth and death dates
import delimited "$data\HES_APC_Baby_Tail_clean_vars_combined.csv", varnames(1) 
*Format birth date
*keep gestat to help with defining some MCAs
keep encrypt bday gestat
gen dob=date(bday, "YMD")
format %td dob
drop bday
*Bring deaths in
sort encrypt
merge 1:m encrypt using "$temp\deaths.dta"
drop if _m==2
drop _m
recode death_record .=0
*Deal with those infants that have two death records
bro if death_record==2
duplicates tag encrypt dod_year if death_record==2, gen(tmp)
drop if tmp==0 & death_record==2 // dropped conflicting dod year
drop if tmp==1 & death_record==2 & dod_month==1 // kept latest dod month
drop tmp dod_month dod_year dod_day
*All should have 1 death record now so recode death_record variable
recode death_record 2=1
*Create age at death variable
gen death_age=dod-dob if death_rec==1
*Count
count
tab death_record, m 
*keep those within cohort dates
drop if dob<mdy(09,01,2003) | dob>mdy(08,31,2013) 
save "$temp\babytail_dates.dta", replace
clear

*****************************************************************************
*# DEFINE MCAS IN SEPERATE DO FILE
*****************************************************************************
do "$dofiles\01b_Define_MCAs.do"
clear

*****************************************************************************
*# FLOWCHART NUMBERS AND EXCLUSIONS
*****************************************************************************
*need to add in residential region
import delimited "$data\HES_APC_Area_combined.csv", varnames(1)
* mark records where earliest episode is nonres
bysort encrypted_hesid (epistart): keep if _n==1
keep encrypted_hesid resgor
generate non_res=.
replace non_res=1 if resgor=="S" | resgor=="W" | resgor=="X" | resgor=="Z"
tab non_res,m
save "$temp\residence_birth.dta", replace
clear

* Open babytail back up including more detail / do not need dob dod 
import delimited "$data\HES_APC_Baby_Tail_clean_vars_combined.csv", varnames(1) 
keep encrypted_hesid stillb multiple
merge 1:1 encrypted_hesid using "$temp\babytail_dates.dta"
keep if _merge==3
drop _merge
* Flowchart numbers
tab stillb,m
drop if stillb==1
count // FLOWCHART step 1 - overall live births in study period
* Exclude multiples & non-res 
tab multiple,m // FLOWCHART exclusion - multiple births
merge 1:1 encrypted_hesid using "$temp\residence_birth.dta"
keep if _merge!=2
drop _merge
tab non_res,m // FLOWCHART exclusion - multiple births
tab multiple non_res,m // FLOWCHART exclusion - non resident
drop if non_res==1 | multiple==1 
count // FLOWCHART step 2 - full N for cohort
merge 1:1 encrypted_hesid using "$savefiles\MCA_flags.dta"
drop _merge
foreach var of varlist dig_arm_full-any_MCA{
qui replace `var'=0 if `var'==.
}
tab any_MCA,m // FLOWCHART step 2 - with/without MCA

drop multiple stillb non_res resgor

save "$savefiles\full_cohort.dta", replace
clear

*# SENSITIVITY TO LOOK AT MCA CODING OVER TIME
do "$dofiles\01b_Define_MCAs.do"
clear

*erase "$temp\residence_birth.dta"
*erase "$temp\babytail_dates.dta"
*erase "$temp\death_infancy_causes_long.dta"
*erase "$temp\diag_infancy.dta"
