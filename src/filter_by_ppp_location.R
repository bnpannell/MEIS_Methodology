#Defines function "filter_ppp" 

filter_ppp <- function(file_name, state, filters, out_name) {
  read.csv(file.path(getwd(), "data", "temp", file_name))  %>%
    filter(primary_place_of_performance_state_name == state) %>%
    select(all_of(filters)) %>%
    write.csv((file.path(getwd(), "data", "temp", out_name)))
  }
