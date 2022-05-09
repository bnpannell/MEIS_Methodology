##If we went the route of the census API R package...

# Add key to .Renviron
Sys.setenv(CENSUS_KEY= c_key)
# Reload .Renviron
readRenviron("~/.Renviron")
# Check to see that the expected key is output in your R console
Sys.getenv("CENSUS_KEY")

state_call = paste0("state:", state_fips) 
regionin_call = paste0(state_call, "+congressional district:", dist_list)
YEAR = as.integer(f_year)

# API Call - this is for apportioning VA direct benefits
districts_vets <- getCensus(
  name = "acs/acs5",
  vintage = YEAR, 
  vars = c("NAME", "B21001_002E"), 
  region = "county (or part):*", 
  regionin = regionin_call)

counties_vets <- getCensus(
  name = "acs/acs5",
  vintage = YEAR, 
  vars = c("NAME", "B21001_002E"), 
  region = "county:*", 
  regionin = state_call)

#API Call - this is for apportioning VA and DHS employment
counties_armedforces <- getCensus(
  name = "acs/acs5",
  vintage = YEAR, 
  vars = c("NAME", "B23025_006E"), 
  region = "county:*", 
  regionin = state_call)

counties_armedforces <- counties_armedforces[c("NAME", "B23025_006E")]
colnames(counties_armedforces) <- c("county", "armed_forces")
counties_armedforces$county <- gsub(' County, California', "", counties_armedforces$county)
counties_armedforces$county <- toupper(counties_armedforces$county)