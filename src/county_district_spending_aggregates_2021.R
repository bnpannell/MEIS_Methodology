## MILITARY INVESTMENT AGGREGATES BY COUNTY AND DISTRICT ##


## CLEAR ENVIRONMENT ##
rn(list = ls(all.names = TRUE)) 


## LOAD PACKAGES ##
library(readxl) #needed to read in excel sheets
library(dplyr)  #not entirely sure if this is needed 
library(openxlsx) #needed to write excel sheets


## SET WORKING DIRECTORY ##
setwd("/Users/daynanothnagel/Desktop/MEIS/R")

## FILES NEEDED ##
# USA Spending Files <- input data
# DHS_Grants_Recipient_USA_CA.csv
# DHS_Contracts_Recipient_USA_CA.csv
# DOD_Grants_Recipient_USA_CA.csv
# DOD_Contracts_Recipient_USA_CA.csv
# VA_Grants_Recipient_USA_CA.csv
# VA_Contracts_Recipient_USA_CA.csv
# VA_Direct_Payments_Recipient_USA_CA_no90.csv (for household spending data)
# Bridge_2017NaicsToImplan546.xlsx <- NAICS to IMPLAN Bridge (for contracts data)
# business_type_implan_crosswalk.csv <- Business type to IMPLAN Bridge (for grants data) - This came out of Devin's USA Spending spreadsheet from the 2020 report
# 2021_employment_totals.csv
# VA_Direct_Payments_Recipient_USA_CA.csv
# Actitivy sheet spreadsheets
#   CommodityOutput2.xlsx
#   LaborIncomeChange3.xlsx
#   HouseholdSpendingChange4.xlsx
#   IndustrySpendingPattern5.xlsx
#   InstitutionSpendingPattern6.xlsx

## CLEAN USASPENDING DATA ##
#rename base file for report year
VAGrants21 <- read.csv(file = "VA_Grants_Recipient_USA_CA.csv", stringsAsFactors = FALSE)
VAContracts21 <- read.csv(file = "VA_Contracts_Recipient_USA_CA.csv", stringsAsFactors = FALSE)
DODGrants21 <- read.csv(file = "DOD_Grants_Recipient_USA_CA.csv", stringsAsFactors = FALSE)
DODContracts21 <- read.csv(file = "DOD_Contracts_Recipient_USA_CA.csv", stringsAsFactors = FALSE)
DHSGrants21 <- read.csv(file = "DHS_Grants_Recipient_USA_CA.csv", stringsAsFactors = FALSE)
DHSContracts21 <- read.csv(file = "DHS_Contracts_Recipient_USA_CA.csv", stringsAsFactors = FALSE)

##CROSSWALKS

#Business type to IMPLAN
business_to_implan <- read.csv(file = "business_type_implan_crosswalk.csv", stringsAsFactors = FALSE) 

#NAICS to IMPLAN
naics_to_implan <- read_excel("Bridge_2017NaicsToImplan546.xlsx")
naics_to_implan <- naics_to_implan %>%
  select("Implan546Index", "2017NaicsCode") %>%
  rename(implan_code = "Implan546Index", naics_code = "2017NaicsCode")
naics_to_implan$implan_code[naics_to_implan$naics_code == 335220] <- 327
naics_to_implan$implan_code[naics_to_implan$naics_code == 332117] <- 231
naics_to_implan <- naics_to_implan[!duplicated(naics_to_implan), ] #delete duplicate rows

# this gives you any codes where naics is paired up with multiple implan_codes
# naics_to_implan[duplicated(naics_to_implan$naics_code),]

# DOD GRANTS
DODGrants <- DODGrants21 %>%
  filter(primary_place_of_performance_state_name == "CALIFORNIA") %>%
  select("federal_action_obligation", "recipient_name", "recipient_county_name", "recipient_congressional_district", 
         "business_types_description") %>% #select needed columns
  rename(county = "recipient_county_name", district = "recipient_congressional_district")
