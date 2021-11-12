## MILITARY SPENDING AGGREGATES ACROSS STATES ##
# NOTE: DUE TO LARGE FILE SIZES, YOU WILL HAVE TO CLEAR ENVIRONMENT AND RUN CODE FOR THE DATA PIECES AT A TIME
# NOTE 2: For purposes of the statewide report, we only need contracts data, so will focus on that.


## CLEAR ENVIRONMENT ##
rm(list = ls(all.names = TRUE))
gc()

## LOAD PACKAGES ##
library(readxl) #needed to read in excel sheets
library(dplyr)  #not entirely sure if this is needed 
library(openxlsx) #needed to write excel sheets


## SET WORKING DIRECTORY ##
setwd("C:/Users/sumee/OneDrive/Documents/R/2021_state_comparisons")


## FILES NEEDED ##
# USA Spending Files <- input data
  # DHS_Grants_All_States.csv
  # DHS_Contracts_All_States.csv
  # DOD_Grants_All_States.csv
  # DOD_Contracts_All_States1.csv
  # DOD_Contracts_All_States2.csv
  # DOD_Contracts_All_States3.csv
  # DOD_Contracts_All_States4.csv
  # VA_Grants_All_States.csv
  # VA_Contracts_All_State.csv
  # VA_Direct_Payments_All_States.csv


## CLEAN USASPENDING DATA ##
#rename base file for report year
DODGrants21 <- read.csv(file = "DOD_Grants_All_States.csv", stringsAsFactors = FALSE)
DODContracts21.1 <- read.csv(file = "DOD_Contracts_All_States1.csv", stringsAsFactors = FALSE)
DODContracts21.2 <- read.csv(file = "DOD_Contracts_All_States2.csv", stringsAsFactors = FALSE)
DODContracts21.3 <- read.csv(file = "DOD_Contracts_All_States3.csv", stringsAsFactors = FALSE)
DODContracts21.4 <- read.csv(file = "DOD_Contracts_All_States4.csv", stringsAsFactors = FALSE)
DHSGrants21 <- read.csv(file = "DHS_Grants_All_States.csv", stringsAsFactors = FALSE)
DHSContracts21 <- read.csv(file = "DHS_Contracts_All_States.csv", stringsAsFactors = FALSE)
VAGrants21 <- read.csv(file = "VA_Grants_All_States.csv", stringsAsFactors = FALSE)
VAContracts21 <- read.csv(file = "VA_Contracts_All_States.csv", stringsAsFactors = FALSE)
VADirectPayments21 <- VAContracts21 <- read.csv(file = "VA_Direct_Payments_All_States.csv", stringsAsFactors = FALSE)

# DOD GRANTS
#DODGrants <- DODGrants21 %>%
  filter(recipient_country_name == "UNITED STATES", primary_place_of_performance_country_name == "UNITED STATES") 
#DODGrants <- DODGrants[DODGrants$recipient_state_name == DODGrants$primary_place_of_performance_state_name,]
#DODGrants <- DODGrants %>%
  select("federal_action_obligation", "recipient_name", "primary_place_of_performance_state_name") %>% #select needed columns
  rename(state = "primary_place_of_performance_state_name")
#DODGrants <- aggregate(DODGrants$federal_action_obligation, by=list(DODGrants$state), FUN=sum)
#colnames(DODGrants) <- c("State", "DOD Grants")

# DOD Contracts
DODContracts1 <- DODContracts21.1 %>%
  filter(recipient_country_name == "UNITED STATES", primary_place_of_performance_country_name == "UNITED STATES")
DODContracts1 <- DODContracts1[DODContracts1$recipient_state_name == DODContracts1$primary_place_of_performance_state_name,]
DODContracts1 <- DODContracts1 %>%
  select("federal_action_obligation", "recipient_name", "primary_place_of_performance_state_name") %>% #select needed columns
  rename(state = "primary_place_of_performance_state_name")
DODContracts1 <- aggregate(DODContracts1$federal_action_obligation, by=list(DODContracts1$state), FUN=sum)
colnames(DODContracts1) <- c("State", "DOD Contracts")

DODContracts2 <- DODContracts21.2 %>%
  filter(recipient_country_name == "UNITED STATES", primary_place_of_performance_country_name == "UNITED STATES")
DODContracts2 <- DODContracts2[DODContracts2$recipient_state_name == DODContracts2$primary_place_of_performance_state_name,]
DODContracts2 <- DODContracts2 %>%
  select("federal_action_obligation", "recipient_name", "primary_place_of_performance_state_name") %>% #select needed columns
  rename(state = "primary_place_of_performance_state_name")
