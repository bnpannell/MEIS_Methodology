#This file stores parameters for he MEIS Methodology Script. 
#For specific instructions on how to use this file, see README.md

##USAspending.gov Filter Parameters##

##THE FOLLOWING FILTERS ARE MANDATORY AND MUST HAVE A VALID VALUE FOR THE SCRIPT TO RUN

agency_type = c("awarding", "awarding", "awarding", "awarding")
agency_tier = c("toptier", "toptier", "toptier", "toptier")
agency_name = c("Department of Homeland Security", "Department of Defense", "Department of Veterans Affairs", "Department of Energy")
#tier_name = 
  
date_type = "action_date"
  
date_range_start = "2019-10-01"
date_range_end = "2020-09-30"


##The following filters are OPTIONAL- comment out the line if you do not require a filter
#select award types to apply to filter
awards = c("A", "B", "C", "D", "02", "03", "04", "05", "06", "10") 


#select Location filters, at minimum location_country MUST have a valid entry to use the location filter 
#Cannot use 'location_county' and 'location_district' in the same query, must pick one or the other
recipient_locations_country = c("USA")
recipient_locations_state = c("CA")
#recipient_locations_county = c()
#recipient_locations_district = c() 
  













