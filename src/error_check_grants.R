##GRANTS DATA - read in CSV
grants <- read.csv(file.path(temp_path, paste0(f_year, all_g_data)))

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
grants$award_description <- gsub("/","",
                                 gsub(",","", as.character(grants$award_description)))