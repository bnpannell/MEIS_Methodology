##This code checks the contracts data for errors, fixes the errors where possible, and produces a cleaned contracts dataframe + an error file to work through in later code##

#Load in contracts data
contracts <- read.csv(file.path(getwd(), "data", "temp", paste0(f_year, c_out_name)))

#First read in the NAICS to NAICS crosswalk. Then rewrite the 2007 NAICS codes in the contracts dataframe by matching it to those in the 2007 to 2017 NAICS crosswalk dataframe
naics2naics <- read.xlsx(file.path(getwd(), "data", "raw", naics_crosswalk))

for (i in 1:nrow(naics2naics)) {
  contracts$naics_code[grep(naics2naics$`2007_NAICS`[i],contracts$naics_code)] <- naics2naics$`2017_NAICS`[i]
}

#Now load in the NAICS to IMPLAN crosswalk and merge to contracts - this will assign contracts entries to their appropriate IMPLAN code based on 2012 and 2017 NAICS codes
naics2implan <- read.xlsx(file.path(getwd(), "data", "raw", implan_crosswalk))
naics2implan <- naics2implan %>%
  rename(naics_code = "NaicsCode", implan_code = "Implan546Index") %>%
  distinct(naics_code, implan_code, .keep_all = TRUE)

contracts <- merge(contracts, naics2implan, by = ("naics_code"), all.x = TRUE, all.y = FALSE)

#Next, hard code any contract entries with a NAICS code starting with "92" to IMPLAN code 528
contracts$implan_code[startsWith(as.character(contracts$naics_code), "92")] <- "528"
contracts$implan_code[startsWith(as.character(contracts$naics_code), "236118")] <- "61"

##Define all the tiers of errors as indices that we need to pull out from the contracts dataframe, based on error type and appropriate fix. This includes:
#Contracts without districts; and Contracts with construction NAICS codes that either have no IMPLAN code and/or no district##
no_dist_ind <- which(is.na(contracts$recipient_congressional_district) & !(substr(contracts$naics_code,1,2) == "23") & !(is.na(contracts$implan_code)))
constr_ind <- which(substr(contracts$naics_code,1,2) == "23" & !(is.na(contracts$recipient_congressional_district)) & is.na(contracts$implan_code))
constr_no_dist_ind <- which(substr(contracts$naics_code,1,2) == "23" & is.na(contracts$recipient_congressional_district) & is.na(contracts$implan_code))

#Pull out these various errors into their own dataframes, and drop from the contracts dataframe
no_dist_contracts <- contracts[no_dist_ind,]
construction_contracts <- contracts[constr_ind,]
construction_contracts_no_dist <- contracts[constr_no_dist_ind,]

contracts <- contracts[-c(no_dist_ind, constr_ind, constr_no_dist_ind),]

##Last, be sure to pull out any other contracts entries that do not fall to the above categories, but still did not have an IMPLAN code assigned to them. Repeat above process##
no_implan_rem_ind <- which(is.na(contracts$implan_code))
                           
no_implan_contracts <- contracts[no_implan_rem_ind,]

contracts <- contracts[-no_implan_rem_ind,]


##FIX TIER 2: CONTRACTS WITHOUT DISTRICTS. USE DISTRICTS CROSSWALK FROM DATA/RAW FOLDER TO ASSIGN DISTRICTS.

#Read in CSV file that contains congressional districts for contract entries based on contract recipient
contr_dist_cw <- read.csv(file.path(getwd(), "data", "raw", contr_dist_crosswalk), fileEncoding="UTF-8-BOM")

#Rewrite the NA district values in the no_dist_contracts dataframe by matching it to those in the crosswalk dataframe that we just read in
for (i in 1:nrow(contr_dist_cw)) {
 pattern <- gsub("\\(", "\\\\(", contr_dist_cw$recipient_name[i])
 pattern <- gsub("\\)", "\\\\)", pattern) ##DOUBLE CHECK THAT THERE ARE NO OTHER SPECIAL CHARACTERS IN R THAT ONE MAY NEED TO ESCAPE OUT OF. POTENTIALLY MAKE AS VARIABLE IN PARAMETERS IF THAT IS THE CASE.
  no_dist_contracts$recipient_congressional_district[grep(pattern,no_dist_contracts$recipient_name)] <- contr_dist_cw$recipient_congressional_district[i]
}

#Concat the now-fixed entries back into the contracts dataframe and drop the fixed dataframe - TIER 2 COMPLETED.
#NOTE: The fixed dataframe should only be dropped once all the values in the recipient_congressional_district column is filled.
contracts <- rbind(contracts, no_dist_contracts)

rm(no_dist_contracts)


#FIX TIER 3: CONSTRUCTION CONTRACTS WITH DISTRICTS. USE WORD SEARCH FOR IMPLAN 60 CODES.

#Utilize the contract_check function and the word search defined in parameters to pull out certain construction contracts and drop them from the construction contracts dataframe. 
#All of these contracts will be assigned to IMPLAN code 60
implan_60_contracts <- construction_contracts[contract_check(patterns = implan_60, data = construction_contracts$award_description),]
implan_60_contracts$implan_code <- 60

construction_contracts <- construction_contracts[!(contract_check(patterns = implan_60, data = construction_contracts$award_description)),]

#Rbind this fixed dataframe into the main contracts dataframe and then remove the fixed dataframe - TIER 3 COMPLETED.
contracts <- rbind(contracts, implan_60_contracts)
rm(implan_60_contracts)


#FIX TIER 3A: CONSTRUCTION CONTRACTS WITH DISTRICTS THAT WERE NOT CAPTURED ABOVE. MANUALLY ASSIGN IMPLAN CODES.

construction_contracts




#FIX TIER 4: CONSTRUCTION CONTRACTS WITHOUT DISTRICTS. MANUALLY ASSIGN IMPLAN CODES AND/OR DISTRICTS?

construction_contracts_no_dist




#FIX TIER 5: REMAINING CONTRACTS WITH NO IMPLAN CODE. MANUALLY FIX?

no_implan_contracts