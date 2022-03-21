##If we went the route of the census API R package...

# Add key to .Renviron
Sys.setenv(CENSUS_KEY= "8df2ad0b1d54d9a4a19c1d97bed2e94e44995571")
# Reload .Renviron
readRenviron("~/.Renviron")
# Check to see that the expected key is output in your R console
Sys.getenv("CENSUS_KEY")

#Look at the list of endpoints available
view(listCensusApis())

# API Call
districts_vets <- getCensus(
  name = "acs/acs5",
  vintage = 2020, 
  vars = c("NAME", "B21001_002E"), 
  region = "county (or part):*", 
  regionin = "state:06+congressional district:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53")

counties_vets <- getCensus(
  name = "acs/acs5",
  vintage = 2020, 
  vars = c("NAME", "B21001_002E"), 
  region = "county:*", 
  regionin = "state:06")

districts_vets$county_or_part <- as.numeric(districts_vets$county_or_part)
counties_vets$county <- as.numeric(counties_vets$county)
