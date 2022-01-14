# Functions for aggregating usaspending data into each IMPLAN code based on geography

statewide_aggregate <- function(dataframe, out_name) {
  dataframe  <- aggregate(dataframe$federal_action_obligation, by=list(dataframe$implan_code & dataframe$recipient_county_name), FUN = "sum") %>%
    write.csv((file.path(getwd(), "data", "temp", out_name)), row.names = FALSE)
}

#counties_aggregate <- function(file_name, filters, out_name) {
 # read.csv(file.path(getwd(), "data", "temp", file_name))  %>%
  #  select(all_of(filters)) %>%
  #  aggregate(federal_action_obligation, by=list(implan_code & recipient_county_name), FUN = sum) %>%
  #  write.csv((file.path(getwd(), "data", "temp", out_name)))
#}

#districts_aggregate <- function(file_name, filters, out_name) {
  #read.csv(file.path(getwd(), "data", "temp", file_name))  %>%
  #  select(all_of(filters)) %>%
  #  aggregate(federal_action_obligation, by=list(implan_code & recipient_congressional_district), FUN = sum) %>%
  #  write.csv((file.path(getwd(), "data", "temp", out_name)))
#}