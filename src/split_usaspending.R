#Defines function "split_usaspending" For pulling DOE data out of specified file/dataframe

split_usaspending <- function(file_name, is_doe) {
  temp_data = read.csv(file.path(getwd(), "data", "temp", file_name))
  if(is_doe) {
    filter(temp_data, awarding_agency_name == doe)
  }
    else {
      filter(temp_data, awarding_agency_name != doe)
    }
}