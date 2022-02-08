# MEIS_Methodology
Contains R code for transforming raw data to allow import and processing by IMPLAN 

## How to Use This Repository
Fork the repository, and clone to a new local RStudio Project.
Edit the Parameters file - see instructions below or [(link to Documentation)] for detailed explanations.
Select the relevant "master.R" file to run. The "DEPRECATED_run_analysis_master.R" file may be used to repeat the 2021 study, but all subsequent years should use "run_analysis_master.R"

## Parameters File
Update the parameters file to your desired specifications in order to prepare custom defense spending data for entry into IMPLAN. 

### General Global Variables
- f_year:
  - Accepted values: A four digit year of the fiscal year of data (may be different than the report year) in double quotes
    -Example: "2020"
- year:
  - Accepted values: A four digit year of the expected publication date of the study in double quotes
    - Example: "2021"
- state:
  - Accepted values: The target state of the study, in upper case wrapped in double quotes  
    -Example: "CALIFORNIA"

### User-Generated Employment File Variables
- res_mult:
  - Accepted values: the multiplier to calculate full time equivalent numbers of military reserves in decimal format.
    - Example: 0.1825
- national_sus_dhs:
  - Accepted values: the number of suppressed federal Department of Homeland Security employees in integer format.
    - Example: 155282
- sus_dhs_mult:
  - Accepted values: the multiplier for calculating the number of national suppressed federal Department of Homeland Security employees in the given study region in decimal format.
    - Example: .142
- acs:
  - Accepted values: the properly formatted name (in "") of the file containing needed ACS data after downloading and renaming. 
    - Example: "2019_ACS.xlsx"
- dod_shares:
  - Accepted values: the properly formatted name (in "") of the file containing data for the % of each county that is in each congressional district for the study state.
    - Example: "DOD_County_Shares.xlsx"
- fed_prop:
  - Accepted values: the properly formatted name (in "") of the file containing needed federal data after downloading and renaming. 
    - Example: "fed_prop_2021.csv"

### obtain_usaspending.R Parameters
With the exception of 'tier_name,' variables under "Required" MUST have an accepted value entry or the USAspending API will not run.

#### Required Variables
- agency_type: 
  - Accepted values: A comma separated list of the following values - one for every agency in the query.
    - "awarding"
    - "funding"
- agency_tier: A comma separated list of the following values - one for every agency in the query.
  - Accepted values:
    - "toptier"
    - "subtier" 
- agency_name: Required, A comma separated list of every desired agency in the query.
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
The API can handle a list of countries or a list of states within one country, or a list of counties within one country and state, etc. 
Counties and districts are mutually exclusive filters - you must pick one or the other. If you wish to aggregate data by both, it will require several separate API queries to get the data of interest.

- recipient_locations_country:
  - Accepted Values:
    - Country acronym 
      - Example: "USA"
- recipient_locations_state:
  - Accepted Values:
    - State acronym 
      - Example: "CA"
- recipient_locations_county: 
  - Accepted Values:
    - County 3- digit FIPS code
      - Example: "003"
- recipient_locations_district:
  - Accepted Values:
    - District name 
      - Example: "2"

For complete documentation of award types permitted in the filter, see: 
- https://fedspendingtransparency.github.io/whitepapers/types/ and
- https://github.com/fedspendingtransparency/usaspending-api/blob/master/usaspending_api/api_contracts/contracts/v2/bulk_download/awards.md

### filter_usaspending.R Parameters
This function is designed to filter the USASpending.gov download based on user specified parameters.
Department of Energy (DOE) data has a special additional filtering step, as not all DOE spending is considered defense spending. 

- doe = "DEPARTMENT OF ENERGY (DOE)"
- grant_columns:
  - Accepted values are column headers for data columns you wish to keep in the output file for grants data, exactly as written in the file and in "".
    - Example: "awarding_agency_name"
- c_label:
  - Accepted values: any unique word appearing in the name of the contract data file generated by the USASpending API 
    - Example: 'Contracts'
- g_label: 
  - Accepted values: any unique word appearing in the name of the grant data file generated by the USASpending API 
    - Example: 'Assistance'
- c_out_name:
  - Accepted values: any output name with a ".csv" file type ending. It is recommended to follow a naming convention when entering this variable
    - Example: "_all_contract_spending.csv"
- g_out_name: 
  - Accepted values: any output name with a ".csv" file type ending. It is recommended to follow a naming convention when entering this variable
    - Example: "_all_grant_spending.csv"

### concatenate_usaspending.R Parameters
This function is designed to concatenate the cleaned USASpending.gov spending contracts and grants data into one dataframe and subsequent CSV file.

- u_out_name:
  - Accepted values: any output name with a ".csv" file type ending. It is recommended to follow a naming convention when entering this variable 
    - Example: "_concatenated_usaspending.csv"

### natsec_doe.R Parameters   
This R script is designed to filter the DOE spending data to only national security-related spending, and to provide a national security proportion to be applied to DOE employment and SmartPay spending.

- doe_offices: 
    - Accepted values are DOE subtier agencies that are considered to be part of defense spending, names should be in "", comma separated and upper case
      - Example: "MISSILE DEFENSE AGENCY"

### aggregate_usaspending.R Parameters
This function is designed to aggregate the concatenated USASpending and DOE spending data by IMPLAN sector into two dataframes and subsequent CSV files.

- u_state_outname:
  - Accepted values: any output name with a ".csv" file type ending. It is recommended to follow a naming convention when entering this variable
    - Example: "_aggregated_usaspending_statewide.csv"
- doe_state_outname:
  - Accepted values: any output name with a ".csv" file type ending. It is recommended to follow a naming convention when entering this variable
    -Example: "_aggregated_doespending_statewide.csv"
    
## Additional Notes
If you are repeating the 2021 study, pay attention to what sections of the "DEPRECATED_run_analysis_master.R" code you are running. There is a break between obtaining, filtering and cleaning data where the user will have to manually edit errors in the data and save the files to the correct folders before continuing the code. See ([Link to documentation]) for detailed instructions. 

The "run_analysis_master.R" code follows similar conventions, but is updated to correct errors in the data in a more automated way. Follow instructions in the code comments. 