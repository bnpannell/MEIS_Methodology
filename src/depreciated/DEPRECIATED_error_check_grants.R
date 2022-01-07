## Error check usaspending grants data ##

## See depreciated methodology section for details on manual fix to usaspending contracts and grants Excel sheets prior to running below code
# Assumes that all districts (previously labeled as NA or 90) have been fixed

# Load in grants CSV into dataframe
grants <- read.csv(file.path(getwd(), "data", "temp", paste0("DEPRECIATED_", g_out_name)))

# Load in Business type to IMPLAN crosswalk
business_to_implan <- read.csv(file = "data/raw/business_type_to_implan546_crosswalk.csv", stringsAsFactors = FALSE, fileEncoding="UTF-8-BOM")

# DOD GRANTS
DODGrants  <- merge(DODGrants, business_to_implan, by = ("business_types_description"), all.x = TRUE, all.y = FALSE) #merge with business to implan bridge
DODGrants <- DODGrants %>%
  select("federal_action_obligation", "county", "district", "implan_code") #select needed columns

# DHS Grants
DHSGrants  <- merge(DHSGrants, business_to_implan, by = ("business_types_description"), all.x = TRUE, all.y = FALSE) #merge with business to implan bridge
DHSGrants <- DHSGrants %>%
  select("federal_action_obligation", "county", "district", "implan_code") #select needed columns

# VA GRANTS
VAGrants  <- merge(VAGrants, business_to_implan, by = ("business_types_description"), all.x = TRUE, all.y = FALSE) #merge with business to implan bridge
VAGrants$implan_code[VAGrants$recipient_name == "UNIVERSITY OF CALIFORINA FULLERTON"] <- 531 #reassign some entries
VAGrants$implan_code[VAGrants$recipient_name == "THE UNIVERSITY CORPORATION LOS ANGELES"] <- 524
VAGrants$implan_code[VAGrants$recipient_name == "THE UNIVERSITY CORPORATION"] <- 524
VAGrants <- VAGrants %>%
  select("federal_action_obligation", "county", "district", "implan_code") #select needed columns

## HOUSEHOLD SPENDING CHANGE ##
# Upload VA Payments information (this will be used for household spending change)
VA_payments_21 <- read.csv("VA_Direct_Payments_Recipient_USA_CA.csv") 
VA_payments <- VA_payments_21 %>%
  filter(primary_place_of_performance_state_name == "CALIFORNIA") %>%
  select("total_obligated_amount", "recipient_county_name", "recipient_congressional_district") %>% #select needed columns
  rename(county = "recipient_county_name", district = "recipient_congressional_district")

# County household spending change
HHSpendCH_county <- aggregate(VA_payments$total_obligated_amount, by=list(VA_payments$county), FUN=sum) #aggregate spending based on county
colnames(HHSpendCH_county) <- c("county", "spending_change") #rename columns
HHSpendCH_county$inverse <- (sum(VA_payments$total_obligated_amount)) - HHSpendCH_county$spending_change #add inverse column

# District household spending change
HHSpendCH_dist <- aggregate(VA_payments$total_obligated_amount, by=list(VA_payments$district), FUN=sum) #aggregate spending based on district
colnames(HHSpendCH_dist) <- c("district", "spending_change") #rename columns
HHSpendCH_dist$inverse <- (sum(VA_payments$total_obligated_amount)) - HHSpendCH_dist$spending_change #add inverse column

