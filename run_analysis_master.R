## Master code for running MEIS analysis up until IMPLAN##

## Clear Environment##
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
source("src/concatenate_usaspending.R")
source("src/split_usaspending.R")
source("src/aggregate_usaspending.R")

##Load API obtaining data scripts##
#source("src/obtain_usaspending.R")
#source("src/obtain_vet_census.R")

##Make VA Apportioning File##
#source("src/make_va_benefits_cw.R")

##Load in USASpending.gov Data##
cfile_name <- list.files(path = file.path(getwd(), "data", "temp"), pattern = paste0(c_label, ".+\\.csv"))
gfile_name <- list.files(path = file.path(getwd(), "data", "temp"), pattern = paste0(g_label, ".+\\.csv"))

##Filter data##
filter_usaspending(cfile_name, state, contract_columns, paste0(f_year, c_out_name))
filter_usaspending(gfile_name, state, grant_columns, paste0(f_year, g_out_name))

##Run error check on data##
source("src/error_check_contracts.R")
source("src/error_check_grants.R")

##NOTE: DOUBLE CHECK THE ERRORS FOUND IN THE 2 PREVIOUS LINES OF CODE TO DETERMINE WHAT/HOW TO FIX VIA NEXT 2 LINES OF CODE

##Repair and weight contracts, grants, and direct payment data##
source("src/repair_and_weight_contracts.R")
source("src/repair_and_weight_grants.R")
source("src/repair_and_weight_direct_payments.R")

##Run concatenate function to combine usaspending contracts and grants data into one dataframe, and write into CSV##
concat_files <- concat_usaspending(pattern = paste0(year, "_cleaned.+\\.csv"))
write.csv(concat_files, file.path(getwd(), "data", "temp", paste0(f_year, u_out_name)), row.names = FALSE) 

##Load in concatenated spending file from temp folder as variable for splitting out DOE from DOD/DHS/VA concatenated usaspending##
ufile_name <- list.files(path = file.path(getwd(), "data", "temp"), pattern = paste0(f_year, u_out_name))

usaspending <- split_usaspending(ufile_name, FALSE)
doespending <- split_usaspending(ufile_name, TRUE)

##Load an R script that filters the DOE spending to only national security-related data##
source("src/natsec_doe.R")

##Aggregate the DOD/DHS/VA usaspending, DOE usaspending, and VA benefits for statewide numbers## 
#this gives you all the spending info for the statewide usaspending IMPLAN activity sheet and the statewide DOE IMPLAN activity sheet, as well as the VA benefits at the state, county, and district level (for the Household Spending tab in the IMPLAN activity sheet)
statewide_aggregate(usaspending, (paste0(f_year, u_state_outname)))
statewide_aggregate(doe_ns_spending, (paste0(f_year, doe_state_outname)))

va_benefits_stateagg <- sum(va_benefits$federal_action_obligation)
va_benefits_countiesagg <- aggregate(va_benefits$federal_action_obligation, by=list(va_benefits$recipient_county_name), FUN=sum)
va_benefits_districtsagg <- aggregate(va_benefits$federal_action_obligation, by=list(va_benefits$recipient_congressional_district), FUN=sum)

##Load R script that provides employment calculations at statewide, county, and congressional district levels##
source("src/generate_employment_dataframe.R")

##Run for loop code to get IMPLAN activity sheets generated for counties and districts##
source("src/deprecated/DEPRECATED_create_implan_sheets.R")

##Don't forget to insert code to empty temp folder except for "/data/temp/placeholderfortemp.txt"##