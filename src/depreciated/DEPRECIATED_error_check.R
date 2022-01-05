## MILITARY INVESTMENT AGGREGATES BY COUNTY AND DISTRICT ##

##CROSSWALKS

#Business type to IMPLAN
business_to_implan <- read.csv(file = "business_type_implan_crosswalk.csv", stringsAsFactors = FALSE) 

#NAICS to IMPLAN
naics_to_implan <- read_excel("Bridge_2017NaicsToImplan546.xlsx")
naics_to_implan <- naics_to_implan %>%
  select("Implan546Index", "2017NaicsCode") %>%
  rename(implan_code = "Implan546Index", naics_code = "2017NaicsCode")
naics_to_implan$implan_code[naics_to_implan$naics_code == 335220] <- 327
naics_to_implan$implan_code[naics_to_implan$naics_code == 332117] <- 231
naics_to_implan <- naics_to_implan[!duplicated(naics_to_implan), ] #delete duplicate rows

# this gives you any codes where naics is paired up with multiple implan_codes
# naics_to_implan[duplicated(naics_to_implan$naics_code),]

# DOD GRANTS
DODGrants  <- merge(DODGrants, business_to_implan, by = ("business_types_description"), all.x = TRUE, all.y = FALSE) #merge with business to implan bridge
DODGrants <- DODGrants %>%
  select("federal_action_obligation", "county", "district", "implan_code") #select needed columns

# DOD Contracts
DODContracts  <- merge(DODContracts, naics_to_implan, by = ("naics_code"), all.x = TRUE, all.y = FALSE) #merge with NAICS to IMPLAN crosswalk
DODContracts <- DODContracts %>%
  filter(!(federal_action_obligation == 0 & is.na(naics_code)))

#this line pull all of the entries with unmatched NAICS codes in one DF. 
DODContracts_NA <- DODContracts[is.na(DODContracts$implan_code),]
# use this code to generate a list of all the unique naics_codes that don't have an IMPLAN assignment
# unique(DODContracts_NA$naics_code)

# reassign the naics codes with the corresponding IMPLAN codes (some of the orphan naics 
# (cont.) codes are construction codes while others seem like typos)
DODContracts_NA <- DODContracts_NA %>%
  mutate(implan_code = case_when(
    startsWith(as.character(naics_code), "2361") ~ "61",
    startsWith(as.character(naics_code), "2362") ~ "62",
    startsWith(as.character(naics_code), "237") ~ "56",
    startsWith(as.character(naics_code), "238") ~ "55",
    startsWith(as.character(naics_code), "3149") ~ "121",
    startsWith(as.character(naics_code), "315") ~ "125",
    startsWith(as.character(naics_code), "316") ~ "131",
    startsWith(as.character(naics_code), "3322") ~ "233",
    startsWith(as.character(naics_code), "333313") ~ "271",
    startsWith(as.character(naics_code), "333319") ~ "272",
    startsWith(as.character(naics_code), "333518") ~ "279",
    startsWith(as.character(naics_code), "3339") ~ "286",
    startsWith(as.character(naics_code), "334119") ~ "300",
    startsWith(as.character(naics_code), "334411") ~ "306",
    startsWith(as.character(naics_code), "335222") ~ "325",
    startsWith(as.character(naics_code), "339111") ~ "376",
    startsWith(as.character(naics_code), "339944") ~ "384",
    startsWith(as.character(naics_code), "443120") ~ "404",
    startsWith(as.character(naics_code), "514210") ~ "77",
    startsWith(as.character(naics_code), "517110") ~ "158",
    startsWith(as.character(naics_code), "53229") ~ "412",
    startsWith(as.character(naics_code), "54171") ~ "464",
    startsWith(as.character(naics_code), "921") ~ "531",
    startsWith(as.character(naics_code), "9221") ~ "534",
    startsWith(as.character(naics_code), "928") ~ "528",
    startsWith(as.character(naics_code), "9231") ~ "531",
    startsWith(as.character(naics_code), "924") ~ "534",
    startsWith(as.character(naics_code), "926") ~ "530",
    startsWith(as.character(naics_code), "927") ~ "528",))

#create a crosswalk with the new codes to add to the other naics crosswalk
naics_crosswalk_addition_1 <- DODContracts_NA %>%
  select(implan_code, naics_code) %>%
  filter(!is.na(naics_code))
naics_crosswalk_addition_1 <- distinct(naics_crosswalk_addition_1)

#merge crosswalks
naics_to_implan <- rbind(naics_to_implan, naics_crosswalk_addition_1)

#reapply crosswalk
DODContracts <- DODContracts %>%
  select(-implan_code)
