*****************************************************************************
*               DO FILE 4. PREPARE SCHOOL COHORT 	   *
*****************************************************************************

*# DATASETS AND VARIABLES

/* This code uses the following datasets and variables:
1.	NPD AP PRU and termly school censuses
a.	PMR
b.	
2.	Linked to the HES cohort defined in do file 1
*/
/**************************************************************************

	rename Pupil pupilmatchingrefanonymous
	rename NCyear schoolyear
	rename SENprovision_ sen_provision
	rename AcademicYear_SPR`x' academicyear

rename PRU_* *
	rename Pupil pupilmatchingrefanonymous
	rename SENprovision sen_provision
	rename SENprovisionMajor sen_provision_maj
	rename PrimarySEN sen_primary
	rename SecondarySEN sen_secondary
	rename NC schoolyear
	rename AcademicYear academicyear


****************************************************************************/
*Import NPD HES Linkage Spine (One to One)
import delimited "$data\NPD_HES_Linkage_Spine.csv", varnames(1) 
save "$temp\hes_npd_spine.dta", replace
clear
 
****************************************************************************
* Open birth and finalise cohort		        *
****************************************************************************
Use [merged dataset]

*Generate end of follow up for deaths up to start of KS1
*Need to first convert dob_adm to birth year according to the academic year - NOT calendar year
gen birthyr_academic=.
forvalues k = 2(1)13{
	replace birthyr_academic=(2000+`k') if (dob_adm>=mdy(09,01,(2000+`k')) & dob_adm<=mdy(08,31,(2001+`k')))
}
order birthyr_academic, after(dob_adm)
gen academicyr_1_start=mdy(9, 1, (birthyr_academic+6))
format academicyr_1_start %td
order academicyr_1_start, after(dob_adm)

*drop deaths before KS1 and non-links
count if dod_adj<academicyr_1_start & dod_adj!=. 
drop if dod_adj<academicyr_1_start & dod_adj!=.

count if PMR==""
drop if PMR==""
keep PMR
duplicates drop 

*resave new cohort
Save “cohort2.dta”

	
	merge m:1 pupilmatch using "$savefiles\BirthCohort_PMRs.dta", keep(match)
	drop _m
	duplicates drop
	gen pru_census=1
save "$temp\bc_sen_pru_1013.dta", replace
clear

****************************************************************************
* OPEN GIAS DATA AND LINK ON URNS		   *
****************************************************************************
import delimited "GIAS\DR200604.02B_public_data_gias_data_25102021_20220614.csv"
keep urn establishmenttypegroupcode typeofestablishmentcode typeofestablishmentname establishmenttypegroupname lastchangeddate

gen school_type=0
replace school_type=1 if typeofestablishmentcode==14 | typeofestablishmentcode==24 | typeofestablishmentcode==38 | typeofestablishmentcode==42 | typeofestablishmentcode==43 
replace school_type=2 if typeofestablishmentcode==7 | typeofestablishmentcode==8 | ///
		typeofestablishmentcode==10 | typeofestablishmentcode==12 | ///
		typeofestablishmentcode==32 | typeofestablishmentcode==33 | ///
		typeofestablishmentcode==36 | typeofestablishmentcode==44   
replace school_type=-1 if typeofestablishmentcode==26 | typeofestablishmentcode==27 | ///
		typeofestablishmentcode==41 | typeofestablishmentcode==56 
label define school -1 "unknown" 0 "mainstream" 1 "AP" 2 "special" 
label values school_type school

keep urn school_type 

duplicates drop
save "GIAS_data_temp.dta", replace
clear


*just need years in the study
drop if substr(academicyear,1,4)=="2001" | substr(academicyear,1,4)=="2002" | substr(academicyear,1,4)=="2003" | ///
 substr(academicyear,1,4)=="2004" | substr(academicyear,1,4)=="2005" | substr(academicyear,1,4)=="2006" | ///
 substr(academicyear,1,4)=="2007" |  substr(academicyear,1,4)=="2019" 
duplicates drop

*put different school types within same academic year in another column
duplicates tag pupilmatchingrefanonymous academicyear, gen(tag)
tab tag
drop tag

*keep highest school type within a year
bysort pupilmatchingrefanonymous academicyear (school_type): keep if _n==_N

*keep pupils from birth cohort only
merge m:1 pupilmatchingrefanonymous using "$savefiles\BirthCohort_PMRs.dta", keep(match)
drop _merge

save "GIAS\all_schools_temporary.dta", replace
clear


***************************************************************************
* Add APPENDed CENSUSES						                       		*
***************************************************************************

use “appended_census.dta”,clear
merge m:1 pupilmatchingrefanonymous academicyear using "GIAS\all_schools_temporary.dta"
drop if _merge==2
capture drop sen_primary sen_secondary sen_unit resourced_provision
capture drop AP_Year
capture drop _merge

*Clean schoolyear variable and destring
*All years up to and including reception to be recorded as schoolyear==0
replace schoolyear="0" if schoolyear=="E1" | schoolyear=="E2" | schoolyear=="N" | schoolyear=="N1" | schoolyear=="N2" | schoolyear=="R" | schoolyear=="R " | schoolyear=="n1" | schoolyear=="n2" | schoolyear=="r"
replace schoolyear="2" if schoolyear=="2 "
replace schoolyear="3" if schoolyear=="3 "
replace schoolyear="7" if schoolyear=="7 "
*All X years indicating not following NC to be recoded as schoolyear==99
replace schoolyear="99" if schoolyear=="X"
destring schoolyear, replace
tab schoolyear, m
tab schoolyear school_type,m

*Drop duplicates and save appended file
duplicates drop
sort pupil academicyear
save "$savefiles\bc_census_data_sen_all.dta", replace
clear

*Erase individual files after appending
