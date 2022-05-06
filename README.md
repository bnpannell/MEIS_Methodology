# MEIS_Methodology
Contains R code for transforming raw data to allow import and processing by IMPLAN 

## How to Use This Repository
Fork the repository, and clone to a new local RStudio Project.
Edit the Parameters file - see instructions below or [(link to Documentation)] for detailed explanations.
Run code from the "run_analysis_master.R" file. Pay attention to the comment sections of the code, for example, on line [(INSERT LINE VALUE)] you will need to pause, hand make an error repair file for Contract data without a Congressional District (if needed) and then continue to run the remainder of the code. 

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
    
#General Paths to Folders
- output_path: 
  - Accepted values: A file path to the repository's output folder. 
    - Example: file.path("output")
- temp_path:
  - Accepted values: A file path to the repository's temporary data folder. 
    - Example: file.path("data", "temp")
- raw_path
  - Accepted values: A file path to the repository's raw data folder. 
    - Example: file.path("data", "raw") 

### obtain_usaspending.R Parameters
With the exception of 'tier_name,' variables under "Required" MUST have an accepted value entry or the USAspending API will not run.

#### Required Variables
- agency_type: 
  - Accepted values: A comma separated list ( C("", "") ), of the following values - one for every agency in the query.
    - "awarding"
    - "funding"
- agency_tier: A comma separated list ( C("", "") ), of the following values - one for every agency in the query.
  - Accepted values:
    - "toptier"
    - "subtier" 
- agency_name: Required, A comma separated list ( C("", "") ), of every desired agency in the query.
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
  - Accepted Values: a list ( C("", "") ), of the award types of interest. The types of awards are as follows:
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
    - A Country acronym or a list of country acronyms.
      - Example: c("USA")
- recipient_locations_state:
  - Accepted Values:
    - A State acronym or a list of state acronyms.  
      - Example: c("CA")
- recipient_locations_county: 
  - Accepted Values:
    - A County 3- digit FIPS code, or a list of county FIPS codes. 
      - Example: c("003")
- recipient_locations_district:
  - Accepted Values:
    - A District name or a list of district names. 
      - Example: c("2")

For complete documentation of award types permitted in the filter, see: 
- https://fedspendingtransparency.github.io/whitepapers/types/ and
- https://github.com/fedspendingtransparency/usaspending-api/blob/master/usaspending_api/api_contracts/contracts/v2/bulk_download/awards.md

##obtain_vet_census Parameters##
- c_key:
  - Accepted values: A valid API Key. This repository DOES NOT provide an API Key. Obtain a valid API Key by signing up at this website: https://api.census.gov/data/key_signup.html Please do not share your API Key with anyone else. 
- dist_list:
  -Accepted values: A comma separated list of districts you wish to pull Census data for. DO NOT INCLUDE SPACES BETWEEN THE COMMAS AND THE VALUES! 
    - Example: "01,02,03"
- state_fips:
  - Accepted values: The two digit fips code for the state you are downloading Census data for in "". 
    - Example: "06"  
    
For complete documentation of the censusapi library, see:
- https://cran.r-project.org/web/packages/censusapi/vignettes/getting-started.html

### filter_usaspending.R Parameters
This function is designed to filter the USASpending.gov download based on user specified parameters.

- contract_columns:
  - Accepted values: A list of column headers for data columns you wish to keep in the output file for contracts data, exactly as written in the file.
    - Example: c("awarding_agency_name")
- grant_columns:
  - Accepted values: A list of column headers for data columns you wish to keep in the output file for grants data, exactly as written in the file.
    - Example: c("awarding_agency_name")
- c_label:
  - Accepted values: any unique word appearing in the name of the contract data file generated by the USASpending API 
    - Example: 'Contracts'
- g_label: 
  - Accepted values: any unique word appearing in the name of the grant data file generated by the USASpending API     - Example: 'Assistance'