DODGrants  <- merge(DODGrants, business_to_implan, by = ("business_types_description"), all.x = TRUE, all.y = FALSE) #merge with business to implan bridge
DODGrants <- DODGrants %>%
  select("federal_action_obligation", "county", "district", "implan_code") #select needed columns

# DOD Contracts
DODContracts <- DODContracts21 %>% 
  filter(primary_place_of_performance_state_name == "CALIFORNIA") %>%
  select("federal_action_obligation", "recipient_county_name", 
         "recipient_congressional_district", "naics_code", "recipient_name") #select needed columns
DODContracts  <- merge(DODContracts, naics_to_implan, by = ("naics_code"), all.x = TRUE, all.y = FALSE) #merge with NAICS to IMPLAN crosswalk
DODContracts <- DODContracts %>%
  filter(!(federal_action_obligation == 0 & is.na(naics_code)))

#this line pull all of the entries with unmatched NAICS codes in one DF. 
DODContracts_NA <- DODContracts[is.na(DODContracts$implan_code),]
# use this code to generate a list of all the unique naics_codes that don't have an IMPLAN assignment
# unique(DODContracts_NA$naics_code)

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

#create a crosswalk with the new codes to add to the other naics crosswalk
naics_crosswalk_addition_1 <- DODContracts_NA %>%
  select(implan_code, naics_code) %>%
  filter(!is.na(naics_code))
naics_crosswalk_addition_1 <- distinct(naics_crosswalk_addition_1)

#merge crosswalks
naics_to_implan <- rbind(naics_to_implan, naics_crosswalk_addition_1)

#reapply crosswalk
DODContracts <- DODContracts %>%
  select(-implan_code)
DODContracts  <- merge(DODContracts, naics_to_implan, by = ("naics_code"), all.x = TRUE, all.y = FALSE)

# Some entries had no NAICS code at all. I looked up those industries and manually assigned IMPLAN codes
DODContracts$implan_code[DODContracts$recipient_name == "IMPERIAL IRRIGATION DISTRICT INC"] <- 530
DODContracts$implan_code[DODContracts$recipient_name == "KAMP SYSTEMS, INC"] <- 244
DODContracts$implan_code[DODContracts$recipient_name == "SCIENCE APPLICATIONS INTERNATIONAL CORPORATION"] <- 459
DODContracts$implan_code[DODContracts$recipient_name == "DRS SENSORS & TARGETING SYSTEMS, INC."] <- 514
DODContracts$implan_code[DODContracts$recipient_name == "KEYSTONE ENGINEERING COMPANY I"] <- 457

#select needed columns
DODContracts <- DODContracts %>%
  select("federal_action_obligation", "recipient_county_name", "recipient_congressional_district", "implan_code") %>%
  rename(county = recipient_county_name, district = recipient_congressional_district)

# use these to test where there are NAs
#DODContracts_no_implan <-DODContracts %>%
#  filter(is.na(implan_code))
#DODContracts_no_money <-DODContracts %>%
#  filter(is.na(federal_action_obligation))
#DODContracts_no_district <-DODContracts %>%
#  filter(is.na(district))

# DHS Grants
DHSGrants <- DHSGrants21 %>%
  filter(primary_place_of_performance_state_name == "CALIFORNIA") %>%
  select("federal_action_obligation", "recipient_name", "recipient_county_name", "recipient_congressional_district", 
         "business_types_description") %>% #select needed columns
  rename(county = "recipient_county_name", district = "recipient_congressional_district")
DHSGrants  <- merge(DHSGrants, business_to_implan, by = ("business_types_description"), all.x = TRUE, all.y = FALSE) #merge with business to implan bridge
DHSGrants <- DHSGrants %>%
  select("federal_action_obligation", "county", "district", "implan_code") #select needed columns

# DHS Contracts 
DHSContracts <- DHSContracts21 %>% 
  filter(primary_place_of_performance_state_name == "CALIFORNIA") %>%
  select("federal_action_obligation", "recipient_county_name", 
         "recipient_congressional_district", "naics_code") #select needed columns
DHSContracts  <- merge(DHSContracts, naics_to_implan, by = ("naics_code"), all.x = TRUE, all.y = FALSE) #merge with NAICS to IMPLAN crosswalk

