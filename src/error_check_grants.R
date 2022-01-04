# Place holder for code to error check grants data

# Load in files, start first crosswalk error check of grants data to IMPLAN codes
grants <- read.csv(file.path(getwd(), "data", "temp", g_out_name))
btype2implan <- read.csv(file = "data/raw/business_type_to_implan546_crosswalk.csv", fileEncoding="UTF-8-BOM")

grants <- merge(grants, btype2implan, by = ("business_types_description"), all.x = TRUE, all.y = FALSE)

#output <- file.path(getwd(), "output")


#Run code and pull out data that do not have NAICS codes

grants_no_implan <- grants[is.na(grants$implan_code),]
grants <- grants[!(is.na(grants$implan_code)),]

#Save to "Output" folder- named "no_naics_code"

write.csv(grants_no_implan, paste("output/grants_no_implan_code.csv", sep = '')) #should we use output variable defined above here?



# DOD GRANTS
#DODGrants <- DODGrants21 %>%
#  filter(primary_place_of_performance_state_name == "CALIFORNIA") %>%
#  select("federal_action_obligation", "recipient_name", "recipient_county_name", "recipient_congressional_district", 
#         "business_types_description") %>% #select needed columns
#  rename(county = "recipient_county_name", district = "recipient_congressional_district")
#DODGrants  <- merge(DODGrants, business_to_implan, by = ("business_types_description"), all.x = TRUE, all.y = FALSE) #merge with business to implan bridge
#DODGrants <- DODGrants %>%
#  select("federal_action_obligation", "county", "district", "implan_code") #select needed columns


# VA GRANTS
#VAGrants <- VAGrants21 %>%
#  filter(primary_place_of_performance_state_name == "CALIFORNIA") %>%
#  select("federal_action_obligation", "recipient_name", "recipient_county_name", "recipient_congressional_district", 
#         "business_types_description") %>% #select needed columns
# rename(county = "recipient_county_name", district = "recipient_congressional_district")
#VAGrants  <- merge(VAGrants, business_to_implan, by = ("business_types_description"), all.x = TRUE, all.y = FALSE) #merge with business to implan bridge
#VAGrants$implan_code[VAGrants$recipient_name == "UNIVERSITY OF CALIFORINA FULLERTON"] <- 531 #reassign some entries
#VAGrants$implan_code[VAGrants$recipient_name == "THE UNIVERSITY CORPORATION LOS ANGELES"] <- 524
#VAGrants$implan_code[VAGrants$recipient_name == "THE UNIVERSITY CORPORATION"] <- 524
#VAGrants <- VAGrants %>%
#  select("federal_action_obligation", "county", "district", "implan_code") #select needed columns