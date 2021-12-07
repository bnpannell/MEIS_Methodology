#Defines function "filter.ppp" 

filter.ppp <- function(file, state, filters) {
  file_name <- file %>%
  filter(primary_place_of_performance_state_name == state) %>%
  select(filters) %>%
  print(file)
  print(state)
  print(filters)
  #write.csv(file_name, (file.path(getwd(), "data", "temp", file)))
  }
