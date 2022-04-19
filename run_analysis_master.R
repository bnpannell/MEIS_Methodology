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
#source("src/file_check.R")
source("src/t1_error_check.R")
#source("src/t2_contracts_error_check.R")
#source("src/t3_contracts_error_check.R")
source("src/concatenate_usaspending.R")
source("src/split_usaspending.R")
source("src/aggregate_usaspending.R")

##Load API obtaining data scripts##
#source("src/obtain_usaspending.R")
#source("src/obtain_vet_census.R")

##Make VA Apportioning File##
#source("src/make_va_benefits_cw.R")

##Load in USASpending.gov Data##
cfile_name <- list.files(path = temp_path, pattern = paste0(c_label, ".+\\.csv"))
gfile_name <- list.files(path = temp_path, pattern = paste0(g_label, ".+\\.csv"))

##Filter USAspending data##
filter_usaspending(cfile_name, state, contract_columns, paste0(f_year, c_out_name))
filter_usaspending(gfile_name, state, grant_columns, paste0(f_year, g_out_name))

##Run error check on USAspending data##
##CONTRACTS DATA - read in CSV
contracts <- read.csv(file.path(temp_path, paste0(f_year, c_out_name)))

#Then read in the NAICS to NAICS crosswalk and rewrite the 2007 NAICS codes in the contracts dataframe by matching it to those in the 2007 to 2017 NAICS crosswalk dataframe
naics2naics <- read.xlsx(file.path(raw_path, naics_crosswalk))

for (i in 1:nrow(naics2naics)) {
  contracts$naics_code[grep(naics2naics$`2007_NAICS`[i],contracts$naics_code)] <- naics2naics$`2017_NAICS`[i]
}

#Now load in the NAICS to IMPLAN crosswalk and merge to contracts - this will assign contracts entries to their appropriate IMPLAN code based on 2012 and 2017 NAICS codes
naics2implan <- read.xlsx(file.path(raw_path, implan_crosswalk))
naics2implan <- naics2implan %>%
  rename(naics_code = "NaicsCode", implan_code = "Implan546Index") %>%
  distinct(naics_code, implan_code, .keep_all = TRUE)

contracts <- merge(contracts, naics2implan, by = ("naics_code"), all.x = TRUE, all.y = FALSE)

#Next, hard code any contract entries with a NAICS code starting with 236118 and 92 to IMPLAN codes 61 and 528
contracts$implan_code[startsWith(as.character(contracts$naics_code), "92")] <- "528"
contracts$implan_code[startsWith(as.character(contracts$naics_code), "236118")] <- "61"

#Define index for construction contracts entries with NAICS 237310 - they need to be specifically fixed before moving forward
constr_ind_237310 <- which(contracts$naics_code == "237310" & is.na(contracts$implan_code))

#Pull out construction contracts with NAICS code 237310 and apply their specific fix using 2 word searches with contract_check function
construction_contracts_237310 <- contracts[constr_ind_237310,]
contracts <- contracts[-constr_ind_237310,]

construction_contracts_test1 <- construction_contracts_237310[contract_check(patterns = repair_implan_60, data = construction_contracts_237310$award_description),]
construction_contracts_237310 <- construction_contracts_237310[!(contract_check(patterns = repair_implan_60, data = construction_contracts_237310$award_description)),]

construction_contracts_test2 <- construction_contracts_test1[contract_check(patterns = aircraft_implan_60, data = construction_contracts_test1$award_description),]
construction_contracts_test2$implan_code <- 60
construction_contracts_test1 <- construction_contracts_test1[!(contract_check(patterns = aircraft_implan_60, data = construction_contracts_test1$award_description)),]
construction_contracts_test1$implan_code <- 62

#Pull out the remaining construction contracts into its own dataframe, and drop from the main contracts dataframe
constr_ind <- which(substr(contracts$naics_code,1,2) == "23" & is.na(contracts$implan_code))
construction_contracts <- contracts[constr_ind,]
contracts <- contracts[-constr_ind,]

#Run the IMPLAN code 60 word search on the construction contracts - this will assign IMPLAN code 60 to contracts based on their award description
implan_60_contracts <- construction_contracts[contract_check(patterns = repair_implan_60, data = construction_contracts$award_description),]
implan_60_contracts$implan_code <- 60

construction_contracts <- construction_contracts[!(contract_check(patterns = repair_implan_60, data = construction_contracts$award_description)),]

#Bring back all these dataframes into the main contracts dataframe, and then drop the separate dataframes from environment
contracts_list <- list(contracts, construction_contracts_237310, construction_contracts_test1, construction_contracts_test2, implan_60_contracts, construction_contracts)
contracts <- Reduce(function(x,y) merge(x, y, all=TRUE), contracts_list)

rm(construction_contracts_237310, construction_contracts_test1, construction_contracts_test2, implan_60_contracts, construction_contracts, contracts_list)

#Fix issues with special characters in contracts' award description column, and then run the tier 1 check function on contracts
contracts$award_description <-gsub("/","", as.character(contracts$award_description))
contracts$award_description <-gsub(",","", as.character(contracts$award_description))
contracts$award_description <-gsub(r"(\\)","", as.character(contracts$award_description))
contracts$award_description <-gsub('"',"", as.character(contracts$award_description))

contracts$recipient_county_name[contracts$recipient_county_name == ""] <- NA

contracts <- t1_check(contracts, file.path(temp_path, paste0(f_year, "_cleaned_contracts.csv")))


##GRANTS DATA - read in CSV
grants <- read.csv(file.path(temp_path, paste0(f_year, g_out_name)))

#Now read in the business type to IMPLAN crosswalk - this will help us assign IMPLAN codes to grants
btype2implan <- read.csv(file.path(raw_path, paste0(btype_crosswalk)), fileEncoding="UTF-8-BOM")

#Prior to running crosswalk - pull out the VA direct payments/benefits data - this does not get matched with an IMPLAN code - and write into CSV file
va_benefits <- grants %>%
  filter(grants$assistance_type_code == 10 | grants$assistance_type_code == 6)
grants <- grants %>%
  filter(!(grants$assistance_type_code == 10 | grants$assistance_type_code == 6))

#start first crosswalk error check of grants data to IMPLAN codes

grants <- merge(grants, btype2implan, by = ("business_types_description"), all.x = TRUE, all.y = FALSE)

#Fix issues with special characters in grants' award description column, and then run the tier 1 check function on grants
grants$award_description <-gsub("/","", as.character(grants$award_description))
grants$award_description <-gsub(",","", as.character(grants$award_description))

grants <- t1_check(grants, file.path(temp_path, paste0(f_year, "_cleaned_grants.csv")))


##NOTE: DOUBLE CHECK THE ERRORS FOUND IN THE 2 PREVIOUS LINES OF CODE TO DETERMINE WHAT/HOW TO FIX VIA NEXT 2 LINES OF CODE

##Repair and weight contracts, grants, and direct payment data##
source("src/repair_and_weight_contracts.R")
source("src/repair_and_weight_grants.R")
source("src/repair_and_weight_direct_payments.R")

##Run concatenate function to combine usaspending contracts and grants data into one dataframe, and write into CSV##
concat_files <- concat_usaspending(pattern = paste0(year, "_cleaned.+\\.csv"))
write.csv(concat_files, file.path(temp_path, paste0(f_year, u_out_name)), row.names = FALSE) 

##Load in concatenated spending file from temp folder as variable for splitting out DOE from DOD/DHS/VA concatenated usaspending##
ufile_name <- list.files(path = file.path(temp_path), pattern = paste0(f_year, u_out_name))

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