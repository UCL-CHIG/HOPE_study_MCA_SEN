/**************************************************************************

		EXTRACTION OF SPRING, AUTUMN AND SUMMER SCHOOL CENSUS DATA, 
						PLASC, PRU, AP AND EYC DATA
					FOR THOSE IN COHORT ONLY (including SEN data)
					
			FOR EACH CHILD SHOW EACH SCHOOL YEAR ATTENDED &
		  THE CORRESPONDING ACADEMIC YEAR FOR THAT SCHOOL YEAR
								&
	   	  SHOW THE ACADEMIC YEARS IN WHICH SPECIAL SCHOOL OR
					ALTERNATIVE PROVISION WAS USED					

NOTES:
* SCHOOL CENSUS AVAILABLE FROM 2006 FOR SECONDARY SCHOOLS & 2007 FOR REST
* SPRING CENSUS AVAILABLE FROM 2006 TO 2020
* SUMMER CENSUS AVAILABLE FROM 2006 TO 2019
* AUTUMN CENSUS AVAILABLE FROM 2007 TO 2020
* PLASC  CENSUS AVAILABLE FROM 2002 TO 2005		              
* PRU    CENSUS AVAILABLE FROM 2010 TO 2013		                    
* AP     CENSUS AVAILABLE FROM 2008 TO 2020		                     
* EY     CENSUS AVAILABLE FROM 2008 TO 2020		         

 NOTES:
*BIRTH COHORT OF INTEREST GOES FROM 2003/04 TO 2012/2013
*SCHOOL FOLLOW UP IS FROM 2009/10 to 2018/19
*ONLY CENSUS DATA FROM THESE YEARS WILL BE EXTRACTED

SEN VARIABLES OF INTEREST
* SENprovision 					available from 2001/02 onward
* SENprovisionMajor 			available from 2008/09 onward
	* Not needed, have checked and doesn't add anything
* PrimarySENtype 				available from 2003/04 onward
	* Not needed for this project
* SecondarySENtype 				available from 2003/04 onward
	* Not needed for this project
* SENUnitIndicator 				available from 2006/07 onward
* ResourcedProvisionIndicator 	available from 2006/07 onward
* SpecialProvisionIndicator 	available in 2005/06 only
	* Not needed, outside academic years for this project (2010-2019)

****************************************************************************/
*Import NPD HES Linkage Spine (One to One)
import delimited "$data\NPD_HES_Linkage_Spine.csv", varnames(1) 
save "$temp\hes_npd_spine.dta", replace
clear
 
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
log using "$logfiles\Do_03_extract_census_data_$S_DATE.log", replace

****************************************************************************
* CREATE TEMPORARY LIST OF PMRS FOR CHILDREN IN COHORT        			 *
****************************************************************************
use "$savefiles\full_cohort.dta", clear

*Generate end of follow up for deaths up to start of KS1
*Need to first convert DOB to birth year according to the academic year - NOT calendar year
gen birthyr_academic=.
forvalues k = 2(1)13{
	replace birthyr_academic=(2000+`k') if (dob>=mdy(09,01,(2000+`k')) & dob<=mdy(08,31,(2001+`k')))
}
order birthyr_academic, after(dob)
gen academicyr_1_start=mdy(9, 1, (birthyr_academic+6))
format academicyr_1_start %td
order academicyr_1_start, after(dob)

*drop deaths before KS1 and non-links
count if dod_adj<academicyr_1_start & dod_adj!=. 
drop if dod_adj<academicyr_1_start & dod_adj!=.

count if pupil==""
drop if pupil==""
keep pupil
duplicates drop 
save "$savefiles\BirthCohort_PMRs.dta", replace
clear

***************************************************************************
* EXTRACTION OF SPRING CENSUS DATA FOR YEARS (2006/07-2019/20)            *
***************************************************************************
*Extract data for those in birth cohort
local j "07 08 09 10 11 12 13 14 15 16 17 18 19 20"

