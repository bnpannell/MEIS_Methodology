##This code checks the contracts data for errors, fixes the errors where possible, and calculates the weights for NAICS codes with multiple IMPLAN codes

#Load in contracts data
contracts <- read.csv(file.path(getwd(), "data", "temp", paste0(f_year, c_out_name)))

#First read in the NAICS to NAICS crosswalk and merge to contract entries to get a new dataframe that includes contracts entries with 2007 NAICS codes and their 2017 equivalent
naics2naics <- read.xlsx(file.path(getwd(), "data", "raw", naics_crosswalk))

#Rewrite the 2007 NAICS codes in the contracts dataframe by matching it to those in the 2007 to 2017 NAICS crosswalk dataframe
contracts$naics_code <- naics2naics$`2017_NAICS`[match(contracts$naics_code, naics2naics$`2007_NAICS`)]


old_contracts <- contracts %>%
  filter(naics_code %in% naics_2007)



contracts_naics_fix <- merge(x=contracts, y=naics2naics, by.x="naics_code", by.y="2007_NAICS", x.all=FALSE, y.all=FALSE)

#Drop the contracts whose NAICS have to be fixed from the original contracts dataframe - these will be rbind back together after the fix
contracts <- contracts[! contracts$naics_code %in% naics_2007,]
  
#Drop the 2007 NAICS code column, rename the 2017 NAICS column to "naics_code", and rbind back to contracts dataframe
contracts_naics_fix <- contracts_naics_fix %>%
  select(-(naics_code)) %>%
  rename(naics_code = "2017_NAICS")

contracts <- rbind(contracts, contracts_naics_fix)

#Now load in the NAICS to IMPLAN crosswalk and merge to contracts - this will assign contracts entries to their appropriate IMPLAN code based on 2012 and 2017 NAICS codes
naics2implan <- read.xlsx(file.path(getwd(), "data", "raw", implan_crosswalk))
naics2implan <- naics2implan %>%
  rename(naics_code = "NaicsCode", implan_code = "Implan546Index") %>%
  distinct(naics_code, implan_code, .keep_all = TRUE)

contracts <- merge(contracts, naics2implan, by = ("naics_code"), all.x = TRUE, all.y = FALSE)

#Pull out all contracts entries which do not have an IMPLAN code - this includes construction codes, the "92s", and some entries which didn't have a NAICS code

##QUESTION FOR BRITNEE!! Do we want to just pull out all these errors together, or pull them out based on error type (i.e. 1 for construction, 1 for "92s", and 1 for no NAICS codes?)
##NOTE: Method 1 grabs 3,337 entries of errors. Method 2 combined grabs 3,283 entries of errors, meaning it has 54 less than Method 1. 
##The issue is partly with construction (45 entries aren't pulled out - idk why?), and partly because there are 9 entries with unresolved/unaccounted for NAICS - 339111 and 514210.



#Method 1: Lumping all errors out together
contracts_errors <- contracts %>%
  filter(is.na(implan_code))

contracts <- contracts %>%
  filter(!is.na(implan_code))


#Method 2: Taking out errors based on type - construction, "92s" NAICS, and NAs NAICS

#CONSTRUCTION
#construction_contracts <- contracts %>%
 # filter(naics_code %in% construction_naics)

#contracts <- contracts %>%
 # filter(!(naics_code %in% construction_naics))

#"92s" NAICS
#naics_92_contracts <- contracts %>%
 # filter(grepl(("^92"), naics_code))

#contracts <- contracts %>%
 # filter(!(grepl(("^92"), naics_code)))

#NA NAICS
#naics_na_contracts <- contracts %>%
 # filter(is.na(naics_code))

#contracts <- contracts %>%
 # filter(!is.na(naics_code))



## Apply contract_check filter to filter out contracts that should be assigned IMPLAN code 60
implan_60_contracts <- contracts_errors[contract_check(patterns = implan_60, data = contracts_errors$award_description),]
contracts_errors <- contracts_errors[!(contract_check(patterns = implan_60, data = contracts_errors$award_description)),]