DODContracts2 <- aggregate(DODContracts2$federal_action_obligation, by=list(DODContracts2$state), FUN=sum)
colnames(DODContracts2) <- c("State", "DOD Contracts")

DODContracts3 <- DODContracts21.3 %>%
  filter(recipient_country_name == "UNITED STATES", primary_place_of_performance_country_name == "UNITED STATES")
DODContracts3 <- DODContracts3[DODContracts3$recipient_state_name == DODContracts3$primary_place_of_performance_state_name,]
DODContracts3 <- DODContracts3 %>%
  select("federal_action_obligation", "recipient_name", "primary_place_of_performance_state_name") %>% #select needed columns
  rename(state = "primary_place_of_performance_state_name")
DODContracts3 <- aggregate(DODContracts3$federal_action_obligation, by=list(DODContracts3$state), FUN=sum)
colnames(DODContracts3) <- c("State", "DOD Contracts")

DODContracts4 <- DODContracts21.4 %>%
  filter(recipient_country_name == "UNITED STATES", primary_place_of_performance_country_name == "UNITED STATES")
DODContracts4 <- DODContracts4[DODContracts4$recipient_state_name == DODContracts4$primary_place_of_performance_state_name,]
DODContracts4 <- DODContracts4 %>%
  select("federal_action_obligation", "recipient_name", "primary_place_of_performance_state_name") %>% #select needed columns
  rename(state = "primary_place_of_performance_state_name")
DODContracts4 <- aggregate(DODContracts4$federal_action_obligation, by=list(DODContracts4$state), FUN=sum)
colnames(DODContracts4) <- c("State", "DOD Contracts")

# DHS Grants
#DHSGrants <- DHSGrants21 %>%
  filter(recipient_country_name == "UNITED STATES", primary_place_of_performance_country_name == "UNITED STATES")
#DHSGrants <- DHSGrants[DHSGrants$recipient_state_name == DHSGrants$primary_place_of_performance_state_name,]
#DHSGrants <- DHSGrants %>%
  select("federal_action_obligation", "recipient_name", "primary_place_of_performance_state_name") %>% #select needed columns
  rename(state = "primary_place_of_performance_state_name")
#DHSGrants <- aggregate(DHSGrants$federal_action_obligation, by=list(DHSGrants$state), FUN=sum)
#colnames(DHSGrants) <- c("State", "DHS Grants")

# DHS Contracts 
DHSContracts <- DHSContracts21 %>%
  filter(recipient_country_name == "UNITED STATES", primary_place_of_performance_country_name == "UNITED STATES")
DHSContracts <- DHSContracts[DHSContracts$recipient_state_name == DHSContracts$primary_place_of_performance_state_name,]
DHSContracts <- DHSContracts %>%
  select("federal_action_obligation", "recipient_name", "primary_place_of_performance_state_name") %>% #select needed columns
  rename(state = "primary_place_of_performance_state_name")
DHSContracts <- aggregate(DHSContracts$federal_action_obligation, by=list(DHSContracts$state), FUN=sum)
colnames(DHSContracts) <- c("State", "DHS Contracts")

# VA GRANTS
#VAGrants <- VAGrants21 %>%
  filter(recipient_country_name == "UNITED STATES", primary_place_of_performance_country_name == "UNITED STATES")
#VAGrants <- VAGrants[VAGrants$recipient_state_name == VAGrants$primary_place_of_performance_state_name,]
#VAGrants <- VAGrants %>%
  select("federal_action_obligation", "recipient_name", "primary_place_of_performance_state_name") %>% #select needed columns
  rename(state = "primary_place_of_performance_state_name")
#VAGrants <- aggregate(VAGrants$federal_action_obligation, by=list(VAGrants$state), FUN=sum)
#colnames(VAGrants) <- c("State", "VA Grants")

# VA CONTRACTS
VAContracts <- VAContracts21 %>%
  filter(recipient_country_name == "UNITED STATES", primary_place_of_performance_country_name == "UNITED STATES")
VAContracts <- VAContracts[VAContracts$recipient_state_name == VAContracts$primary_place_of_performance_state_name,]
VAContracts <- VAContracts %>%
  select("federal_action_obligation", "recipient_name", "primary_place_of_performance_state_name") %>% #select needed columns
  rename(state = "primary_place_of_performance_state_name")
VAContracts <- aggregate(VAContracts$federal_action_obligation, by=list(VAContracts$state), FUN=sum)
colnames(VAContracts) <- c("State", "VA Contracts")

