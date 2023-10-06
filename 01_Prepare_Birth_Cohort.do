*****************************************************************************
*                    DO FILE 1. PREPARE BIRTH COHORT                   *
*****************************************************************************

*The birth admissions file used below is created using code written by Ania Zylbersztejn et al.
*See paper: https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0243843 
*And see accompanying code: https://github.com/UCL-CHIG/HES-birth-cohorts/

*# DATASETS AND VARIABLES

/* This code uses the following datasets and variables:
1.	HES APC birth records 
      a.	dob_adm = child’s date of birth admission (defined as ‘admidate’ of birth admission)
      b.	multiple = multiple births as defined in Ania Zylbersztejn et al.
      c.	resgor = region of residence
2.	Linked to HES/ONS mortality records
      a.	dod_year= year of death
      b.	dod_month = month of death
*/

*open HES APC birth file merged with HES/ONS mortality data
use [file_name]

*# ADD STUDY SPECIFIC EXCLUSIONS
*drop those outside cohort birth dates
drop if dob_adm<mdy(09,01,2003) | dob_adm>mdy(08,31,2013)

*exclude multiple births
drop if multiple==1

*Create non-England resident flag and drop births
generate non_res=.
replace non_res=1 if resgor=="S" | resgor=="W" | resgor=="X" | resgor=="Z"
drop if non_res==1

*create approximate date of death (as we don't have day of death)
gen dod=mdy(dod_month,15,dod_year) 
replace dod=(dob_adm+1) if (dod-dob_adm)<1 // Make dod occur 1 day after date of birth admissions if dod same or earlier than dob_adm
format %td dod

*# SAVE FILE
save "birth_cohort.dta", replace
