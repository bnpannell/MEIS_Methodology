# Code for pulling together USAspending contracts and grants into one value for each IMPLAN code

aggregate_usaspending <- function(file_name, state, doe_filters, filters, out_name) {
  read.csv(file.path(getwd(), "data", "temp", file_name))  %>%
    filter(primary_place_of_performance_state_name == state) %>%
    filter(!(awarding_agency_name == doe & !(funding_office_name %in% doe_filters))) %>%
    select(all_of(filters)) %>%
    write.csv((file.path(getwd(), "data", "temp", out_name)))
}
