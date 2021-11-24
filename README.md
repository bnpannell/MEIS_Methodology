# MEIS_Methodology
Contains R code for transforming raw data to allow import and processing by IMPLAN 

## How to Use This Repository
Fork repository, and Clone to a new local RStudio Project
Edit Parameters file- see instructions below or [(link to Documentation)] for detailed explanations
Select relevant master.R" file to run. The depreciated file may be used to repeat the FY 2020 study, but all subsequent years should use "run_analysis_master.R"


## Parameters File
### USAspending.gov Filters
Variables
- awards: Optional.
  - Accepted Values:
    - "A" "B" "C" "D" "01" "02" "03" "04" "05" "06" "10"
    - A-D denote Contract awards
    - 01 - 05 denote Grant awards
    - 06 & 10 denote Direct Payments
- agency_type: Required 
- agency_tier: Required
- agency_name: Required
- tier_name: Optional
-
For complete documentation of award types permitted in the filter see: https://fedspendingtransparency.github.io/whitepapers/types/ and https://github.com/fedspendingtransparency/usaspending-api/blob/master/usaspending_api/api_contracts/contracts/v2/bulk_download/awards.md



