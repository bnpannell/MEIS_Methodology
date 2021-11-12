## DETAILED SPREADSHEET OF COUNTY DATA FOR MAKING FACTSHEETS ##

## FILES NEEDED ##
# INPUT DATA FILES
# usa_spending_clean_2021.xlsx <- Gives us all the event value spending for all regions
# SmartPay_FY_2020.xlsx <- Gives us all the SmartPay data for all regions
# VA_Direct_Payments_Recipient_USA_CA.csv <- Gives us household spending change per each region
# 2021_employment_totals.xlsx <- Gives us employment data per each county
# Regions.xlsx
# Economic Indicators Counties 2021.xlsx <- Gives us total output and employment for each county
# Tax Results Counties 2021.xlsx <- Gives us tax results for each county
# Industries by Impact 2021.xlsx <- Gives us industry output information for each county (WE'LL DO THIS ONE SEPARATE)
# Employment Industries by Impact 2021.xlsx <- Gives us employment by industry
# Industries by Impact Groupings.xlsx <- Gives us industry rollups
# 2020 Labor Force by County EDD.xlsx <- Gives us total number of employed residents per county
# 2020 CA Population by County.xlsx <- to do population calculations (from DOF Demographics Research Unit)

## CLEAR ENVIRONMENT ##
rm(list = ls(all.names = TRUE)) 

# load packages
library(readxl)
library(dplyr)
library(openxlsx)
library(tidyverse)
library(stringr)

# Set Working Directory
setwd("/Users/daynanothnagel/Desktop/MEIS/R")

## START WITH INPUT DATA (6 STEPS)

## Step 1: Read in and wrangle event value spending Excel sheet ##
## NOTE: This section of code may need to be updated if the County_District_Investment_Aggregates.R code is updated
VAGrants <- read_xlsx("usa_spending_clean_2021.xlsx", sheet = 1)
VAContracts <- read_xlsx("usa_spending_clean_2021.xlsx", sheet = 2)
DODGrants <- read_xlsx("usa_spending_clean_2021.xlsx", sheet = 3)
DODContracts <- read_xlsx("usa_spending_clean_2021.xlsx", sheet = 4)
DHSGrants <- read_xlsx("usa_spending_clean_2021.xlsx", sheet = 5)
DHSContracts <- read_xlsx("usa_spending_clean_2021.xlsx", sheet = 6)

# Select only county and spending data, aggregate by county for each agency's grants and contracts data frame, and rename the respective columns to the proper name.
VAGrants <- VAGrants %>% select(county, federal_action_obligation)
VAGrants <- aggregate(VAGrants$federal_action_obligation, by = list(VAGrants$county), FUN = sum) %>%
  rename(County = Group.1, vagrant_spending = x)

VAContracts <- VAContracts %>% select(county, federal_action_obligation)
VAContracts <- aggregate(VAContracts$federal_action_obligation, by = list(VAContracts$county), FUN = sum) %>%
  rename(County = Group.1, vacontract_spending = x)

DODGrants <- DODGrants %>% select(county, federal_action_obligation)
DODGrants <- aggregate(DODGrants$federal_action_obligation, by = list(DODGrants$county), FUN = sum) %>%
  rename(County = Group.1, dodgrant_spending = x)

DODContracts <- DODContracts %>% select(county, federal_action_obligation)
DODContracts <- aggregate(DODContracts$federal_action_obligation, by = list(DODContracts$county), FUN = sum) %>%
  rename(County = Group.1, dodcontract_spending = x)

DHSGrants <- DHSGrants %>% select(county, federal_action_obligation)
DHSGrants <- aggregate(DHSGrants$federal_action_obligation, by = list(DHSGrants$county), FUN = sum) %>%
  rename(County = Group.1, dhsgrant_spending = x)

DHSContracts <- DHSContracts %>% select(county, federal_action_obligation)
DHSContracts <- aggregate(DHSContracts$federal_action_obligation, by = list(DHSContracts$county), FUN = sum) %>%
  rename(County = Group.1, dhscontract_spending = x)

