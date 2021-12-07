## Pseudo code for file:
#Load prenamed contracts data file from temp file, load in NAICS/IMPLAN crosswalk file from ?raw data? (grants/awards file has its own error checking code)

#Run code and pull out data that do not have NAICS codes
#Save to "Output" folder- named "no_naics_code"

#README instructions to manually fix "no_naics_code" by altering "no_naics_code_fixes" file in raw data and saving a copy to src folder?? - not temp because you would want the documentation

#Run code and pull out data that have mismatched NAICS codes (that don't match any NAICS code in the crosswalk)
#Save to "Output" folder- named "naics_code_errors" 

#README instructions to manually fix "naics_code_errors" by altering "naics_code_fixes" file in raw data and saving a copy to src folder?? - not temp because you would want the documentation

#Run through file again? At same time?? Pull out data that matches one of the NAICS/IMPLAN codes of concern:
#NAICS code 335220 can be IMPLAN code 325, 326, 327 or 328
#NAICS code 111191 can be IMPLAN code 1 or 2
#NAICS code 111366 can be IMPLAN code 4 or 5
#NAICS code 332117 can be IMPLAN code 231 or 232
#Save to "Output" folder- named "multi_implan_codes"

#README instructions to manually fix "multi_implan_code" by altering "multi_implan_code_fixes.R" file in raw data and saving a copy to src folder?? - not temp because you would want the documentation

#Save contract data file with error lines REMOVED to temp folder "{YEAR}_cleaned_usaspending_contract_data"  {} = from parameters file 


