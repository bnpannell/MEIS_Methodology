## Code for generating county and district IMPLAN activity sheets

#These are the blank sheets from the activity sheet - they'll be combined with the aggregated data to create a multi-sheet excel doc for IMPLAN
CommodityOutput2 <- read_excel(path = (file.path(getwd(), "data", "raw", "Blank_Sheets_for_R", "CommodityOutput2.xlsx")))
LaborIncomeChange3 <- read_excel(path = (file.path(getwd(), "data", "raw", "Blank_Sheets_for_R", "LaborIncomeChange3.xlsx")))
HouseholdSpendingChange4 <- read_excel(path = (file.path(getwd(), "data", "raw", "Blank_Sheets_for_R", "HouseholdSpendingChange4.xlsx")))
IndustrySpendingPattern5 <- read_excel(path = (file.path(getwd(), "data", "raw", "Blank_Sheets_for_R", "IndustrySpendingPattern5.xlsx")))
InstitutionSpendingPattern6 <- read_excel(path = (file.path(getwd(), "data", "raw", "Blank_Sheets_for_R", "InstitutionSpendingPattern6.xlsx")))


## Create a list of unique counties and districts to read into the for loop
countynames <- unique(c(unique(usaspending[3])))
#view(countynames)

congressid <- unique(c(unique(usaspending[4])))
#view(congressid)


## LOOP FOR SPENDING PER COUNTY AND INVERSE SPENDING PER COUNTY ##
for (county in countynames){
  temp <- NULL
  for(sheet_num in 1:length(usaspending)){
    j <- which(usaspending[3] == county)
    temp <- rbind(temp, usaspending[3][j,])
  } 
  temp <- aggregate(temp$federal_action_obligation, by=list(temp$implan_code), FUN=sum) #this line aggregates the data by sector
  colnames(temp) <- c("Sector", "Event_value") #change the column names to match activity sheet
  county_emp$totalemployment <- 0 #create new employment column
  m <- which(county_emp$county == county)
  temp$Employment <- ""
  temp <- rbind(temp, c(545, "", county_emp$implan_545[which(county_emp$county == county)])) #add employment to temp for 545
  temp <- rbind(temp, c(546, "", county_emp$implan_546[which(county_emp$county == county)])) #add employment to temp for 546
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
  HouseholdSpendingChange4[5,2] <- as.character(va_benefits_countiesagg[which(va_benefits_countiesagg$recipient_county_name == county), 2]) #update household spending by county
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
  tempooc <- rbind(tempooc, c(545, "", county_emp$inverse_545[which(county_emp$county == county)]))
  tempooc <- rbind(tempooc, c(546, "", county_emp$inverse_546[which(county_emp$county == county)]))
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
