##Code for generating county and district IMPLAN activity sheets

#These are the blank sheets from the activity sheet - they'll be combined with the aggregated data to create a multi-sheet excel doc for IMPLAN
CommodityOutput2 <- read_excel(path = (file.path(getwd(), "data", "raw", "Blank_Sheets_for_R", "CommodityOutput2.xlsx")))
LaborIncomeChange3 <- read_excel(path = (file.path(getwd(), "data", "raw", "Blank_Sheets_for_R", "LaborIncomeChange3.xlsx")))
HouseholdSpendingChange4 <- read_excel(path = (file.path(getwd(), "data", "raw", "Blank_Sheets_for_R", "HouseholdSpendingChange4.xlsx")))
IndustrySpendingPattern5 <- read_excel(path = (file.path(getwd(), "data", "raw", "Blank_Sheets_for_R", "IndustrySpendingPattern5.xlsx")))
InstitutionSpendingPattern6 <- read_excel(path = (file.path(getwd(), "data", "raw", "Blank_Sheets_for_R", "InstitutionSpendingPattern6.xlsx")))

##Create a list of unique counties and districts to read into the for loop
countynames <- unique(usaspending[,4])
countynames <- countynames[countynames!=""] 

congressid <- as.character(unique(usaspending[,5]))
congressid <- congressid[congressid!=90] 
congressid <- congressid[!(is.na(congressid))]

##LOOP FOR "NORMAL" AND INVERSE IMPLAN ACTIVITY SHEETS PER COUNTY
# Account for counties without spending data # 
va_benefits_countiesagg <- merge(va_benefits_countiesagg, data.frame(county = countynames), by.x = "Group.1", by.y = "county", all.y = TRUE)
va_benefits_countiesagg$x[is.na(va_benefits_countiesagg$x)] <- 0

for (county in countynames){
    j <- which(usaspending[4] == county)
    temp <- usaspending[j,]
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
  temp$EventYear <- as.integer(f_year)
  temp$Retail <- "No"
  temp$Local_Direct_Purchase <- "100%"
  #add rows to top of sheet to match needed formatting 
  temp <- rbind(c("Activity Type", "Activity Name",    "Activity Level","",    "Activity Year","","",""),    
                c("Industry Change", "Industry Purchases",    "1","",    "2020","","",""),
                c("","","","","","","",""),
                c("Sector", "Event value", "Employment", "Employee Compensation", "Proprieter Income", "Event Year", "Retail", "Local Direct Purchase"),
                temp)
  HouseholdSpendingChange4[5,2] <- as.character(va_benefits_countiesagg[which(va_benefits_countiesagg$Group.1 == county), 2]) #update household spending by county
  temp <- rbind(temp, c("temp", "0", "0")) #add fake 0s to make the line below work
  temp <- temp[-(which(temp[,2]=="0" | temp[,3]=="0")),] #delete 0s
  #put sheets into a list. This list will turn into the excel file.
  templist <- list("Industry Change" = temp, "Commodity Output" = CommodityOutput2, 
                   "Labor Income Change" = LaborIncomeChange3, "Household Spending Change" = HouseholdSpendingChange4,
                   "Industry Spending Pattern" = IndustrySpendingPattern5, 
                   "Institution Spending Pattern" = InstitutionSpendingPattern6) 
  #write into multi-sheet excel file
  output_dep_c <- file.path("output", paste0("DEPRECATED_IMPLAN_", year, "_counties//"))
  if(!dir.exists(output_dep_c)){dir.create(output_dep_c)}
  write.xlsx(templist, paste0(output_dep_c, county, ".xlsx"), colNames = FALSE)
  print(paste(county, ":", (length(templist[["Industry Change"]][["Sector"]])-4)))
  #tempooc is the INVERSE sheet
  tempooc <- usaspending
  tempooc <- aggregate(tempooc$federal_action_obligation, by=list(tempooc$implan_code), FUN=sum) #this line aggregates the data by sector
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
  tempooc$EventYear <- as.integer(f_year)
  tempooc$Retail <- "No"
  tempooc$Local_Direct_Purchase <- "100%"  
  #add four additional rows to top of spreadsheet to match needed formatting 
  tempooc <- rbind(c("Activity Type", "Activity Name",    "Activity Level","",    "Activity Year","","",""),    
                   c("Industry Change", "Industry Purchases",    "1","",    "2020","","",""),
                   c("","","","","","","",""),
                   c("Sector", "Event value", "Employment", "Employee Compensation", "Proprieter Income", "Event Year", "Retail", "Local Direct Purchase"),
                   tempooc)
  HouseholdSpendingChange4[5,2] <- as.character(va_benefits_stateagg - va_benefits_countiesagg[which(va_benefits_countiesagg$Group.1 == county), 2]) #update household spending by county (in)
  tempooc <- rbind(tempooc, c("temp", "0", "0"))
  tempooc <- tempooc[-(which(tempooc[,2]=="0" | tempooc[,3]=="0")),]
  #put all sheets into one list
  tempooclist <- list("Industry Change" = tempooc, "Commodity Output" = CommodityOutput2, 
                      "Labor Income Change" = LaborIncomeChange3, "Household Spending Change" = HouseholdSpendingChange4,
                      "Industry Spending Pattern" = IndustrySpendingPattern5, 
                      "Institution Spending Pattern" = InstitutionSpendingPattern6)
  #write into multi-sheet excel file
  write.xlsx(tempooclist, paste0(output_dep_c, county, "in.xlsx"), colNames = FALSE)
  print(paste(county, "(in) :", (length(tempooclist[["Industry Change"]][["Group.1"]])-4)))
}

