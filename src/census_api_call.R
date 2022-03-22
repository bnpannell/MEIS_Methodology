##If we went the route of the census API R package...

# Add key to .Renviron
Sys.setenv(CENSUS_KEY= "8df2ad0b1d54d9a4a19c1d97bed2e94e44995571")
# Reload .Renviron
readRenviron("~/.Renviron")
# Check to see that the expected key is output in your R console
Sys.getenv("CENSUS_KEY")

#Look at the list of endpoints available
#view(listCensusApis())
dist_list = "01,02,03,04,05,06,07,08" #define in parameters- CANNOT CONTAIN SPACES
state_fips = 06  #define in parameters
thing = paste0("state:", state_fips, "+congressional district:", dist_list) #make variable in api section, not parameters

print(thing)

# API Call
districts_vets <- getCensus(
  name = "acs/acs5",
  vintage = 2020, 
  vars = c("NAME", "B21001_002E"), 
  region = "county (or part):*", 
  regionin = thing)

counties_vets <- getCensus(
  name = "acs/acs5",
  vintage = 2020, 
  vars = c("NAME", "B21001_002E"), 
  region = "county:*", 
  regionin = "state:06")

districts_vets$county_or_part <- as.numeric(districts_vets$county_or_part)
counties_vets$county <- as.numeric(counties_vets$county)
