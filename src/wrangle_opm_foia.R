##Employment calculations for civilian employment using OPM FOIA data##

#First read in Excel file retrieved from OPM FOIA - then rename columns, remove unneeded rows, and ensure the "total" column is numeric
opm_emp <- read.xlsx(file.path(raw_path, opm_foia_file))

colnames(opm_emp) <- c("file_date", "agency", "agency_sub", "state", "county", "city", "total")
opm_emp <- opm_emp[-c(1,2),]
opm_emp <- opm_emp %>%
  select(-agency_sub)
opm_emp$total <- as.numeric(opm_emp$total)

#Aggregate the "total" employees column based on agency and file_date. 
opm_emp_counties <- opm_emp %>%
  group_by(file_date, agency, county) %>%
  summarise(employees = sum(total))

#Transpose the dataframe - we need the county as the row, agency as the column, and employees as the cell value.
opm_emp_counties <- opm_emp_counties %>%
  spread(agency, employees)

#Rename columns, drop DoD-related agency columns/rows (OPM FOIA didn't specify them by county), and then change NAs to 0
colnames(opm_emp_counties) <- c("file_date", "county", "airforce_emp", "army_emp", "dod_emp", "doe_emp", "dhs_emp", "navy_emp", "va_emp")

opm_emp_counties <- opm_emp_counties %>%
  select("file_date", "county", "doe_emp", "dhs_emp", "va_emp") %>%
  filter(!(county == "DOD COUNTY REDACTED"))

opm_emp_counties[is.na(opm_emp_counties)] = 0