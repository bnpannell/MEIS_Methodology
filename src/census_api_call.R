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
vets <- getCensus(
  name = "acs/acs5",
  vintage = 2020, 
  vars = c("NAME", "B21001_002E"), 
  region = "county (or part):*", 
  regionin = "state:06+congressional district:51")

listCensusMetadata(
  name="acs/acs5",
  vintage = 2020,
  type = "geography")