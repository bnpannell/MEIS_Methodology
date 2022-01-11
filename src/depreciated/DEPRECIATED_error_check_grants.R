## Error check usaspending grants data ##

## See depreciated methodology section for details on manual fix to usaspending grants and grants Excel sheets prior to running below code
# Assuming that all manual fixes have been implemented

# Load in grants CSV into dataframe
grants <- read.csv(file.path(getwd(), "data", "temp", paste0("DEPRECIATED_", g_out_name)))

#PRIOR to applying crosswalk - take out VA benefits entries. These do not get assigned to an IMPLAN code.
va_benefits <- grants %>%
  filter(grants$assistance_type_code == 10)
grants <- grants %>%
  filter(!(grants$assistance_type_code == 10))

# Load in Business type to IMPLAN crosswalk
business_to_implan <- read.csv(file = "data/raw/business_type_to_implan546_crosswalk.csv", stringsAsFactors = FALSE, fileEncoding="UTF-8-BOM")

# Apply crosswalk to grants, and check for entries that do not get matched to an IMPLAN code
grants <- merge(grants, business_to_implan, by = ("business_types_description"), all.x = TRUE, all.y = FALSE)

# For entries with no NAICS code at all - manually assign IMPLAN codes based on recipient's industry
grants$implan_code[grants$recipient_name == "UNIVERSITY OF CALIFORINA FULLERTON"] <- 531 #reassign some entries
grants$implan_code[grants$recipient_name == "THE UNIVERSITY CORPORATION LOS ANGELES"] <- 524
grants$implan_code[grants$recipient_name == "THE UNIVERSITY CORPORATION"] <- 524
grants$implan_code[grants$recipient_name == "CALIFORNIA INSTITUTE OF TECHNOLOGY"] <- 481
grants$implan_code[grants$recipient_name == "CONTRA COSTA MOSQUITO AND VECTOR CONTROL DISTRICT"] <- 476
grants$implan_code[grants$recipient_name == "LELAND STANFORD JUNIOR UNIVERSITY, THE"] <- 481


#Take out grant entries that were not assigned an IMPLAN code, and manually code them. Remove these entries from the original "grants" dataframe

grants_missing_implan <- grants %>%
  filter(is.na(implan_code))

grants <- grants %>%
  filter(!(is.na(implan_code)))

# Rbind grants_missing_implan back into original grants dataframe
grants <- rbind(grants, grants_missing_implan)

#select needed columns
grants <- grants %>%
  select("federal_action_obligation", "recipient_county_name", "recipient_congressional_district", "implan_code")

# Write grants and VA benefits CSVs into temp folder
write.csv(grants, file.path(getwd(), "data", "temp", paste0(year, "_DEPRECIATED_cleaned_usaspending_grant_data.csv")), row.names = FALSE)
write.csv(va_benefits, file.path(getwd(), "data", "temp", paste0(year, "_DEPRECIATED_cleaned_usaspending_va_benefits_data.csv")), row.names = FALSE)