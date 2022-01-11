## Error check usaspending contracts data ##

## See depreciated methodology section for details on manual fix to usaspending contracts and grants Excel sheets prior to running below code
# Assuming that all manual fixes have been implemented

# Load in contracts CSV into dataframe
contracts <- read.csv(file.path(getwd(), "data", "temp", paste0("DEPRECIATED_", c_out_name)))

# Load in NAICS to IMPLAN crosswalk
naics_to_implan <- read.xlsx(xlsxFile = "data/raw/depreciated/2017_implan_online_naics_to_implan546.xlsx")
naics_to_implan <- naics_to_implan %>%
  select("Implan546Index", "2017NaicsCode") %>%
  rename(implan_code = "Implan546Index", naics_code = "2017NaicsCode") %>%
  distinct(naics_code, implan_code, .keep_all = TRUE)
naics_to_implan$implan_code[naics_to_implan$naics_code == 335220] <- 327
naics_to_implan$implan_code[naics_to_implan$naics_code == 332117] <- 231
naics_to_implan <- naics_to_implan[!duplicated(naics_to_implan), ] #delete duplicate rows

# this gives you any codes where naics is paired up with multiple implan_codes
# naics_to_implan[duplicated(naics_to_implan$naics_code),]


# Apply crosswalk to contracts, and check for entries that do not have a NAICS code
contracts <- merge(contracts, naics_to_implan, by = ("naics_code"), all.x = TRUE, all.y = FALSE)

# For entries with no NAICS code at all - manually assign IMPLAN codes based on recipient's industry
contracts$implan_code[contracts$recipient_name == "IMPERIAL IRRIGATION DISTRICT INC"] <- 530
contracts$implan_code[contracts$recipient_name == "KAMP SYSTEMS, INC"] <- 244
contracts$implan_code[contracts$recipient_name == "SCIENCE APPLICATIONS INTERNATIONAL CORPORATION"] <- 459
contracts$implan_code[contracts$recipient_name == "DRS SENSORS & TARGETING SYSTEMS, INC."] <- 514
contracts$implan_code[contracts$recipient_name == "KEYSTONE ENGINEERING COMPANY I"] <- 457

#Take out contract entries that were not assigned an IMPLAN code, and manually code them. Remove these entries from the original "contracts" dataframe
contracts_missing_implan <- contracts %>%
  filter(is.na(implan_code)) %>%
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

contracts <- contracts %>%
  filter(!(is.na(implan_code)))

# Rbind contracts_missing_implan back into original contracts dataframe
contracts <- rbind(contracts, contracts_missing_implan)

#select needed columns
contracts <- contracts %>%
  select("federal_action_obligation", "recipient_county_name", "recipient_congressional_district", "implan_code")

# Write contracts CSV into temp folder
write.csv(contracts, file.path(getwd(), "data", "temp", paste0(year, "_DEPRECIATED_cleaned_usaspending_contract_data.csv")), row.names = FALSE)