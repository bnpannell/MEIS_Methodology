#Define function "na_district_repair" to check if there is a district crosswalk file, and if so, to apply it to contracts.
#If not, return an error noting to create a district crosswalk

na_district_repair <- function(file_path, dataframe) {
  if(file.exists(file_path)) {
    cw <- read.csv(file_path, fileEncoding="UTF-8-BOM")
    nodist_ind <- which(is.na(dataframe$recipient_congressional_district) & !is.na(dataframe$recipient_county_name) & !is.na(dataframe$implan_code))
    df2 <- dataframe[nodist_ind,]
    dataframe <- dataframe[-nodist_ind,]
    for (i in 1:nrow(cw)) {
      df2$recipient_congressional_district[grep(cw$recipient_name[i],df2$recipient_name)] <- cw$recipient_congressional_district[i]
    }
    val <- rbind(dataframe, df2)
    #There is something weird in the above line and you need to assign the output to the 'val' variable 
  } else {
    val <- dataframe
    stop("Create contract-district crosswalk using no district contract errors file in Output folder")
    }
  return(val)
}
