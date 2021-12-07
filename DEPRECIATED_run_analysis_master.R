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
source("src/filter_by_ppp_location.R") 
##Load Data Sources from Temp as variable: if name contains Assistance? (for Grants) or if name contains Contracts? (for Contract data)

contract_spending <- read.csv(file.path(getwd(), "data", "temp", "All_Contracts_PrimeTransactions_2021-11-30_H20M03S43_1.csv"))
#grant_spending <- read.csv([some code]) 

print(contract_spending)

filter.ppp(contract_spending, state, contract_columns)



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
