## EMPLOYMENT CALCULATIONS FOR NATIONAL SECURITY MILITARY AND CIVLIAN EMPLOYEES ##

##Read in CSV file that contains statewide employment numbers, and define the values for statewide military, civilian, and DOE employees
#NOTE: Be sure to go into this file and appropriately edit the numbers for your state of interest

state_emp <- read.csv(file.path(getwd(), "data", "raw", paste0(state,"_emp.csv")), fileEncoding="UTF-8-BOM")

mili_emp = state_emp[1,1] + (state_emp[1,2] * res_mult)
dod_emp = sum(state_emp[1,5:8])
dhs_emp = state_emp[1,3] + (national_sus_dhs * sus_dhs_mult)
va_emp = state_emp[1,4]
civilian_emp = dod_emp + dhs_emp + va_emp
doe_emp = state_emp[1,9] * doe_ns_adjustment

##Begin apportioning military and civilian employment by county and district, sectioning off based on employment type##
##Start out with military employment - use ACS data. First clean up the ACS dataframe to format entries as needed.

acs_data <- read_excel(file.path(getwd(), "data", "temp", acs)) %>%
  select(geography, armed_forces_employed)

acs_data$geography <- gsub(pattern = " County, California", replacement = "", acs_data$geography)
acs_data$geography <- gsub(pattern = "Congressional District ([0-9]+) \\(116th Congress\\), California",
                           replacement = "\\1", acs_data$geography)
acs_data$geography = toupper(acs_data$geography)

#Calculate armed_forces_percent by dividing each geography's armed_forces_employed by the statewide total. Then multiply that percent by mili_emp to get military employees for each local geography.
acs_data <- acs_data %>% mutate(armed_forces_percent = (acs_data$armed_forces_employed / acs_data$armed_forces_employed[112]),
                      military_personnel = mili_emp * armed_forces_percent) %>%
  select(geography, military_personnel)

#Separate county military personnel and district military personnel into 2 dataframes. Localized military personnel is done.
mili_county <- acs_data %>% filter(is.na(as.numeric(acs_data$geography))) %>%
  filter(!(geography == "CALIFORNIA"))
mili_county <- mili_county %>%
  rename(county = geography, mili_emp = military_personnel)

mili_district <- acs_data %>% filter(!is.na(as.numeric(acs_data$geography)))
mili_district <- mili_district %>%
  rename(district = geography, mili_emp = military_personnel)


##Next is DOD civilian employment - use DOD County Shares Excel file##
dod_shares_county <- read_excel(file.path(getwd(), "data", "raw", dod_shares), sheet = 1)
dod_shares_district <- read_excel(file.path(getwd(), "data", "raw", dod_shares ), sheet = 2)

#Start out by calculating DOD employment by county - multiply the county share percentage by the statewide DOD employees to get each county's DOD employees
dod_county <- dod_shares_county %>%
  mutate("dod_emp" = dod_shares_county$Share * dod_emp) %>%
  select("geography", "dod_emp")

#Use the dod_county values to calculate the DOD employment by district. Multiply the DOD county_employees by each district's share of a county, and aggregate by district to get our total amount of DOD civilian employees per district
dod_district <- merge(dod_county, dod_shares_district)

dod_district <- dod_district %>%
  mutate("dod_emp" = dod_district$dod_emp * dod_district$`%`) %>%
  select(District, dod_emp)
dod_district <- aggregate(dod_district, by = list(dod_district$District), FUN = sum) %>%
  select("Group.1", "dod_emp") %>%
  rename(district = "Group.1")

dod_county <- dod_county %>%
  rename(county = "geography")

