##GRANTS DATA - read in CSV and fix up congressional district and county fips code columns
grants <- read.csv(file.path(temp_path, paste0(f_year, all_g_data)))

grants <- grants %>%
  rename("recipient_congressional_district" = prime_award_transaction_recipient_cd_current,
         "recipient_county_code" = prime_award_transaction_recipient_county_fips_code)

grants$recipient_congressional_district <- gsub("CA-", "", grants$recipient_congressional_district) %>%
  as.numeric(grants$recipient_congressional_district)

grants$recipient_county_code <- as.numeric(substring(grants$recipient_county_code, 2))

#Now read in the business type to IMPLAN crosswalk - this will help us assign IMPLAN codes to grants
btype2implan <- read.csv(file.path(raw_path, paste0(btype_crosswalk)), fileEncoding="UTF-8-BOM")

#Prior to running crosswalk - pull out the VA direct payments/benefits data - this does not get matched with an IMPLAN code - and write into CSV file
va_benefits <- grants %>%
  filter(grants$assistance_type_code == 10 | grants$assistance_type_code == 6)
grants <- grants %>%
  filter(!(grants$assistance_type_code == 10 | grants$assistance_type_code == 6))

#start first crosswalk error check of grants data to IMPLAN codes
grants <- merge(grants, btype2implan, by = ("business_types_description"), all.x = TRUE, all.y = FALSE)

#Fix issues with special characters in grants' award description column, and then run the tier 1 check function on grants
grants$transaction_description <- gsub("/","",
                                 gsub(",","",
                                      gsub(r"(\\)","",
                                           gsub('"',"", as.character(grants$transaction_description)))))