# MEIS_Methodology
Contains R code for transforming raw data to allow import and processing by IMPLAN 

## How to Use This Repository
Fork repository, and Clone to a new local RStudio Project.
Edit Parameters file- see instructions below or [(link to Documentation)] for detailed explanations.
Select relevant master.R" file to run. The depreciated file may be used to repeat the FY 2020 study, but all subsequent years should use "run_analysis_master.R"


## Parameters File
Update the parameters file to your desired specifications in order to prepare custom data for entry into IMPLAN. 

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
    - "A" (contract award)
    - "B" (contract award)
    - "C" (contract award)
    - "D" (contract award)
    - "01" (grant award)
    - "02" (grant award)
    - "03" (grant award)
    - "04" (grant award)
    - "05" (grant award)
    - "06" (direct payment)
    - "10" (direct payment)

-

Location variables
Notes- can handle a list of countries, states, counties or districts. If listing multiple countries you cant list more states, if listing states you cant get specific counties or districts
Counties and districts are mutually exclusing filters- you must pick one or the other and may have to run several seperate API queries to get data of interest


For complete documentation of award types permitted in the filter see: https://fedspendingtransparency.github.io/whitepapers/types/ and https://github.com/fedspendingtransparency/usaspending-api/blob/master/usaspending_api/api_contracts/contracts/v2/bulk_download/awards.md



