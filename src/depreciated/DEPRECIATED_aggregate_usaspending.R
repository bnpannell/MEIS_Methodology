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