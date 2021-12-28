## Pseudo code for file:
#Load pre-named contracts data file from temp file, load in NAICS/IMPLAN crosswalk file from ?raw data? (grants/awards file has its own error checking code)

contracts <- read.csv(file = "data/temp/2021_all_contract_spending.csv") #un-hard code file path later 
naics2implan <- read.xlsx(xlsxFile = "data/raw/2017_implan_online_naics_to_implan546.xlsx") %>%
  rename(naics_code = "2017NaicsCode", implan_code = "Implan546Index") %>%
  distinct(naics_code, implan_code, .keep_all = TRUE)

contracts <- merge(contracts, naics2implan, by = ("naics_code"), all.x = TRUE, all.y = FALSE)

output <- file.path(getwd(), "output")


#Run code and pull out data that do not have NAICS codes

contracts_no_naics <- contracts[is.na(contracts$naics_code),]
contracts <- contracts[!(is.na(contracts$naics_code)),]

#Save to "Output" folder- named "no_naics_code"

write.csv(contracts_no_naics, paste("output/no_naics_code.csv", sep = ''))

#README instructions to manually fix "no_naics_code" by altering "no_naics_code_fixes" file in raw data and saving a copy to src folder?? - not temp because you would want the documentation



#Run code and pull out data that have mismatched NAICS codes (that don't match any NAICS code in the crosswalk)

contracts_mismatch_naics <- contracts[is.na(contracts$implan_code),]
contracts <- contracts[!(is.na(contracts$implan_code)),]

#Save to "Output" folder- named "naics_code_errors" 

write.csv(contracts_mismatch_naics, paste("output/naics_code_errors.csv", sep = ''))

#README instructions to manually fix "naics_code_errors" by altering "naics_code_fixes" file in raw data and saving a copy to src folder?? - not temp because you would want the documentation



#Run through file again? At same time?? Pull out data that matches one of the NAICS/IMPLAN codes of concern:

contracts_with_multi_implan_code <- contracts %>%
  filter(naics_code == n2i_dup)
contracts <- contracts %>%
  filter(!(naics_code == n2i_dup))

#Save to "Output" folder- named "multi_implan_codes" 

write.csv(contracts_with_multi_implan_code, paste("output/multi_implan_codes.csv", sep = ''))

#Save cleaned data to "Output" folder - named "2021_cleaned_state_contracts"

write.csv(contracts, paste("output/2021_cleaned_state_contracts.csv", sep = ''))



#NAICS code 335220 can be IMPLAN code 325, 326, 327 or 328
#NAICS code 111191 can be IMPLAN code 1 or 2
#NAICS code 111366 can be IMPLAN code 4 or 5
#NAICS code 332117 can be IMPLAN code 231 or 232
#Save to "Output" folder- named "multi_implan_codes"

#README instructions to manually fix "multi_implan_code" by altering "multi_implan_code_fixes.R" file in raw data and saving a copy to src folder?? - not temp because you would want the documentation

#Save contract data file with error lines REMOVED to temp folder "{YEAR}_cleaned_usaspending_contract_data"  {} = from parameters file 
