# MEIS_Methodology
Contains R code for transforming raw data to allow import and processing by IMPLAN 

## How to Use This Repository
Fork repository, and Clone to a new local RStudio Project.
Edit Parameters file- see instructions below or [(link to Documentation)] for detailed explanations.
Select relevant master.R" file to run. The depreciated file may be used to repeat the FY 2020 study, but all subsequent years should use "run_analysis_master.R"


## Parameters File
Update the parameters file to your desired specifications in order to prepare custom data for entry into IMPLAN. 
### USAspending.gov Filters
Variables marked "required" MUST have an accepted value entry or the USAspending API will not run. 
#### Variables
- awards: Optional.
  - Accepted Values:
    - "A" "B" "C" "D" "01" "02" "03" "04" "05" "06" "10"
- agency_type: Required
  - Accepted values:
    - "awarding"
    - "funding"
- agency_tier: Required
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
-
For complete documentation of award types permitted in the filter see: https://fedspendingtransparency.github.io/whitepapers/types/ and https://github.com/fedspendingtransparency/usaspending-api/blob/master/usaspending_api/api_contracts/contracts/v2/bulk_download/awards.md



