# Functions for aggregating usaspending data into each IMPLAN code based on geography

statewide_aggregate <- function(file_name, filters, out_name) {
  read.csv(file.path(getwd(), "data", "temp", file_name))  %>%
    select(all_of(filters)) %>%
    aggregate(federal_action_obligation, by=list(implan_code)) %>%
    write.csv((file.path(getwd(), "data", "temp", out_name)))
}

#aggregate_usaspending <- function(file_name, state, doe_filters, filters, out_name) {
 # read.csv(file.path(getwd(), "data", "temp", file_name))  %>%
  #  filter(primary_place_of_performance_state_name == state) %>%
  #  filter(!(awarding_agency_name == doe & !(funding_office_name %in% doe_filters))) %>%
  #  select(all_of(filters)) %>%
  #  write.csv((file.path(getwd(), "data", "temp", out_name)))
#}

#aggregate_usaspending <- function(file_name, state, doe_filters, filters, out_name) {
 # read.csv(file.path(getwd(), "data", "temp", file_name))  %>%
  #  filter(primary_place_of_performance_state_name == state) %>%
  #  filter(!(awarding_agency_name == doe & !(funding_office_name %in% doe_filters))) %>%
  #  select(all_of(filters)) %>%
  #  write.csv((file.path(getwd(), "data", "temp", out_name)))
#}