DODContracts  <- merge(DODContracts, naics_to_implan, by = ("naics_code"), all.x = TRUE, all.y = FALSE)

# Some entries had no NAICS code at all. I looked up those industries and manually assigned IMPLAN codes
DODContracts$implan_code[DODContracts$recipient_name == "IMPERIAL IRRIGATION DISTRICT INC"] <- 530
DODContracts$implan_code[DODContracts$recipient_name == "KAMP SYSTEMS, INC"] <- 244
DODContracts$implan_code[DODContracts$recipient_name == "SCIENCE APPLICATIONS INTERNATIONAL CORPORATION"] <- 459
DODContracts$implan_code[DODContracts$recipient_name == "DRS SENSORS & TARGETING SYSTEMS, INC."] <- 514
DODContracts$implan_code[DODContracts$recipient_name == "KEYSTONE ENGINEERING COMPANY I"] <- 457

#select needed columns
DODContracts <- DODContracts %>%
  select("federal_action_obligation", "recipient_county_name", "recipient_congressional_district", "implan_code") %>%
  rename(county = recipient_county_name, district = recipient_congressional_district)

# use these to test where there are NAs
#DODContracts_no_implan <-DODContracts %>%
#  filter(is.na(implan_code))
#DODContracts_no_money <-DODContracts %>%
#  filter(is.na(federal_action_obligation))
#DODContracts_no_district <-DODContracts %>%
#  filter(is.na(district))

# DHS Grants
DHSGrants  <- merge(DHSGrants, business_to_implan, by = ("business_types_description"), all.x = TRUE, all.y = FALSE) #merge with business to implan bridge
DHSGrants <- DHSGrants %>%
  select("federal_action_obligation", "county", "district", "implan_code") #select needed columns

# DHS Contracts 
DHSContracts  <- merge(DHSContracts, naics_to_implan, by = ("naics_code"), all.x = TRUE, all.y = FALSE) #merge with NAICS to IMPLAN crosswalk

# find missing naics codes
DHSContracts_NA <- DHSContracts[is.na(DHSContracts$implan_code),]
# unique(DHSContracts_NA$naics_code)

# reassign codes
DHSContracts_NA <- DHSContracts_NA %>%
  mutate(implan_code = case_when(
    startsWith(as.character(naics_code), "2381") ~ "125",
    startsWith(as.character(naics_code), "2381") ~ "125",
    startsWith(as.character(naics_code), "9221") ~ "534",
    startsWith(as.character(naics_code), "926") ~ "530",))

#create additional crosswalk
naics_crosswalk_addition_2 <- DHSContracts_NA %>%
  select(implan_code, naics_code)
naics_crosswalk_addition_2 <- distinct(naics_crosswalk_addition_2)
naics_to_implan <- rbind(naics_to_implan, naics_crosswalk_addition_2)

DHSContracts <- DHSContracts %>%
  select(-implan_code)
DHSContracts  <- merge(DHSContracts, naics_to_implan, by = ("naics_code"), all.x = TRUE, all.y = FALSE)

DHSContracts <- DHSContracts %>%
  select("federal_action_obligation", "recipient_county_name", "recipient_congressional_district", "implan_code") %>%
  rename(county = recipient_county_name, district = recipient_congressional_district)

# VA GRANTS
VAGrants  <- merge(VAGrants, business_to_implan, by = ("business_types_description"), all.x = TRUE, all.y = FALSE) #merge with business to implan bridge
VAGrants$implan_code[VAGrants$recipient_name == "UNIVERSITY OF CALIFORINA FULLERTON"] <- 531 #reassign some entries
VAGrants$implan_code[VAGrants$recipient_name == "THE UNIVERSITY CORPORATION LOS ANGELES"] <- 524
VAGrants$implan_code[VAGrants$recipient_name == "THE UNIVERSITY CORPORATION"] <- 524
VAGrants <- VAGrants %>%
  select("federal_action_obligation", "county", "district", "implan_code") #select needed columns

# VA CONTRACTS
VAContracts  <- merge(VAContracts, naics_to_implan, by = ("naics_code"), all.x = TRUE, all.y = FALSE) #merge with NAICS to IMPLAN crosswalk
VAContracts$implan_code[VAContracts$naics_code == 532291] <- 412 #reassign some entries
VAContracts$implan_code[VAContracts$naics_code == 922130] <- 534
VAContracts$implan_code[VAContracts$naics_code == 926150] <- 530
VAContracts <- VAContracts %>%
  select("federal_action_obligation", "recipient_county_name", "recipient_congressional_district", "implan_code") %>%
  rename(county = recipient_county_name, district = recipient_congressional_district)


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

