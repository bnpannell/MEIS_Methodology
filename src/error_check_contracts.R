##This code checks the contracts data for errors, fixes the errors where possible, and calculates the weights for NAICS codes with multiple IMPLAN codes

#Load in contracts data
contracts <- read.csv(file.path(getwd(), "data", "temp", paste0(f_year, c_out_name)))

#First read in the NAICS to NAICS crosswalk and merge to contract entries to get a new dataframe that includes contracts entries with 2007 NAICS codes and their 2017 equivalent
naics2naics <- read.xlsx(file.path(getwd(), "data", "raw", naics_crosswalk))

#Rewrite the 2007 NAICS codes in the contracts dataframe by matching it to those in the 2007 to 2017 NAICS crosswalk dataframe
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

#Pull out all contracts errors - those entries without an IMPLAN code

index_na <- which(is.na(contracts$implan_code) & is.na(contracts$naics_code))
index_construct <- which(substr(contracts$naics_code,1,2) == "23")





contracts_errors <- contracts %>%
  filter(is.na(implan_code) & is.na(naics_code))

contracts <- contracts %>%
  filter(!(is.na(implan_code) | is.na(naics_code)))

#Now, pull out construction contracts from the contracts_errors dataframe - there are some entries we can fix easily
construction_contracts <- contracts_errors[which(substr(contracts_errors$naics_code,1,2) == "23"),]

contracts_errors <- contracts_errors[which(!substr(contracts_errors$naics_code,1,2) == "23"),]

#Construction contracts that have NAICS code 236118 can be associated with IMPLAN code 61. Also, we developed a word search to assign construction contracts to IMPLAN code 60.
construction_contracts <- construction_contracts %>%
  mutate(implan_code = case_when(startsWith(as.character(naics_code), "236118") ~ "61",))

implan_60_contracts <- construction_contracts[contract_check(patterns = implan_60, data = construction_contracts$award_description),]
contracts_errors <- construction_contracts[!(contract_check(patterns = implan_60, data = construction_contracts$award_description)),]


#Pull out all contracts entries which do not have an IMPLAN code - this includes construction codes, the "92s", and some entries which didn't have a NAICS code

##QUESTION FOR BRITNEE!! Do we want to just pull out all these errors together, or pull them out based on error type (i.e. 1 for construction, 1 for "92s", and 1 for no NAICS codes?)
##NOTE: Method 1 grabs 3,337 entries of errors. Method 2 combined grabs 3,283 entries of errors, meaning it has 54 less than Method 1. 
##The issue is partly with construction (45 entries aren't pulled out - idk why?), and partly because there are 9 entries with unresolved/unaccounted for NAICS - 339111 and 514210.



#Method 1: Lumping all errors out together



#Method 2: Taking out errors based on type - construction, "92s" NAICS, and NAs NAICS

#NA NAICS
#naics_na_contracts <- contracts %>%
 # filter(is.na(naics_code))

#contracts <- contracts %>%
 # filter(!is.na(naics_code))



