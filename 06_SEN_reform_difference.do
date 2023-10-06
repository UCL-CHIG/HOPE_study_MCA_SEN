******************************************************************************
* COMPARISON OF SEN PROVISION IN YEAR 1, BY BIRTH YEAR GROUPS
******************************************************************************
use "sub_cohort_all_school_years.dta", clear
label define sen 0 "None" 1 "SEN support" 2 "EHCP" 3 "Specialist school" ,replace
label val sen_record sen
tab sen_record, m

keep if schoolyear_final==1
drop schoolyear_final

bysort pupilmatchingrefanonymous: egen sen_max=max(sen_record)

count

gen reform_period=1
replace reform_period=0 if birthyr>=2008

*count sen across reform periods
preserve
keep if reform_period==1
collapse (sum) no_MCA any_MCA nerv_all iso_nerv nerv_microceph nerv_hydroceph nerv_bifida eye_all iso_eye eye_anomicro eye_cataract eye_glaucoma efn_all iso_efn heart_all iso_heart heart_severe resp_all iso_resp resp_choanal oro_all iso_oro oro_lip oro_pal oro_both dig_all iso_dig dig_oatresia dig_intestinal dig_hirsch dig_batresia dig_cdh_full dig_arm_full abdo_all iso_abdo abdo_omphal abdo_gastro urin_all iso_urin urin_exstrophy genital_all iso_genital genital_hypospadia genital_indsex limb_all iso_limb limb_reduct chrom_all iso_chrom chrom_21 chrom_turn, by(sen_record)
export excel using "$results\Table 3_raw_99.xlsx", firstrow(variables) sheet(pre_reform) replace
restore

preserve
keep if reform_period==0
collapse (sum) no_MCA any_MCA nerv_all iso_nerv nerv_microceph nerv_hydroceph nerv_bifida eye_all iso_eye eye_anomicro eye_cataract eye_glaucoma efn_all iso_efn heart_all iso_heart heart_severe resp_all iso_resp resp_choanal oro_all iso_oro oro_lip oro_pal oro_both dig_all iso_dig dig_oatresia dig_intestinal dig_hirsch dig_batresia dig_cdh_full dig_arm_full abdo_all iso_abdo abdo_omphal abdo_gastro urin_all iso_urin urin_exstrophy genital_all iso_genital genital_hypospadia genital_indsex limb_all iso_limb limb_reduct chrom_all iso_chrom chrom_21 chrom_turn, by(sen_record)
export excel using "$results\Table 3_raw_99.xlsx", firstrow(variables) sheet(post_reform) 
restore

*** risk difference - Any SEN *** 
preserve
gen var_case=0 
replace var_case=1 if sen_record>0

*create table for No MCA group first
gen count_all=_n // create counter to put results on new row for each MCA group
gen count=1 if _n<3 
tab count
local N = r(N)
cs var_case reform_period if no_MCA==1, level(99)
putexcel set "Dif_table_99.xlsx", sheet(rd_anySEN) modify
       putexcel A1 = "MCA_group"
	   putexcel B1 = "r(afe)"
	   putexcel C1 = "r(lb_afe)"
	   putexcel D1 = "r(ub_afe)"
	   putexcel E1 = "r(rr)"
	   putexcel F1 = "r(lb_rr)"
	   putexcel G1 = "r(ub_rr)"
	   putexcel H1 = "r(rd)"
	   putexcel I1 = "r(lb_rd)"
	   putexcel J1 = "r(ub_rd)"
	   putexcel K1 = "r(p)"
	   putexcel L1 = "r(chi2)"
	   putexcel M1 = "r(afp)" 
	foreach k of local N{
	   putexcel A`k' = "no_MCA"   
       putexcel B`k' = (`r(afe)'*100), nformat(number_d2)
	   putexcel C`k' = (`r(lb_afe)'*100), nformat(number_d2)
	   putexcel D`k' = (`r(ub_afe)'*100), nformat(number_d2)
	   putexcel E`k' = (`r(rr)'), nformat(number_d2)
	   putexcel F`k' = (`r(lb_rr)'), nformat(number_d2)
	   putexcel G`k' = (`r(ub_rr)'), nformat(number_d2)
	   putexcel H`k' = (`r(rd)'*100), nformat(number_d2)
	   putexcel I`k' = (`r(lb_rd)'*100), nformat(number_d2)
	   putexcel J`k' = (`r(ub_rd)'*100), nformat(number_d2)
	   putexcel K`k' = (`r(p)'*100), nformat(number_d2)
	   putexcel L`k' = (`r(chi2)'*100), nformat(number_d2)
	   putexcel M`k' = (`r(afp)'*100), nformat(number_d2)
	}

