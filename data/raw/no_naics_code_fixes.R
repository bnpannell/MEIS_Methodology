##Pseudo Code for file

# Copy over hard code fixes (if simple) to change lines of "no_naics_code" to reflect correct IMPLAN code assignments

###CODE BELOW FROM "county_district_spending_aggregates_2021.R" 

# Some entries had no NAICS code at all. I looked up those industries and manually assigned IMPLAN codes
DODContracts$implan_code[DODContracts$recipient_name == "IMPERIAL IRRIGATION DISTRICT INC"] <- 530
DODContracts$implan_code[DODContracts$recipient_name == "KAMP SYSTEMS, INC"] <- 244
DODContracts$implan_code[DODContracts$recipient_name == "SCIENCE APPLICATIONS INTERNATIONAL CORPORATION"] <- 459
DODContracts$implan_code[DODContracts$recipient_name == "DRS SENSORS & TARGETING SYSTEMS, INC."] <- 514
DODContracts$implan_code[DODContracts$recipient_name == "KEYSTONE ENGINEERING COMPANY I"] <- 457