# VA Direct Payments
#VADirectPayments <- VADirectPayments21 %>%
  filter(recipient_country_name == "UNITED STATES", primary_place_of_performance_country_name == "UNITED STATES")
#VADirectPayments <- VADirectPayments[VADirectPayments$recipient_state_name == VADirectPayments$primary_place_of_performance_state_name,]
#VADirectPayments <- VADirectPayments %>%
  select("federal_action_obligation", "recipient_name", "primary_place_of_performance_state_name") %>% #select needed columns
  rename(state = "primary_place_of_performance_state_name")
#VADirectPayments <- aggregate(VADirectPayments$federal_action_obligation, by=list(VADirectPayments$state), FUN=sum)
#colnames(VADirectPayments) <- c("State", "VA Direct Payments")


#write out all the data into spreadsheets (may have to clear environment and run through multiple times)
dod_contracts_part1 <- list("DODContracts1" = DODContracts1, "DODContracts2" = DODContracts2)
write.xlsx(dod_contracts_part1, paste0("dod_contracts_part1.xlsx")) 

dod_contracts_part2 <- list("DODContracts3" = DODContracts3, "DODContracts4" = DODContracts4)
write.xlsx(dod_contracts_part2, paste0("dod_contracts_part2.xlsx"))

dod_grants_dhs_spend <- list("DODGrants" = DODGrants, "DHSContracts" = DHSContracts, "DHSGrants" = DHSGrants)
write.xlsx(dod_grants_dhs_spend, paste0("dod_grants_dhs_spend.xlsx")) 

vaspend <- list("VAGrants" = VAGrants, "VAContracts" = VAContracts, "VADirectPayments" = VADirectPayments)
write.xlsx(vaspend, paste0("vaspending.xlsx"))


## FINAL STEP: Clear environment, reupload all these generated files, and combine into one master sheet.

# First read in DOD Contracts, and rbind into one
DODContracts21_1 <- read.xlsx("dod_contracts_part1.xlsx", sheet = 1)
DODContracts21_2 <- read.xlsx("dod_contracts_part1.xlsx", sheet = 2)
DODContracts21_3 <- read.xlsx("dod_contracts_part2.xlsx", sheet = 1)
DODContracts21_4 <- read.xlsx("dod_contracts_part2.xlsx", sheet = 2)

DODContracts <- rbind(DODContracts21_1, DODContracts21_2, DODContracts21_3, DODContracts21_4)
DODContracts <- aggregate(DODContracts$DOD.Contracts, by=list(DODContracts$State), FUN=sum)
colnames(DODContracts) <- c("State", "DOD Contracts")

# Read in the remaining files
DHSContracts <- read.xlsx("dod_grants_dhs_spend.xlsx", sheet = 2)
VAContracts <- read.xlsx("vaspending.xlsx", sheet = 2)

# Combine into one large file now and write into Excel file
ns_contracts_states <- Reduce(function(x,y) merge(x = x, y = y, by = "State"), 
                                  list(DODContracts, DHSContracts, VAContracts))
colnames(ns_contracts_states) <- c("State", "DOD Contracts", "DHS Contracts","VA Contracts")
ns_contracts_states <- ns_contracts_states %>%
  mutate(total_contracts = ns_contracts_states$`DOD Contracts` + ns_contracts_states$`DHS Contracts` + ns_contracts_states$`VA Contracts`)

write.xlsx(ns_contracts_states, paste0("National_Security_Contracts_States.xlsx"))

## IF you need to check a certain state's totals for a certain spending data source...

DODContracts21.1 <- DODContracts21.1 %>%
  filter(recipient_country_name == "UNITED STATES", primary_place_of_performance_country_name == "UNITED STATES",
         recipient_state_name == "CALIFORNIA", primary_place_of_performance_state_name == "CALIFORNIA")
DODContracts21.2 <- DODContracts21.2 %>%
  filter(recipient_country_name == "UNITED STATES", primary_place_of_performance_country_name == "UNITED STATES",
         recipient_state_name == "CALIFORNIA", primary_place_of_performance_state_name == "CALIFORNIA")
DODContracts21.3 <- DODContracts21.3 %>%
  filter(recipient_country_name == "UNITED STATES", primary_place_of_performance_country_name == "UNITED STATES",
         recipient_state_name == "CALIFORNIA", primary_place_of_performance_state_name == "CALIFORNIA")
DODContracts21.4 <- DODContracts21.4 %>%
  filter(recipient_country_name == "UNITED STATES", primary_place_of_performance_country_name == "UNITED STATES",
         recipient_state_name == "CALIFORNIA", primary_place_of_performance_state_name == "CALIFORNIA")