## DETAILED SPREADSHEET OF DISTRICT INPUT AND OUTPUT DATA ##


## FILES NEEDED ##
# INPUT DATA FILES
  # county_district_investment_aggregates_2021.R <- R code that gave us all the input data for all regions (for our reference)
  # usa_spending_clean_2021.xlsx <- Gives us all the event value spending for all regions
  # Smartpay_FY_2020.xlsx <- Gives us all the SmartPay data for all regions
  # VA_Direct_Payments_Recipient_USA_CA.csv <- Gives us household spending change per each region
  # 2021_employment_totals.xlsx <- Gives us employment data per each district
# OUTPUT DATA FILES
  # district_economic_indicators_2021.xlsx <- Gives us total direct output and employment for each district
  # Economic Indicators Counties 2021.xlsx <- Gives us county output numbers to proportion indirect and induced output
  # county_district_proportion.xlsx <- Gives us the percentages for proportioning indirect and induced output and employment for each district
  # District Regions.xlsx <- For regionalizing the district data
  # 2019_ACS.xlsx <- for districts' employment numbers (2019)
  # 2019_ACS_5yrpop.xlsx <- for districts' population number (2019)
  # 2011_District_Land_Area.xlsx <- for districts' land area

## CLEAR ENVIRONMENT ##

rm(list = ls(all.names = TRUE))


# load packages
library(readxl)
library(dplyr)
library(openxlsx)
library(tidyverse)
library(stringr)


# Set Working Directory

setwd("C:/Users/sumee/OneDrive/Documents/R/2021_iodata")


## START WITH BRINGING IN INPUT DATA (6 STEPS)

## Step 1: Read in and wrangle event value spending Excel sheet ##
## NOTE: This section of code may need to be updated if the County_District_Investment_Aggregates.R code is updated

VAGrants <- read_xlsx("usa_spending_clean_2021.xlsx", sheet = 1)
VAContracts <- read_xlsx("usa_spending_clean_2021.xlsx", sheet = 2)
DODGrants <- read_xlsx("usa_spending_clean_2021.xlsx", sheet = 3)
DODContracts <- read_xlsx("usa_spending_clean_2021.xlsx", sheet = 4)
DHSGrants <- read_xlsx("usa_spending_clean_2021.xlsx", sheet = 5)
DHSContracts <- read_xlsx("usa_spending_clean_2021.xlsx", sheet = 6)

# Select only district and spending data, aggregate by district for each agency's grants and contracts data frame, and rename the respective columns to the proper name.

VAGrants <- VAGrants %>% select(district, federal_action_obligation)
VAGrants <- aggregate(VAGrants$federal_action_obligation, by = list(VAGrants$district), FUN = sum) %>%
  rename(District = Group.1, vagrant_spending = x)

VAContracts <- VAContracts %>% select(district, federal_action_obligation)
VAContracts <- aggregate(VAContracts$federal_action_obligation, by = list(VAContracts$district), FUN = sum) %>%
  rename(District = Group.1, vacontract_spending = x)

DODGrants <- DODGrants %>% select(district, federal_action_obligation)
DODGrants <- aggregate(DODGrants$federal_action_obligation, by = list(DODGrants$district), FUN = sum) %>%
  rename(District = Group.1, dodgrant_spending = x)

DODContracts <- DODContracts %>% select(district, federal_action_obligation)
DODContracts <- aggregate(DODContracts$federal_action_obligation, by = list(DODContracts$district), FUN = sum) %>%
  rename(District = Group.1, dodcontract_spending = x)

DHSGrants <- DHSGrants %>% select(district, federal_action_obligation)
DHSGrants <- aggregate(DHSGrants$federal_action_obligation, by = list(DHSGrants$district), FUN = sum) %>%
  rename(District = Group.1, dhsgrant_spending = x)

DHSContracts <- DHSContracts %>% select(district, federal_action_obligation)
DHSContracts <- aggregate(DHSContracts$federal_action_obligation, by = list(DHSContracts$district), FUN = sum) %>%
  rename(District = Group.1, dhscontract_spending = x)

# DHS Contracts and all grants data frames are missing districts that have $0 spending - we need to add them into each frame. The "md" data frame for each = "missing districts" to add in using the "rbind" function.

