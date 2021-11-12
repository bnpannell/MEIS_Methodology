## DOE USASPENDING, EMPLOYMENT, AND SMARTPAY CALCULATIONS ##


## CLEAR ENVIRONMENT ##
rm(list = ls(all.names = TRUE))


## LOAD PACKAGES ##
library(readxl) #needed to read in excel sheets
library(dplyr)  #not entirely sure if this is needed 
library(openxlsx) #needed to write excel sheets


## SET WORKING DIRECTORY ##
setwd("C:/Users/sumee/OneDrive/Documents/R/2021_doe")


## DOE USA SPENDING ##
# Read in CSV files of DOE contracts and grants, filter for spending performed in California, and select recipient name and spending amount
# DOE GRANTS
DOEGrants21 <- read.csv(file = "DOE_Grants_Recipient_USA_CA.csv", stringsAsFactors = FALSE) #rename base file for report year

DOEGrants <- DOEGrants21 %>%
  filter(primary_place_of_performance_state_name == "CALIFORNIA") %>%
  select("federal_action_obligation", "recipient_name") %>%
  rename(grants_money = federal_action_obligation, recipient = recipient_name)

# DOE Contracts
DOEContracts21 <- read.csv(file = "DOE_Contracts_Recipient_USA_CA.csv", stringsAsFactors = FALSE)

DOEContracts <- DOEContracts21 %>% 
  filter(primary_place_of_performance_state_name == "CALIFORNIA") %>%
  select("federal_action_obligation", "recipient_name") %>%
  rename(contracts_money = federal_action_obligation, recipient = recipient_name) 

# We now have the total of DOE Contracts and grants spent and performed in California. Now we want to filter for
# (cont'd) national security-related spending. Start again from the original dataframes and filter by funding office
DOEGrants_security <- DOEGrants21 %>%
  filter(primary_place_of_performance_state_name == "CALIFORNIA") %>%
  filter(funding_office_name %in% c("ADVANCED RSRCH PROJ AGENCY ARPA-E", "ENVIRONMENT, HEALTH, SAFETY  SEC",
         "NNSA OFFICE OF THE ADMIN FUNDS", "NNSA OTHER FUNDS", "NNSA WEAPONS ACTIVITIES FUNDS",
         "NNSA-DEFENSE NUCLEAR NONPRO FUNDS", "OFC CYBERSECURITY, (CESER)")) %>%
  select("federal_action_obligation", "recipient_name", "funding_office_name") %>%
  rename(grants_money = federal_action_obligation, recipient = recipient_name)

DOEContracts_security <- DOEContracts21 %>%
  filter(primary_place_of_performance_state_name == "CALIFORNIA") %>%
  filter(funding_office_name %in% c("526 ICBMSW", "ACCTG DISB STA NR 503000", "COMMANDER SUBMARINE FORCE",
                                    "DEF ADVANCED RESEARCH PROJECTS AGCY", "DEPT OF COMMERCE NIST", "DOD SUPPLY ACTIVITY",
                                    "EM-ENVIRONMENTAL MGMT CON BUS CTR", "F59900 SAF FMBIB'", "IDAHO OPERATIONS OFFICE",
                                    "MISSILE DEFENSE AGENCY", "MISSILE DEFENSE AGENCY (MDA)", "NASA MARSHALL SPACE FLIGHT CENTER",
                                    "NNSA M&O CONTRACTING", "NNSA NAVAL REACTORS LAB FLD OFFICE", "NNSA NON-M&O CNTRACTING OPS DIV",
                                    "NNSA OFFICE OF THE ADMIN FUNDS", "NNSA OTHER FUNDS", "NNSA WEAPONS ACTIVITIES FUNDS",
                                    "NNSA-DEFENSE NUCLEAR NONPRO FUNDS", "OFFICE OF NAVAL RESEARCH")) %>%
  select("federal_action_obligation", "recipient_name", "funding_office_name") %>%
  rename(contracts_money = federal_action_obligation, recipient = recipient_name)

