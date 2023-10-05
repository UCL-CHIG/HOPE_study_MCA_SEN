# School-recorded special educational needs provision in children with major congenital anomalies: a linked administrative records study of births in England, 2003-2013
## Aim of this study
Using a national cohort of births in England between 2003 and 2013, we aimed to describe patterns of survival to the start of compulsory education and frequencies of recorded SEN provision across children with and without a broad range of major congenital anomalies identified in hospital and mortality records.

   Obective 1. rates of survival up to the age 5 and 7 years
* the prevalence of recorded SEN provision between years 1 and 6 of those attending a state-funded school
* differences in the prevalence of recorded SEN provision in year 1 between children attending state-funded school before and after the 2014 SEN reforms 
## Scripts
This repository contains 5 scripts:
1. Sets up the birth cohort 
2. Defines major congenital anomalies
3. Survival analaysis (Objective 1)
4. Set ups the school cohort (linked health-education data)
5. Calculated the prevalence of recorded SEN provision and
The datasets and variables used are defined at the top of each do file
## Software
This code was developed using Stata v17. Analyses was conducted within the Office for National Statistics Secure Research Service (ONS SRS).
## Data sources
This work uses the following datasets within [Education and Child Health Insights from Linked Data (ECHILD)](https://www.ucl.ac.uk/child-health/research/population-policy-and-practice-research-and-teaching-department/cenb-clinical-20):  
| **Dataset** | **Common acronym** | **Data provider** | **Description** | **Additional details** |
| ------ | ------ | ------| ------ | ------ |
| Hospital episode statistics admitted patient care | HES APC | NHS England |  Episode level data on inpatient and day case discharges from English NHS hospitals and English NHS commissioned activity in the independent sector | [NHS England website](https://digital.nhs.uk/data-and-information/data-tools-and-services/data-services/hospital-episode-statistics) |
| National pupil database termly school census | NPD School Census | Department for Education | Pupil level information for students attending state-maintained educational settings in England | [Department for Education website](https://www.find-npd-data.education.gov.uk/datasets/775def61-ecd2-4e9a-8ef9-c168c4f51aac) |
| National pupil database alternative provision census | NPD AP census | Department for Education | Pupil level information for students attending alternative provision in England (Schools not maintained by an authority for whom the local authority is paying full tuition fees; including some independent schools, hospitals and non-maintained special schools) | [Department for Education website](https://www.gov.uk/guidance/alternative-provision-ap-census) |
| National pupil database pupil referral unit census | NPD PRU census | Department for Education | Pupil level information for students attending maintained pupil referral units, alternative provision academies and alternative provision free schools in England (2009/10-2012/13 only, then collected as part of the the NPD School Census) | [Department for Education website](https://www.find-npd-data.education.gov.uk/datasets/36479c85-5dff-42ec-bdf6-492773eccbae) |
| Get Information about Schools^ | GIAS | Department for Education | Opensoure information on all educational establishments in England | [Department for Education website](https://www.get-information-schools.service.gov.uk/) |

^Linked to ECHILD using each school’s unique reference number (URN)
## Data access
The ECHILD database is made available for free for approved research based in the UK, via the office for National Statistics (ONS) Secure Research Service. Enquiries to access the ECHILD database can be made by emailing ich.echild@ucl.ac.uk. Researchers will need to be approved and submit a successful application to the ECHILD Data Access Committee and ONS Research Accreditation Panel to access the data, with strict statistical disclosure controls of all outputs of analyses.
## Useful references
* Ford K, Peppa M, Zylbersztejn A, Curry JI, Gilbert R. Birth prevalence of anorectal malformations in England and 5-year survival: a national birth cohort study. Arch Dis Child. 2022;107: 758. doi:10.1136/archdischild-2021-323474
* Herbert A, Wijlaars L, Zylbersztejn A, Cromwell D, Hardelid P. Data Resource Profile: Hospital Episode Statistics Admitted Patient Care (HES APC). Int J Epidemiol. 2017;46: 1093–1093i. doi:10.1093/ije/dyx015
* Mc Grath-Lone L, Libuy N, Harron K, Jay MA, Wijlaars L, Etoori D, et al. Data Resource Profile: The Education and Child Health Insights from Linked Data (ECHILD) Database. Int J Epidemiol. 2022;51: 17–17f. doi:10.1093/ije/dyab149
* Peppa M, De Stavola BL, Loukogeorgakis S, Zylbersztejn A, Gilbert R, De Coppi P. Congenital diaphragmatic hernia subtypes: Comparing birth prevalence, occurrence by maternal age, and mortality in a national birth cohort. Paediatr Perinat Epidemiol. 2022;n/a. doi:10.1111/ppe.12939.
## Study authors
Maria Peppa wrote the Stata code, with edits and additions by Kate Lewis. Additional study authors: Bianca De Stavola, Pia Hardelid and Ruth Gilbert.
## Acknowledgements
We gratefully acknowledge all children and families whose de-identified data are used in this research. This work was carried out as part of the [HOPE study](https://www.ucl.ac.uk/child-health/research/population-policy-and-practice-research-and-teaching-department/cenb-clinical-30). We thank Ruth Blackburn, Matthew Jay, Matthew Lilliman, Vincent Nguyen, Farzan Ramzan, Anthony Stone and Ania Zylbersztejn for ECHILD database support.
## Funding
MP was funded by the National Institute for Health Research Great Ormond Street Hospital Biomedical Research Centre (NIHR GOSH-BRC). KML was funded by the National Institute for Health Research (NIHR) under its Programme Grants for Applied Research Programme (NIHR202025, The HOPE Study). RG is supported by a NIHR Senior Investigator award. ECHILD is supported by ADR UK (Administrative Data Research UK), an Economic and Social Research Council (part of UK Research and Innovation) programme (ES/V000977/1, ES/X003663/1, ES/X000427/1). The funders had no role in study design, data collection and analysis, decision to publish, or preparation of the manuscript.
