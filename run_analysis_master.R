##Master code for running MEIS analysis up until IMPLAN##

##Clear Environment##
rm(list = ls(all.names = TRUE))

##Load Libraries##
library(dplyr)
library(httr)
library(jsonlite)
library(openxlsx)
library(readxl)
library(tidyverse)
library(censusapi)

##Load Parameters##
source("parameters.R")

##Load Function Scripts##
source("src/filter_usaspending.R")
source("src/contract_check.R")
source("src/t1_error_check.R")
source("src/na_district_repair.R")
source("src/concatenate_usaspending.R")
source("src/split_usaspending.R")
source("src/aggregate_usaspending.R")

##Load API obtaining data scripts##
#source("src/obtain_usaspending.R")
#source("src/census_api_call.R")

##Make VA Apportioning File##
#source("src/make_va_benefits_cw.R")

##Load in USASpending.gov Data##
cfile_name <- list.files(path = temp_path, pattern = paste0(c_label, ".+\\.csv"))
gfile_name <- list.files(path = temp_path, pattern = paste0(g_label, ".+\\.csv"))

##Filter USAspending data##
filter_usaspending(cfile_name, state, contract_columns, paste0(f_year, all_c_data))
filter_usaspending(gfile_name, state, grant_columns, paste0(f_year, all_g_data))

##Run error check on USAspending data##
#CONTRACTS
source("src/error_check_contracts.R")

#Run tier 1 check on contracts data to pull out cleaned contracts entries into file
contracts <- t1_check(contracts, file.path(temp_path, paste0(f_year, clean_c_data)), file.path(output_path, paste0(f_year, contract_errors)))

##STOP - BE SURE TO HAVE USED NO DISTRICT CONTRACT ERROR FILE IN OUTPUT TO CREATE DISTRICT CROSSWALK IN RAW DATA FOLDER##

#Run the na_district_repair function on the contracts dataframe, and then run the t1_check again
contracts <- na_district_repair(file.path(raw_path, paste0(contr_dist_crosswalk)), contracts)

contracts <- t1_check(contracts, file.path(temp_path, paste0(f_year, clean_c_data)), file.path(output_path, paste0(f_year, contract_errors)))
rm(contracts)


#GRANTS
source("src/error_check_grants.R")
grants <- t1_check(grants, file.path(temp_path, paste0(f_year, clean_g_data)), file.path(output_path, paste0(f_year, grant_errors)))
rm(grants)


##Repair and weight contracts, grants, and direct payment data##
#CONTRACTS
##FIRST GO THROUGH THE CONTRACT ERRORS FILE, AND MANUALLY FIX THROUGH IT. THEN RUN IT THROUGH T1 CHECK ONCE AGAIN.
#YOU CAN REPEAT THESE 2 LINES OF CODE OVER AND OVER AGAIN TO REPAIR ERRORS AS YOU LIKE
manual_fixes_c <- read.csv(file.path(output_path, paste0(f_year, contract_errors)))
rem_contracts <- t1_check(manual_fixes_c, file.path(temp_path, paste0(f_year, clean_c_data)), file.path(output_path, paste0(f_year, contract_errors)))

#Run script to fix and weigh contracts
source("src/repair_and_weight_contracts.R")


#GRANTS
##FIRST GO THROUGH THE GRANTS ERRORS FILE, AND MANUALLY FIX THROUGH IT. THEN RUN IT THROUGH T1 CHECK ONCE AGAIN.
#YOU CAN RUN THIS OVER AND OVER AGAIN TO REPAIR ERRORS AS YOU LIKE
manual_fixes_g <- read.csv(file.path(output_path, paste0(f_year, grant_errors)))
rem_grants <- t1_check(manual_fixes_g, file.path(temp_path, paste0(f_year, clean_g_data)), file.path(output_path, paste0(f_year, grant_errors)))


#VA DIRECT PAYMENTS
source("src/repair_and_weight_direct_payments.R")


##Run concatenate function to combine usaspending contracts and grants data into one dataframe, and write into CSV##
concat_files <- concat_usaspending(pattern = paste0(year, "_cleaned.+\\.csv"))
write.csv(concat_files, file.path(temp_path, paste0(f_year, u_out_name)), row.names = FALSE)

##Load in concatenated spending file from temp folder as variable for splitting out DOE from DOD/DHS/VA concatenated usaspending##
ufile_name <- list.files(path = temp_path, pattern = paste0(f_year, u_out_name))

usaspending <- split_usaspending(ufile_name, FALSE)
doespending <- split_usaspending(ufile_name, TRUE)

##Load an R script that filters the DOE spending to only national security-related data##
source("src/natsec_doe.R")

##Aggregate the DOD/DHS/VA usaspending, DOE usaspending, and VA benefits for statewide numbers## 
#this gives you all the spending info for the statewide usaspending IMPLAN activity sheet and the statewide DOE IMPLAN activity sheet, as well as the VA benefits at the state, county, and district level (for the Household Spending tab in the IMPLAN activity sheet)
statewide_aggregate(usaspending, (paste0(f_year, u_state_outname)))
statewide_aggregate(doe_ns_spending, (paste0(f_year, doe_state_outname)))

va_benefits_stateagg <- sum(va_benefits$spending)
va_benefits_countiesagg <- aggregate(va_benefits$spending, by=list(va_benefits$recipient_county_name), FUN=sum)
va_benefits_districtsagg <- aggregate(va_benefits$spending, by=list(va_benefits$congressional_district), FUN=sum)

##Load R script that provides employment calculations at statewide, county, and congressional district levels##
source("src/generate_employment_dataframe.R")

##Run for loop code to get IMPLAN activity sheets generated for counties and districts##
source("src/deprecated/DEPRECATED_create_implan_sheets.R")

##Don't forget to insert code to empty temp folder except for "/data/temp/placeholderfortemp.txt"##