# All of the above data frames are missing counties that have $0 spending - we need to add them into only the first frame. The "mc" data frame for each = "missing counties" to add in using the "rbind" function.
VAGrantsmc <- data.frame(c("ALPINE", "BUTTE", "CALAVERAS", "COLUSA", "DEL NORTE", "EL DORADO", "GLENN", "HUMBOLDT",
                           "IMPERIAL", "KINGS", "LAKE", "LASSEN", "MADERA", "MARIPOSA", "MENDOCINO", "MERCED", "MODOC",
                           "MONO", "NEVADA", "PLACER", "PLUMAS", "SAN BENITO", "SIERRA", "SISKIYOU", "STANISLAUS",
                           "SUTTER", "TEHAMA", "TRINITY", "TULARE", "TUOLUMNE", "YOLO", "YUBA"),
                         c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
names(VAGrantsmc) <- c("County", "vagrant_spending")
VAGrants <- rbind(VAGrants, VAGrantsmc)

# Merge all of these data frames into one, add a column for the total event value spending for each of the counties, and then select only the counties and total spending
VASpend <- merge(VAGrants, VAContracts, by = "County", all = TRUE)
DHSSpend <- merge(DHSGrants, DHSContracts, by = "County", all = TRUE)
DODSpend <- merge(DODGrants, DODContracts, by = "County", all = TRUE)

Event_Value_Spending <- Reduce(function(x,y) merge(x = x, y = y, by = "County", all = TRUE), list(VASpend, DHSSpend, DODSpend))

Event_Value_Spending[is.na(Event_Value_Spending)] <- 0

Event_Value_Spending <- Event_Value_Spending %>% 
  mutate("event_value_spending" = vagrant_spending +
           vacontract_spending + dhsgrant_spending +
           dhscontract_spending + dodgrant_spending +
           dodcontract_spending) %>%
  select("County", "event_value_spending")

## step 2: Read in and wrangle SmartPay Excel sheet, selecting only the county and SmartPay spending by county
SmartPay <- read_xlsx("SmartPay_FY_2020.xlsx", sheet = 2) %>% 
  rename(County = ...1, smartpay_c = Total) %>%
  select("County", "smartpay_c")

SmartPay$County = toupper(SmartPay$County)
SmartPay<-SmartPay[!(SmartPay$County=="TOTAL"),]

## Step 3: Read in and wrangle VA Payments (for Household Spending data), selecting only the county and household spending by county. Then aggregate the spending by county, and rename the columns to its respective names.
HouseholdSpending <- read.csv("VA_Direct_Payments_Recipient_USA_CA.csv") %>%
  filter(primary_place_of_performance_state_name == "CALIFORNIA") %>%
  select("recipient_county_name", "total_obligated_amount") %>% #select needed columns
  rename(County = "recipient_county_name") 

HouseholdSpending <- aggregate(HouseholdSpending$total_obligated_amount, by = list(HouseholdSpending$County), FUN = sum) %>%
  rename(County = Group.1, household_spending = x)

## Step 4: Aggregate all 3 spending data sources by county to get total input spending per county
InputSpending <- Reduce(function(x,y) merge(x = x, y = y, by = "County", all = TRUE), list(Event_Value_Spending, HouseholdSpending, SmartPay))

InputSpending <- InputSpending %>% 
  mutate("input_spending" = event_value_spending + household_spending + smartpay_c)

## Step 5: Read in and wrangle 2021_employment_totals.xlsx
InputEmployment <- read.xlsx("2021_employment_totals.xlsx", sheet = 1)

#reorganize employment sheet - NOTE!!! - the .1825 calculation reverts the employment number from FTEs to total jobs
## in other words, these employment numbers represent TOTAl jobs, NOT FTEs.
InputEmployment <- InputEmployment %>% 
  rename(County = county, Military_Personnel = implan_545, Civilian_Personnel = implan_546, input_employment = total) %>%
  select("County", "Civilian_Personnel", "Military_Personnel", "input_employment")

## Step 6: Merge employment and spending data together to get TOTAL input spending and employment for counties
CountyInputs <- merge(InputSpending, InputEmployment, by = "County", all = TRUE)

## NOW BRING IN OUTPUT DATA (3 STEPS) ##

# Read in the County Economic Indicators and County Tax Results Excel sheets
county_econ_indicators <- read.xlsx("Economic Indicators Counties 2021.xlsx")
county_tax_results <- read.xlsx("Tax Results Counties 2021.xlsx")

# Step 1: County Output AND Employment - use "county_econ_indicators" and select the county, output/employment impact type, output, and employment columns
EconOutput <- county_econ_indicators %>% 
  select ("County", "Impact", "total_Output") %>%
  rename(total_econ_output = total_Output)

OutputEmployment <- county_econ_indicators %>% 
  select ("County", "Impact", "total_employment") %>%
  rename(output_employment = total_employment)

# Step 2: County Tax Results - use "county_tax_results", add a column for total local tax revenue, 
          #select the county, impact, and total tax revenue by local, state, and federal columns. 
          #Then filter to only include the totals of each by total impact.

county_tax_results <- county_tax_results %>% 
  mutate("total_Local" = total_Sub_County_General + total_Sub_County_Special_District + total_County) %>%
  select("County", "Impact", "total_Local", "total_State", "total_Federal", "total") %>% 
  rename(tax_Local = total_Local, tax_State = total_State, tax_Federal = total_Federal, tax_total = total)

# Step 3: Combine all of the output data frames into one
CountyOutputs <- Reduce(function(x,y,z) merge(x = x, y = y, z = z, c("County", "Impact")), 
                      list(EconOutput, county_tax_results, OutputEmployment))

# Clean output data frames (remove unnecessary numbers from Impacts column)
CountyOutputs <- CountyOutputs %>%
  mutate(Impact = replace(Impact, Impact == "1 - Direct", "Direct")) %>%
  mutate(Impact = replace(Impact, Impact == "2 - Indirect", "Indirect")) %>%
  mutate(Impact = replace(Impact, Impact == "3 - Induced", "Induced"))

# Convert data to vertical
CountyOutputs <- CountyOutputs %>% 
  gather(variable, value, -(County:Impact)) %>%
  unite(temp, Impact, variable) %>%
  spread(temp, value)

## FINAL STEPS: Combine input and output data, and reorder column names
CountyIOData <- merge(CountyInputs, CountyOutputs, by = "County", all = TRUE)

## REGIONALIZE DATA
regions_crosswalk <- read_excel("Regions.xlsx") #upload regions crosswalk
colnames(regions_crosswalk) <- c("County", "Region") #change col names so they match dfs

# Merge crosswalk to get regions for every county
CountyIOData <- merge(CountyIOData, regions_crosswalk, by = ("County"), all = TRUE)

# Reorder columns
CountyIOData <- CountyIOData %>%
  select(c("County", "Region", "event_value_spending", "household_spending", "smartpay_c", "input_spending", "Civilian_Personnel", 
           "Military_Personnel", "input_employment", "Direct_total_econ_output", "Indirect_total_econ_output", 
           "Induced_total_econ_output", "Total_total_econ_output", "Direct_output_employment", "Indirect_output_employment", 
           "Induced_output_employment", "Total_output_employment", "Direct_tax_Local", "Indirect_tax_Local", 
           "Induced_tax_Local", "Total_tax_Local", "Direct_tax_State", "Indirect_tax_State", 
           "Induced_tax_State", "Total_tax_State","Direct_tax_Federal", "Indirect_tax_Federal", 
           "Induced_tax_Federal", "Total_tax_Federal", "Direct_tax_total", "Indirect_tax_total", "Induced_tax_total",
           "Total_tax_total")) %>%
  rename(Direct_econ_output = Direct_total_econ_output, Indirect_econ_output = Indirect_total_econ_output, 
         Induced_econ_output = Induced_total_econ_output, Total_econ_output = Total_total_econ_output, 
         Direct_output_FTE = Direct_output_employment, Indirect_output_FTE = Indirect_output_employment, 
         Induced_output_FTE = Induced_output_employment, Total_output_FTE = Total_output_employment, 
         Total_combined_tax = Total_tax_total)

# Create new DF with data aggregated by region
Regionsag <- CountyIOData %>% 
  select(-(County)) %>% #get rid of County column (it breaks the code below)
  group_by(Region) %>% #group by region
  summarise_each(funs(sum)) %>% #sum the columns
  mutate(County = "REGION") %>% #make county name "region"
  relocate(County, .before = Region) #move the region column

# Vertically merge data aggregated by region with CountyIOData
CountyIOData <- rbind(CountyIOData, Regionsag)

## ADD % OF EMPLOYMENT PER COUNTY ## - this is percentage of total jobs in a county that are supported by national security spending
labor_force_county <- read_xlsx("2020 Labor Force by County EDD.xlsx")

labor_force_county <- labor_force_county %>% #select only needed columns
  select(COUNTY, EMPLOYMENT)  %>%
  rename(County = COUNTY, Employment = EMPLOYMENT)

# merge region crosswalk with labor force dta
labor_force_county <- merge(labor_force_county, regions_crosswalk, by = ("County"), all = TRUE) 

# get region totals
regions_labor_force_data <- labor_force_county %>%
  select(-(County)) %>% #get rid of County column (it breaks the code below)
  group_by(Region) %>% #group by region
  summarise_each(funs(sum)) %>% #sum the columns
  mutate(County = "REGION") %>% #make county name "region"
  relocate(County, .before = Region) #move the region column

# vertically merge regionalized data with labor force data
labor_force_county <- rbind(labor_force_county, regions_labor_force_data) 

# Merge with county input/output data
CountyIOData <- merge(CountyIOData, labor_force_county, by = (c("County", "Region")), all = TRUE)

# Calculate percentage of total county employment made up by national security-generated jobs
CountyIOData <- CountyIOData %>%
  mutate(percent_total_county_employment = Total_output_FTE/Employment) %>%
  select(-(Employment)) %>%
  relocate(percent_total_county_employment, .after = Total_output_FTE)

## ADD COUNTY POPULATION COLUMN ##
County_pop <- read_xlsx("2020 CA Population by County.xlsx", sheet = 2)
County_pop <- County_pop %>%
  select(Geography, "2020") %>%
  rename(County = Geography, Population = "2020")
County_pop$County <-gsub(" County","",as.character(County_pop$County))
County_pop$County <-toupper(County_pop$County)

County_pop <- merge(County_pop, regions_crosswalk, by = ("County"))

#regionalize county population data
regions_County_pop <- County_pop %>%
  select(-(County)) %>% #get rid of County column (it breaks the code below)
  group_by(Region) %>% #group by region
  summarise_each(funs(sum)) %>% #sum the columns
  mutate(County = "REGION") %>% #make county name "region"
  relocate(County, .before = Region) #move the region column

# vertically merge regionalized data with labor force data
County_pop <- rbind(County_pop, regions_County_pop) 

# Merge with county input/output data
CountyIOData <- merge(CountyIOData, County_pop, by = (c("County", "Region")), all = TRUE)
 
# relocate to top of data
CountyIOData <- CountyIOData %>%
  relocate(Population, .before = event_value_spending)

#Add column that converts county names to title case (Del Norte instead of DEL NORTE) - this is for ease of use in making graphs
CountyIOData$County_Title <- str_to_title(CountyIOData$County)

# relocate to top of data
CountyIOData <- CountyIOData %>%
  relocate(County_Title, .before = Region)

## Add data per 100,000 residents ##
CountyIOData <- CountyIOData %>%
  mutate(input_spending_per_100000 = ((input_spending/Population)*100000), 
         input_employment_per_100000 = ((input_employment/Population)*100000),
         economic_output_per_100000 = ((Total_econ_output/Population)*100000),
         FTE_per_100000 = ((Total_output_FTE/Population)*100000))

CountyIOData <- CountyIOData %>%
  relocate(input_spending_per_100000, .after = input_spending) %>%
  relocate(input_employment_per_100000, .after = input_employment) %>%
  relocate(economic_output_per_100000, .after = Total_econ_output) %>%
  relocate(FTE_per_100000, .after = Total_output_FTE)

## Industries by Impact (will be a separate sheet in the same spreadsheet)

# Import industries by impact master spreadsheet and crosswalk
industries_by_impact <- read_excel("Industries by Impact 2021.xlsx") # upload industries by impact for counties
ind_crosswalk <- read_excel("Industries by Impact Groupings.xlsx") # upload crosswalk

industries_by_impact <- industries_by_impact %>% 
  separate(Impact, c("industry_display","description"), sep = "( - )")

ind_crosswalk <- ind_crosswalk %>%
  select(industry_display, rollup) #get rid of un-needed columns

industries_by_impact <- merge(ind_crosswalk, industries_by_impact, by = ("industry_display")) #merge by industry_display
industries_by_impact <- industries_by_impact %>% 
  select(-(c(industry_display, description))) %>% #get rid of extra column (it breaks the code below)
  group_by(County, rollup) %>% #group by rollup, then county
  summarise_each(funs(sum)) #sum the columns

industries_by_impact <- merge(industries_by_impact, regions_crosswalk, by = ("County"), all = TRUE) #apply crosswalk to counties spreadsheet

#Move columns around so they match the other df 
industries_by_impact <- industries_by_impact %>%
   relocate(Region, .after = County)

#Regionalize data - create a separate df with industry info aggregated by region
industry_Regionsag <- industries_by_impact %>% 
  select(-(County)) %>% #get rid of impacts column (it breaks the code below)
  group_by(Region, rollup) %>% #group by region and rollup
  summarise_each(funs(sum)) %>% #sum the columns
  mutate(County = "REGION") %>% #re-add county name but set them all to Region
  relocate(County, .before = Region) #move columns around for consistency

#Vertically merge regionalized data with industries by impact data
industries_by_impact <- rbind(industries_by_impact, industry_Regionsag)

#get rid of unnecessary columns, rename columns
industries_by_impact <- industries_by_impact %>%
  select(County, Region, rollup, total_Direct, total_Indirect, total_Induced, total) %>%
  rename(Direct = total_Direct, Indirect = total_Indirect, Induced = total_Induced, Total = total)

## EMPLOYMENT BY INDUSTRY ## (will be a separate sheet in the same spreadsheet)

# Import employment by industrymaster spreadsheet
employment_by_industry <- read_excel("Employment Industries by Impact 2021.xlsx") # upload industries by impact for counties

employment_by_industry <- employment_by_industry %>% 
  separate(Impact, c("industry_display","description"), sep = "( - )")

employment_by_industry <- merge(ind_crosswalk, employment_by_industry, by = ("industry_display")) #merge by industry_display

employment_by_industry  <- employment_by_industry %>% 
  select(-(c(industry_display, description))) %>% #get rid of extra columns (it breaks the code below)
  group_by(County, rollup) %>% #group by rollup, then county
  summarise_each(funs(sum)) #sum the columns

employment_by_industry  <- merge(employment_by_industry, regions_crosswalk, by = ("County"), all = TRUE) #apply crosswalk to counties spreadsheet

#Move columns around so they match the other df 
employment_by_industry <- employment_by_industry %>%
  relocate(Region, .after = County)

#Regionalize data - create a separate df with industry info aggregated by region
employment_Regionsag <- employment_by_industry %>% 
  select(-(County)) %>% #get rid of impacts column (it breaks the code below)
  group_by(Region, rollup) %>% #group by region and rollup
  summarise_each(funs(sum)) %>% #sum the columns
  mutate(County = "REGION") %>% #re-add county name but set them all to Region
  relocate(County, .before = Region) #move columns around for consistency

#Vertically merge regionalized data with industries by imact data
employment_by_industry <- rbind(employment_by_industry, employment_Regionsag)

#get rid of unnecessary columns, rename columns
employment_by_industry <- employment_by_industry %>%
  select(County, Region, rollup, total_Direct, total_Indirect, total_Induced, total) %>%
  rename(Direct = total_Direct, Indirect = total_Indirect, Induced = "total_Induced", Total = total)

#create list with dataframes
multisheetlist <- list(InputOutput = CountyIOData, Industry = industries_by_impact, EmploymentIndustry = employment_by_industry)

#write into multi-sheet excel file
write.xlsx(multisheetlist, paste0("County Input-Output Data detailed 2021.xlsx"))

# ALL DONE - This gives you a detailed spreadsheet of all the counties' input and output data for us to use for the factsheets, and a seperate sheet for the industry groupings