foreach var of varlist any_MCA nerv_all iso_nerv nerv_microceph nerv_hydroceph nerv_bifida eye_all iso_eye eye_anomicro eye_cataract eye_glaucoma efn_all iso_efn heart_all iso_heart heart_severe resp_all iso_resp resp_choanal oro_all iso_oro oro_lip oro_pal oro_both dig_all iso_dig dig_oatresia dig_intestinal dig_hirsch dig_batresia dig_cdh_full dig_arm_full abdo_all iso_abdo abdo_omphal abdo_gastro urin_all iso_urin urin_exstrophy genital_all iso_genital genital_hypospadia genital_indsex limb_all iso_limb limb_reduct chrom_all iso_chrom chrom_21 chrom_turn{
	
   tab count
   local N = r(N)
   foreach k of local N{
   replace count=1 if count_all==`k'+1
   }
	tab count
	local N = r(N)
	cs var_case reform_period if `var'==1, level(99)
	putexcel set "Dif_table_99.xlsx", sheet(rd_anySEN) modify
	
	   foreach k of local N{
	   putexcel A`k' = "`var'"   
       putexcel B`k' = (`r(afe)'*100), nformat(number_d2)
	   putexcel C`k' = (`r(lb_afe)'*100), nformat(number_d2)
	   putexcel D`k' = (`r(ub_afe)'*100), nformat(number_d2)
	   putexcel E`k' = (`r(rr)'), nformat(number_d2)
	   putexcel F`k' = (`r(lb_rr)'), nformat(number_d2)
	   putexcel G`k' = (`r(ub_rr)'), nformat(number_d2)
	   putexcel H`k' = (`r(rd)'*100), nformat(number_d2)
	   putexcel I`k' = (`r(lb_rd)'*100), nformat(number_d2)
	   putexcel J`k' = (`r(ub_rd)'*100), nformat(number_d2)
	   putexcel K`k' = (`r(p)'*100), nformat(number_d2)
	   putexcel L`k' = (`r(chi2)'*100), nformat(number_d2)
	   putexcel M`k' = (`r(afp)'*100), nformat(number_d2)
}
}
restore

*** risk difference - Lower level SEN*** 
preserve
gen var_case=0 
replace var_case=1 if sen_record==1

*create table for No MCA group first
gen count_all=_n // create counter to put results on new row for each MCA group
gen count=1 if _n<3 
tab count
local N = r(N)
cs var_case reform_period if no_MCA==1, level(99)
putexcel set "Dif_table_99.xlsx", sheet(rd_lowSEN) modify
       putexcel A1 = "MCA_group"
	   putexcel B1 = "r(afe)"
	   putexcel C1 = "r(lb_afe)"
	   putexcel D1 = "r(ub_afe)"
	   putexcel E1 = "r(rr)"
	   putexcel F1 = "r(lb_rr)"
	   putexcel G1 = "r(ub_rr)"
	   putexcel H1 = "r(rd)"
	   putexcel I1 = "r(lb_rd)"
	   putexcel J1 = "r(ub_rd)"
	   putexcel K1 = "r(p)"
	   putexcel L1 = "r(chi2)"
	   putexcel M1 = "r(afp)" 
	foreach k of local N{
	   putexcel A`k' = "no_MCA"   
       putexcel B`k' = (`r(afe)'*100), nformat(number_d2)
	   putexcel C`k' = (`r(lb_afe)'*100), nformat(number_d2)
	   putexcel D`k' = (`r(ub_afe)'*100), nformat(number_d2)
	   putexcel E`k' = (`r(rr)'), nformat(number_d2)
	   putexcel F`k' = (`r(lb_rr)'), nformat(number_d2)
	   putexcel G`k' = (`r(ub_rr)'), nformat(number_d2)
	   putexcel H`k' = (`r(rd)'*100), nformat(number_d2)
	   putexcel I`k' = (`r(lb_rd)'*100), nformat(number_d2)
	   putexcel J`k' = (`r(ub_rd)'*100), nformat(number_d2)
	   putexcel K`k' = (`r(p)'*100), nformat(number_d2)
	   putexcel L`k' = (`r(chi2)'*100), nformat(number_d2)
	   putexcel M`k' = (`r(afp)'*100), nformat(number_d2)
}

