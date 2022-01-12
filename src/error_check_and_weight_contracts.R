# This code checks contracts data for errors, where possible fixes them and calculates the weights for NAICS codes with multiple IMPLAn codes
# ((This will all change again once we add in the 2022 NAICS codes... assuming IMPLAN is ready for them at the end of the year)) 

# Run hard coded fixes file first called "data/raw/2007_to_2017_NAICS.xlsx" so 2007 codes can get caught in the IMPLAN crosswalk

# Load in contracts data
contracts <- read.csv(file.path(getwd(), "data", "temp", c_out_name))

#Check for errors in contracts entries where congressional districts are "NAs", and subset from original contracts dataframe
contracts_error_districts <- contracts %>%
  filter(is.na(recipient_congressional_district))

contracts <- contracts %>%
  filter(!(is.na(recipient_congressional_district)))

# Read in crosswalk that accounts for recipients to congressional districts



# Load in second crosswalk - NAICS codes to IMPLAN codes - to fix contracts entries where there was no match between NAICS and IMPLAN
naics2implan <- read.xlsx(xlsxFile = "data/raw/2012_2017_NAICS_to_IMPLAN.xlsx") %>% #re-name crosswalk, now includes some 2002 NAICS data
  rename(naics_code = "NaicsCode", implan_code = "Implan546Index") %>%
  distinct(naics_code, implan_code, .keep_all = TRUE)

contracts <- merge(contracts, naics2implan, by = ("naics_code"), all.x = TRUE, all.y = FALSE)

output <- file.path(getwd(), "output")

#Run code and pull out data that do not have NAICS codes

contracts_no_naics <- contracts[is.na(contracts$naics_code),]
contracts <- contracts[!(is.na(contracts$naics_code)),]

#Save to "Output" folder- named "no_naics_code"

write.csv(contracts_no_naics, paste("output/no_naics_code.csv", sep = '')) 

# What do we want to do with construction data?? Do we pull it out here or ignore it? It isnt going to automatically match a NAICS code, maybe hardcoding
# Everything wont be too big an issue, we can re-run the code to test what IMPLAN does with the different assignments like we did in our meeting
# If thats the case, should we just make our own construction codes crosswalk and include it in raw data?? That way we could have a depreciated version
# and a newer version

#Run code and pull out data that have mismatched NAICS codes (that don't match any NAICS code in the crosswalk)

contracts_mismatch_naics <- contracts[is.na(contracts$implan_code),]
contracts <- contracts[!(is.na(contracts$implan_code)),]

#Save to "Output" folder- named "naics_code_errors" 

write.csv(contracts_mismatch_naics, paste("output/naics_code_errors.csv", sep = ''))

## Create new column "fao_weighted" that distributes federal_action_obligation spending by the CewAvgRatio weight for each implan code
contracts <- contracts %>%
  mutate(fao_weighted = federal_action_obligation * CewAvgRatio)

#Save contract data file with error lines REMOVED to temp folder "{YEAR}_cleaned_usaspending_contract_data" 

write.csv(contracts, file.path(getwd(), "data", "temp", paste0(year, "_cleaned_usaspending_contract_data.csv")))