# find missing naics codes
DHSContracts_NA <- DHSContracts[is.na(DHSContracts$implan_code),]
# unique(DHSContracts_NA$naics_code)

# reassign codes
DHSContracts_NA <- DHSContracts_NA %>%
  mutate(implan_code = case_when(
    startsWith(as.character(naics_code), "2381") ~ "125",
    startsWith(as.character(naics_code), "2381") ~ "125",
    startsWith(as.character(naics_code), "9221") ~ "534",
    startsWith(as.character(naics_code), "926") ~ "530",))

#create additional crosswalk
naics_crosswalk_addition_2 <- DHSContracts_NA %>%
  select(implan_code, naics_code)
naics_crosswalk_addition_2 <- distinct(naics_crosswalk_addition_2)
naics_to_implan <- rbind(naics_to_implan, naics_crosswalk_addition_2)

DHSContracts <- DHSContracts %>%
  select(-implan_code)
DHSContracts  <- merge(DHSContracts, naics_to_implan, by = ("naics_code"), all.x = TRUE, all.y = FALSE)

DHSContracts <- DHSContracts %>%
  select("federal_action_obligation", "recipient_county_name", "recipient_congressional_district", "implan_code") %>%
  rename(county = recipient_county_name, district = recipient_congressional_district)

# VA GRANTS
VAGrants <- VAGrants21 %>%
  filter(primary_place_of_performance_state_name == "CALIFORNIA") %>%
  select("federal_action_obligation", "recipient_name", "recipient_county_name", "recipient_congressional_district", 
         "business_types_description") %>% #select needed columns
  rename(county = "recipient_county_name", district = "recipient_congressional_district")
VAGrants  <- merge(VAGrants, business_to_implan, by = ("business_types_description"), all.x = TRUE, all.y = FALSE) #merge with business to implan bridge
VAGrants$implan_code[VAGrants$recipient_name == "UNIVERSITY OF CALIFORINA FULLERTON"] <- 531 #reassign some entries
VAGrants$implan_code[VAGrants$recipient_name == "THE UNIVERSITY CORPORATION LOS ANGELES"] <- 524
VAGrants$implan_code[VAGrants$recipient_name == "THE UNIVERSITY CORPORATION"] <- 524
VAGrants <- VAGrants %>%
  select("federal_action_obligation", "county", "district", "implan_code") #select needed columns

# VA CONTRACTS
VAContracts <- VAContracts21 %>% 
  filter(primary_place_of_performance_state_name == "CALIFORNIA") %>%
  select("federal_action_obligation", "recipient_county_name", 
         "recipient_congressional_district", "naics_code") #select needed columns
VAContracts  <- merge(VAContracts, naics_to_implan, by = ("naics_code"), all.x = TRUE, all.y = FALSE) #merge with NAICS to IMPLAN crosswalk
VAContracts$implan_code[VAContracts$naics_code == 532291] <- 412 #reassign some entries
VAContracts$implan_code[VAContracts$naics_code == 922130] <- 534
VAContracts$implan_code[VAContracts$naics_code == 926150] <- 530
VAContracts <- VAContracts %>%
  select("federal_action_obligation", "recipient_county_name", "recipient_congressional_district", "implan_code") %>%
  rename(county = recipient_county_name, district = recipient_congressional_district)
  
#put all cleaned dataframes into a new list called usa_spending_clean_2021
usa_spending_clean_2021 <- list("VAGrants" = VAGrants, "VAContracts" = VAContracts, 
                                "DODGrants" = DODGrants, "DODContracts" = DODContracts, 
                                "DHSGrants" = DHSGrants, "DHSContracts" = DHSContracts) 

#write usa_spending_clean_2021 into multi-sheet excel file. Excel file should be saved to wd. This will be re-uploaded in the next lines
write.xlsx(usa_spending_clean_2021, paste0("usa_spending_clean_2021.xlsx")) 