foreach var of varlist any_MCA nerv_all iso_nerv nerv_microceph nerv_hydroceph nerv_bifida eye_all iso_eye eye_anomicro eye_cataract eye_glaucoma efn_all iso_efn heart_all iso_heart heart_severe resp_all iso_resp resp_choanal oro_all iso_oro oro_lip oro_pal oro_both dig_all iso_dig dig_oatresia dig_intestinal dig_hirsch dig_batresia dig_cdh_full dig_arm_full abdo_all iso_abdo abdo_omphal abdo_gastro urin_all iso_urin urin_exstrophy genital_all iso_genital genital_hypospadia genital_indsex limb_all iso_limb limb_reduct chrom_all iso_chrom chrom_21 chrom_turn{
	
   tab count
   local N = r(N)
   foreach k of local N{
   replace count=1 if count_all==`k'+1
   }
	tab count
	local N = r(N)
	cs var_case reform_period if `var'==1, level(99)
	putexcel set "Dif_table_99.xlsx", sheet(rd_lowSEN) modify
	
	   foreach k of local N{
	   putexcel A`k' = "`var'"   
       putexcel B`k' = (`r(afe)'*100), nformat(number_d2)
	   putexcel C`k' = (`r(lb_afe)'*100), nformat(number_d2)
	   putexcel D`k' = (`r(ub_afe)'*100), nformat(number_d2)
	   putexcel E`k' = (`r(rr)'), nformat(number_d2)
	   putexcel F`k' = (`r(lb_rr)'), nformat(number_d2)
	   putexcel G`k' = (`r(ub_rr)'), nformat(number_d2)
	   putexcel H`k' = (`r(rd)'*100), nformat(number_d2)
	   putexcel I`k' = (`r(lb_rd)'*100), nformat(number_d2)
	   putexcel J`k' = (`r(ub_rd)'*100), nformat(number_d2)
	   putexcel K`k' = (`r(p)'*100), nformat(number_d2)
	   putexcel L`k' = (`r(chi2)'*100), nformat(number_d2)
	   putexcel M`k' = (`r(afp)'*100), nformat(number_d2)
}
}
restore

*** risk difference - Higher level SEN, mainstream school *** 
*** 99% confidence intervals
preserve
gen var_case=0 
replace var_case=1 if sen_record==2

*create table for No MCA group first
gen count_all=_n // create counter to put results on new row for each MCA group
gen count=1 if _n<3 
tab count
local N = r(N)
cs var_case reform_period if no_MCA==1, level(99)
putexcel set "Dif_table_99.xlsx", sheet(rd_highSEN) modify
       putexcel A1 = "MCA_group"
	   putexcel B1 = "r(afe)"
	   putexcel C1 = "r(lb_afe)"
	   putexcel D1 = "r(ub_afe)"
	   putexcel E1 = "r(rr)"
	   putexcel F1 = "r(lb_rr)"
	   putexcel G1 = "r(ub_rr)"
	   putexcel H1 = "r(rd)"
	   putexcel I1 = "r(lb_rd)"
	   putexcel J1 = "r(ub_rd)"
	   putexcel K1 = "r(p)"
	   putexcel L1 = "r(chi2)"
	   putexcel M1 = "r(afp)" 
	foreach k of local N{
	   putexcel A`k' = "no_MCA"   
       putexcel B`k' = (`r(afe)'*100), nformat(number_d2)
	   putexcel C`k' = (`r(lb_afe)'*100), nformat(number_d2)
	   putexcel D`k' = (`r(ub_afe)'*100), nformat(number_d2)
	   putexcel E`k' = (`r(rr)'), nformat(number_d2)
	   putexcel F`k' = (`r(lb_rr)'), nformat(number_d2)
	   putexcel G`k' = (`r(ub_rr)'), nformat(number_d2)
	   putexcel H`k' = (`r(rd)'*100), nformat(number_d2)
	   putexcel I`k' = (`r(lb_rd)'*100), nformat(number_d2)
	   putexcel J`k' = (`r(ub_rd)'*100), nformat(number_d2)
	   putexcel K`k' = (`r(p)'*100), nformat(number_d2)
	   putexcel L`k' = (`r(chi2)'*100), nformat(number_d2)
	   putexcel M`k' = (`r(afp)'*100), nformat(number_d2)
}

