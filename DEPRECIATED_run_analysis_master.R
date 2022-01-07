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

##Load Scripts##
#source("src/obtain_usaspending.R")
source("src/filter_usaspending.R")

##Prepare to Load Data Sources from Temp as variable
cfile_name <- list.files(path = file.path(getwd(), "data", "temp"), pattern = paste0(c_label, ".+\\.csv"))
gfile_name <- list.files(path = file.path(getwd(), "data", "temp"), pattern = paste0(g_label, ".+\\.csv"))

##Filter files, save new output

filter_usaspending(cfile_name, state, doe_offices, contract_columns, paste0("DEPRECIATED_", c_out_name))
filter_usaspending(gfile_name, state, doe_offices, grant_columns, paste0("DEPRECIATED_", g_out_name))

## Run error check on data
#source("src/DEPRECIATED_error_check.R")




## Split out DOE data from original/regular data
#source("src/split_usaspending.R")
# print(split_usaspending(cfile_name, doe))