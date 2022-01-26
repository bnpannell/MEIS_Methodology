## EMPLOYMENT CALCULATIONS FOR NATIONAL SECURITY MILITARY AND CIVLIAN EMPLOYEES ##

##Read in CSV file that contains statewide employment numbers, and define the values for statewide military, civilian, and DOE employees
#NOTE: Be sure to go into this file and appropriately edit the numbers for your state of interest

state_emp <- read.csv(file.path(getwd(), "data", "raw", paste0(state,"_emp.csv")), fileEncoding="UTF-8-BOM")

mili_emp = state_emp[1,1] + (state_emp[1,2] * res_mult)
civilian_emp = state_emp[1,3] + (national_sus_dhs * sus_dhs_mult) + state_emp[1,4] + sum(state_emp[1,5:8])
doe_emp = state_emp[1,9] * doe_ns_adjustment

## FILES NEEDED ##
  # 2019_ACS.xlsx
  # DOD_County_Shares_R.xlsx
  # fed_prop_2021.csv

## FIRST START WITH MILITARY EMPLOYMENT ##

# Read in CSV file with 2019 ACS 5-year estimate data per county and district and select needed columns
miliemp <- read_excel("2019_ACS.xlsx")
miliemp <- miliemp %>% select(geography, armed_forces_employed)

# Now, create a new column of armed_forces_percent by dividing each geography's armed_forces_employed by the statewide total armed_forces_employed

miliemp <- miliemp %>% mutate(armed_forces_percent = miliemp$armed_forces_employed / miliemp$armed_forces_employed[112])

# Pull the total number of FTE military employees in California from DMDC September 2020 file - 167,761 active duty and 57,100 national guard/reservists (must be multiplied by 0.1825 for FTEs)
# Then, multiply this figure by armed_forces_percent to get the military employees in California across all counties and districts

mili_FTEs <- 167761 + (57100 * 0.1825)
mili_notFTEs <- 167761 + 57100

miliemp <- miliemp %>% mutate(military_employees_FTEs = mili_FTEs * miliemp$armed_forces_percent,
                              military_employees_notFTEs = mili_notFTEs * miliemp$armed_forces_percent)

# Select the geography and military_employees columns, and clean up names of the geography to just have county name or district number

miliemp <- miliemp %>% select(geography, military_employees_FTEs, military_employees_notFTEs)

miliemp$geography <- gsub(pattern = " County, California", replacement = "", miliemp$geography)

miliemp$geography <- gsub(pattern = "Congressional District ([0-9]+) \\(116th Congress\\), California",
                          replacement = "\\1",
                          miliemp$geography)

miliemp$geography = toupper(miliemp$geography)

#I'm certain there's a better way to split up this dataframe, but this is the best I got today
mili_county <- miliemp %>% filter(is.na(as.numeric(miliemp$geography))) %>%
  filter(!(geography == "CALIFORNIA"))
mili_county <- mili_county %>%
  rename(county = geography, mili_emp_FTEs = military_employees_FTEs, mili_emp_notFTEs = military_employees_notFTEs)

mili_district <- miliemp %>% filter(!is.na(as.numeric(miliemp$geography)))
mili_district <- mili_district %>%
  rename(district = geography, mili_emp_FTEs = military_employees_FTEs, mili_emp_notFTEs = military_employees_notFTEs)

## NOW, ON TO DOD CIVILIAN EMPLOYMENT ##
# Read in DOD_County_Shares_R.xlsx, which will help us distribute DOD civilian employees by county and district
# Sheet 1 is for counties' 2016 share of DOD employees in CA, while Sheet 2 is for districts and how much they encompasses a county(ies)
dodemp_county <- read_excel("DOD_County_Shares_R.xlsx")
dodemp_district <- read_excel("DOD_County_Shares_R.xlsx", sheet = 2)

# First calculate DOD civilian employees by county - there were 63,548 DOD civilian employees in CA for September 2020 (combined from 4 departments: Air Force, Army, Navy, and Defense)
# Multiply that number by the county share column, and select the geography and dod_employees columns
dodemp_county <- dodemp_county %>% 
  mutate("dod_emp" = dodemp_county$Share * 63548) %>%
  select("geography", "dod_emp")

# Now calculate for DOD civilian employees by district - to do this, we merge dodemp_county and dodemp_district.
# Then, we can multiply the dod_county_employees by each district's share of a county, and aggregate by district to get our total amount of DOD civilian employees per district
dodemp_district <- merge(dodemp_county, dodemp_district)

dodemp_district <- dodemp_district %>% 
  mutate("dod_emp" = dodemp_district$dod_emp * dodemp_district$`%`) %>%
  select(District, dod_emp)

dodemp_district <- aggregate(dodemp_district, by = list(dodemp_district$District), FUN = sum) %>%
  select("Group.1", "dod_emp") %>% 
  rename(district = "Group.1")

dodemp_county <- dodemp_county %>%
  rename(county = "geography")

## VA AND DHS EMPLOYMENT ##
#open fed_prop csv 
fed_prop_21 <- read.csv(file = "fed_prop_2021.csv", stringsAsFactors = FALSE) 