foreach var of varlist any_MCA nerv_all iso_nerv nerv_microceph nerv_hydroceph nerv_bifida eye_all iso_eye eye_anomicro eye_cataract eye_glaucoma efn_all iso_efn heart_all iso_heart heart_severe resp_all iso_resp resp_choanal oro_all iso_oro oro_lip oro_pal oro_both dig_all iso_dig dig_oatresia dig_intestinal dig_hirsch dig_batresia dig_cdh_full dig_arm_full abdo_all iso_abdo abdo_omphal abdo_gastro urin_all iso_urin urin_exstrophy genital_all iso_genital genital_hypospadia genital_indsex limb_all iso_limb limb_reduct chrom_all iso_chrom chrom_21 chrom_turn{
	
   tab count
   local N = r(N)
   foreach k of local N{
   replace count=1 if count_all==`k'+1
   }
	tab count
	local N = r(N)
	cs var_case reform_period if `var'==1, level(99)
	putexcel set "Dif_table_99.xlsx", sheet(rd_highSEN) modify
	
	   foreach k of local N{
	   putexcel A`k' = "`var'"   
       putexcel B`k' = (`r(afe)'*100), nformat(number_d2)
	   putexcel C`k' = (`r(lb_afe)'*100), nformat(number_d2)
	   putexcel D`k' = (`r(ub_afe)'*100), nformat(number_d2)
	   putexcel E`k' = (`r(rr)'), nformat(number_d2)
	   putexcel F`k' = (`r(lb_rr)'), nformat(number_d2)
	   putexcel G`k' = (`r(ub_rr)'), nformat(number_d2)
	   putexcel H`k' = (`r(rd)'*100), nformat(number_d2)
	   putexcel I`k' = (`r(lb_rd)'*100), nformat(number_d2)
	   putexcel J`k' = (`r(ub_rd)'*100), nformat(number_d2)
	   putexcel K`k' = (`r(p)'*100), nformat(number_d2)
	   putexcel L`k' = (`r(chi2)'*100), nformat(number_d2)
	   putexcel M`k' = (`r(afp)'*100), nformat(number_d2)
}
}
restore

*** risk difference - Higher level SEN, specialised school*** 
preserve
gen var_case=0 
replace var_case=1 if sen_record==3

*create table for No MCA group first
gen count_all=_n // create counter to put results on new row for each MCA group
gen count=1 if _n<3 
tab count
local N = r(N)
cs var_case reform_period if no_MCA==1, level(99)
putexcel set "Dif_table_99.xlsx", sheet(rd_highSEN_spec) modify
       putexcel A1 = "MCA_group"
	   putexcel B1 = "r(afe)"
	   putexcel C1 = "r(lb_afe)"
	   putexcel D1 = "r(ub_afe)"
	   putexcel E1 = "r(rr)"
	   putexcel F1 = "r(lb_rr)"
	   putexcel G1 = "r(ub_rr)"
	   putexcel H1 = "r(rd)"
	   putexcel I1 = "r(lb_rd)"
	   putexcel J1 = "r(ub_rd)"
	   putexcel K1 = "r(p)"
	   putexcel L1 = "r(chi2)"
	   putexcel M1 = "r(afp)" 
	foreach k of local N{
	   putexcel A`k' = "no_MCA"   
       putexcel B`k' = (`r(afe)'*100), nformat(number_d2)
	   putexcel C`k' = (`r(lb_afe)'*100), nformat(number_d2)
	   putexcel D`k' = (`r(ub_afe)'*100), nformat(number_d2)
	   putexcel E`k' = (`r(rr)'), nformat(number_d2)
	   putexcel F`k' = (`r(lb_rr)'), nformat(number_d2)
	   putexcel G`k' = (`r(ub_rr)'), nformat(number_d2)
	   putexcel H`k' = (`r(rd)'*100), nformat(number_d2)
	   putexcel I`k' = (`r(lb_rd)'*100), nformat(number_d2)
	   putexcel J`k' = (`r(ub_rd)'*100), nformat(number_d2)
	   putexcel K`k' = (`r(p)'*100), nformat(number_d2)
	   putexcel L`k' = (`r(chi2)'*100), nformat(number_d2)
	   putexcel M`k' = (`r(afp)'*100), nformat(number_d2)
}

