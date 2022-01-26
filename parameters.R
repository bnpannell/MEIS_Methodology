#This file stores parameters for the MEIS Methodology Script. 
#Comment out parameters that are not needed. 
#For specific instructions on how to use this file, see README.md

##General Global Variables##
f_year = "2020" #Fiscal year of target data 
year = "2021" #report output year
state = "CALIFORNIA"

#User-Generated Employment Files
res_mult = 0.1825
national_sus_dhs = 155282
sus_dhs_mult = .142

acs <- read_excel(file.path(getwd(), "data", "raw", paste0("2019_ACS.xlsx"))) %>%
  select(geography, armed_forces_employed)
dod_shares_county <- read_excel(file.path(getwd(), "data", "raw", paste0("DOD_County_Shares.xlsx")), sheet = 1)
dod_shares_district <- read_excel(file.path(getwd(), "data", "raw", paste0("DOD_County_Shares.xlsx")), sheet = 2)
fedprop <- read.csv(file.path(getwd(), "data", "raw", paste0("fed_prop_", year, ".csv")), stringsAsFactors = FALSE) %>%  
  select(Reporting.Agency, Reporting.Bureau, Real.Property.Type, Real.Property.Use, Square.Feet..Buildings.,  
         Street.Address, State.Name, County.Name, Zip.Code, Congressional.District) %>%
  rename(Department = Reporting.Agency, Prop_type=Real.Property.Type,
         Prop_use=Real.Property.Use, Sq_ft=Square.Feet..Buildings., Add=Street.Address, county=County.Name,
         district=Congressional.District) %>% 
  filter(State.Name == state) %>% #select only entries in California 
  filter(Prop_type == "Building") %>% #select only buildings 
  filter(Department == "VETERANS AFFAIRS" | Department == "HOMELAND SECURITY")

##USAspending.gov API Variables##

##THE FOLLOWING FILTERS ARE MANDATORY AND MUST HAVE A VALID VALUE FOR THE SCRIPT TO RUN

agency_type = c("awarding", "awarding", "awarding", "awarding")
agency_tier = c("toptier", "toptier", "toptier", "toptier")
agency_name = c("Department of Homeland Security", "Department of Defense", "Department of Veterans Affairs", "Department of Energy")
#tier_name = 

date_type = "action_date"

date_range_start = "2019-10-01"
date_range_end = "2020-09-30"


##The following filters are OPTIONAL- comment out the line if you do not require a filter
#select award types to apply to filter
awards = c("A", "B", "C", "D", "02", "03", "04", "05", "06", "10") 


#select Location filters, at minimum location_country MUST have a valid entry to use the location filter 
#Cannot use 'location_county' and 'location_district' in the same query, must pick one or the other
recipient_locations_country = c("USA")
recipient_locations_state = c("CA")
#recipient_locations_county = c()
#recipient_locations_district = c() 


##filter_usaspending variables##
doe = "DEPARTMENT OF ENERGY (DOE)"
doe_offices = c("526 ICBMSW", "ACCTG DISB STA NR 503000", "COMMANDER SUBMARINE FORCE",
                        "DEF ADVANCED RESEARCH PROJECTS AGCY", "DEPT OF COMMERCE NIST", "DOD SUPPLY ACTIVITY",
                        "EM-ENVIRONMENTAL MGMT CON BUS CTR", "F59900 SAF FMBIB'", "IDAHO OPERATIONS OFFICE",
                        "MISSILE DEFENSE AGENCY", "MISSILE DEFENSE AGENCY (MDA)", "NASA MARSHALL SPACE FLIGHT CENTER",
                        "NNSA M&O CONTRACTING", "NNSA NAVAL REACTORS LAB FLD OFFICE", "NNSA NON-M&O CNTRACTING OPS DIV",
                        "NNSA OFFICE OF THE ADMIN FUNDS", "NNSA OTHER FUNDS", "NNSA WEAPONS ACTIVITIES FUNDS",
                        "NNSA-DEFENSE NUCLEAR NONPRO FUNDS", "OFFICE OF NAVAL RESEARCH")
contract_columns = c("federal_action_obligation", "awarding_agency_name", "awarding_sub_agency_name", "award_description", "recipient_name", "recipient_county_name", "recipient_congressional_district", "recipient_zip_4_code", "naics_code")
grant_columns = c("federal_action_obligation", "awarding_agency_name", "awarding_sub_agency_name", "award_description", "recipient_name", "recipient_county_name", "recipient_congressional_district", "recipient_zip_code", "recipient_zip_last_4_code", "assistance_type_code", "business_types_description")

c_label <- "Contracts"
g_label <- "Assistance" 

c_out_name = paste0(year,"_all_contract_spending.csv")
g_out_name = paste0(year,"_all_grant_spending.csv")


##concatenate_usaspending variables##
u_out_name = paste0(year,"_concatenated_usaspending.csv")


##aggregate_usaspending variables##
u_state_outname = paste0(year, "_aggregated_usaspending_statewide.csv")
doe_state_outname = paste0(year, "_aggregated_doespending_statewide.csv")
