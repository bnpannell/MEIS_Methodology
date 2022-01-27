#Defines function "filter_usaspending" 

filter_usaspending <- function(file_name, state, filters, out_name) {
  read.csv(file.path(getwd(), "data", "temp", file_name))  %>%
    filter(primary_place_of_performance_state_name == state) %>%
    filter(!(federal_action_obligation == 0)) %>%
    select(all_of(filters)) %>%
    write.csv((file.path(getwd(), "data", "temp", out_name)))
  }
