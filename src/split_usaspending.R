#Defines functions "split_usaspending" and "split_doespending"

split_usaspending <- function(file_name) {
  read.csv(file.path(getwd(), "data", "temp", file_name)) %>%
    filter(!(awarding_agency_name == doe))
}

split_doespending <- function(file_name) {
  read.csv(file.path(getwd(), "data", "temp", file_name)) %>%
    filter(awarding_agency_name == doe)
}