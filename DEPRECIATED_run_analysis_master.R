##DEPRECIATED## 
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

filter_usaspending(cfile_name, state, doe_offices, contract_columns, paste0("DEPRECIATED_", c_out_name))
filter_usaspending(gfile_name, state, doe_offices, grant_columns, paste0("DEPRECIATED_", g_out_name))


## Run error check on data - including manual fixes mentioned in methodology
source("src/depreciated/DEPRECIATED_error_check_contracts.R")
source("src/depreciated/DEPRECIATED_error_check_grants.R")


## Run concatenate function to combine usaspending contracts and grants data, and write into CSV
source("src/concatenate_usaspending.R")
concatenated_usaspending <- c_usaspending(pattern = paste0(year, "_DEPRECIATED.+\\.csv"))

write.csv(concatenated_usaspending, file.path(getwd(), "data", "temp", paste0("DEPRECATED_", u_out_name)), row.names = FALSE) 


##Prepare to load data sources from temp folder as variable for splitting out DOE from DOD/DHS/VA usaspending
ufile_name <- list.files(path = file.path(getwd(), "data", "temp"), pattern = paste0("DEPRECATED_", u_out_name))

##Split out DOE data from concatenated usaspending data
usaspending <- split_usaspending(ufile_name, FALSE)
doespending <- split_usaspending(ufile_name, TRUE)


## Aggregate the DOD/DHS/VA usaspending, DOE usaspending, and VA benefits for statewide, county, and district numbers
source("src/aggregate_usaspending.R")

statewide_aggregate(usaspending, u_state_outname)
statewide_aggregate(doespending, doe_state_outname)

va_benefits_stateagg <- sum(va_benefits$federal_action_obligation)
