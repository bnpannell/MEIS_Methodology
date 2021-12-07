##Pseudo Code for file

# Copy over hard code fixes (if simple) to change lines of "multi_implan_codes" to reflect correct IMPLAN code assignments

###CODE BELOW FROM "county_district_spending_aggregates_2021.R" 

#NAICS to IMPLAN
naics_to_implan <- read_excel("Bridge_2017NaicsToImplan546.xlsx")
naics_to_implan <- naics_to_implan %>%
  select("Implan546Index", "2017NaicsCode") %>%
  rename(implan_code = "Implan546Index", naics_code = "2017NaicsCode")
naics_to_implan$implan_code[naics_to_implan$naics_code == 335220] <- 327
naics_to_implan$implan_code[naics_to_implan$naics_code == 332117] <- 231
naics_to_implan <- naics_to_implan[!duplicated(naics_to_implan), ] #delete duplicate rows