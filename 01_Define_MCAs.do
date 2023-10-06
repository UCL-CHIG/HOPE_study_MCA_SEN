*****************************************************************************
*               DO FILE. DEFINE MCAS USING ICD-10 CODES 	   *
*****************************************************************************

* Code to apply to HES APC and ONS mortality records
* Mostly defined using the EUROCAT guidelines: see https://eu-rd-platform.jrc.ec.europa.eu/system/files/public/eurocat/Guide_1.5_Chapter_3.3.pdf 
* All diagnoses in HES APC admissions up to one year of age are used (i.e startage>7000)
* All causes of death in mortality records up to one year of age are used appended
* file with one row per child created

********************************************************************************
*                      NERVOUS SYSTEM ANOMALIES                                * 
*                                 Q00-07                                       *
*                     No exclusion of any 3-digit codes                        *
*   Codes Q0461 Q0782 Q0780 minor but ICD-10 not granular enough to exclude    *
*	Loop whole code once to add outcome by cause of death (and diag)	*
********************************************************************************

gen nerv_all=.
gen nerv_tube=.
gen nerv_anenceph=.
gen nerv_enceph=.
gen nerv_microceph=.
gen nerv_hydroceph=.
gen nerv_arhine=.
gen nerv_bifida=.

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


********************************************************************************
*			EAR, FACE AND NECK				   *
*                                 Q16-18                                       *
*	Excluding Q170-175 Q179 Q180-182 Q184-187 Q189             *
*            Code Q1880 minor but ICD-10 not granular enough to exclude        *
********************************************************************************

gen efn_all=.
gen efn_anotia=.

foreach var of varlist diag cause{
*Ear, face, neck
replace efn_all=1 if substr(`var',1,3)=="Q16"
local efn_all Q178 Q183 Q188
foreach k of local efn_all{
replace efn_all=1 if substr(`var',1,4)=="`k'"
}
*Anotia
replace efn_anotia=1 if substr(`var',1,4)=="Q160"


********************************************************************************
*				  HEART                                        *
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


********************************************************************************
*				RESPIRATORY                                    *
*                             Q300 Q32-34                                      *
*                     Exclude  Q320 Q322 Q331 Q336                             *
*	     Code Q3300 minor but ICD-10 not granular enough to exclude        *
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


********************************************************************************
*				  OROFACIAL                                    *
*  				Q35-37                                         *
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


********************************************************************************
*** Anorectal malformations from Ford et al. (2022) ***
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
*** Congenital diaphragmatic hernia FROM Peppa et al. (2022) ***
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
* DIGESTIVE (includes anorectal malformations and congenital diaphragmatic hernia ) *
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

* add in ARM and CDH (defined, seperately, above) to overall indicator
replace dig_all=1 if dig_cdh_full==1 | dig_arm_full==1


********************************************************************************
*			ABDOMINAL WALL DEFECTS                                 *
*                           Q792 Q793 Q795                                     *
*			 No 3-digit exclusions                                 *
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


********************************************************************************
*	  			URINARY                                        *
*				Q60-64 Q794                                    *
*        		 Exclude Q610 Q627 Q633                                *
********************************************************************************

gen urin_all=.
gen urin_biagenesis=.
gen urin_hydronephrosis=.
gen urin_exstrophy=.
gen urin_prune=.

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


********************************************************************************
*		 		 GENITAL                                       *
*				Q50-52 Q54-56                                  *
*		Exclude Q501-502 Q505 Q523 Q525 Q527 Q544                	*
*Codes Q5010 Q5011 Q5520 Q5521 minor but ICD-10 not granular enough to exclude *
********************************************************************************

gen genital_all=.
gen genital_hypospadia=.
gen genital_indsex=.

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


********************************************************************************
*				LIMB                           		       *
*				Q65-74                                	       *
*          Exclude Q653-659 Q661-669 Q670-678 Q680 Q683-685                    *
*     Codes Q6810 Q6821 Q7400 minor but ICD-10 to granular to exclude          *
********************************************************************************      
 
gen limb_all=.
gen limb_reduct=.
gen limb_clubfoot=.
gen limb_hip=.
gen limb_polydact=.
gen limb_syndact=.

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


********************************************************************************
*				CHROMOSOMAL                                    *
*                              Q90-93 Q96-99                                   *
********************************************************************************

gen chrom_all=.
gen chrom_21=.
gen chrom_18=.
gen chrom_13=.
gen chrom_turn=.
gen chrom_kline=.

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
** Drop all but first episode showing each MCA for each child
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
*# SAVE FILE
save "MCA_flags.dta", replace
