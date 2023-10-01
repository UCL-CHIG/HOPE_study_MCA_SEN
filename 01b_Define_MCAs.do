*ICD-10 CODES FOR EACH MCM SUBGROUP

*cause of death for deaths in infancy
import delimited "$data\HES_Death_all_data_wide.csv", varnames(1)
keep encrypted_hesid dod_month dod_year age_at_death cause* death_record_used match_rank
gen dod_day=15 //set death date to mid month; as day not available 
gen dod=mdy(dod_month, dod_day, dod_year)
format %td dod
duplicates drop
*merge ids and dod in to see which records to keep
merge m:1 encrypted_hesid dod using "$temp\babytail_dates.dta"
keep if _merge==3
*select the best match rank where there are duplicates (1 is best match)
capture drop death_record
bysort encrypted_hesid: gen death_record=_N
tab death_record
tab match_rank if death_record==2
replace match_rank=99 if match_rank==0 //match_rank 0 indicates HES record only death
bysort encrypted_hesid(match_rank): gen death_record_dup=_n
bysort encrypted_hesid (match_rank): drop if match_rank!=match_rank[_n-1] & death_record_dup==2
*still some multiple records-looks like many are the same information just needs reformatting
*get rid of leading zeroes in some cause of deaths
tostring cause_of_death_neonatal_15 ,replace
foreach var of varlist cause_of_death cause_of_death_neonatal_1-cause_of_death_neonatal_15 cause_of_death_non_neonatal_1-cause_of_death_non_neonatal_15{
replace `var'=substr(`var',2,3) if substr(`var',-4,1)=="0"
replace `var'=substr(`var',2,2) if substr(`var',-3,1)=="0" & substr(`var',-4,1)==""	
}
drop death_record_dup death_record_used
duplicates drop
drop death_record
bysort encrypted_hesid: gen death_record=_N
tab death_record // no more duplicates now

*keeping all death information for now if death is in infancy
keep if age_at_death==0
keep encrypted_hesid dod cause_of_death* dob gestat_baby
*reformat to long to match HES APC noses format
*need to have common name for cause of death variables
rename cause_of_death cause_of_death_neonatal_0
	forvalues k=1/15{ 
		local a=`k'+15
	rename cause_of_death_non_neonatal_`k' cause_of_death_neonatal_`a'
	}
reshape long cause_of_death_neonatal_, i(encrypted_hesid dod gestat_baby dob) j(cause_death_order)
drop if cause_of_death_neonatal_==""	|  cause_of_death_neonatal_=="."
save "$temp\death_infancy_causes_long.dta", replace
clear

*### Load hospital data in to identify MCA noses ###*
** keep admissions in the first year of life only
import delimited "$data\HES_APC_DIAG_combined.csv", varnames(1) // this file contains admissions in long format
** admissions before age 1 only
keep if startage>7000 

** keep only children in our cohort
merge m:1 encrypted_hesid using "$temp\babytail_dates.dta"
drop if _merge!=3
drop _merge
drop epikey
save "$temp\diag_infancy.dta",replace
clear

*add in operations in infancy // need  to merge 
import delimited "$data\HES_APC_Operations_combined.csv", varnames(1)
drop epikey op_no
duplicates drop
*merge ids in to see which records to keep and get dob
merge m:1 encrypted_hesid using "$temp\babytail_dates.dta"
keep if _merge==3
drop _merge
*change dates to Stata format
foreach var of varlist epistart epiend opdate{
gen `var'_2=date(`var',"YMD")	
format `var'_2 %td	
}
*delete episodes after 1st birthday now // no startage in operations file
drop if (epistart_2-dob)>=365
sort encrypted_hesid epistart epiend 
* merge with diagnoses data
merge m:m encrypted_hesid epistart epiend using "$temp\diag_infancy.dta"
*change dates to Stata format
foreach var of varlist epistart epiend opdate{
capture drop `var'_2
gen `var'_2=date(`var',"YMD")	
format `var'_2 %td	
drop `var'
rename `var'_2 `var' 
}
drop _merge 

drop if (epistart-dob)>=365 & epistart!=.

*# Flag as birth admission if same or <=1 day #
*First, creating admissions:joining subsequent episodes together to flag full birth admission*
bysort encrypted_hesid epistart (epiend epiorder): gen adm_end=epiend[_N]
bysort encrypted_hesid (epistart epiend epiorder): gen adm_start=epistart[_n-1] if adm_end[_n-1]>=epistart & epistart!=epistart[_n-1] 
bysort encrypted_hesid epistart (adm_start): replace adm_start=adm_start[1]
replace adm_start=epistart if adm_start==.
bysort encrypted_hesid adm_start(adm_end): replace adm_end=adm_end[_N] 

