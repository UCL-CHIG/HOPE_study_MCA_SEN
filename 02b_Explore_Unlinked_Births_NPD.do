*****************************************************************************
*                          EXPLORE UNLINKED BIRTHS	                        *
*****************************************************************************

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
log using "$logfiles\Do_02b_unlinked_births_$S_DATE.log", replace

* Open babytail up including more detail 
import delimited "$linked_children\HES_APC_Baby_Tail_clean_vars_combined.csv", varnames(1) 
keep encrypted_hesid matage_baby gestat_baby birweit_baby sex maybe_false_match 
merge 1:1 encrypted_hesid using "$savefiles\full_cohort.dta"
drop if _merge==1
drop _merge

*flag linked children
merge m:1 pupilmatchingrefanonymous using "$savefiles\cohort_ids.dta"
gen linked_children=1 if _merge==3
replace linked_children=0 if _merge==1
drop _merge
codebook encrypted_hesid

*Difference between linked and unlinked
*first flag deaths before entry to year 1 of school
gen birthyr_academic=.
forvalues k = 2(1)13{
	replace birthyr_academic=(2000+`k') if (dob>=mdy(09,01,(2000+`k')) & dob<=mdy(08,31,(2001+`k')))
}
gen academicyr_1_start=mdy(9, 1, (birthyr_academic+6))
count if dod_adj<academicyr_1_start & dod_adj!=. 

gen linked_children2=1 if linked_children==1
replace linked_children=0 if linked_children!=1 
replace linked_children=. if (dod_adj<academicyr_1_start & dod_adj!=.) //replace deaths before school as missing

*drop if dod_adj<academicyr_1_start & dod_adj!=. 
*drop academicyr_1_start

*recode string variables
encode resgor,gen(region)
encode ethnos_des,gen(ethnicity)
*recode missing values 
replace region=99 if resgor==""|resgor=="S"|resgor=="U" |resgor=="W"|resgor=="X"   
replace sex=99 if sex==.
replace ethnicity=99 if ethnicity==.
replace imd=99 if imd==.

*redo table and ORs
tab any_MCA linked_children2,m
tab sex linked_children2,m
tab region linked_children2,m
tab ethnos_des linked_children2,m
tab birthyr_academic linked_children2,m
tab imd linked_children2,m