## REUPLOAD EXCEL SHEET INTO LIST OF TIBBLES- usa_spending_clean_2021.xlsx ##
# Save names of sheets into new object tab_names using file path 
tab_names <- excel_sheets(path = "/Users/daynanothnagel/Desktop/MEIS/R/usa_spending_clean_2021.xlsx") #make sure to change filepath
#this pulls all the sheets into one list - usaspending
usaspending <- lapply(tab_names, function(x) read_excel(path = "/Users/daynanothnagel/Desktop/MEIS/R/usa_spending_clean_2021.xlsx", sheet = x))

## EMPLOYMENT DATA##
# Read in employment data for counties and districts
usaemp_county <- read_excel("2021_employment_totals.xlsx", sheet=1) 
usaemp_dist <- read_excel("2021_employment_totals.xlsx", sheet=2) 

# add inverse for employees per county
usaemp_county <- usaemp_county %>% #add inverse employment
  mutate(inverse_545 = (sum(usaemp_county$implan_545)) - usaemp_county$implan_545,
         inverse_546 = (sum(usaemp_county$implan_546)) - usaemp_county$implan_546) %>%
  select(-(total))

# add inverse for employees per district
usaemp_dist <- usaemp_dist %>%
  mutate(inverse_545 = sum(usaemp_dist$implan_545) - usaemp_dist$implan_545,
         inverse_546 = sum(usaemp_dist$implan_546) - usaemp_dist$implan_546) %>%
  select(-(total))

## HOUSEHOLD SPENDING CHANGE ##
# Upload VA Payments information (this will be used for household spending change)
VA_payments_21 <- read.csv("VA_Direct_Payments_Recipient_USA_CA.csv") 
VA_payments <- VA_payments_21 %>%
  filter(primary_place_of_performance_state_name == "CALIFORNIA") %>%
  select("total_obligated_amount", "recipient_county_name", "recipient_congressional_district") %>% #select needed columns
  rename(county = "recipient_county_name", district = "recipient_congressional_district")

# County household spending change
HHSpendCH_county <- aggregate(VA_payments$total_obligated_amount, by=list(VA_payments$county), FUN=sum) #aggregate spending based on county
colnames(HHSpendCH_county) <- c("county", "spending_change") #rename columns
HHSpendCH_county$inverse <- (sum(VA_payments$total_obligated_amount)) - HHSpendCH_county$spending_change #add inverse column

# District household spending change
HHSpendCH_dist <- aggregate(VA_payments$total_obligated_amount, by=list(VA_payments$district), FUN=sum) #aggregate spending based on district
colnames(HHSpendCH_dist) <- c("district", "spending_change") #rename columns
HHSpendCH_dist$inverse <- (sum(VA_payments$total_obligated_amount)) - HHSpendCH_dist$spending_change #add inverse column

## CA SPENDING TOTALS ## used for inverse calculations 
# Reread in all sheets in usaspending_RNEW
usa_spending_1 <- read_excel(path = "/Users/daynanothnagel/Desktop/MEIS/R/usa_spending_clean_2021.xlsx", sheet = 1)
usa_spending_2 <- read_excel(path = "/Users/daynanothnagel/Desktop/MEIS/R/usa_spending_clean_2021.xlsx", sheet = 2)
usa_spending_3 <- read_excel(path = "/Users/daynanothnagel/Desktop/MEIS/R/usa_spending_clean_2021.xlsx", sheet = 3)
usa_spending_4 <- read_excel(path = "/Users/daynanothnagel/Desktop/MEIS/R/usa_spending_clean_2021.xlsx", sheet = 4)
usa_spending_5 <- read_excel(path = "/Users/daynanothnagel/Desktop/MEIS/R/usa_spending_clean_2021.xlsx", sheet = 5)
usa_spending_6 <- read_excel(path = "/Users/daynanothnagel/Desktop/MEIS/R/usa_spending_clean_2021.xlsx", sheet = 6)

#combine all sheets into one master dataframe
combined <- rbind(usa_spending_1, usa_spending_2, usa_spending_3, usa_spending_4, usa_spending_5, usa_spending_6)

