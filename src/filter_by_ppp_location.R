## Pseudo Code for File:
# For file in temp, load in data obtained from "obtain_usaspending"- need to make it selects without knowing the name OR potential additional files in folder we are un interested in
#Assistance and Contracts files need to be processed and saved separately due to subsequent processes
#Filter both files by Recipient and Planed Performance location, both in the state of CA- check location variables and document
#Output filtered data with new name into temp folder- follow some output format. Define name in parameters file


# DOD GRANTS
DODGrants <- DODGrants21 %>%
  filter(primary_place_of_performance_state_name == "CALIFORNIA") %>%
  select("federal_action_obligation", "recipient_name", "recipient_county_name", "recipient_congressional_district", 
         "business_types_description") %>% #select needed columns
  rename(county = "recipient_county_name", district = "recipient_congressional_district")
# DOD Contracts
DODContracts <- DODContracts21 %>% 
  filter(primary_place_of_performance_state_name == "CALIFORNIA") %>%
  select("federal_action_obligation", "recipient_county_name", 
         "recipient_congressional_district", "naics_code", "recipient_name") #select needed columns
