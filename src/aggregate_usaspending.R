# Functions for aggregating usaspending data into each IMPLAN code based on geography

statewide_aggregate <- function(dataframe, out_name) {
  dataframe  <- aggregate(dataframe$federal_action_obligation, by=list(dataframe$implan_code), FUN = "sum") %>%
    write.csv(file.path(getwd(), "data", "temp", out_name), row.names = FALSE)
}