## Create cleaned dataframe  
fed_prop_clean <- fed_prop_21 %>%  
  select(Reporting.Agency, Reporting.Bureau, Real.Property.Type, Real.Property.Use, Square.Feet..Buildings.,  
         Street.Address, State.Name, County.Name, Zip.Code, Congressional.District) %>% #select needed columns 
  rename(Department = Reporting.Agency, Prop_type=Real.Property.Type, #rename columns 
         Prop_use=Real.Property.Use, Sq_ft=Square.Feet..Buildings., Add=Street.Address, county=County.Name,
         district=Congressional.District) %>% 
  filter(State.Name == 'CALIFORNIA') %>% #select only entries in California 
  filter(Prop_type == 'Building') %>% #select only buildings 
  filter(Department == 'VETERANS AFFAIRS' | Department =='HOMELAND SECURITY') #select only these departments 

# Create a dataframe with JUST VA buildings 
VA_21 <- fed_prop_clean %>%  
  filter(Department == 'VETERANS AFFAIRS') #subset only VA buildings 
VA_21$district[VA_21$Zip.Code == '921261077'] <- '52' #Fix districts listed as 0
VA_21$district[VA_21$Zip.Code == '928404665'] <- '46'
VA_21$district[VA_21$Zip.Code == '945341464'] <- '3'
VA_21 <- VA_21 %>%
  mutate(employees = (Sq_ft/14283937)*34641) #find employees per building, round. the 142.. is the total sqft of all VA buildings in CA. 34641 is total VA employees in CA 

#Total employees per county 
VAemp_county_21 <- aggregate(VA_21$employees, by=list(VA_21$county), FUN=sum)  

#Total employees per district 
VAemp_dist_21 <- aggregate(VA_21$employees, by=list(VA_21$district), FUN=sum) 

#rename columns
colnames(VAemp_county_21) <- c("county", "va_emp")
colnames(VAemp_dist_21) <- c("district", "va_emp")

# Create a dataframe with JUST DHS buildings 
DHS_21 <- fed_prop_clean %>%  
  filter(Department == 'HOMELAND SECURITY') %>% #subset only DHS buildings 
  mutate(employees = (Sq_ft/2112786)*(2526+(155282*.142))) #find employees per building. The 2526+(155282*.142) is for DHS's suppressed employees for Sept 2020. Devin gave us the .142 number
DHS_21$county[DHS_21$county == "UNKNOWN"] <- "LOS ANGELES"

DHSemp_county_21 <- aggregate(DHS_21$employees, by=list(DHS_21$county), FUN=sum) #total employees per county 
DHSemp_dist_21 <- aggregate(DHS_21$employees, by=list(DHS_21$district), FUN=sum) #total employees per district 
DHSemp_dist_21$Group.1 <- as.numeric(DHSemp_dist_21$Group.1)

#rename columns
colnames(DHSemp_county_21) <- c("county", "dhs_emp")
colnames(DHSemp_dist_21) <- c("district", "dhs_emp")

#these should be nested, but I forgot how :( 
county_employees_21 <- merge(DHSemp_county_21, VAemp_county_21, by = "county", all = TRUE)
county_employees_21 <- merge(county_employees_21, dodemp_county, by = "county", all = TRUE)
county_employees_21 <- merge(county_employees_21, mili_county, by = "county", all = TRUE)

district_employees_21 <- merge(DHSemp_dist_21, VAemp_dist_21, by = "district", all = TRUE)
district_employees_21 <- merge(district_employees_21, dodemp_district, by = "district", all = TRUE)
district_employees_21 <- merge(district_employees_21, mili_district, by = "district", all = TRUE)

county_employees_21[is.na(county_employees_21)] <- 0
district_employees_21[is.na(district_employees_21)] <- 0

county_employees_21$dhs_emp <- as.numeric(county_employees_21$dhs_emp)
county_employees_21$va_emp <- as.numeric(county_employees_21$va_emp)
county_employees_21$dod_emp <- as.numeric(county_employees_21$dod_emp)
county_employees_21$mili_emp_FTEs <- as.numeric(county_employees_21$mili_emp_FTEs)
county_employees_21$mili_emp_notFTEs <- as.numeric(county_employees_21$mili_emp_notFTEs)


district_employees_21$district <- as.numeric(district_employees_21$district)
district_employees_21$dhs_emp <- as.numeric(district_employees_21$dhs_emp)
district_employees_21$va_emp <- as.numeric(district_employees_21$va_emp)
district_employees_21$dod_emp <- as.numeric(district_employees_21$dod_emp)
district_employees_21$mili_emp_FTEs <- as.numeric(district_employees_21$mili_emp_FTEs)
district_employees_21$mili_emp_notFTEs <- as.numeric(district_employees_21$mili_emp_notFTEs)

county_employees_21 <- county_employees_21 %>%
  mutate(implan_545 = mili_emp_FTEs,
         implan_546 = (dhs_emp+va_emp+dod_emp),
         total_input_emp = (dhs_emp+va_emp+dod_emp+mili_emp_notFTEs))
district_employees_21 <- district_employees_21 %>%
  mutate(implan_545 = mili_emp_FTEs,
         implan_546 = (dhs_emp+va_emp+dod_emp),
         total_input_emp = (dhs_emp+va_emp+dod_emp+mili_emp_notFTEs))

# Final step: Write miliemp and dodemp into an Excel sheet
emp_totals_2021 <- list("County" = county_employees_21, "District" = district_employees_21)

write.xlsx(emp_totals_2021, paste0("2021_employment_totals.xlsx"))
