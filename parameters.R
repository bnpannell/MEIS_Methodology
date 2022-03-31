#This file stores parameters for the MEIS Methodology Script. 
#Comment out parameters that are not needed. 
#For specific instructions on how to use this file, see README.md

##General Global Variables##
f_year = "2020" #Fiscal year of target data 
year = "2021" #report output year
state = "CALIFORNIA"


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


##obtain_vet_census variables##
c_key = "8df2ad0b1d54d9a4a19c1d97bed2e94e44995571" #DELETE BEFORE POSTING TO GITHUB!!!
dist_list = "01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53" 
#Above list CANNOT CONTAIN SPACES
state_fips = "06"  #Uses 2 digit state fips code


##filter_usaspending variables##
contract_columns = c("federal_action_obligation", "awarding_agency_name", "awarding_sub_agency_name", "award_description", "funding_office_name", "recipient_name", "recipient_county_name", "recipient_congressional_district", "recipient_zip_4_code", "naics_code")
grant_columns = c("federal_action_obligation", "awarding_agency_name", "awarding_sub_agency_name", "award_description", "funding_office_name", "recipient_name", "recipient_county_code", "recipient_county_name", "recipient_congressional_district", "recipient_zip_code", "recipient_zip_last_4_code", "assistance_type_code", "business_types_description")

c_label <- "Contracts"
g_label <- "Assistance" 

c_out_name = "_all_contract_spending.csv"
g_out_name = "_all_grant_spending.csv"


##error_check_contracts variables##
naics_crosswalk <- "2007_to_2017_NAICS.xlsx"
naics_2007 <- c(314912, 315228, 315999, 316999, 332212, 333313, 333319, 333518, 334119, 334411, 339944, 443120)

implan_crosswalk <- "2012_2017_NAICS_to_IMPLAN.xlsx"
construction_naics <- c(236118, 236220, 237110, 237130, 237310, 237990, 238110, 238120, 238140, 238160, 238190, 238210, 
                        238220, 238290, 238310, 238320, 238330, 238390, 238910, 238990)


##concatenate_usaspending variables##
u_out_name = "_concatenated_usaspending.csv"


##split_usaspending variables##
doe = "DEPARTMENT OF ENERGY (DOE)"


##natsec_doe variables##
doe_offices = c("526 ICBMSW", "ACCTG DISB STA NR 503000", "COMMANDER SUBMARINE FORCE",
                "DEF ADVANCED RESEARCH PROJECTS AGCY", "DEPT OF COMMERCE NIST", "DOD SUPPLY ACTIVITY",
                "EM-ENVIRONMENTAL MGMT CON BUS CTR", "F59900 SAF FMBIB'", "IDAHO OPERATIONS OFFICE",
                "MISSILE DEFENSE AGENCY", "MISSILE DEFENSE AGENCY (MDA)", "NASA MARSHALL SPACE FLIGHT CENTER",
                "NNSA M&O CONTRACTING", "NNSA NAVAL REACTORS LAB FLD OFFICE", "NNSA NON-M&O CNTRACTING OPS DIV",
                "NNSA OFFICE OF THE ADMIN FUNDS", "NNSA OTHER FUNDS", "NNSA WEAPONS ACTIVITIES FUNDS",
                "NNSA-DEFENSE NUCLEAR NONPRO FUNDS", "OFFICE OF NAVAL RESEARCH")


##aggregate_usaspending variables##
u_state_outname = "_aggregated_usaspending_statewide.csv"
doe_state_outname = "_aggregated_doespending_statewide.csv"


##generate_employment_dataframe Variables##
res_mult = 0.1825
national_sus_dhs = 155282
sus_dhs_mult = .142
acs = "2019_acs.xlsx"
dod_shares = "dod_county_shares.xlsx"
fed_prop = "fed_prop_2021.csv" 


##Parameters for wrangle_opm_foia.R##
opm_foia_file <- "Copy of Select Agencies by Locations FY 2019 - FY 2021.xlsx"