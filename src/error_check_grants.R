# This code checks grant data for errors and where possible, fixes them

# Load in grants data and grants-related implan crosswalk
grants <- read.csv(file.path(getwd(), "data", "temp", g_out_name))
btype2implan <- read.csv(file = "data/raw/business_type_to_implan546_crosswalk.csv", fileEncoding="UTF-8-BOM")

#Prior to running crosswalk - pull out the VA direct payments/benefits data - this does not get matched with an IMPLAN code - and write into CSV file

va_benefits <- grants %>%
  filter(grants$assistance_type_code == 10)
grants <- grants %>%
  filter(!(grants$assistance_type_code == 10))

write.csv(va_benefits, file.path(getwd(), "data", "temp", paste0(year, "_cleaned_usaspending_va_benefit_data.csv")))

# start first crosswalk error check of grants data to IMPLAN codes

grants <- merge(grants, btype2implan, by = ("business_types_description"), all.x = TRUE, all.y = FALSE)

#Now pull out grants' errors that did not get matched with an IMPLAN code

grants_no_implan <- grants[is.na(grants$implan_code),]
grants <- grants[!(is.na(grants$implan_code)),]

#Save the grants' errors to "Output" folder - named "grants_no_implan_code" - and the grants data to "temp" folder

write.csv(grants_no_implan, paste("output/grants_no_implan_code.csv", sep = '')) 

write.csv(grants, file.path(getwd(), "data", "temp", paste0(year, "_cleaned_usaspending_grant_data.csv")))
