#Creates a function to check if there is a district crosswalk file, and if so, to apply it to contracts.
#If not, say an error to create a district crosswalk

na_district_repair <- function(file_path, dataframe) {
  if(file.exists(file_path)) {
    val <- read.csv(file_path, fileEncoding="UTF-8-BOM")
    for (i in 1:nrow(val)) {
      dataframe$recipient_congressional_district[grep(val$recipient_name[i],dataframe$recipient_name)] <- val$recipient_congressional_district[i]
    }
  } else {
    stop("Create contract-district crosswalk using no district contract errors file in Output folder")
    }
  return(dataframe)
}