##Last employment data to localize is VA and DHS employment - use fedprop CSV file##
fedprop <- read.csv(file.path(getwd(), "data", "temp", fed_prop), stringsAsFactors = FALSE) %>%  
  select(Reporting.Agency, Reporting.Bureau, Real.Property.Type, Real.Property.Use, Square.Feet..Buildings.,  
         Street.Address, State.Name, County.Name, Zip.Code, Congressional.District) %>%
  rename(Department = Reporting.Agency, Prop_type=Real.Property.Type,
         Prop_use=Real.Property.Use, Sq_ft=Square.Feet..Buildings., Add=Street.Address, county=County.Name,
         district=Congressional.District) %>% 
  filter(State.Name == state) %>% #select only entries in California 
  filter(Prop_type == "Building") %>% #select only buildings 
  filter(Department == "VETERANS AFFAIRS" | Department == "HOMELAND SECURITY")

##First start with working through VA - limit fedprop to VA entries, and clean up some missing 0's in districts column.
va_fedprop <- fedprop %>%
  filter(Department == "VETERANS AFFAIRS")
va_fedprop$district[va_fedprop$Zip.Code == "921261077"] <- "52"
va_fedprop$district[va_fedprop$Zip.Code == "928404665"] <- "46"
va_fedprop$district[va_fedprop$Zip.Code == "945341464"] <- "3"

#Calculate the number of VA employees across each entry, and then aggregate by county and district to get the localized numbers.
va_fedprop <- va_fedprop %>%
  mutate(employees = (Sq_ft/(sum(Sq_ft)))*va_emp)

va_county <- aggregate(va_fedprop$employees, by=list(va_fedprop$county), FUN=sum) %>%
  rename(county = Group.1, va_emp = x)

va_district <- aggregate(va_fedprop$employees, by=list(va_fedprop$district), FUN=sum) %>%
  rename(district = Group.1, va_emp = x)

# Now do the same process as VA employment for DHS
dhs_fedprop <- fedprop %>%
  filter(Department == "HOMELAND SECURITY") %>%
  mutate(employees = (Sq_ft/(sum(Sq_ft)))*dhs_emp)
dhs_fedprop$county[dhs_fedprop$county == "UNKNOWN"] <- "LOS ANGELES"

dhs_county <- aggregate(dhs_fedprop$employees, by=list(dhs_fedprop$county), FUN=sum) %>%
  rename(county = Group.1, dhs_emp = x)

dhs_district <- aggregate(dhs_fedprop$employees, by=list(dhs_fedprop$district), FUN=sum) %>%
  rename(district = Group.1, dhs_emp = x)
dhs_district$district[dhs_district$district == "02"] <- "2"
dhs_district$district[dhs_district$district == "03"] <- "3"
dhs_district$district[dhs_district$district == "05"] <- "5"
dhs_district$district[dhs_district$district == "06"] <- "6"
dhs_district$district[dhs_district$district == "09"] <- "9"


##Merge the county employee dataframes into one dataframe, and the district employees dataframes into a second dataframe. Make sure all values are numeric, and replace NAs with 0s.
county_emp <- Reduce(function(x,y) merge(x = x, y = y, by = "county", all = TRUE), list(dhs_county, va_county, dod_county, mili_county))
county_emp[2:5] <- lapply(county_emp[2:5], as.numeric)
county_emp[is.na(county_emp)] <- 0

district_emp <- Reduce(function(x,y) merge(x = x, y = y, by = "district", all = TRUE), list(dhs_district, va_district, dod_district, mili_district))
district_emp[1:5] <- lapply(district_emp[1:5], as.numeric)
district_emp[is.na(district_emp)] <- 0


##Final step: mutate dataframes to get columns needed for the for loop code##
county_emp <- county_emp %>%
  mutate(implan_545 = mili_emp,
         implan_546 = (dhs_emp+va_emp+dod_emp),
         inverse_545 = (sum(mili_emp) - mili_emp),
         inverse_546 = (sum(implan_546) - implan_546))

district_emp <- district_emp %>%
  mutate(implan_545 = mili_emp,
         implan_546 = (dhs_emp+va_emp+dod_emp))