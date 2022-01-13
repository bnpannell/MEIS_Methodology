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


##Prepare to load data sources from temp folder as variable for splitting out DOE from DOD + DHS + VA usaspending
ufile_name <- list.files(path = file.path(getwd(), "data", "temp"), pattern = paste0("DEPRECATED_", u_out_name))

##Split out DOE data from concatenated usaspending data
source("src/split_usaspending.R")

usaspending <- split_usaspending(ufile_name)
doespending <- split_doespending(ufile_name)

write.csv(usaspending, file.path(getwd(), "data", "temp", paste0("DEPRECATED_", u_out_name_final)), row.names = FALSE) 
write.csv(doespending, file.path(getwd(), "data", "temp", paste0("DEPRECATED_", doe_out_name)), row.names = FALSE) 


##Prepare to load data sources from temp folder as variable for aggregating for statewide, county, and district IMPLAN models
ufile_name_final <- list.files(path = file.path(getwd(), "data", "temp"), pattern = paste0("DEPRECATED_", u_out_name_final))
doe_file_name <- list.files(path = file.path(getwd(), "data", "temp"), pattern = paste0("DEPRECATED_", doe_out_name))
vabenefits_file_name <- list.files(path = file.path(getwd(), "data", "temp"), pattern = paste0(year, "_DEPRECIATED_cleaned_usaspending_va_benefits_data.csv"))


## Aggregate the DOD/DHS/VA usaspending, DOE usaspending, and VA benefits for statewide, county, and district numbers
source("src/aggregate_usaspending.R")

usaspending_state <- statewide_aggregate(ufile_name_final, state_agg, u_state_outname)
usaspending_counties
usaspending_districts

doespending_state
doespending_counties
doespending_districts

vabenefits_state
vabenefits_counties
vabenefits_districts