*****************************************************************************
*                       Look at the coding of MCAs over time           		*
*****************************************************************************

*get final pupil ids
use "$savefiles\sub_cohort_all_school_years.dta", clear
keep pupilmatchingrefanonymous
duplicates drop
save "$savefiles\cohort_ids", replace

*open main file: these numbers are following some exclusions but pre linkage
use "$savefiles\full_cohort.dta", clear

gen year=year(dob)

*change year to academic year
replace year = year-1 if month(dob)<9

gen count=1

*flag linked children
merge m:1 pupilmatchingrefanonymous using "$savefiles\cohort_ids.dta"
gen linked_children=1 if _merge==3
replace linked_children=0 if _merge==1
drop _merge
codebook encrypted_hesid

gen no_MCA=0
replace no_MCA=1 if any_MCA!=1

collapse (sum) any_MCA no_MCA nerv_all iso_nerv nerv_microceph nerv_hydroceph nerv_bifida eye_all iso_eye eye_anomicro eye_cataract eye_glaucoma efn_all iso_efn heart_all iso_heart heart_severe resp_all iso_resp resp_choanal oro_all iso_oro oro_lip oro_pal oro_both dig_all iso_dig dig_oatresia dig_intestinal dig_hirsch dig_batresia dig_cdh_full dig_arm_full abdo_all iso_abdo abdo_omphal abdo_gastro urin_all iso_urin urin_exstrophy genital_all iso_genital genital_hypospadia genital_indsex limb_all iso_limb limb_reduct chrom_all iso_chrom chrom_21 chrom_turn count, by(year linked_children)

local MCAs any_MCA no_MCA nerv_all iso_nerv nerv_microceph nerv_hydroceph nerv_bifida eye_all iso_eye eye_anomicro eye_cataract eye_glaucoma efn_all iso_efn heart_all iso_heart heart_severe resp_all iso_resp resp_choanal oro_all iso_oro oro_lip oro_pal oro_both dig_all iso_dig dig_oatresia dig_intestinal dig_hirsch dig_batresia dig_cdh_full dig_arm_full abdo_all iso_abdo abdo_omphal abdo_gastro urin_all iso_urin urin_exstrophy genital_all iso_genital genital_hypospadia genital_indsex limb_all iso_limb limb_reduct chrom_all iso_chrom chrom_21 chrom_turn

bysort year (linked_children): replace count=count+count[_n+1] if linked_children==0 // changing count for the non linked children

foreach var of local MCAs {
	bysort year (linked_children): replace `var'=`var'+`var'[_n+1] if linked_children==0 //changing unlinked numbers to total rather than unlinked only
	gen `var'_prev=`var'*100/count
	}

*bivariate graphs
foreach var of local MCAs {
	*two scatter `var'_prev year if linked_children==0, by(linked_children) yscale(range(0,.)) 
	two scatter `var'_prev year if linked_children==0, yscale(range(0,.)) || scatter `var'_prev year if linked_children==1, yscale(range(0,.))
	graph save "Graph" "$results\\timeseries_graphs\\`var'_prev_linked.gph", replace
}

*bivariate graphs; average and isloated in one graph
local MCAs_subgroups nerv eye efn heart resp oro dig abdo urin genital limb chrom
foreach var of local MCAs_subgroups {
	twoway scatter `var'_all_prev year, yscale(range(0,.)) || scatter iso_`var'_prev year, yscale(range(0,.))
	graph save "Graph" "$results\\timeseries_graphs\\`var'_prev_combo_linked.gph"
}

*look at main groups all together - average
graph combine "$results\\timeseries_graphs\\nerv_all_prev_linked.gph" "$results\\timeseries_graphs\\eye_all_prev_linked.gph" "$results\\timeseries_graphs\\efn_all_prev_linked.gph" "$results\\timeseries_graphs\\heart_all_prev_linked.gph" "$results\\timeseries_graphs\\resp_all_prev_linked.gph" "$results\\timeseries_graphs\\oro_all_prev_linked.gph" "$results\\timeseries_graphs\\dig_all_prev_linked.gph" "$results\\timeseries_graphs\\abdo_all_prev_linked.gph"  "$results\\timeseries_graphs\\urin_all_prev_linked.gph" "$results\\timeseries_graphs\\genital_all_prev_linked.gph" "$results\\timeseries_graphs\\limb_all_prev_linked.gph" "$results\\timeseries_graphs\\chrom_all_prev_linked.gph" 

*look at main groups all together - isolated
graph combine "$results\\timeseries_graphs\\iso_nerv_prev_linked.gph" "$results\\timeseries_graphs\\iso_eye_prev_linked.gph" "$results\\timeseries_graphs\\iso_efn_prev_linked.gph" "$results\\timeseries_graphs\\iso_heart_prev_linked.gph" "$results\\timeseries_graphs\\iso_resp_prev_linked.gph" "$results\\timeseries_graphs\\iso_oro_prev_linked.gph" "$results\\timeseries_graphs\\iso_dig_prev_linked.gph" "$results\\timeseries_graphs\\iso_abdo_prev_linked.gph"  "$results\\timeseries_graphs\\iso_urin_prev_linked.gph" "$results\\timeseries_graphs\\iso_genital_prev_linked.gph" "$results\\timeseries_graphs\\iso_limb_prev_linked.gph" "$results\\timeseries_graphs\\iso_chrom_prev_linked.gph"

*look at main groups all together - average and isolated
graph combine "$results\\timeseries_graphs\\nerv_prev_combo_linked.gph" "$results\\timeseries_graphs\\eye_prev_combo_linked.gph" "$results\\timeseries_graphs\\efn_prev_combo_linked.gph" "$results\\timeseries_graphs\\heart_prev_combo_linked.gph" "$results\\timeseries_graphs\\resp_prev_combo_linked.gph" "$results\\timeseries_graphs\\oro_prev_combo_linked.gph" "$results\\timeseries_graphs\\dig_prev_combo_linked.gph" "$results\\timeseries_graphs\\abdo_prev_combo_linked.gph"  "$results\\timeseries_graphs\\urin_prev_combo_linked.gph" "$results\\timeseries_graphs\\genital_prev_combo_linked.gph" "$results\\timeseries_graphs\\limb_prev_combo_linked.gph" "$results\\timeseries_graphs\\chrom_prev_combo_linked.gph"

*look at groups that have been validated
graph combine "$results\\timeseries_graphs\\dig_cdh_full_prev_linked.gph" "$results\\timeseries_graphs\\dig_cdh_simple_prev_linked.gph" "$results\\timeseries_graphs\\dig_arm_full_prev_linked.gph" "$results\\timeseries_graphs\\chrom_21_prev.gph"