VAGrantsmd <- data.frame(c(10, 15, 27, 28, 32, 35, 36, 38, 40, 45, 46, 48, 49),
                         c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
names(VAGrantsmd) <- c("District", "vagrant_spending")
VAGrants <- rbind(VAGrants, VAGrantsmd)

DODGrantsmd <- data.frame(c(4, 11, 21, 25, 29, 36, 38, 40, 48),
                         c(0, 0, 0, 0, 0, 0, 0, 0, 0))
names(DODGrantsmd) <- c("District", "dodgrant_spending")
DODGrants <- rbind(DODGrants, DODGrantsmd)

DHSGrantsmd <- data.frame(c(25, 29, 30, 40, 43),
                         c(0, 0, 0, 0, 0))
names(DHSGrantsmd) <- c("District", "dhsgrant_spending")
DHSGrants <- rbind(DHSGrants, DHSGrantsmd)

DHSContractsmd <- data.frame(c(21),
                             c(0))
names(DHSContractsmd) <- c("District", "dhscontract_spending")
DHSContracts <- rbind(DHSContracts, DHSContractsmd)

# Merge all of these data frames into one, add a column for the total event value spending for each of the districts, and then select only the districts and total spending

VASpend <- merge(VAGrants, VAContracts, by = "District", all = TRUE)
DHSSpend <- merge(DHSGrants, DHSContracts, by = "District", all = TRUE)
DODSpend <- merge(DODGrants, DODContracts, by = "District", all = TRUE)

Event_Value_Spending <- Reduce(function(x,y) merge(x = x, y = y, by = "District"), list(VASpend, DHSSpend, DODSpend))

Event_Value_Spending <- Event_Value_Spending %>% mutate("event_value_spending" = Event_Value_Spending$vagrant_spending +
                                  Event_Value_Spending$vacontract_spending + Event_Value_Spending$dhsgrant_spending +
                                  Event_Value_Spending$dhscontract_spending + Event_Value_Spending$dodgrant_spending +
                                  Event_Value_Spending$dodcontract_spending) %>%
 select("District", "event_value_spending")


## step 2: Read in and wrangle SmartPay Excel sheet, selecting only the district and SmartPay spending by district

SmartPay <- read_xlsx("Smartpay_FY_2020.xlsx", sheet = 1)

SmartPay <- SmartPay %>% select(...10, ...14)

# Remove the NAs, the top and bottom rows, make the spend $$ numeric, and rename the column titles

SmartPay <- na.omit(SmartPay)
SmartPay = SmartPay[-1,]
SmartPay = SmartPay[-54,]
colnames(SmartPay) <- c("District","SmartPay")
SmartPay$SmartPay = as.numeric(as.character(SmartPay$SmartPay))


## Step 3: Read in and wrangle VA Payments CSV (for Household Spending data), selecting only the district and household spending by district. Then aggregate the spending by district, and rename the columns to its respective names.

HouseholdSpending <- read.csv("VA_Direct_Payments_Recipient_USA_CA.csv") %>%
  filter(primary_place_of_performance_state_name == "CALIFORNIA") %>%
  select("recipient_congressional_district", "total_obligated_amount") %>% #select needed columns
  rename(District = "recipient_congressional_district") 

HouseholdSpending <- aggregate(HouseholdSpending$total_obligated_amount, by = list(HouseholdSpending$District), FUN = sum) %>%
  rename(District = Group.1, household_spending = x)


## Step #4: Aggregate all 3 spending data sources by district to get total input spending per district

InputSpending <- Reduce(function(x,y) merge(x = x, y = y, by = "District"), list(Event_Value_Spending, HouseholdSpending, SmartPay))

InputSpending <- InputSpending %>% mutate("input_spending" = InputSpending$event_value_spending +
                                            InputSpending$household_spending +
                                            InputSpending$SmartPay)


## Step 5: Read in 2021 employment totals Excel sheet, grab district, military, and civilian employment, and get the total employment for all districts

InputEmployment <- read.xlsx("2021_employment_totals.xlsx", sheet = 2)

InputEmployment <- InputEmployment %>% rename(District = district, Military_Personnel = mili_emp_notFTEs, Civilian_Personnel = implan_546,
                                              input_employment = total_input_emp) %>%
  select("District", "Civilian_Personnel", "Military_Personnel", "input_employment")


## Step #6: Merge employment and spending data together to get TOTAL input spending and employment for counties

DistrictInputs <- merge(InputSpending, InputEmployment, by = "District", all = TRUE)


## NOW BRING IN OUTPUT DATA (4 STEPS) ##

# Read in the District Economic Indicators Excel sheet for direct output and employment 

district_econ_indicators <- read.xlsx("district_economic_indicators_2021.xlsx")


## Step 1: Direct Output AND Employment - use "district_econ_indicators" and select the district, output/employment impact type, output, and employment columns

DirectDistrictOutput <- district_econ_indicators %>% 
  select ("District", "Impact", "Output") %>%
  mutate(Impact = replace(Impact, Impact == "1 - Direct", "Direct")) %>%
  filter(Impact == "Direct") %>%
  mutate(District = as.numeric(gsub("CA-", "", District))) %>%
  rename(direct_district_output = Output) %>%
  select("District", "direct_district_output")

DirectDistrictEmployment <- district_econ_indicators %>% 
  select ("District", "Impact", "Employment") %>%
  mutate(Impact = replace(Impact, Impact == "1 - Direct", "Direct")) %>%
  filter(Impact == "Direct") %>%
  mutate(District = as.numeric(gsub("CA-", "", District))) %>%
  rename(direct_district_FTE = Employment) %>%
  select("District", "direct_district_FTE")

DirectDistrict <- merge(DirectDistrictOutput, DirectDistrictEmployment, by = "District")

# Now read in the needed files for calculating indirect and induced output and employment

county_econ_indicators <- read.xlsx("Economic Indicators Counties 2021.xlsx")

cd_proportion <- read.xlsx("county_district_proportion.xlsx")


## Step #2: Induced Output and Employment - grab the induced data from the County Econ Indicators file and merge them

InducedCountyOutput <- county_econ_indicators %>% 
  select ("County", "Impact", "total_Output") %>%
  mutate(Impact = replace(Impact, Impact == "3 - Induced", "Induced")) %>%
  filter(Impact == "Induced") %>%
  rename(induced_county_output = total_Output) %>%
  select("County", "induced_county_output")

InducedCountyEmp <- county_econ_indicators %>% 
  select ("County", "Impact", "total_employment") %>%
  mutate(Impact = replace(Impact, Impact == "3 - Induced", "Induced")) %>%
  filter(Impact == "Induced") %>%
  rename(induced_county_employment = total_employment) %>%
  select("County", "induced_county_employment")

InducedCounty <- merge(InducedCountyEmp, InducedCountyOutput)


# Use the cd_proportion to distribute induced county output and employment to the districts, and aggregate the results to the respective districts

InducedDistrict <- merge(InducedCounty, cd_proportion, by = "County")
  
InducedDistrict <- InducedDistrict %>% mutate(induced_district_FTE = InducedDistrict$induced_county_employment*InducedDistrict$`%`,
         induced_district_output = InducedDistrict$induced_county_output*InducedDistrict$`%`) %>%
  select("District", "induced_district_FTE", "induced_district_output")

InducedDistrict <- InducedDistrict %>% aggregate(by = list(InducedDistrict$District), FUN = sum) %>%
  select("Group.1", "induced_district_FTE", "induced_district_output") %>%
    rename(District = Group.1)


## Step 3: Indirect Output and Employment - grab the indirect data from the County Econ Indicators file and merge them

IndirectCountyOutput <- county_econ_indicators %>% 
  select ("County", "Impact", "total_Output") %>%
  mutate(Impact = replace(Impact, Impact == "2 - Indirect", "Indirect")) %>%
  filter(Impact == "Indirect") %>%
  rename(indirect_county_output = total_Output) %>%
  select("County", "indirect_county_output")

IndirectCountyEmp <- county_econ_indicators %>% 
  select ("County", "Impact", "total_employment") %>%
  mutate(Impact = replace(Impact, Impact == "2 - Indirect", "Indirect")) %>%
  filter(Impact == "Indirect") %>%
  rename(indirect_county_employment = total_employment) %>%
  select("County", "indirect_county_employment")

IndirectCounty <- merge(IndirectCountyEmp, IndirectCountyOutput)

# Merge in districts' direct output and employment data with counties' indirect results to calculate districts' indirect results

IndirectCountyProp <- merge(IndirectCounty, cd_proportion, by = "County")

DistrictD_CountyI <- Reduce(function(x,y) merge(x = x, y = y, by = "District"), list(DirectDistrictEmployment, DirectDistrictOutput, IndirectCountyProp))
DistrictD_CountyI <- DistrictD_CountyI %>% relocate(County, .before = District) %>%
  relocate('%', .after = District) %>%
  relocate(POP, .after= '%') %>%
  rename(countypop2010 = POP)

# Calculate the districts' 2010 population, which is used to apportion the district's share in each county, and multiply this share by the districts' direct output and employment

DistrictPop2010 <- aggregate(DistrictD_CountyI$countypop2010, by = list(DistrictD_CountyI$District), FUN = sum) %>%
  rename(District = Group.1, districtpop2010 = x)

DistrictD_CountyI <- merge(DistrictD_CountyI, DistrictPop2010, by = "District") %>%
  relocate(districtpop2010, .after= "countypop2010")

DistrictD_CountyI <- DistrictD_CountyI %>% mutate(CountyDistrictShare = DistrictD_CountyI$countypop2010 / DistrictD_CountyI$districtpop2010)
DistrictD_CountyI <- DistrictD_CountyI %>% mutate(CountyDistrictDirectOutput = DistrictD_CountyI$direct_district_output * DistrictD_CountyI$CountyDistrictShare,
                                                  CountyDistrictDirectEmployment = DistrictD_CountyI$direct_district_FTE * DistrictD_CountyI$CountyDistrictShare)

# Create 2 new data frames that aggregate the CountyDistrict output and employment, and merge back into the original data frame DistrictD_CountyI

CountyDistrictDirectOutputSum <- aggregate(DistrictD_CountyI$CountyDistrictDirectOutput, by = list(DistrictD_CountyI$County), FUN = sum) %>%
  rename(County = Group.1, CountyDistrictDirectOutputSum = x)

CountyDistrictDirectEmploymentSum <- aggregate(DistrictD_CountyI$CountyDistrictDirectEmployment, by = list(DistrictD_CountyI$County), FUN = sum) %>%
  rename(County = Group.1, CountyDistrictDirectEmploymentSum = x)

DistrictD_CountyI <- Reduce(function(x,y) merge(x = x, y = y, by = "County"), list(DistrictD_CountyI, CountyDistrictDirectEmploymentSum, CountyDistrictDirectOutputSum)) %>%
  relocate(CountyDistrictDirectOutputSum, .after= "CountyDistrictDirectOutput")

# Calculate the countydistricts' direct output and employment share, and then multiply the share by the counties' indirect output and employment to determine the counties' share of indirect output and employment

DistrictD_CountyI <- DistrictD_CountyI %>% mutate(CountyDistrictDirectOutputShare = CountyDistrictDirectOutput / CountyDistrictDirectOutputSum,
                                                  CountyDistrictDirectEmploymentShare = CountyDistrictDirectEmployment / CountyDistrictDirectEmploymentSum,
                                                  CountyShareOutput = CountyDistrictDirectOutputShare * indirect_county_output,
                                                  CountyShareEmployment = CountyDistrictDirectEmploymentShare * indirect_county_employment)

# Aggregate the county's shared output and employment by district to get each district's indirect output and employment

IndirectDistrictOutput <- aggregate(DistrictD_CountyI$CountyShareOutput, by = list(DistrictD_CountyI$District), FUN = sum) %>%
  rename(District = Group.1, indirect_district_output = x)

IndirectDistrictEmployment <- aggregate(DistrictD_CountyI$CountyShareEmployment, by = list(DistrictD_CountyI$District), FUN = sum) %>%
  rename(District = Group.1, indirect_district_FTE = x)

IndirectDistrict <- merge(IndirectDistrictOutput, IndirectDistrictEmployment)


## Step 4: Combine all data frames into one

DistrictOutputs <- Reduce(function(x,y) merge(x = x, y = y, by = "District"),
                          list(DirectDistrict, InducedDistrict, IndirectDistrict))

DistrictOutputs <- DistrictOutputs %>%
  relocate(indirect_district_output, .after = direct_district_output) %>%
  relocate(induced_district_output, .after = indirect_district_output) %>%
  relocate(indirect_district_FTE, .after = direct_district_FTE) %>%
  relocate(induced_district_FTE, .after = indirect_district_FTE)

DistrictOutputs <- DistrictOutputs %>% mutate(total_district_output = direct_district_output +
                                                indirect_district_output + induced_district_output,
                                              total_district_FTE = direct_district_FTE +
                                                indirect_district_FTE + induced_district_FTE)

DistrictOutputs <- DistrictOutputs %>% relocate("total_district_output", .before = "direct_district_FTE")


## FINAL STEPS: Combine input and output data, and reorder column names. Remove extra rows.

DistrictIOData <- merge(DistrictInputs, DistrictOutputs, by = "District", all = TRUE)

# REGIONALIZE DATA

regions_crosswalk <- read_excel("District Regions.xlsx") #upload regions crosswalk

# Merge crosswalk to get regions for every district

DistrictIOData <- merge(DistrictIOData, regions_crosswalk, by = ("District"), all = TRUE)

# Reorder columns

DistrictIOData <- DistrictIOData %>% relocate("Region", .after = "District")

# Create new data frame with data aggregated by region

Regionsag <- DistrictIOData %>% 
  select(-(District)) %>% #get rid of impacts column (it breaks the code below)
  group_by(Region) %>% #group by rollup, then district
  summarise_each(funs(sum)) %>% #sum the columns
  mutate(District = "REGION") %>%
  relocate(District, .before = Region)

# Vertically merge data aggregated by region with DistrictIOData

DistrictIOData <- rbind(DistrictIOData, Regionsag)


## Calculate each district/region's employment %, 2019 population, and land area ##

# Read in needed files for 2019 population, 2019 employment, and land area. Merge together and with regions

districts_pop_2019 <- read.csv("2019_ACS_5yrpop.csv")
colnames(districts_pop_2019) <- c("District", "districtpop2019", "moe2019")
districts_pop_2019 = districts_pop_2019[-1,]
districts_pop_2019$District <- gsub(pattern = "Congressional District ([0-9]+) \\(116th Congress\\), California",
     replacement = "\\1", districts_pop_2019$District)
districts_pop_2019 <- districts_pop_2019 %>% select("District", "districtpop2019")

districts_emp_2019 <- read.xlsx("2019_ACS.xlsx") %>%
  select("geography", "civilian_employed", "armed_forces_employed")
districts_emp_2019 <- anti_join(districts_emp_2019, districts_emp_2019[1:58,])
districts_emp_2019 = districts_emp_2019[-54,]
districts_emp_2019 <- districts_emp_2019 %>% rename(District = geography)
districts_emp_2019$District <- gsub(pattern = "Congressional District ([0-9]+) \\(116th Congress\\), California",
                                    replacement = "\\1", districts_emp_2019$District)
districts_emp_2019 <- districts_emp_2019 %>% mutate(districtemp2019 = 
                                                      districts_emp_2019$civilian_employed + districts_emp_2019$armed_forces_employed) %>%
  select("District", "districtemp2019")

districts_land_area <- read.xlsx("2011_District_Land_Area.xlsx") %>%
  rename(area = AREA, District = DISTRICT) %>%
  select("area", "District")
  
district_region_pop_emp_land <- Reduce(function(x,y) merge(x = x, y = y, by = "District"),
                          list(districts_pop_2019, districts_emp_2019, districts_land_area, regions_crosswalk))

# Regionalize the data and vertically merge back to the data frame with regions in it

RegionsPopEmpLandag <- district_region_pop_emp_land %>% 
  select(-(District)) %>%
  group_by(Region) %>% #group by rollup, then district
  summarise_each(funs(sum)) %>% #sum the columns
  mutate(District = "REGION") %>%
  relocate(District, .before = Region)

district_region_pop_emp_land <- rbind(district_region_pop_emp_land, RegionsPopEmpLandag)
district_region_pop_emp_land <- district_region_pop_emp_land %>% relocate("Region", .after = "District")

# Merge this data frame into a new, final IO data frame to have it all in one

DistrictIOData_final <- full_join(DistrictIOData, district_region_pop_emp_land)

# Calculate spending per 100k, output per 100k, employment per 100k (both input and output), % district employment, and % population and land area

DistrictIOData_final <- DistrictIOData_final %>% mutate(input_spending_per_100k = (input_spending / districtpop2019) * 100000,
                                            input_employment_per_100k = (input_employment / districtpop2019) * 100000,
                                            econ_output_per_100k = (total_district_output / districtpop2019) * 100000,
                                            FTE_per_100k = (total_district_FTE / districtpop2019) * 100000,
                                            percent_district_emp = total_district_FTE / districtemp2019,
                                            total_pop = sum(districtpop2019[1:53]),
                                            total_land = sum(area[1:53]),
                                            percent_pop = districtpop2019 / total_pop,
                                            percent_land_area = area / total_land)

DistrictIOData_final <- DistrictIOData_final %>%
  relocate(districtpop2019, .after = Region) %>%
  relocate(input_spending_per_100k, .after = input_spending) %>%
  relocate(input_employment_per_100k, .after = input_employment) %>%
  relocate(econ_output_per_100k, .after = total_district_output) %>%
  relocate(FTE_per_100k, .after = total_district_FTE) %>%
  select(-(c(districtemp2019, area, total_pop, total_land)))

#write into multi-sheet excel file

write.xlsx(DistrictIOData_final, paste0("District_IO_Data_2021.xlsx"))

# ALL DONE - This gives you a detailed spreadsheet of all the districts' input and output data for us to use for the factsheets