# NOW WE HAVE THE TOTALS OF DOE GRANTS AND CONTRACTS SECURITY-RELATED SPENDING
# $2.4 BILLION IN DOE CONTRACTS, AND $54 MILLION IN DOE GRANTS, ADDS ROUGHLY TO $2.5 BILLION IN DOE SECURITY-RELATED SPENDING IN CALIFORNIA
# THE OVERALL TOTAL OF DOE SPENDING IN CA ($4.0 BILLION IN CONTRACTS, $50 MILLION IN GRANTS) WAS $4.1 BILLION


## CALCULATING SECURITY-RELATED DOE EMPLOYMENT IN CALIFORNIA ##
# From FedScope 2020 data, there were 358 DOE employees in CA. But we need to adjust for national security-related employees.
# To do so, we'll use the proportion of security-related DOE spending in CA over total DOE spending in CA as an adjustment for the 358
DOE_adjustment <- ((sum(DOEContracts_security$contracts_money) + sum(DOEGrants_security$grants_money)) /
                      (sum(DOEContracts$contracts_money) + sum(DOEGrants$grants_money)))

DOE_employees <- 358 * DOE_adjustment


## CALCULATING DOE SMARTPAY IN CALIFORNIA ##
# We need to use the proportion of DOE SmartPay spending in CA over DOE national SmartPay spending in FY 2019 to 
# (cont'd) approximate DOE SmartPay spending in CA for FY 2020

# Read in DOE_SmartPay_FY_2019.xlsx and select the needed columns. Rename to shorter names.
doe_smartpay_ca2019.1 <- read_excel("DOE_SmartPay_FY_2019.xlsx")
doe_smartpay_ca2019.2 <- read_excel("DOE_SmartPay_FY_2019.xlsx", sheet = 2)

doe_smartpay_ca2019.1 <- doe_smartpay_ca2019.1 %>% select("Transaction Date", "Transaction Amount", "Merchant") %>%
  rename(date = "Transaction Date", amount = "Transaction Amount")
doe_smartpay_ca2019.2 <- doe_smartpay_ca2019.2 %>% select("Transaction Date", "Transaction Amount", "Merchant Name") %>%
  rename(date = "Transaction Date", amount = "Transaction Amount", Merchant = "Merchant Name")


# Set the date columns as dates, and then filter for entries that fall in the FY 2019 timeframe (10/2018 to 09/2019)
doe_smartpay_ca2019.1$date <- as.Date(doe_smartpay_ca2019.1$date)
doe_smartpay_ca2019.2$date <- as.Date(doe_smartpay_ca2019.2$date)

doe_smartpay_ca2019.1 <- subset(doe_smartpay_ca2019.1, date >= "2018-10-01" & date <= "2018-11-29")
doe_smartpay_ca2019.2 <- subset(doe_smartpay_ca2019.2, date >= "2018-10-01" & date <= "2019-09-30")

# Merge the two dataframes, and add the amount to get total SmartPay in CA for FY 2019

doe_smartpay_ca2019 <- rbind(doe_smartpay_ca2019.1, doe_smartpay_ca2019.2)

CA_SmartPay_2019 <- sum(doe_smartpay_ca2019$amount)

# Now divide the CA_SmartPay_2019 by DOE's 2019 national number, which was $132,056,177.64, to get the proportion
# DOE FY 2019 SmartPay figure retrieved from the GSA SmartPay program statistics website

CA_SmartPay_2019_prop <- CA_SmartPay_2019 / 132056177.64

# Last, multiply this proportion by the DOE FY 2020 national SmartPay to get CA's share of that spending
# For FY 2020, DOE's national SmartPay spending total was $97,256,574
# Last step is to multiply the final number by the DOE_adjustment for national security

CA_SmartPay_2020 <- CA_SmartPay_2019_prop * 97256574
CA_SmartPay_2020 <- CA_SmartPay_2020 * DOE_adjustment

# Final step: write all pertinent DOE info into an Excel sheet
doe_2021 <- list("Contracts" = DOEContracts_security, "Grants" = DOEGrants_security, "Adjustment" = DOE_adjustment,
                        "Employees" = DOE_employees, "SmartPay" = CA_SmartPay_2020)

write.xlsx(doe_2021, paste0("2021_DOE_data.xlsx"))