*repeat this code until no more changes to admissions
forvalues k = 1/40 {
bysort encrypted_hesid (adm_start adm_end): gen adm_start`k'=adm_start[_n-1] if adm_end[_n-1]>=adm_start & adm_start!=adm_start[_n-1] 
bysort encrypted_hesid adm_start: replace adm_start`k'=adm_start`k'[1]
replace adm_start=adm_start`k' if adm_start`k'!=.
bysort encrypted_hesid adm_start(adm_end): replace adm_end=adm_end[_N] 
drop adm_start`k' 
}

format adm_start* adm_end %td

*Birth admission flag
gen birth_adm=1 if adm_start==dob

** append in cause of death information 
append using "$temp\death_infancy_causes_long.dta"
rename cause_of_death_neonatal_ cause

*keep relevant variables only
keep encrypted_hesid opertn dob diag gestat_baby cause birth_adm adm_start adm_end
order encrypted_hesid dob adm_start adm_end birth_adm opertn diag cause gestat_baby
duplicates drop

/* USING MARIAS DEFINITION INSTEAD: this needs rechecking before use
********************************************************************************
*                           ANY MCA - as define in EUROCAT                    	* 
*					Whole Q-chapter & D215 D821 D1810 P350 P351 P371  			*
* Excluding Q101 Q102 Q103 Q105 Q135 Q170 Q171 Q172 Q173 Q174 Q179 Q180 Q181 	*
* Q182 Q183 Q184 Q185 Q186 Q187 Q189 Q261 Q270 Q314 Q320 Q331 Q381 Q382 Q400 	*
* Q430 Q523 Q525 Q527 Q53 Q627 Q633 Q653 Q654 Q655 Q656 Q662 Q663 Q664 Q665     *
* Q667 Q668 Q669 Q670 Q671 Q672 Q673 Q674 Q675 Q676 Q677 Q678 Q680 Q683 Q684	*
* Q685 Q752 Q753 Q760 Q765 Q825 Q833 Q845 Q899									*
*  				exclusions based on rules Q250 < 37 weeks, Q256 < 37				*
*  Can't exclude any of the following 5 character ICD10 codes as precision 		*
*is only up to 4 chars in HES: Q0461 Q0782 Q1880 Q2111 Q2541 Q3850 Q4021 Q4320  *
* Q4381 Q4382 Q6821 Q6810 Q7400 Q7643 Q7660 Q7662 Q7671 Q8280 					*
********************************************************************************

gen any_MCA_eurocat=.

foreach var of varlist diag cause{
replace any_MCA_eurocat=1 if substr(`var',1,1)=="Q" | substr(`var',1,4)=="D215" | substr(`var',1,5)=="D1810" |  substr(`var',1,4)=="P350" |  substr(`var',1,4)=="P351" |  substr(`var',1,4)=="P371" 
replace any_MCA_eurocat=. if substr(`var',1,3)=="Q53" 
local any_MCA_eurocat_exclusions Q101 Q102 Q103 Q105 Q135 Q170 Q171 Q172 Q173 Q174 Q179 Q180 Q181 Q182 Q183 Q184 Q185 Q186 Q187 Q189 Q261 Q270 Q314 Q320 Q331 Q381 Q382 Q400 Q430 Q523 Q525 Q527 Q627 Q633 Q653 Q654 Q655 Q656 Q662 Q663 Q664 Q665 Q667 Q668 Q669 Q670 Q671 Q672 Q673 Q674 Q675 Q676 Q677 Q678 Q680 Q683 Q684 Q685 Q752 Q753 Q760 Q765 Q825 Q833 Q845 Q899
foreach k of local any_MCA_eurocat_exclusions{
	replace any_MCA_eurocat=. if substr(`var',1,4)=="`k'" 
}
replace any_MCA_eurocat=. if (substr(`var',1,4)=="Q250" |  substr(`var',1,4)=="Q256") & gestat_baby<37
}
*/

********************************************************************************
*                           ANORECTAL MALFORMATIONS                            * 
*                            from Ford et al. (2022)                           *
********************************************************************************
* specific and general diagnoses, operations and cause of death used to define ARM
*specific diagnoses
local arm_diag_spec Q420 Q421 Q422 Q423 Q435 Q437 K604 K605 K624 N321 N360 N823 N824 
gen arm_diag_spec=.
foreach k of local arm_diag_spec  {
replace arm_diag_spec=1 if substr(diag,1,4)=="`k'"
}
*specific operations
local arm_op_spec H504 H501 H5042 H5043 H509 N242 N248 N249 M375 M459 M733 P134 P138 P139 P253 P274
gen arm_op_spec=.
foreach k of local arm_op_spec {
replace arm_op_spec=1 if substr(opertn,1,4)=="`k'"
}
*specific causes of death
local arm_death_spec Q420 Q421 Q422 Q423 Q435 Q437 K604 K605 K624 N321 N360 N823 N824
gen arm_death_spec=.
foreach k of local arm_death_spec {
replace arm_death_spec=1 if substr(cause,1,4)=="`k'"
}
*general diagnoses
local arm_diag_gen Q438 Q439
gen arm_diag_gen=.
foreach k of local arm_death_gen  {
replace arm_diag_gen=1 if substr(diag,1,4)=="`k'"
}
*specific operations
local arm_op_gen H568 H151 H152 H158 H159 H321 G742 G743 G748 G749
gen arm_op_gen=.
foreach k of local arm_op_gen {
replace arm_op_gen=1 if substr(opertn,1,4)=="`k'"
}
*specific causes of death
local arm_death_gen Q438 Q439
gen arm_death_gen=.
foreach k of local arm_death_gen {
replace arm_death_gen=1 if substr(cause,1,4)=="`k'"
}
*copy results across rows for each child
foreach var of varlist arm_diag_spec arm_op_spec arm_death_spec arm_diag_gen arm_op_gen arm_death_gen{
	bysort encrypted_hesid (`var'): replace `var'=`var'[1] 
}
*ARM DEFINITION 1: Potential procedure for anorectal malformations alongside evidence from a hospital diagnosis or death certificate 
gen dig_arm_full=.
replace dig_arm_full=1 if (arm_diag_spec==1| arm_diag_gen==1) & (arm_op_spec==1|arm_op_gen==1)
replace dig_arm_full=1 if (arm_op_spec==1|arm_op_gen==1) & (arm_death_spec==1|arm_death_gen==1)
*ARM DEFINITION 2: Potential hospital diagnosis for anorectal malformations alongside evidence from a death certificate 
replace dig_arm_full=1 if (arm_diag_spec==1| arm_diag_gen==1) & arm_death_gen==1
*ARM DEFINITION 3: Death recorded using specific code indicating anorectal malformations 
replace dig_arm_full=1 if (arm_death_spec==1)
drop arm_diag_spec arm_op_spec arm_death_spec arm_diag_gen arm_op_gen arm_death_gen

********************************************************************************
*                     Defining congenital diaphragmatic hernia 					*
*							FROM Peppa et al. (2022)							*
********************************************************************************
* CDH in hospital or mortality records
gen CDH_diag=1 if substr(diag,1,4)=="Q790"
gen CDH_death=1 if substr(cause,1,4)=="Q790" 
*procedures
local CDH_op G232 G234 G238 G239 T161 T164 T165	
gen CDH_op=.
foreach k of local CDH_op{
replace CDH_op=1 if substr(opertn,1,4)=="`k'"
}
*add CDH diag and procedures to all rows within the same admission
bysort encrypted_hesid adm_start (CDH_diag): replace CDH_diag=1 if CDH_diag[1]==1
bysort encrypted_hesid adm_start (CDH_op): replace CDH_op=1 if CDH_op[1]==1
*add death to all rows
bysort encrypted_hesid (CDH_death): replace CDH_death=1 if CDH_death[1]==1
**Support for evidence of CDH
*lung hypoplasia in death or hospital records
gen CDH_supp=1 if substr(cause,1,4)=="Q336" | substr(diag,1,4)=="Q336" 
*respiratory distress/pulmonary hypertension that occured in the same admission as CDH repair
replace CDH_supp=1 if (substr(diag,1,3)=="J96" | substr(diag,1,3)=="P22") & CDH_op==1
local CDH_supp P282 P284 P285 Z991 R092 R068 I270 I272 P293 P292
foreach k of local CDH_supp{
replace CDH_supp=1 if substr(diag,1,4)=="`k'" & CDH_op==1 
}
*hypoxia/asphyxia, tracheostomy and invasive ventilation that occured in birth admission AND same admission as CDH repair
replace CDH_supp=1 if substr(diag,1,3)=="P21" & CDH_op==1 & birth_adm==1
local CDH_supp P201 P209 Z430 J950 Z930
foreach k of local CDH_supp{
replace CDH_supp=1 if substr(diag,1,4)=="`k'" & CDH_op==1 & birth_adm==1
}
local CDH_supp E423 E424 E425 E426 E427 E851 X561 X562 X569 X581
foreach k of local CDH_supp{
replace CDH_supp=1 if substr(opertn,1,4)=="`k'" & CDH_op==1 & birth_adm==1
}
*exclusions
gen CDH_excl=.
replace CDH_excl=1 if substr(diag,1,3)=="Q39" | substr(cause,1,3)=="Q39" 
local CDH_excl Q792 Q793
foreach k of local CDH_excl {
replace CDH_excl=1 if substr(diag,1,4)=="`k'" | substr(cause,1,4)=="`k'" 
}
*Hiatus hernia only an exclusion if present WITHOUT any of the following:
* // CDH recorded on the death certificate
* // diagnosis of lung hypoplasia at any time
* // an indication of respiratory distress, hypoxia/asphyxia or invasive ventilation in the delivery record OR in any record containing a CDH diagnosis or repair 
gen CDH_hypop_excl=1 if substr(cause,1,4)=="Q336" | substr(diag,1,4)=="Q336"  
gen CDH_distress_excl=.
local CDH_distress P282 P284 P285 Z991 R092 R068 P201 P209 Z430 J950 Z930
foreach k of local CDH_distress{
replace CDH_distress_excl=1  if  substr(diag,1,4)=="`k'"  & (birth_adm==1 | CDH_diag | CDH_op)
}
local CDH_distress J96 P22 P21
foreach k of local CDH_distress{
replace CDH_distress_excl=1  if  substr(diag,1,3)=="`k'"  & (birth_adm==1 | CDH_diag | CDH_op)
}
local CDH_distress E423 E424 E425 E426 E427 E851 X561 X562 X569 X581
foreach k of local CDH_distress{
replace CDH_distress_excl=1  if  substr(opertn,1,4)=="`k'"  & (birth_adm==1 | CDH_diag | CDH_op)
}
*exclusions are at any point
bysort encrypted_hesid(CDH_hypop_excl):replace CDH_hypop_excl=1 if CDH_hypop_excl[1]==1
bysort encrypted_hesid(CDH_distress_excl):replace CDH_distress_excl=1 if CDH_distress_excl[1]==1

bysort encrypted_hesid: replace CDH_excl=1 if (substr(diag,1,4)=="Q401" | substr(cause,1,4)=="Q401") & CDH_death!=1 & CDH_hypop_excl!=1 & CDH_distress_excl!=1

*create final indicator 
gen dig_cdh_full=1 if CDH_diag==1 & CDH_op==1
replace dig_cdh_full=1 if CDH_death==1
replace dig_cdh_full=1 if (CDH_diag==1|CDH_op==1) & CDH_supp==1
bysort encrypted_hesid(CDH_excl): replace dig_cdh_full=. if CDH_excl[1]==1

drop CDH_*

********************************************************************************
*                             NERVOUS SYSTEM                                   * 
*                                 Q00-07                                       *
*                     No exclusion of any 3-digit codes                        *
*   Codes Q0461 Q0782 Q0780 minor but ICD-10 not granular enough to exclude    *
*		Loop whole code once to add outcome by cause of death (and diag)	*
********************************************************************************

gen nerv_all=.
gen nerv_tube=.
gen nerv_anenceph=.
gen nerv_enceph=.
gen nerv_microceph=.
gen nerv_hydroceph=.
gen nerv_arhine=.
gen nerv_bifida=.
gen nerv_hardelid=.
gen nerv_feudtner=.

foreach var of varlist diag cause{
local nerv_all Q00 Q01 Q02 Q03 Q04 Q05 Q06 Q07
foreach k of local nerv_all{
	replace nerv_all=1 if substr(`var',1,3)=="`k'" 
}
*Neural tube defects
local nerv_tube Q00 Q01 Q05
foreach k of local nerv_tube{
	replace nerv_tube=1 if substr(`var',1,3)=="`k'"
}
*Anencephalus
replace nerv_anenceph=1 if substr(`var',1,3)=="Q00"

*Encephalocele
replace nerv_enceph=1 if substr(`var',1,3)=="Q01"

*Microcephaly
replace nerv_microceph=1 if substr(`var',1,3)=="Q02"

*Hydrocephalus
replace nerv_hydroceph=1 if substr(`var',1,3)=="Q03"

*Arhinenceph
local nerv_arhine Q041 Q042
foreach k of local nerv_arhine{
replace nerv_arhine=1 if substr(`var',1,4)=="`k'"
}

*Spina Bifida
replace nerv_bifida=1 if substr(`var',1,3)=="Q05"

*Nervous system - Hardelid (SAME AS NERV_ALL)
local nerv_hardelid Q00 Q01 Q02 Q03 Q04 Q05 Q06 Q07
foreach k of local nerv_hardelid{
replace nerv_hardelid=1 if substr(`var',1,3)=="`k'"
}
*Nervous system - Feudtner (SAME AS NERV_ALL)
local nerv_feudtner Q00 Q01 Q02 Q03 Q04 Q05 Q06 Q07
foreach k of local nerv_feudtner{
replace nerv_feudtner=1 if substr(`var',1,3)=="`k'"
}
}

********************************************************************************
*                                  EYE                                         *
*                                Q10-15                                        *
*                    Excluding  Q101-103 Q105 Q135                             *
********************************************************************************

gen eye_all=.
gen eye_anomicro=.
gen eye_anoph=. 
gen eye_microph=.
gen eye_cataract=.
gen eye_glaucoma=.
gen eye_hardelid=.

foreach var of varlist diag cause{
*Eye
local eye_all Q11 Q12 Q14 Q15
foreach k of local eye_all{
replace eye_all=1 if substr(`var',1,3)=="`k'"
}
local eye_all Q100 Q104 Q106 Q107 Q130 Q131 Q132 Q133 Q134 Q138 Q139 
foreach k of local eye_all{
replace eye_all=1 if substr(`var',1,4)=="`k'"
} 
*Anophthalmos and microphthalmos
local eye_anomicro Q110 Q111 Q112
foreach k of local eye_anomicro{
replace eye_anomicro=1 if substr(`var',1,4)=="`k'"
}
*Anophthalmos only
local eye_anoph Q110 Q111
foreach k of local eye_anoph{
replace eye_anoph=1 if substr(`var',1,4)=="`k'"
}
*Microphthalmos only
replace eye_microph=1 if substr(`var',1,4)=="Q112"

*Congenital cataract
replace eye_cataract=1 if substr(`var',1,4)=="Q120"

*Congenital glaucoma
replace eye_glaucoma=1 if substr(`var',1,4)=="Q150"

*Eye - Hardelid
local eye_hardelid Q104 Q107 Q130 Q131 Q132 Q133 Q134 Q138 Q139
foreach k of local eye_hardelid{
replace eye_hardelid=1 if substr(`var',1,4)=="`k'"
}
local eye_hardelid Q11 Q12 Q14 Q15
foreach k of local eye_hardelid{
replace eye_hardelid=1 if substr(`var',1,3)=="`k'"
}
*Eye - Feudtner (NONE)
}

********************************************************************************
*							EAR, FACE AND NECK								   *
*                                 Q16-18                                       *
*					Excluding Q170-175 Q179 Q180-182 Q184-187 Q189             *
*            Code Q1880 minor but ICD-10 not granular enough to exclude        *
********************************************************************************

gen efn_all=.
gen efn_anotia=.
gen efn_hardelid=.

foreach var of varlist diag cause{
*Ear, face, neck
replace efn_all=1 if substr(`var',1,3)=="Q16"
local efn_all Q178 Q183 Q188
foreach k of local efn_all{
replace efn_all=1 if substr(`var',1,4)=="`k'"
}
*Anotia
replace efn_anotia=1 if substr(`var',1,4)=="Q160"
*Ear, face, neck - Hardelid
replace efn_hardelid=1 if substr(`var',1,4)=="Q188"
replace efn_hardelid=1 if substr(`var',1,3)=="Q16"
*Ear, face, neck - Feudtner (NONE)
}

********************************************************************************
*								  HEART                                        *
*                                Q20-26                                        *
*      Excluding Q261 & Q246 always, excluding Q250 & Q256 if gestage<37wks    *
*       Codes Q2111 Q2541 minor but ICD-10 not granular enough to exclude      *
*******************************************************************************

gen heart_all=.
gen heart_severe=.
gen heart_truncus=.
gen heart_doubleout=.
gen heart_transpos=.
gen heart_single=.
gen heart_vsd=.
gen heart_asd=.
gen heart_avsd=.
gen heart_fallot=.
gen heart_tricusp=.
gen heart_ebstein=.
gen heart_pvstenosis=.
gen heart_pvatresia=.
gen heart_avstenosis=.
gen heart_mitral=.
gen heart_hypoleft=.
gen heart_hyporight=.
gen heart_coarc=.
gen heart_aortatresia=.
gen heart_anomreturn=.
gen heart_pda=.
gen heart_pastenos=.
gen heart_feudtner=.

foreach var of varlist diag cause{
*Heart
local heart_all Q20 Q21 Q22 Q23 Q25
foreach k of local heart_all{
replace heart_all=1 if substr(`var',1,3)=="`k'"
}
local heart_all Q240 Q241 Q242 Q243 Q244 Q245 Q248 Q249 Q260 Q262 Q263 Q264 Q265 Q266 Q268 Q269
foreach k of local heart_all{
replace heart_all=1 if substr(`var',1,4)=="`k'"
}
replace heart_all=. if (substr(`var',1,4)=="Q250"|substr(`var',1,4)=="Q256") & gestat_baby<37
*Severe heart
local heart_severe Q200 Q201 Q203 Q204 Q212 Q213 Q220 Q224 Q225 Q226 Q230 Q232 Q233 Q234 Q251 Q252 Q262
foreach k of local heart_severe {
replace heart_severe=1 if substr(`var',1,4)=="`k'"
}
*Common arterial truncus
replace heart_truncus=1 if substr(`var',1,4)=="Q200"
*Double outlet right ventricle
replace heart_doubleout=1 if substr(`var',1,4)=="Q201"
*Transposition of great vessels
replace heart_transpos=1 if substr(`var',1,4)=="Q203"
*Single ventricle
replace heart_single=1 if substr(`var',1,4)=="Q204"
*Ventricular septal defect
replace heart_vsd=1 if substr(`var',1,4)=="Q210"
*Atrial septal defect
replace heart_asd=1 if substr(`var',1,4)=="Q211"
*Atrioventricular septal defect
replace heart_avsd=1 if substr(`var',1,4)== "Q212"
*Tetralogy of Fallot
replace heart_fallot=1 if substr(`var',1,4)== "Q213"
*Tricuspid atresia and stenosis
replace heart_tricusp=1 if substr(`var',1,4)== "Q224"
*Ebstein's anomaly
replace heart_ebstein=1 if substr(`var',1,4)== "Q225"
*Pulmonary valve stenosis
replace heart_pvstenosis=1 if substr(`var',1,4)=="Q221"
*Pulmonary valve atresia
replace heart_pvatresia=1 if substr(`var',1,4)=="Q220"
*Aortic valve stenosis
replace heart_avstenosis=1 if substr(`var',1,4)=="Q230"
*Mitral valve anomalies
replace heart_mitral=1 if substr(`var',1,4)=="Q232" | substr(`var',1,4)=="Q233"
*Hypoplastic left heart
replace heart_hypoleft=1 if substr(`var',1,4)=="Q234"
*Hypoplastic right heart
replace heart_hyporight=1 if substr(`var',1,4)=="Q226"
*Coarctation of aorta
replace heart_coarc=1 if substr(`var',1,4)=="Q251"
*Aortic atresia
replace heart_aortatresia=1 if substr(`var',1,4)=="Q252"
*Total Anomalous Pulmonary Venous Return
replace heart_anomreturn=1 if substr(`var',1,4)=="Q262"
*Patent Ductus Arteriosus 
replace heart_pda=1 if substr(`var',1,4)=="Q250" & gestat_baby>=37 & gestat_baby!=.
*Pulmonary Artery Stenosis 
replace heart_pastenos=1 if substr(`var',1,4)=="Q256" & gestat_baby>=37 & gestat_baby!=.
*Heart - Feudtner
local heart_feudtner Q20 Q22 Q23 
foreach k of local heart_feudtner{
replace heart_feudtner=1 if substr(`var',1,3)=="`k'"
}
local heart_feudtner Q212 Q213 Q214 Q218 Q219 Q240 Q241 Q242 Q243 Q244 Q245 Q248 Q249 Q251 Q252 Q253 Q254 Q255 Q256 Q257 Q258 Q259 Q260 Q262 Q263 Q264 Q265 Q266 Q268 Q269
foreach k of local heart_feudtner{
replace heart_feudtner=1 if substr(`var',1,4)=="`k'"
}
}
*Heart - Hardelid (SAME AS HEART_ALL)
gen heart_hardelid=heart_all 

********************************************************************************
*					          RESPIRATORY                                      *
*                             Q300 Q32-34                                      *
*                     Exclude  Q320 Q322 Q331 Q336                             *
*	     Code Q3300 minor but ICD-10 not granular enough to exclude            *
********************************************************************************

gen resp_all=.
gen resp_choanal=.

foreach var of varlist diag cause{
*Respiratory
replace resp_all=1 if  substr(`var',1,3)=="Q34"
local resp_all Q300 Q321 Q323 Q324 Q330 Q332 Q333 Q334 Q335 Q338 Q339
foreach k of local resp_all{
replace resp_all=1 if substr(`var',1,4)=="`k'"
}
*Choanal atresia
replace resp_choanal=1 if substr(`var',1,4)=="Q300"

}

*Respiratory - Hardelid (SAME AS RESP_ALL)
gen resp_hardelid=resp_all
*Respiratory - Feudtner (SAME AS RESP_ALL)
gen resp_feudtner=resp_all

********************************************************************************
*							   OROFACIAL                                       *
*  								Q35-37                                         *
*                            Exclude Q357                                      *
********************************************************************************

*Orofacial
gen oro_all=.
gen oro_pal=.
gen oro_lip=.
gen oro_both=.

foreach var of varlist diag cause{
*Orofacial
replace oro_all=1 if  substr(`var',1,3)=="Q36" | substr(`var',1,3)=="Q37"
local oro_all Q350 Q351 Q352 Q353 Q354 Q355 Q356 Q358 Q359
foreach k of local oro_all{
replace oro_all=1 if substr(`var',1,4)=="`k'"
}
*Cleft palate
local oro_pal Q350 Q351 Q352 Q353 Q354 Q355 Q356 Q358 Q359
foreach k of local oro_pal{
replace oro_pal=1 if substr(`var',1,4)=="`k'"
}
*Cleft lip
replace oro_lip=1 if substr(`var',1,3)=="Q36"
*Cleft lip and palate
replace oro_both=1 if substr(`var',1,3)=="Q37"
}
*Orofacial - Hardelid (SAME AS ORO_ALL)
gen oro_hardelid=oro_all
*Orofacial - Feudtner (NONE)

********************************************************************************
*                       	 DIGESTIVE                                         *
*                          Q38-45, Q790                                        *
*                   Exclude Q381-382 Q400-401 Q430 Q444                        *
*    Codes Q3850 Q4021 Q4320 Q4381 Q4382 minor but ICD-10 not granular enough  *
********************************************************************************

gen dig_all=.
gen dig_oatresia=.
gen dig_datresia=.
gen dig_smatresia=.
gen dig_anatresia=.
gen dig_hirsch=.
gen dig_batresia=. 
gen dig_pancreas=. 
gen dig_cdh_simple=.
gen dig_hardelid=.
gen dig_feudtner=.

foreach var of varlist diag cause{
*Digestive
local dig_all Q39 Q41 Q42 Q45 
foreach k of local dig_all{
replace dig_all=1 if substr(`var',1,3)=="`k'"
}
local dig_all Q380 Q383 Q384 Q385 Q386 Q387 Q388 Q402 Q403 Q408 Q409 Q431 Q432 Q433 Q434 Q435 Q436 Q437 Q438 Q439 Q440 Q441 Q442 Q443 Q445 Q446 Q447 Q790
foreach k of local dig_all{
replace dig_all=1 if substr(`var',1,4)=="`k'"
}
*OA with or with TOF
replace dig_oatresia=1 if substr(`var',1,4)=="Q390"| substr(`var',1,4)=="Q391"
*Duodenal atresia
replace dig_datresia=1 if substr(`var',1,4)=="Q410"
*Small intestine stenosis
local dig_smatresia Q411 Q412 Q413 Q414 Q415 Q416 Q417 Q418
foreach k of local dig_smatresia{
replace dig_smatresia=1 if substr(`var',1,4)=="`k'"
}
*Anorectal atresia
local dig_anatresia Q420 Q421 Q422 Q423
foreach k of local dig_anatresia{
replace dig_anatresia=1 if substr(`var',1,4)=="`k'"
}
*Hirschprung
replace dig_hirsch=1 if substr(`var',1,4)=="Q431"
*Bile duct atresia
replace dig_batresia=1 if substr(`var',1,4)=="Q442"
*Annular pancreas
replace dig_pancreas=1 if substr(`var',1,4)=="Q451"
*Congenital diaphragmatic hernia simple
replace dig_cdh_simple=1 if substr(`var',1,4)=="Q790"

*Digestive - hardelid
local dig_hardelid Q39 Q41 Q42 Q45 
foreach k of local dig_hardelid{
replace dig_hardelid=1 if substr(`var',1,3)=="`k'"
}
local dig_hardelid Q380 Q383 Q384 Q386 Q387 Q388 Q402 Q403 Q408 Q409 Q431 Q433 Q434 Q435 Q436 Q437 Q439 Q440 Q441 Q442 Q443 Q445 Q446 Q447 Q790
foreach k of local dig_hardelid{
replace dig_hardelid=1 if substr(`var',1,4)=="`k'"
}
*Digestive - feudtner
local dig_feudtner Q41 Q42 Q45 
foreach k of local dig_feudtner{
replace dig_feudtner=1 if substr(`var',1,3)=="`k'"
}
local dig_feudtner Q390 Q391 Q392 Q393 Q394 Q431 Q432 Q433 Q434 Q435 Q436 Q437 Q438 Q439 Q440 Q441 Q442 Q443 Q445 Q446 Q447 Q790
foreach k of local dig_feudtner{
replace dig_feudtner=1 if substr(`var',1,4)=="`k'"
}
}

* add in ARM and CDH (defined, seperately, above) to overall indicator
replace dig_all=1 if dig_cdh_full==1 | dig_arm_full==1

********************************************************************************
*				     	ABDOMINAL WALL DEFECTS                                 *
*                           Q792 Q793 Q795                                     *
*						 No 3-digit exclusions                                 *
********************************************************************************

gen abdo_all=.
gen abdo_gastro=.
gen abdo_omphal=.

foreach var of varlist diag cause{
*Abdominal wall defects
replace abdo_all=1 if substr(`var',1,4)=="Q792" | substr(`var',1,4)=="Q793"| substr(`var',1,4)=="Q795"
*Gastroschisis
replace abdo_gastro=1 if substr(`var',1,4)=="Q793"
*Omphalocele
replace abdo_omphal=1 if substr(`var',1,4)=="Q792"
}

*Abdominal wall defects - Hardelid (SAME AS ABDO_ALL)
gen abdo_hardelid=abdo_all
*Abdominal wall defects - Feudtner (SAME AS ABDO_ALL)
gen abdo_feudtner=abdo_all

********************************************************************************
*					          URINARY                                          *
*						    Q60-64 Q794                                        *
*                     Exclude Q610 Q627 Q633                                   *
********************************************************************************

gen urin_all=.
gen urin_biagenesis=.
gen urin_hydronephrosis=.
gen urin_exstrophy=.
gen urin_prune=.
gen urin_hardelid=.

foreach var of varlist diag cause{
*Urinary
local urin_all Q60 Q64
foreach k of local urin_all{
replace urin_all=1 if substr(`var',1,3)=="`k'"
}
local urin_all Q611 Q612 Q613 Q614 Q615 Q618 Q619 Q620 Q621 Q622 Q623 Q624 Q625 Q626 Q628 Q630 Q631 Q632 Q638 Q639 Q794
foreach k of local urin_all{
replace urin_all=1 if substr(`var',1,4)=="`k'"
}
*Bilateral agenesis
replace urin_biagenesis=1 if substr(`var',1,4)=="Q601" | substr(`var',1,4)=="Q606"
*Hydronephrosis
replace urin_hydronephrosis=1 if substr(`var',1,4)=="Q620"
*Bladder exstrophy
replace urin_exstrophy=1 if substr(`var',1,4)=="Q640" | substr(`var',1,4)=="Q641"
replace urin_prune=1 if substr(`var',1,4)== "Q794"
*Urinary - Hardelid
replace urin_hardelid=1 if substr(`var',1,3)=="Q64" 
local urin_all Q601 Q602 Q604 Q605 Q606 Q611 Q612 Q613 Q614 Q615 Q618 Q619 Q620 Q621 Q622 Q623 Q624 Q625 Q626 Q628 Q630 Q631 Q632 Q638 Q639 Q794
foreach k of local urin_all{
replace urin_all=1 if substr(`var',1,4)=="`k'"
}
}
*Urinary - Feudtner (SAME AS URIN_ALL)
gen urin_feudtner=urin_all

********************************************************************************
*					            GENITAL                                        *
*							Q50-52 Q54-56                                      *
*					Exclude Q501-502 Q505 Q523 Q525 Q527 Q544                  *
*Codes Q5010 Q5011 Q5520 Q5521 minor but ICD-10 not granular enough to exclude *
********************************************************************************

gen genital_all=.
gen genital_hypospadia=.
gen genital_indsex=.
gen genital_hardelid =.

foreach var of varlist diag cause{
*Genital
local genital_all Q51 Q55 Q56
foreach k of local genital_all {
replace genital_all =1 if substr(`var',1,3)=="`k'"
}
local genital_all Q500 Q503 Q504 Q506 Q520 Q521 Q522 Q524 Q526 Q528 Q529 Q540 Q541 Q542 Q543 Q548 Q549
foreach k of local genital_all {
replace genital_all=1 if substr(`var',1,4)=="`k'"
}
*Hypospadias
local genital_hypospadia Q540 Q541 Q542 Q543 Q548 Q549
foreach k of local genital_hypospadia {
replace genital_hypospadia=1 if substr(`var',1,4)=="`k'"
}
*Indeterminate sex
replace genital_indsex=1 if substr(`var',1,3)=="Q56"
*Genital - Hardelid
local genital_hardelid Q51 Q56
foreach k of local genital_hardelid {
replace genital_hardelid =1 if substr(`var',1,3)=="`k'"
}
local genital_hardelid Q500 Q520 Q521 Q522 Q524 Q540 Q541 Q542 Q543 Q548 Q549 Q550 Q555 
foreach k of local genital_hardelid {
replace genital_hardelid=1 if substr(`var',1,4)=="`k'"
}
}
*Genital - Feudtner (NONE)

********************************************************************************
*							    	LIMB                                       *
*								   Q65-74                                      *
*          Exclude Q653-659 Q661-669 Q670-678 Q680 Q683-685                    *
*     Codes Q6810 Q6821 Q7400 minor but ICD-10 to granular to exclude          *
********************************************************************************      
 
gen limb_all=.
gen limb_reduct=.
gen limb_clubfoot=.
gen limb_hip=.
gen limb_polydact=.
gen limb_syndact=.
gen limb_hardelid=.
gen limb_feudtner=.
 
foreach var of varlist diag cause{ 
*Limb 
local limb_all Q69 Q70 Q71 Q72 Q73 Q74

foreach k of local limb_all {
replace limb_all=1 if substr(`var',1,3)=="`k'"
}
local limb_all Q650 Q651 Q652 Q660 Q681 Q682 Q688
foreach k of local limb_all {
replace limb_all=1 if substr(`var',1,4)=="`k'"
}
*Limb reduction
local limb_reduct Q71 Q72 Q73
foreach k of local limb_reduct {
replace limb_reduct=1 if substr(`var',1,3)=="`k'"
}
*Club foot
replace limb_clubfoot=1 if substr(`var',1,4)=="Q660"
*Hip dyspasia
local limb_hip Q650 Q651 Q652
foreach k of local limb_hip {
replace limb_hip=1 if substr(`var',1,4)=="`k'"
}
*Polydactyly
replace limb_polydact=1 if substr(`var',1,4)== "Q69"
*Syndactyl
replace limb_syndact=1 if substr(`var',1,4)== "Q70"
*Limb - Hardelid
local limb_hardelid Q71 Q72 Q73 Q74
foreach k of local limb_hardelid {
replace limb_hardelid=1 if substr(`var',1,3)=="`k'"
}
local limb_hardelid Q650 Q651 Q652 Q682 
foreach k of local limb_hardelid {
replace limb_hardelid=1 if substr(`var',1,4)=="`k'"
}
*Limb - Feudtner
replace limb_feudtner=1 if substr(`var',1,4)== "Q722"
}

********************************************************************************
*								CHROMOSOMAL                                    *
*                              Q90-93 Q96-99                                   *
********************************************************************************

gen chrom_all=.
gen chrom_21=.
gen chrom_18=.
gen chrom_13=.
gen chrom_turn=.
gen chrom_kline=.
gen chrom_hardelid=.
gen chrom_feudtner=.

foreach var of varlist diag cause{
*Chromosomal
local chrom_all Q90 Q91 Q92 Q93 Q96 Q97 Q98 Q99
foreach k of local chrom_all {
replace chrom_all=1 if substr(`var',1,3)=="`k'"
}
replace chrom_all=. if substr(`var',1,4)=="Q936"
*
replace chrom_21=1 if substr(`var',1,3)=="Q90"
*
local chrom_18 Q90 Q91 Q92 Q93 Q96 Q97 Q98 Q99
foreach k of local chrom_18 {
replace chrom_18=1 if substr(`var',1,3)=="`k'"
}
replace chrom_18=. if substr(`var',1,4)=="Q936"
*
local chrom_13 Q914 Q915 Q916 Q917
foreach k of local chrom_13 {
replace chrom_13=1 if substr(`var',1,4)=="`k'"
}
*
replace chrom_turn=1 if substr(`var',1,3)=="Q96"
*
local chrom_kline Q980 Q981 Q982 Q983 Q984
foreach k of local chrom_kline {
replace chrom_kline=1 if substr(`var',1,4)=="`k'"
}
*Chromosomal - Hardelid
local chrom_hardelid Q90 Q91 Q92 Q93 Q97 Q99
foreach k of local chrom_hardelid {
replace chrom_hardelid=1 if substr(`var',1,3)=="`k'"
}
*Chromosomal - Feudtner
local chrom_feudtner Q93 Q97 Q98 
foreach k of local chrom_feudtner {
replace chrom_feudtner=1 if substr(`var',1,3)=="`k'"
}
local chrom_feudtner Q909 Q913 Q914 Q917 Q928 Q969 Q992 Q998 Q999
foreach k of local chrom_feudtner {
replace chrom_feudtner=1 if substr(`var',1,4)=="`k'"
}
}

********************************************************************************
*                OTHER MALFORMATIONS NOT IN ABOVE GROUPS                       *
********************************************************************************

gen other_all=.
gen other_circ=.
gen other_nasolar=.
gen other_skeletal=.
gen other_skin=.
gen other_breast=.
gen other_integument=.
gen other_syndrome=.
gen other_unclass=.
gen other_translocal=.

foreach var of varlist diag cause{
local other_all Q28 Q77 Q78 Q80 Q81 Q83 Q85 Q86 Q87 
foreach k of local other_all {
replace other_all=1 if substr(`var',1,3)=="`k'"
}
local other_all Q271 Q272 Q273 Q274 Q278 Q279 Q301 Q302 Q303 Q308 Q309 Q310 Q311 Q312 Q313 Q318 Q319 Q750 Q751 Q754 Q755 Q758 Q759 Q761 Q762 Q763 Q764 Q766 Q767 Q768 Q769 Q791 Q796 Q798 Q799 Q820 Q821 Q822 Q823 Q824 Q828 Q829 Q840 Q841 Q842 Q843 Q844 Q846 Q848 Q849 Q890 Q891 Q892 Q893 Q894 Q897 Q898 Q952 Q953 Q954 Q955 Q958 Q959
foreach k of local other_all {
replace other_all=1 if substr(`var',1,4)=="`k'"
}
*OTHER PERIPHERAL CIRCULATION ANOMALIES
local other_circ Q271 Q272 Q273 Q274 Q278 Q279 Q28
foreach k of local other_circ {
replace other_circ=1 if substr(`var',1,4)=="`k'"
}
*OTHER NASOLARYNX ANOMALIES
local other_nasolar Q301 Q302 Q303 Q308 Q309 Q310 Q311 Q312 Q313 Q318 Q319
foreach k of local other_nasolar {
replace other_nasolar=1 if substr(`var',1,4)=="`k'"
}
*OTHER SKELETAL ANOMALIES
local other_skeletal Q77 Q78
foreach k of local other_skeletal {
replace other_skeletal=1 if substr(`var',1,3)=="`k'"
}
local other_skeletal Q750 Q751 Q754 Q755 Q758 Q759 Q761 Q762 Q763 Q764 Q766 Q767 Q768 Q769 Q791 Q796 Q798 Q799
foreach k of local other_skeletal {
replace other_skeletal=1 if substr(`var',1,4)=="`k'"
}
*OTHER SKIN ANOMALIES
replace other_skin=1  if substr(`var',1,3)=="Q80" |  substr(`var',1,3)=="Q81" 
local other_skin Q820 Q821 Q822 Q823 Q824 Q828 Q829
foreach k of local other_skin  {
replace other_skin=1 if substr(`var',1,4)=="`k'"
}
*OTHER BREAST ANOMALIES
replace other_breast=1 if substr(`var',1,3)=="Q83"
*OTHER INTEGUMENT ANOMALIES
local other_integument Q840 Q841 Q842 Q843 Q844 Q846 Q848 Q849
foreach k of local other_integument {
replace other_integument=1 if substr(`var',1,4)=="`k'"
}
*OTHER SYNDROMES
local other_syndrome Q85 Q86 Q87
foreach k of local other_syndrome {
replace other_syndrome=1 if substr(`var',1,3)=="`k'"
}
*OTHER UNCLASSIFIED
local other_unclass Q890 Q891 Q892 Q893 Q894 Q897 Q898
foreach k of local other_unclass {
replace other_unclass=1 if substr(`var',1,4)=="`k'"
}
*OTHER CHROMOSOMAL TRANSLOCATIONS
local other_translocal Q952 Q953 Q954 Q955 Q958 Q959
foreach k of local other_translocal {
replace other_translocal=1 if substr(`var',1,4)=="`k'"
}
}

********************************************************************************
** Drop all but first episode showing each MCA
*drop rows that have no anomalies
gen total_mca_count=0
foreach var of varlist dig_arm_full-other_translocal {
	replace total_mca_count=total_mca_count+1 if `var'==1
}
drop if total_mca_count==0

*keep relevant variables only
drop diag adm* opertn cause gestat_baby total_mca_count birth_adm

*fill in other rows so we can create one row per child
foreach var of varlist dig_arm_full-other_translocal {
	bysort encrypted_hesid (`var'): replace `var'=1 if `var'[1]==1
		}
duplicates drop

********************************************************************************
*SOME ADDITIONAL CHANGES just for this study

*Make group that combines small intestine and duodenal atresia
gen dig_intestinal=.
replace dig_intestinal=1 if (dig_datresia==1 | dig_smatresia==1)

*Make severe cardiac group that excludes mitral valve anomalies
*This is in case you need it for sensitivity analysis 
gen heart_nomitral_severe=.
foreach var of varlist heart_anomreturn heart_aortatresia heart_coarc heart_hypoleft heart_ebstein heart_tricusp heart_pvatresia heart_fallot heart_avsd heart_single heart_transpos heart_doubleout heart_truncus{
	replace heart_nomitral_severe=1 if `var'==1
}

*Identify infants who have malformations ONLY within 1 system (i.e. isolated anomalies)
egen system = rownonmiss(nerv_all eye_all efn_all heart_all resp_all oro_all dig_all abdo_all urin_all genital_all limb_all chrom_all other_all)

local group nerv eye efn heart resp oro dig abdo urin genital limb chrom other
foreach k of local group {
gen iso_`k'=1 if system==1 & `k'_all==1
	}
drop system


foreach var of varlist dig_arm_full-other_translocal {
	replace `var'=. if `var'==0
}

*Create overall anomaly indicator (0 = no anomaly, 1 = at least one anomaly)
gen any_MCA=0
foreach var of varlist nerv_all eye_all efn_all heart_all resp_all oro_all dig_all abdo_all urin_all genital_all limb_all chrom_all other_all {
	replace any_MCA=1 if `var'==1 
		}

count	
		
		
********************************************************************************
** Save finalised cohort
save "$savefiles\MCA_flags.dta", replace