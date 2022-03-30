##This code checks the contracts data for errors, fixes the errors where possible, and calculates the weights for NAICS codes with multiple IMPLAN codes

#Load in contracts data
contracts <- read.csv(file.path(getwd(), "data", "temp", paste0(f_year, c_out_name)))

#First read in the NAICS to NAICS crosswalk and merge to contract entries to get a new dataframe that includes contracts entries with 2007 NAICS codes and their 2017 equivalent
naics2naics <- read.xlsx(file.path(getwd(), "data", "raw", naics_crosswalk))

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
