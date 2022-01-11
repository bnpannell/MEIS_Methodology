#Defines function "concatenate_usaspending" 

filter_usaspending <- function(file_name, state, doe_filters, filters, out_name) {
  read.csv(file.path(getwd(), "data", "temp", file_name))  %>%
    filter(primary_place_of_performance_state_name == state) %>%
    filter(!(awarding_agency_name == doe & !(funding_office_name %in% doe_filters))) %>%
    filter(!(federal_action_obligation == 0)) %>%
    select(all_of(filters)) %>%
    write.csv((file.path(getwd(), "data", "temp", out_name)))
}

usa_spending <- rbind(contracts, grants)


files <- list.files(path = file.path(getwd(), "data", "temp"), pattern = paste0(year, "_DEPRECIATED.+\\.csv"), full.names = TRUE)
tables <- lapply(files, read.csv, header = TRUE)
tables = tables[-3]
usa_spending2 <- do.call(rbind, tables)
