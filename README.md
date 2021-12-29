# MEIS_Methodology
Contains R code for transforming raw data to allow import and processing by IMPLAN 

## How to Use This Repository
Fork repository, and Clone to a new local RStudio Project.
Edit Parameters file- see instructions below or [(link to Documentation)] for detailed explanations.
Select relevant master.R" file to run. The depreciated file may be used to repeat the FY 2020 study, but all subsequent years should use "run_analysis_master.R"


## Parameters File
Update the parameters file to your desired specifications in order to prepare custom defense spending data for entry into IMPLAN. 

### General Global Variables


f_year = "2020" #Fiscal year of target data 
year = "2021" #report output year
state = "CALIFORNIA"

### obtain_usaspending.R Parameters
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
      -Example: "Department of Veterans Affairs" 
- tier_name: Optional, Required if agency_name is for a subtier agency
  - Accepted Format:
    - ["Full Proper-case Name of Agency"]
      - Example: "Department of Homeland Security"
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

##### Award Type Variables

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

##### Location Variables
The API can handle a list of countries or a list of states within one country or a list of counties within one country and state etc. 
Counties and districts are mutually exclusive filters- you must pick one or the other. If you wish to aggregate data by both, it will require several separate API queries to get data of interest.

- recipient_locations_country:
  - Accepted Values:
    - Country acronym 
      - Example: "USA"
    
- recipient_locations_state:
  - Accepted Values:
    - State acronym 
      - Example: "CA"

- recipient_locations_county 
  - Accepted Values:
    - County 3- digit FIPS code
      - Example: "003"
      
- recipient_locations_district
  - Accepted Values:
    - District name 
      - Example: "2"

For complete documentation of award types permitted in the filter see: https://fedspendingtransparency.github.io/whitepapers/types/ and https://github.com/fedspendingtransparency/usaspending-api/blob/master/usaspending_api/api_contracts/contracts/v2/bulk_download/awards.md

### filter_usaspending.R Parameters
This function is designed to filter the USASpending.gov download based on user specified parameters in the form of data columns of interest
Department of Energy (DOE) data has a special additional filtering step, not all DOE spending is considered defense spending. 

- doe = "DEPARTMENT OF ENERGY (DOE)"

- doe_offices 
    - Accepted values are DOE subtier agencies that are considered to be part of defense spending, names should be in "", comma seperated and   upper case
      - Example: "MISSILE DEFENSE AGENCY"

- grant_columns 

c_label <- "Contracts"
g_label <- "Assistance" 

c_out_name = paste0(year,"_all_contract_spending.csv")
g_out_name = paste0(year,"_all_grant_spending.csv")


### error_check_contracts_data.R Parameters

n2i_dup <- c(111191, 111366, 332117, 335220)

