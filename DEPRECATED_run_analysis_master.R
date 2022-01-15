##deprecated## 
## Clear Environment##
rm(list = ls(all.names = TRUE))

##Set Working Directory##

##Load Libraries##
library(httr)
library(jsonlite)
library(tidyverse)
library(readxl) 
library(dplyr)  
library(openxlsx) 


##Load Parameters##
source("src/parameters.R")


##Load Scripts to retrieve usaspending from API and filter the data down##
#source("src/obtain_usaspending.R")
source("src/filter_usaspending.R")
source("src/split_usaspending.R")

##Prepare to load data sources from temp folder as variable for filtering
cfile_name <- list.files(path = file.path(getwd(), "data", "temp"), pattern = paste0(c_label, ".+\\.csv"))
gfile_name <- list.files(path = file.path(getwd(), "data", "temp"), pattern = paste0(g_label, ".+\\.csv"))

##Filter files, save new output

filter_usaspending(cfile_name, state, doe_offices, contract_columns, paste0("DEPRECATED_", c_out_name))
filter_usaspending(gfile_name, state, doe_offices, grant_columns, paste0("DEPRECATED_", g_out_name))


## Run error check on data - including manual fixes mentioned in methodology
source("src/deprecated/deprecated_error_check_contracts.R")
source("src/deprecated/deprecated_error_check_grants.R")


## Run concatenate function to combine usaspending contracts and grants data, and write into CSV
source("src/concatenate_usaspending.R")
concatenated_usaspending <- concat_usaspending(pattern = paste0(year, "_DEPRECATED.+\\.csv"))

write.csv(concatenated_usaspending, file.path(getwd(), "data", "temp", paste0("DEPRECATED_", u_out_name)), row.names = FALSE) 


##Prepare to load data sources from temp folder as variable for splitting out DOE from DOD/DHS/VA usaspending
ufile_name <- list.files(path = file.path(getwd(), "data", "temp"), pattern = paste0("DEPRECATED_", u_out_name))

##Split out DOE data from concatenated usaspending data
usaspending <- split_usaspending(ufile_name, FALSE)
doespending <- split_usaspending(ufile_name, TRUE)


## Aggregate the DOD/DHS/VA usaspending, DOE usaspending, and VA benefits for statewide numbers - 
#this gives you all the spending info for the statewide usaspending IMPLAN activity sheet and statewide DOE IMPLAN activity sheet
source("src/aggregate_usaspending.R")

statewide_aggregate(usaspending, u_state_outname)
statewide_aggregate(doespending, doe_state_outname)

va_benefits_stateagg <- sum(va_benefits$federal_action_obligation)
va_benefits_countiesagg <- aggregate(va_benefits$federal_action_obligation, by=list(va_benefits$county), FUN=sum)
va_benefits_districtsagg <- aggregate(va_benefits$federal_action_obligation, by=list(va_benefits$county), FUN=sum)


## Define and/or read in employment data for purposes of the statewide, county, and district IMPLAN activity sheets
state_miliemp = 167761 + (57100 * 0.1825)
state_civilianemp =  (2526+(155282*.142)) + 34641 + (9807 + 9235 + 5612 + 38894)

state_doeemp = 358 * 0.550142248

county_emp <- read_excel(path = (file.path(getwd(), "data", "raw", "2021_employment_totals.xlsx")), sheet=1) %>%
  mutate(inverse_545 = (sum(county_emp$implan_545)) - county_emp$implan_545,
         inverse_546 = (sum(county_emp$implan_546)) - county_emp$implan_546) %>%
  select(-(total))

district_emp <- read_excel(path = (file.path(getwd(), "data", "raw", "2021_employment_totals.xlsx")), sheet=2) %>%
  mutate(inverse_545 = (sum(district_emp$implan_545)) - district_emp$implan_545,
         inverse_546 = (sum(district_emp$implan_546)) - district_emp$implan_546) %>%
  select(-(total))


## Run for loop code to get activity sheets generated for counties and districts
#source("src/deprecated/deprecated_create_implan_sheets.R")