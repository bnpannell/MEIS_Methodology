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

filter_usaspending(cfile_name, state, doe_offices, contract_columns, c_out_name)
filter_usaspending(gfile_name, state, doe_offices, grant_columns, g_out_name)


## Run error check on data
source("src/error_check_contracts_data.R")


#Questions: How to implement the fork of manual check for error files and manual fixes vs automated fixes?
#Run in master file for check, call on separate file for automatic fixes?? 
# Something like: if "naics_code_errors" exists check for file "naics_code_fixes" in src file,
# if "naics_code_fixes" exists run code, 
#concat back to cleaned data file in ?temp folder?
# else, return "fix file does not exist, make fix file and re run OR loose [sum of $ spent] $ from totals" - track money not tracked by report due to not fixing errors here
#(Same for if no NAICS code exists?)


#if "multi_implan_codes" exists check for file "multi_implan_codes_fixes" in src file  
#if "multi_implan_codes_fixes.R" exists in src file,
#run file on multi_implan_codes and concat back to cleaned data file in ?temp folder?
#else run multiplier_for_multi_implan_codes.R" from src file & concat back to cleaned data file 


## Split out DOE data from original/regular data
#source("src/split_usaspending.R")
# print(split_usaspending(cfile_name, doe))