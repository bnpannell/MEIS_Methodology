## Code for generating county and district IMPLAN activity sheets ##

# Read in blank sheets from the event template - they'll be combined with the final data to create a multi-sheet Excel file for IMPLAN
iia2 <- read_excel(path = (file.path(raw_path, blank_sheets, "iia2.xlsx")))
ica3 <- read_excel(path = (file.path(raw_path, blank_sheets, "ica3.xlsx")))
commodity4 <- read_excel(path = (file.path(raw_path, blank_sheets, "commodity4.xlsx")))
marg_commodity5 <- read_excel(path = (file.path(raw_path, blank_sheets, "marginable_commodities5.xlsx")))
labor_income6 <- read_excel(path = (file.path(raw_path, blank_sheets, "labor_income6.xlsx")))
household_income7 <- read_excel(path = (file.path(raw_path, blank_sheets, "household_income7.xlsx")))
industry_spend8 <- read_excel(path = (file.path(raw_path, blank_sheets, "industry_spending8.xlsx")))
institution_spend9 <- read_excel(path = (file.path(raw_path, blank_sheets, "institution_spending9.xlsx")))

# Create a list of unique counties and districts to read into the for loop
countynames <- unique(usaspending[,4])
countynames <- countynames[countynames != ""]
sort(countynames)

congressid <- as.character(unique(usaspending[,5]))
congressid <- congressid[congressid != 90]
congressid <- congressid[!(is.na(congressid))]

## LOOP FOR "NORMAL" AND INVERSE IMPLAN ACTIVITY SHEETS PER COUNTY ##
# Account for counties without spending data # 
va_benefits_countiesagg <- merge(va_benefits_countiesagg, data.frame(county = countynames), by.x = "Group.1", by.y = "county", all.y = TRUE)
va_benefits_countiesagg$x[is.na(va_benefits_countiesagg$x)] <- 0

for (county in countynames){
    j <- which(usaspending[4] == county)
    temp <- usaspending[j,]
  temp <- aggregate(temp$spending, by=list(temp$implan_code), FUN=sum) #this line aggregates the data by Specification
  colnames(temp) <- c("Specification", "Output") #change the column names to match activity sheet
  temp <- temp %>%
    filter(temp$Output != 0) #Take out rows where there is no spending
  county_emp$totalemployment <- 0 #create new employment column
  m <- which(county_emp$county == county)
  temp$Employment <- ""
  temp <- rbind(temp, c(545, "", county_emp$implan_545[which(county_emp$county == county)])) #add employment to temp for 545
  temp <- rbind(temp, c(546, "", county_emp$implan_546[which(county_emp$county == county)])) #add employment to temp for 546
  temp <- temp %>%
    mutate_at(c(1:3), as.numeric) #Make columns numeric
  #create extra columns for the first sheet (temp)
  temp$'Event Name' <- paste0("ind", temp$Specification)
  temp$'Employee Compensation' <- ""
  temp$'Proprieter Income' <- ""
  temp$Margins <- ""
  temp$'Event Tag' <- ""
  #reorder the columns and input the va_benefits data into the household income sheet
  temp <- temp[, c("Event Name", "Specification", "Output", "Employment", "Employee Compensation", "Proprieter Income",
                   "Margins", "Event Tag")]
  household_income7[1,1] <- "va_benefits"
  household_income7[1,2] <- 10001
  household_income7[1,3] <- as.numeric(va_benefits_countiesagg[which(va_benefits_countiesagg$Group.1 == county), 2]) #update household spending by county
  #input notation for SmartPay into the institutional spending pattern sheet
  institution_spend9[1,1] <- "SmartPay"
  institution_spend9[1,2] <- "11002"
  institution_spend9[1,3] <- "2022"
  #put sheets into a list. This list will turn into the excel file.
  templist <- list("Industry" = temp, "IIA (Detailed)" = iia2, "Industry Contribution Analysis" = ica3,
                   "Commodity" = commodity4, "Marginable Commodities" = marg_commodity5, "Labor Income" = labor_income6,
                   "Household Income" = household_income7, "Industry Spending Pattern" = industry_spend8, "Institution Spending Pattern" = institution_spend9)
  #write into multi-sheet excel file
  output_dep_c <- file.path(output_path, paste0("IMPLAN_", year, "_counties//"))
  if(!dir.exists(output_dep_c)){dir.create(output_dep_c)}
  write.xlsx(templist, paste0(output_dep_c, county, ".xlsx"), colNames = T)
  print(paste(county, ":", (length(templist[["Industry"]][["Specification"]])-1)))
  #tempooc is the INVERSE sheet
  tempooc <- usaspending
  tempooc <- aggregate(tempooc$spending, by=list(tempooc$implan_code), FUN=sum) #this line aggregates the data by Specification
  temp <- temp[-(1:4),]
  for (i in 1:nrow(temp)){
    n <- which(tempooc$Group.1 == temp$Specification[i])
    tempooc$x[n] <- tempooc$x[n] - as.numeric(temp$Output[i]) #subtract each event value from total CA spending
  }
  colnames(tempooc) <- c("Specification", "Output") #change the column names to match activity sheet
  tempooc <- tempooc %>%
    filter(tempooc$Output != 0) #Take out rows where there is no spending
  #add inverse employment data to tempooc and make columns numeric
  tempooc$Employment <- ""
  tempooc <- rbind(tempooc, c(545, "", county_emp$inverse_545[which(county_emp$county == county)]))
  tempooc <- rbind(tempooc, c(546, "", county_emp$inverse_546[which(county_emp$county == county)]))
  tempooc <- tempooc %>%
    mutate_at(c(1:3), as.numeric)
  #add extra sheets to tempooc
  tempooc$'Event Name' <- paste0("ind", tempooc$Specification)
  tempooc$'Employee Compensation' <- ""
  tempooc$'Proprieter Income' <- ""
  tempooc$Margins <- ""
  tempooc$'Event Tag' <- ""  
  #reorder the columns and input the va_benefits data into the household income sheet 
  tempooc <- tempooc[, c("Event Name", "Specification", "Output", "Employment", "Employee Compensation", "Proprieter Income",
                         "Margins", "Event Tag")]
  household_income7[1,1] <- "va_benefits"
  household_income7[1,2] <- 10001
  household_income7[1,3] <- as.numeric(va_benefits_stateagg - va_benefits_countiesagg[which(va_benefits_countiesagg$Group.1 == county), 2]) #update household spending by county (in)
  #input notation for SmartPay into the institutional spending pattern sheet
  institution_spend9[1,1] <- "SmartPay"
  institution_spend9[1,2] <- "11002"
  institution_spend9[1,3] <- "2022"
  #put all sheets into one list
  tempooclist <- list("Industry" = tempooc, "IIA (Detailed)" = iia2, "Industry Contribution Analysis" = ica3,
                      "Commodity" = commodity4, "Marginable Commodities" = marg_commodity5, "Labor Income" = labor_income6,
                      "Household Income" = household_income7, "Industry Spending Pattern" = industry_spend8, "Institution Spending Pattern" = institution_spend9)
  #write into multi-sheet excel file
  write.xlsx(tempooclist, paste0(output_dep_c, county, "in.xlsx"), colNames = T)
  print(paste(county, "(in) :", (length(tempooclist[["Industry"]][["Specification"]])-1)))
}

