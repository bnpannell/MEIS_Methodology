# MEIS_Methodology
Contains R code for transforming raw data to allow import and processing by IMPLAN 

## How to Use This Repository
Fork repository, and Clone to a new local RStudio Project.
Edit Parameters file- see instructions below or [(link to Documentation)] for detailed explanations.
Select relevant master.R" file to run. The depreciated file may be used to repeat the FY 2020 study, but all subsequent years should use "run_analysis_master.R"


## Parameters File
Update the parameters file to your desired specifications in order to prepare custom defense spending data for entry into IMPLAN. 

### General Global Variables


#need file naming conventions
f_year = "2020" #Fiscal year of target data 
year = "2021" #report output year
state = "CALIFORNIA"

### USAspending.gov Filters
With the exception of 'tier_name,' variables under "Required" MUST have an accepted value entry or the USAspending API will not run.

#### Required Variables
- agency_type: 
  - Accepted values:
    - "awarding"
    - "funding"
- agency_tier: 
  - Accepted values:
    - "toptier"
    - "subtier" 
- agency_name: Required
  - Accepted Format:
    - ["Full Proper-case Name of Agency"]
      -Example:
        - "Department of Veterans Affairs" 
- tier_name: Optional, Required if agency_name is for a subtier agency
  - Accepted Format:
    - ["Full Proper-case Name of Agency"]
      - Example:
        - "Department of Homeland Security"
- date_type:
  - Accepted Values:
    - "action_date"
    - "last_modified_date"
- date_range_start:
  - Accepted Format: 
    - Year-Month-Day or yyyy-mm-dd 
- date_range_end:
  - Accepted Format: 
    - Year-Month-Day or yyyy-mm-dd 

#### Optional Variables
- awards: 
  - Accepted Values:
    - Contract Type Awards:
      - "A" 
      - "B" 
      - "C" 
      - "D"
    - Grant Type Awards:
      - "01" 
      - "02" 
      - "03" 
      - "04" 
      - "05" 
    - Direct Payments:  
      - "06" 
      - "10" 

-

Location variables
Notes- can handle a list of countries, states, counties or districts. If listing multiple countries you cant list more states, if listing states you cant get specific counties or districts
Counties and districts are mutually exclusing filters- you must pick one or the other and may have to run several separate API queries to get data of interest
recipient_locations_country = c("USA")
recipient_locations_state = c("CA")
recipient_locations_county = c()
recipient_locations_district

For complete documentation of award types permitted in the filter see: https://fedspendingtransparency.github.io/whitepapers/types/ and https://github.com/fedspendingtransparency/usaspending-api/blob/master/usaspending_api/api_contracts/contracts/v2/bulk_download/awards.md

##filter_usaspending parameters##

doe = "DEPARTMENT OF ENERGY (DOE)"
doe_offices = c("526 ICBMSW", "ACCTG DISB STA NR 503000", "COMMANDER SUBMARINE FORCE",
                        "DEF ADVANCED RESEARCH PROJECTS AGCY", "DEPT OF COMMERCE NIST", "DOD SUPPLY ACTIVITY",
                        "EM-ENVIRONMENTAL MGMT CON BUS CTR", "F59900 SAF FMBIB'", "IDAHO OPERATIONS OFFICE",
                        "MISSILE DEFENSE AGENCY", "MISSILE DEFENSE AGENCY (MDA)", "NASA MARSHALL SPACE FLIGHT CENTER",
                        "NNSA M&O CONTRACTING", "NNSA NAVAL REACTORS LAB FLD OFFICE", "NNSA NON-M&O CNTRACTING OPS DIV",
                        "NNSA OFFICE OF THE ADMIN FUNDS", "NNSA OTHER FUNDS", "NNSA WEAPONS ACTIVITIES FUNDS",
                        "NNSA-DEFENSE NUCLEAR NONPRO FUNDS", "OFFICE OF NAVAL RESEARCH")
contract_columns = c("federal_action_obligation", "awarding_agency_name", "awarding_sub_agency_name", "award_description", "recipient_name", "recipient_county_name", "recipient_congressional_district", "recipient_zip_4_code", "naics_code")
grant_columns = c("federal_action_obligation", "awarding_agency_name", "awarding_sub_agency_name", "award_description", "recipient_name", "recipient_county_name", "recipient_congressional_district", "recipient_zip_code", "recipient_zip_last_4_code", "business_types_description")

c_label <- "Contracts"
g_label <- "Assistance" 

c_out_name = paste0(year,"_all_contract_spending.csv")
g_out_name = paste0(year,"_all_grant_spending.csv")


##error_check_contracts_data parameters##

n2i_dup <- c(111191, 111366, 332117, 335220)

