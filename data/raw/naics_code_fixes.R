##Pseudo Code for file

# Copy over hard code fixes (if simple) to change lines of "naics_code_errors" to reflect correct IMPLAN code assignments

###CODE BELOW FROM "county_district_spending_aggregates_2021.R" 

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
    startsWith(as.character(naics_code), "54171") ~ "398",
    startsWith(as.character(naics_code), "921") ~ "531",
    startsWith(as.character(naics_code), "9221") ~ "534",
    startsWith(as.character(naics_code), "928") ~ "528",
    startsWith(as.character(naics_code), "9231") ~ "531",
    startsWith(as.character(naics_code), "924") ~ "534",
    startsWith(as.character(naics_code), "926") ~ "530",
    startsWith(as.character(naics_code), "927") ~ "528",))