foreach x of local j {
    odbc load, exec("select PupilMatchingRefAnonymous_SPR`x', SENprovision_SPR`x', AcademicYear_SPR`x', NCyearActual_SPR`x' from dbo.Spring_Census_20`x'") connectionstring("XXX")
	rename Pupil pupilmatchingrefanonymous
	rename NCyear schoolyear
	rename SENprovision_ sen_provision
	rename AcademicYear_SPR`x' academicyear
	sort pupilmatch
	merge m:1 pupilmatch using "$savefiles\BirthCohort_PMRs.dta", keep(match)
	drop _m 
	save "$temp\bc_spring_census_sen_`x'.dta", replace
	clear
}

clear

*Append data extracts to create single file
use "$temp\bc_spring_census_sen_07.dta"

local k "08 09 10 11 12 13 14 15 16 17 18 19 20"

foreach y of local k {
	append using "$temp\bc_spring_census_sen_`y'.dta"
}

codebook pupil 
duplicates drop
compress
gen spring_census=1
save "$temp\bc_spring_census_sen_0619.dta", replace
clear

*Delete all but appended file
local j "07 08 09 10 11 12 13 14 15 16 17 18 19 20"

foreach x of local j {
	erase "$temp\bc_spring_census_sen_`x'.dta"
}

clear

