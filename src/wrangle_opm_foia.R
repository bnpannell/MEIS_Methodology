##Employment calculations for civilian employment using OPM FOIA data##

#First read in Excel file retrieved from OPM FOIA - then rename columns, remove unneeded rows, and ensure the "total" column is numeric
opm_emp <- read.xlsx(file.path(getwd(), "data", "raw", opm_foia_file))

colnames(opm_emp) <- c("file_date", "agency", "agency_sub", "state", "county", "city", "total")
opm_emp <- opm_emp[-c(1,2),]
opm_emp$total <- as.numeric(opm_emp$total)

#Aggregate the "total" employees column based on agency and file_date. 
#Question for Patrick and Britnee: Why doesn't the first method work, but the other 2 do?

opm_emp_counties <- opm_emp %>%
  aggregate(opm_emp$total, by=list(opm_emp$file_date, opm_emp$agency, opm_emp$county), FUN = sum)

opm_emp_counties <- opm_emp %>%
  group_by(file_date, agency, county) %>%
  summarise(employees = sum(total))

opm_emp_counties <- aggregate(total ~ file_date + agency + county, data = opm_emp, FUN = sum, na.rm = TRUE)