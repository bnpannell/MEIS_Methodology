#Defines function "split_usaspending" 

split_usaspending <- function(file_name, doe) {
  read.csv(file.path(getwd(), "data", "temp", file_name)) %>%
    filter(awarding_agency_name == doe) %>%
    return(file_name)
}