**************************************************************************
* EXTRACTION OF SUMMER CENSUS DATA FOR ALL YEARS (2006/07-2018/19        *
**************************************************************************
*Extract data for those in mother-baby birth cohort
local j "07 08 09 10 11 12 13 14 15 16 17 18 19"

foreach x of local j {
    odbc load, exec("select PupilMatchingRefAnonymous_SUM`x', SENprovision_SUM`x', AcademicYear_SUM`x', NCyearActual_SUM`x' from dbo.Summer_Census_20`x'") connectionstring("XXX")
	rename Pupil pupilmatchingrefanonymous
	rename SENprovision_ sen_provision
	rename NCyear schoolyear
	rename AcademicYear_SUM`x' academicyear
	sort pupilmatch
	merge m:1 pupilmatch using "$savefiles\BirthCohort_PMRs.dta", keep(match)
	drop _m
	save "$temp\bc_summer_census_sen_`x'.dta", replace
	clear
}

clear


*Append data extracts to create single file
use "$temp\bc_summer_census_sen_07.dta", clear

local k "08 09 10 11 12 13 14 15 16 17 18 19"

foreach y of local k {
	append using "$temp\bc_summer_census_sen_`y'.dta"
}

codebook pupil 
duplicates drop
compress
gen summer_census=1
save "$temp\bc_summer_census_sen_0618.dta", replace
clear

*Delete all but appended file
local j "07 08 09 10 11 12 13 14 15 16 17 18 19"

foreach x of local j {
	erase "$temp\bc_summer_census_sen_`x'.dta"
}

clear

**************************************************************************
* EXTRACTION OF AUTUMN CENSUS DATA FOR ALL YEARS (2007/08-2020/21)       *
**************************************************************************
*Extract data for those in mother-baby birth cohort
local j "07 08 09 10 11 12 13 14 15 16 17 18 19 20"

foreach x of local j {
    odbc load, exec("select PupilMatchingRefAnonymous_AUT`x', SENprovision_AUT`x', AcademicYear_AUT`x', NCyearActual_AUT`x' from dbo.Autumn_Census_20`x'") connectionstring("XXX")
	rename Pupil pupilmatchingrefanonymous
	rename SENprovision_ sen_provision
	rename NCyear schoolyear
	rename AcademicYear_AUT`x' academicyear
	sort pupilmatch
	merge m:1 pupilmatch using "$savefiles\BirthCohort_PMRs.dta", keep(match)
	drop _m
	save "$temp\bc_autumn_census_sen_`x'.dta", replace
	clear
}

clear

*Append data extracts to create single file
use "$temp\bc_autumn_census_sen_07.dta", clear

local k "08 09 10 11 12 13 14 15 16 17 18 19 20"

foreach y of local k {
	append using "$temp\bc_autumn_census_sen_`y'.dta"
}

codebook pupil 
duplicates drop
compress
gen autumn_census=1
save "$temp\bc_autumn_census_sen_0720.dta", replace
clear

*Delete all but appended file
local j "07 08 09 10 11 12 13 14 15 16 17 18 19 20"

foreach x of local j {
	erase "$temp\bc_autumn_census_sen_`x'.dta"
}

clear

*******************************************************************************
* EXTRACTION OF PRU FOR AVAILABLE YEARS (2010-2013)		                      *
*******************************************************************************
odbc load, exec("select PRU_PupilMatchingRefAnonymous, PRU_AcademicYear, PRU_SENprovision, PRU_SENprovisionMajor, PRU_PrimarySENtype, PRU_SecondarySENtype, PRU_NCyearActual from dbo.PRU_Census_2010_to_2013") connectionstring("XXX")
	rename PRU_* *
	rename Pupil pupilmatchingrefanonymous
	rename SENprovision sen_provision
	rename SENprovisionMajor sen_provision_maj
	rename PrimarySEN sen_primary
	rename SecondarySEN sen_secondary
	rename NC schoolyear
	rename AcademicYear academicyear
	merge m:1 pupilmatch using "$savefiles\BirthCohort_PMRs.dta", keep(match)
	drop _m
	duplicates drop
	gen pru_census=1
save "$temp\bc_sen_pru_1013.dta", replace
clear

*******************************************************************************
* EXTRACTION OF AP FOR AVAILABLE YEARS (2008-2020)		                      *
*******************************************************************************
odbc load, exec("select AP_ACADYR, AP_Pupil, AP_SENProvision, AP_Primary, AP_Secondary from dbo.AP_Census_2008_to_2020") connectionstring("XXX")
	rename AP_ACADYR academicyear
	rename AP_Pupil pupilmatchingrefanonymous
	rename AP_SENProvision sen_provision
	rename AP_Primary sen_primary
	rename AP_Secondary sen_secondary
	sort pupilmatchingrefanonymous
	merge m:1 pupilmatch using "$savefiles\BirthCohort_PMRs.dta", keep(match)
	drop _m
	duplicates drop
	gen schoolyear="100"
	gen ap_census=1
save "$temp\bc_sen_altprov_0820.dta", replace
clear

*******************************************************************************
* EXTRACTION OF EYC FOR AVAILABLE YEARS (2008-2020)	use to look at missing children only*
*******************************************************************************
odbc load, exec("select EYC_PupilMatchingRefAnonymous, EYC_ACADYR from dbo.EYC_2008_to_2020") connectionstring("XXX")
	gen academicyear_EYC=substr(EYC_ACADYR,1,4)
	destring academicyear, replace
	duplicates drop
	gen schoolyear=0
	gen eyc_census=1
	rename EYC_PupilMatchingRefAnonymous pupilmatchingrefanonymous
save "$temp\bc_eyc_0820.dta", replace
clear

****************************************************************************
* GET LIST OF URNS TO DEFINE SCHOOLS TYPES: Special and alternative		   *
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
save "GIAS\all_schools_urn_temporary.dta", replace
clear


**************************************************************************
* OPEN FILE CONTAINING URNS FOR SCHOOL ATTENDED BY YEAR FOR EACH CHILD   *
* MERGE WITH URNS TO GET SCHOOL TYPE									 *
**************************************************************************
import delimited "$data\NPD_All_URN\NPD_All_URN.csv", encoding(ISO-8859-2)
tab academicyear, m
merge m:1 urn using "GIAS\all_schools_urn_temporary.dta"
keep if _m==3
drop _m
codebook pup
drop urn
sort pup academicyear

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
* APPEND CENSUSES						                       			  *
***************************************************************************

*Append all census data (not EYC)
use "$temp\bc_spring_census_sen_0619.dta", clear
append using "$temp\bc_summer_census_sen_0618.dta"
append using "$temp\bc_autumn_census_sen_0720.dta"
append using "$temp\bc_sen_pru_1013.dta"
append using "$temp\bc_sen_altprov_0820.dta"
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
erase "$temp\bc_spring_census_sen_0619.dta"
erase "$temp\bc_summer_census_sen_0618.dta"
erase "$temp\bc_autumn_census_sen_0720.dta"
erase "$temp\bc_sen_pru_1013.dta"
erase "$temp\bc_sen_altprov_0820.dta"
erase "$savefiles\BirthCohort_PMRs.dta"
erase "GIAS\special_schools_urn_temporary.dta"

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