## LOOP FOR "NORMAL" IMPLAN ACTIVITY SHEETS PER DISTRICT ##
# Account for districts without spending data # 
va_benefits_districtsagg <- merge(va_benefits_districtsagg, data.frame(id = congressid), by.x = "Group.1", by.y = "id", all.y = TRUE)
va_benefits_districtsagg$x[is.na(va_benefits_districtsagg$x)] <- 0 

for (district in congressid){
  #print(paste(district, class(district)))
  k <- which(usaspending[5] == district)
  temp2 <- usaspending[k,]
  temp2 <- aggregate(temp2$federal_action_obligation, by=list(temp2$implan_code), FUN=sum) #this line aggregates the data by sector
  colnames(temp2) <- c("Sector", "Event_value") #change the column names to match activity sheet
  district_emp$totalemployment <- 0 #create new employment column
  n <- which(district_emp$district == district)
  temp2$Employment <- ""
  temp2 <- rbind(temp2, c(545, "", district_emp$implan_545[which(district_emp$district == district)])) #add employment to temp for 545
  temp2 <- rbind(temp2, c(546, "", district_emp$implan_546[which(district_emp$district == district)])) #add employment to temp for 546
  #create extra columns for the first sheet (temp2)
  temp2$Employee_Compensation <- ""
  temp2$Proprieter_Income <- ""
  temp2$EventYear <- as.integer(f_year)
  temp2$Retail <- "No"
  temp2$Local_Direct_Purchase <- "100%"
  #add rows to top of sheet to match needed formatting
  temp2 <- rbind(c("Activity Type", "Activity Name",    "Activity Level","",    "Activity Year","","",""),
                c("Industry Change", "Industry Purchases",    "1","",    "2020","","",""),
                c("","","","","","","",""),
                c("Sector", "Event value", "Employment", "Employee Compensation", "Proprieter Income", "Event Year", "Retail", "Local Direct Purchase"),
                temp2)
  HouseholdSpendingChange4[5,2] <- as.character(va_benefits_districtsagg[which(va_benefits_districtsagg$Group.1 == district), 2]) #update household spending by district
  temp2 <- rbind(temp2, c("temp2", "0", "0")) #add fake 0s to make the line below work
  temp2 <- temp2[-(which(temp2[,2]=="0" | temp2[,3]=="0")),] #delete 0s
  #put sheets into a list. This list will turn into the excel file.
  temp2list <- list("Industry Change" = temp2, "Commodity Output" = CommodityOutput2,
                   "Labor Income Change" = LaborIncomeChange3, "Household Spending Change" = HouseholdSpendingChange4,
                   "Industry Spending Pattern" = IndustrySpendingPattern5,
                   "Institution Spending Pattern" = InstitutionSpendingPattern6)
  #write into multi-sheet excel file
  output_dep_d <- file.path("output", paste0("DEPRECATED_IMPLAN_", year, "_districts//"))
  if(!dir.exists(output_dep_d)){dir.create(output_dep_d)}
  write.xlsx(temp2list, paste0(output_dep_d, "CA-", district, ".xlsx"), colNames = FALSE)
  print(paste(district, ":", (length(temp2list[["Industry Change"]][["Sector"]])-4)))
}