#use the combined df and aggregate total spending by sector. This gives you total state spending per sector. 
CATotals <- aggregate(combined$federal_action_obligation, by=list(combined$implan_code), FUN=sum)

## BLANK SHEETS FOR MULTI-SHEET EXCEL ##
#These are the blank sheets from the activity sheet - they'll be combined with the aggregated data to create a multi-sheet excel doc
CommodityOutput2 <- read_excel("CommodityOutput2.xlsx")
LaborIncomeChange3 <- read_excel("LaborIncomeChange3.xlsx")
HouseholdSpendingChange4 <- read_excel("HouseholdSpendingChange4.xlsx")
IndustrySpendingPattern5 <- read_excel("IndustrySpendingPattern5.xlsx")
InstitutionSpendingPattern6 <- read_excel("InstitutionSpendingPattern6.xlsx")

## LIST OF UNIQUE COUNTIES AND DISTRICTS ## 

# List of all unique counties included in all sheets (looks like there are only 55 counties where spending happened)
countynames <- unique(c(unique(usaspending[[1]][["county"]]), unique(usaspending[[2]][["county"]]), 
                        unique(usaspending[[3]][["county"]]), unique(usaspending[[4]][["county"]]), 
                        unique(usaspending[[5]][["county"]]), unique(usaspending[[6]][["county"]])))

# Gives you all of the congressional districts 
congressid <- unique(c(unique(usaspending[[1]][["district"]]), unique(usaspending[[2]][["district"]]), 
                       unique(usaspending[[3]][["district"]]), unique(usaspending[[4]][["district"]]), 
                       unique(usaspending[[5]][["district"]]), unique(usaspending[[6]][["district"]])))