## LOOP FOR "NORMAL" IMPLAN ACTIVITY SHEETS PER DISTRICT ##
# Account for districts without spending data # 
va_benefits_districtsagg <- merge(va_benefits_districtsagg, data.frame(id = congressid), by.x = "Group.1", by.y = "id", all.y = TRUE)
va_benefits_districtsagg$x[is.na(va_benefits_districtsagg$x)] <- 0 

for (district in congressid){
  #print(paste(district, class(district)))
  k <- which(usaspending[5] == district)
  temp2 <- usaspending[k,]
  temp2 <- aggregate(temp2$spending, by=list(temp2$implan_code), FUN=sum) #this line aggregates the data by Specification
  colnames(temp2) <- c("Specification", "Output") #change the column names to match activity sheet
  temp2 <- temp2 %>%
    filter(temp2$Output != 0) #Take out rows where there is no spending
  district_emp$totalemployment <- 0 #create new employment column
  n <- which(district_emp$district == district)
  temp2$Employment <- ""
  temp2 <- rbind(temp2, c(545, "", district_emp$implan_545[which(district_emp$district == district)])) #add employment to temp for 545
  temp2 <- rbind(temp2, c(546, "", district_emp$implan_546[which(district_emp$district == district)])) #add employment to temp for 546
  temp2 <- temp2 %>%
    mutate_at(c(1:3), as.numeric) #Make columns numeric
  #create extra columns for the first sheet (temp2)
  temp2$'Event Name' <- paste0("ind", temp2$Specification)
  temp2$'Employee Compensation' <- ""
  temp2$'Proprieter Income' <- ""
  temp2$Margins <- ""
  temp2$'Event Tag' <- ""
  #reorder the columns and input the va_benefits data into the household income sheet
  temp2 <- temp2[, c("Event Name", "Specification", "Output", "Employment", "Employee Compensation", "Proprieter Income",
                   "Margins", "Event Tag")]
  household_income7[1,1] <- "va_benefits"
  household_income7[1,2] <- 10001
  household_income7[1,3] <- as.numeric(va_benefits_districtsagg[which(va_benefits_districtsagg$Group.1 == district), 2]) #update household spending by district
  #input notation for SmartPay into the institutional spending pattern sheet
  institution_spend9[1,1] <- "SmartPay"
  institution_spend9[1,2] <- "11002"
  institution_spend9[1,3] <- "2022"
  #put sheets into a list. This list will turn into the excel file.
  temp2list <- list("Industry" = temp2, "IIA (Detailed)" = iia2, "Industry Contribution Analysis" = ica3,
                    "Commodity" = commodity4, "Marginable Commodities" = marg_commodity5, "Labor Income" = labor_income6,
                    "Household Income" = household_income7, "Industry Spending Pattern" = industry_spend8, "Institution Spending Pattern" = institution_spend9)
  #write into multi-sheet excel file
  output_dep_d <- file.path(output_path, paste0("IMPLAN_", year, "_districts//"))
  if(!dir.exists(output_dep_d)){dir.create(output_dep_d)}
  write.xlsx(temp2list, paste0(output_dep_d, "CA-", district, ".xlsx"), colNames = T)
  print(paste(district, ":", (length(temp2list[["Industry"]][["Specification"]])-1)))
}