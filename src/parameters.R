#This file stores parameters for he MEIS Methodology Script. 
#For specific instructions on how to use this file, see README.md

##USAspending.gov Filter Parameters##

#For complete documentation of award types permitted in the filter see: https://fedspendingtransparency.github.io/whitepapers/types/
# and https://github.com/fedspendingtransparency/usaspending-api/blob/master/usaspending_api/api_contracts/contracts/v2/bulk_download/awards.md

#select award types to apply to filter, if none required enter "Null"
awards = list("A", "B", "C", "D", "02", "03", "04", "05", "06", "10") #optional filter














body = list(
  filters = list(
    prime_award_types = c("A", "B", "C", "D", "02", "03", "04", "05", "06", "10"),
    agencies = data.frame(
      type = c("awarding", "awarding", "awarding", "awarding"),
      tier = c("toptier", "toptier", "toptier", "toptier"),
      name = c("Department of Homeland Security", "Department of Defense", "Department of Veterans Affairs", "Department of Energy")
    ),
    date_type = "action_date",
    date_range = list(start_date = "2019-10-01",
                      end_date = "2020-09-30"),
    recipient_locations = data.frame(country = "USA",
                                     state = "CA",
                                     district = "30")))