## LOOP FOR SPENDING PER COUNTY AND INVERSE SPENDING PER COUNTY ##
for (county in countynames){
  temp <- NULL
  for(sheet_num in 1:length(usaspending)){
    j <- which(usaspending[[sheet_num]][["county"]] == county)
    temp <- rbind(temp, usaspending[[sheet_num]][j,])
  } 
  temp <- aggregate(temp$federal_action_obligation, by=list(temp$implan_code), FUN=sum) #this line aggregates the data by sector
  colnames(temp) <- c("Sector", "Event_value") #change the column names to match activity sheet
  usaemp_county$totalemployment <- 0 #create new employment column
  m <- which(usaemp_county$county == county)
  temp$Employment <- ""
  temp <- rbind(temp, c(545, "", usaemp_county$implan_545[which(usaemp_county$county == county)])) #add employment to temp for 545
  temp <- rbind(temp, c(546, "", usaemp_county$implan_546[which(usaemp_county$county == county)])) #add employment to temp for 546
  #create extra columns for the first sheet (temp)
  temp$Employee_Compensation <- ""
  temp$Proprieter_Income <- ""
  temp$EventYear <- 2020
  temp$Retail <- "No"
  temp$Local_Direct_Purchase <- "100%"
  #add rows to top of sheet to match needed formatting 
  temp <- rbind(c("Activity Type", "Activity Name",    "Activity Level","",    "Activity Year","","",""),    
                c("Industry Change", "Industry Purchases",    "1","",    "2020","","",""),
                c("","","","","","","",""),
                c("Sector", "Event value", "Employment", "Employee Compensation", "Proprieter Income", "Event Year", "Retail", "Local Direct Purchase"),
                temp)
  HouseholdSpendingChange4[5,2] <- as.character(HHSpendCH_county[which(HHSpendCH_county$county == county), 2]) #update household spending by county
  temp <- rbind(temp, c("temp", "0", "0")) #add fake 0s to make the line below work
  temp <- temp[-(which(temp[,2]=="0" | temp[,3]=="0")),] #delete 0s
  #put sheets into a list. This list will turn into the excel file.
  templist <- list("Industry Change" = temp, "Commodity Output" = CommodityOutput2, 
                   "Labor Income Change" = LaborIncomeChange3, "Household Spending Change" = HouseholdSpendingChange4,
                   "Industry Spending Pattern" = IndustrySpendingPattern5, 
                   "Institution Spending Pattern" = InstitutionSpendingPattern6) 
  #write into multi-sheet excel file
  write.xlsx(templist, paste0("Output/", county, ".xlsx"), colNames = FALSE) #note that "output" is where your sheets will end up
  print(paste(county, ":", (length(templist[["Industry Change"]][["Sector"]])-4)))
  #tempooc is the INVERSE sheet
  tempooc <- CATotals
  temp <- temp[-(1:4),]
  for (i in 1:nrow(temp)){
    n <- which(tempooc$Group.1 == temp$Sector[i])
    tempooc$x[n] <- tempooc$x[n] - as.numeric(temp$Event_value[i]) #subtract each event value from total CA spending
  }
  #add inverse employment data to tempooc doc
  tempooc$Employment <- ""
  tempooc <- rbind(tempooc, c(545, "", usaemp_county$inverse_545[which(usaemp_county$county == county)]))
  tempooc <- rbind(tempooc, c(546, "", usaemp_county$inverse_546[which(usaemp_county$county == county)]))
  #add extra sheets to inverse doc
  tempooc$Employee_Compensation <- ""
  tempooc$Proprieter_Income <- ""
  tempooc$EventYear <- 2020
  tempooc$Retail <- "No"
  tempooc$Local_Direct_Purchase <- "100%"  
  #add four additional rows to top of spreadsheet to match needed formatting 
  tempooc <- rbind(c("Activity Type", "Activity Name",    "Activity Level","",    "Activity Year","","",""),    
                   c("Industry Change", "Industry Purchases",    "1","",    "2020","","",""),
                   c("","","","","","","",""),
                   c("Sector", "Event value", "Employment", "Employee Compensation", "Proprieter Income", "Event Year", "Retail", "Local Direct Purchase"),
                   tempooc)
  HouseholdSpendingChange4[5,2] <- as.character(HHSpendCH_county[which(HHSpendCH_county$county == county), 3]) #update household spending by county (in)
  tempooc <- rbind(tempooc, c("temp", "0", "0"))
  tempooc <- tempooc[-(which(tempooc[,2]=="0" | tempooc[,3]=="0")),]
  #put all sheets into one list
  tempooclist <- list("Industry Change" = tempooc, "Commodity Output" = CommodityOutput2, 
                      "Labor Income Change" = LaborIncomeChange3, "Household Spending Change" = HouseholdSpendingChange4,
                      "Industry Spending Pattern" = IndustrySpendingPattern5, 
                      "Institution Spending Pattern" = InstitutionSpendingPattern6)
  #write into multi-sheet excel file
  write.xlsx(tempooclist, paste0("Output/", county, "in.xlsx"), colNames = FALSE) #Output is the folder name
  print(paste(county, "(in) :", (length(tempooclist[["Industry Change"]][["Group.1"]])-4)))
}

