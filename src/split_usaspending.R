#Defines functions "split_usaspending" and "split_doespending"

split_usaspending <- function(file_name, is_doe) {
  read.csv(file.path(getwd(), "data", "temp", file_name)) %>%
    if(is_doe == "yes") {
    filter((awarding_agency_name == doe))
    }
    else {
    filter((awarding_agency_name != doe))
    }
}




