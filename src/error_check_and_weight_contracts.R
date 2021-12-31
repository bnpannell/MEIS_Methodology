# If we don't make this a function should it go to the master R code line by line as written? 

# Run hardcoded 2007 to 2017 NAICS code fixes first

#Enter code here for that

# Load in files, start first crosswalk error check of NAICS codes to IMPLAN codes
contracts <- read.csv(file.path(getwd(), "data", "temp", c_out_name)) 
naics2implan <- read.xlsx(xlsxFile = "data/raw/2012_2017_NAICS_to_IMPLAN.xlsx") %>%
  rename(naics_code = "NaicsCode", implan_code = "Implan546Index") %>%
  distinct(naics_code, implan_code, .keep_all = TRUE)

contracts <- merge(contracts, naics2implan, by = ("naics_code"), all.x = TRUE, all.y = FALSE)

output <- file.path(getwd(), "output")


#Run code and pull out data that do not have NAICS codes

contracts_no_naics <- contracts[is.na(contracts$naics_code),]
contracts <- contracts[!(is.na(contracts$naics_code)),]

#Save to "Output" folder- named "no_naics_code"

write.csv(contracts_no_naics, paste("output/no_naics_code.csv", sep = '')) #should we use output variable defined above here? 

#README instructions to manually fix "no_naics_code" by altering "no_naics_code_fixes" file in raw data and saving a copy to src folder?? - not temp because you would want the documentation



#Run code and pull out data that have mismatched NAICS codes (that don't match any NAICS code in the crosswalk)

contracts_mismatch_naics <- contracts[is.na(contracts$implan_code),]
contracts <- contracts[!(is.na(contracts$implan_code)),]

#Save to "Output" folder- named "naics_code_errors" 

write.csv(contracts_mismatch_naics, paste("output/naics_code_errors.csv", sep = ''))

#README instructions to manually fix "naics_code_errors" by altering "naics_code_fixes" file in raw data and saving a copy to src folder?? - not temp because you would want the documentation
# Run construction code fixes here?? Or before final output of "cleaned" data? 

## Create new column "fao_weighted" that distributes federal_action_obligation spending by the CewAvgRatio weight for each implan code
contracts <- contracts %>%
  mutate(fao_weighted = federal_action_obligation * CewAvgRatio)

#Save contract data file with error lines REMOVED to temp folder "{YEAR}_cleaned_usaspending_contract_data"  {} = from parameters file 
#Save cleaned data to "Output" folder - named "2021_cleaned_state_contracts"

#temp <- file.path(getwd(), "data", "temp/")

write.csv(contracts, file.path(getwd(), "data", "temp", year, "_cleaned_usaspending_contract_data"))