foreach var of varlist any_MCA nerv_all iso_nerv nerv_microceph nerv_hydroceph nerv_bifida eye_all iso_eye eye_anomicro eye_cataract eye_glaucoma efn_all iso_efn heart_all iso_heart heart_severe resp_all iso_resp resp_choanal oro_all iso_oro oro_lip oro_pal oro_both dig_all iso_dig dig_oatresia dig_intestinal dig_hirsch dig_batresia dig_cdh_full dig_arm_full abdo_all iso_abdo abdo_omphal abdo_gastro urin_all iso_urin urin_exstrophy genital_all iso_genital genital_hypospadia genital_indsex limb_all iso_limb limb_reduct chrom_all iso_chrom chrom_21 chrom_turn{
	
   tab count
   local N = r(N)
   foreach k of local N{
   replace count=1 if count_all==`k'+1
   }
	tab count
	local N = r(N)
	cs var_case reform_period if `var'==1, level(99)
	putexcel set "Dif_table_99.xlsx", sheet(rd_highSEN_spec) modify
	
	   foreach k of local N{
	   putexcel A`k' = "`var'"   
       putexcel B`k' = (`r(afe)'*100), nformat(number_d2)
	   putexcel C`k' = (`r(lb_afe)'*100), nformat(number_d2)
	   putexcel D`k' = (`r(ub_afe)'*100), nformat(number_d2)
	   putexcel E`k' = (`r(rr)'), nformat(number_d2)
	   putexcel F`k' = (`r(lb_rr)'), nformat(number_d2)
	   putexcel G`k' = (`r(ub_rr)'), nformat(number_d2)
	   putexcel H`k' = (`r(rd)'*100), nformat(number_d2)
	   putexcel I`k' = (`r(lb_rd)'*100), nformat(number_d2)
	   putexcel J`k' = (`r(ub_rd)'*100), nformat(number_d2)
	   putexcel K`k' = (`r(p)'*100), nformat(number_d2)
	   putexcel L`k' = (`r(chi2)'*100), nformat(number_d2)
	   putexcel M`k' = (`r(afp)'*100), nformat(number_d2)
}
}
restore


********************************************************************************
*time series of SEN by MCA/Non-MCA
*ALL ELIGIBLE, Year 1 only
******************************************************************************
*Reformat SEN data for final tables
use "sub_cohort_all_school_years.dta", clear
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
