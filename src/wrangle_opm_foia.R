##Employment calculations for civilian employment using OPM FOIA data##

#First read in Excel file retrieved from OPM FOIA - then rename columns, remove unneeded rows, and ensure the "total" column is numeric
opm_emp <- read.xlsx(file.path(raw_path, opm_foia_file))

colnames(opm_emp) <- c("file_date", "agency", "agency_sub", "state", "county", "city", "total")
opm_emp <- opm_emp[-c(1,2),]
opm_emp <- opm_emp %>%
  select(-agency_sub)
opm_emp$total <- as.numeric(opm_emp$total)

#Filter for the most recent year of FOIA data, and Aggregate the "total" employees column based on agency and file_date. 
opm_emp_counties <- opm_emp %>%
  filter(file_date == 202009) %>%
  group_by(agency, county) %>%
  summarise(employees = sum(total))

#Transpose the dataframe - we need the county as the row, agency as the column, and employees as the cell value.
opm_emp_counties <- opm_emp_counties %>%
  spread(agency, employees)

#Rename columns, drop DoD-related agency columns/rows (OPM FOIA didn't specify them by county), and then change NAs to 0
colnames(opm_emp_counties) <- c("county", "airforce_emp", "army_emp", "dod_emp", "doe_emp", "dhs_emp", "navy_emp", "va_emp")

dhs_va_emp_counties <- opm_emp_counties %>%
  filter(!(county == "DOD COUNTY REDACTED")) %>%
  select("county", "dhs_emp", "va_emp")

dhs_va_emp_counties[is.na(dhs_va_emp_counties)] = 0

#Read in VA employees crosswalk to get employment numbers by district
va_emp_cw <- read.csv(file.path(raw_path, "va_emp_sqft_crosswalk.csv"))

va_emp_cw <- va_emp_cw[c("county", "district", "multiplier")]

#Merge the crosswalk to the opm_emp_counties dataframe to get the va_emp for districts

dhs_va_emp_counties <- merge(dhs_va_emp_counties, va_emp_cw, by = "county")

dhs_va_emp_counties <- dhs_va_emp_counties %>%
  mutate(va_emp_dist = va_emp * multiplier)

#Split out the data by geography
va_emp_dist <- dhs_va_emp_counties %>%
  select(district, va_emp_dist)
va_emp_dist <- aggregate(va_emp_dist$va_emp_dist, by = list(va_emp_dist$district), FUN = sum)
colnames(va_emp_dist) <- c("district", "va_emp")
va_emp_dist$va_emp <- round(va_emp_dist$va_emp, digits = 0)

dhs_va_emp_counties <- dhs_va_emp_counties %>%
  select(county, va_emp, dhs_emp)
dhs_va_emp_counties <- unique(dhs_va_emp_counties)

#Combine this dataframe with counties_pop dataframe for regression analysis. Write into file
#dhs_va_emp <- full_join(opm_emp_counties, counties_armedforces, by = "county")
#dhs_va_emp[is.na(dhs_va_emp)] = 0

#write.csv(dhs_va_emp, "dhs_va_emp_armedforces_comparison.csv", row.names = FALSE)

#Create 2 new columns that calculates the percentage that each county represents the statewide total for DHS and VA employment
#opm_emp_counties <- opm_emp_counties %>%
#  mutate(dhs_emp_perc = dhs_emp / sum(dhs_emp),
#         va_emp_perc = va_emp / sum(va_emp))