- all_c_data:
  - Accepted values: any output name with a ".csv" file extension. It is recommended to follow a naming convention when entering this variable
    - Example: "_all_contract_spending.csv"
- all_g_data: 
  - Accepted values: any output name with a ".csv" file extension. It is recommended to follow a naming convention when entering this variable
    - Example: "_all_grant_spending.csv"

##contract_check variables##
Please note: care should be taken to choose words (or when available- word stems that allow for the matching of multiple words), that are unique to the category you seek to sort and long enough that it is providing meaningful category specific matches. 
- repair_implan_60: 
  - Accepted values: A list of word and word fragments that refer to repair or maintenance activities, used to filter construction NAICs codes into the correct IMPLAN category. 
    - Example: c("repair", "rpr", "maint", "renovat", "replac")
- aircraft_implan_60:
  - Accepted values: A list of word and word fragments that refer to airport or runway maintenance, used to filter construction NAICs codes into the correct IMPLAN category.
    -Example: c("aircraft", "carrier", "airplane", "airfield", "taxiway", "runway")
- new_implan_56:
  - Accepted values: A list of word and word fragments that refer to new construction, used to filter construction NAICs codes into the correct IMPLAN category. 
    - Example: c("construct", "rebuild")

##error_check_contracts variables##
- naics_crosswalk:
    - Accepted values: The full name (including file extension) of the NAICs to NAICs crosswalk used to fix outdated NAICs codes.
      - Example: "2007_to_2017_NAICS.xlsx"
- implan_crosswalk:
  - Accepted values: The full name (including file extension) of the NAICS to IMPLAN crosswalk used to match NAICs code to the correct IMPLAN category.
    - Example: "2012_2017_NAICS_to_IMPLAN.xlsx"
- clean_c_data:
  - Accepted values: The desired file name of the cleaned contract data, including file extension. This name should start with an underscore if you wish to add a prefix. 
    - Example: "_cleaned_contracts.csv"
- contract_errors:
  - Accepted values: The desired file name of the contract data containing errors, including file extension. This name should start with an underscore if you wish to add a prefix. 
    - Example: "_contract_errors.csv"

##error_check_grants variables##
- btype_crosswalk:
  - Accepted values: The name of the file provided in the raw data folder containing the business type to implan crosswalk, including file type.
    - Example: "business_type_to_implan546_crosswalk.csv"
- clean_g_data:
  - Accepted values: The desired file name of the cleaned grants data, including file extension. This name should start with an underscore if you wish to add a prefix. 
    - Example: "_cleaned_grants.csv"
- grant_errors:
  - Accepted values: The desired file name of the grants data containing errors, including file extension. This name should start with an underscore if you wish to add a prefix.
    - Example: "_grant_errors.csv"

##na_dist_repair function variables## 
- contr_dist_crosswalk:
  - Accepted values: The full name (including file extension) of the user made district/ recipient repair file for contract data 
    - Example: "contract_industry_district_crosswalk.csv"

##repair_and_weight_direct_payments variable
clean_v_data = "_cleaned_va_benefits.csv"





### concatenate_usaspending.R Parameters
This function is designed to concatenate the cleaned USASpending.gov spending contracts and grants data into one dataframe and subsequent CSV file.

- u_out_name:
  - Accepted values: any output name with a ".csv" file type ending. It is recommended to follow a naming convention when entering this variable 
    - Example: "_concatenated_usaspending.csv"
    
##split_usaspending variables##
doe = "DEPARTMENT OF ENERGY (DOE)"

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
    
##generate_employment_dataframe Variables##
res_mult = 0.1825
national_sus_dhs = 155282
sus_dhs_mult = .142
acs = "2019_acs.xlsx"
dod_shares = "dod_county_shares.xlsx"
fed_prop = "fed_prop_2021.csv" 

##Parameters for wrangle_opm_foia.R##
opm_foia_file <- "Copy of Select Agencies by Locations FY 2019 - FY 2021.xlsx"