## LOOP FOR SPENDING PER DISTRICT AND INVERSE SPENDING PER DISTRICT ##
for (district in congressid){
  temp1 <- NULL
  for(sheet_num1 in 1:length(usaspending)){
    j <- which(usaspending[[sheet_num1]][["district"]] == district)
    temp1 <- rbind(temp1, usaspending[[sheet_num1]][j,])
  } 
  temp1 <- aggregate(temp1$federal_action_obligation, by=list(temp1$implan_code), FUN=sum) #this line aggregates the data by sector
  colnames(temp1) <- c("Sector", "Event_value") #change column names 
  usaemp_dist$totalemployment <- 0 #create employment column
  p <- which(usaemp_dist$dist == district)
  temp1$Employment <- ""
  temp1 <- rbind(temp1, c(545, "", usaemp_dist$implan_545[which(usaemp_dist$district == district)]))
  temp1 <- rbind(temp1, c(546, "", usaemp_dist$implan_546[which(usaemp_dist$district == district)]))
  #add additional sheets
  temp1$Employee_Compensation <- ""
  temp1$Proprieter_Income <- ""
  temp1$EventYear <- 2020
  temp1$Retail <- "No"
  temp1$Local_Direct_Purchase <- "100%"
  #add rows to top of sheet to match needed formatting 
  temp1 <- rbind(c("Activity Type", "Activity Name",    "Activity Level","",    "Activity Year","","",""),    
                 c("Industry Change", "Industry Purchases",    "1","",    "2020","","",""),
                 c("","","","","","","",""),
                 c("Sector", "Event value", "Employment", "Employee Compensation", "Proprieter Income", "Event Year", "Retail", "Local Direct Purchase"),
                 temp1)
  HouseholdSpendingChange4[5,2] <- as.character(HHSpendCH_dist[which(HHSpendCH_dist$district == district), 2]) #update household spending by district
  temp1 <- rbind(temp1, c("temp1", "0", "0"))
  temp1 <- temp1[-(which(temp1[,2]=="0" | temp1[,3]=="0")),]
  #put sheets into master list
  temp1list <- list("Industry Change" = temp1, "Commodity Output" = CommodityOutput2, 
                    "Labor Income Change" = LaborIncomeChange3, "Household Spending Change" = HouseholdSpendingChange4,
                    "Industry Spending Pattern" = IndustrySpendingPattern5, 
                    "Institution Spending Pattern" = InstitutionSpendingPattern6)
  #write into a multi-sheet excel file
  write.xlsx(temp1list, paste0("Output/", "CA-", district, ".xlsx"), colNames = FALSE) #note that "output" is where your sheets will end up
  print(paste(district, ":", (length(temp1list[["Industry Change"]][["Sector"]])-4)))
  #tempood is the inverse for districts  
  tempood <- CATotals
  temp1 <- temp1[-(1:4),]
  for (i in 1:nrow(temp1)){
    q <- which(tempood$Group.1 == temp1$Sector[i])
    tempood$x[q] <- tempood$x[q] - as.numeric(temp1$Event_value[i]) #calculates inverse
  }
  #add inverse employment data to tempood doc
  tempood$Employment <- ""
  tempood <- rbind(tempood, c(545, "", usaemp_dist$inverse_545[which(usaemp_dist$district == district)]))
  tempood <- rbind(tempood, c(546, "", usaemp_dist$inverse_546[which(usaemp_dist$district == district)]))
  #create extra columns
  tempood$Employee_Compensation <- ""
  tempood$Proprieter_Income <- ""
  tempood$EventYear <- 2020
  tempood$Retail <- "No"
  tempood$Local_Direct_Purchase <- "100%"
  tempood <- tempood[(which(tempood[,2]!="0" | tempood[,3]!="0")),]
  #add four additional rows to top of spreadsheet to match needed formatting 
  tempood <- rbind(c("Activity Type", "Activity Name",    "Activity Level","",    "Activity Year","","",""),    
                   c("Industry Change", "Industry Purchases",    "1","",    "2020","","",""),
                   c("","","","","","","",""),
                   c("Sector", "Event value", "Employment", "Employee Compensation", "Proprieter Income", "Event Year", "Retail", "Local Direct Purchase"),
                   tempood)
  HouseholdSpendingChange4[5,2] <- as.character(HHSpendCH_dist[which(HHSpendCH_dist$district == district), 3]) #update household spending by district (in)
  tempood <- rbind(tempood, c("tempood", "0", "0"))
  tempood <- tempood[-(which(tempood[,2]=="0" | tempood[,3]=="0")),]
  #put all sheets into one list
  tempoodlist <- list("Industry Change" = tempood, "Commodity Output" = CommodityOutput2, 
                      "Labor Income Change" = LaborIncomeChange3, "Household Spending Change" = HouseholdSpendingChange4,
                      "Industry Spending Pattern" = IndustrySpendingPattern5, 
                      "Institution Spending Pattern" = InstitutionSpendingPattern6)
  #write into multi-sheet excel file
  write.xlsx(tempoodlist, paste0("Output/", "CA-", district, "inverse.xlsx"), colNames = FALSE) #Output is the folder name
  print(paste(district, "(in) :", (length(tempooclist[["Industry Change"]][["Group.1"]])-4)))
}

### DONE! :) ###
