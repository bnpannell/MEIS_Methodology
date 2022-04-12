#Define function to error check contracts - TIER 1

##TIER 1 =
##Check and see if a file exists - if a saved cleaned contracts file exists in output
#Sort data based on if it has an implan_code and district
#Pull it from the contracts dataframe and save it as a file if a file doesn't exist
#if file exists, then append. If not, then make file. Subsequently, deletes that written data from the contracts dataframe.

##Call file_check within the t1_check function##
t1_check <- function(df1, file_path) {
  t1_ind <- which(!(is.na(df1$recipient_congressional_district)) & !(is.na(df1$implan_code)))
  df2 <- df1 %>%
    filter(!is.na(recipient_congressional_district) & !is.na(implan_code))
  ifelse(file.exists(file_path), write.table(df2, file_path, append = TRUE, row.names = FALSE), write.csv(df2, file_path, row.names = FALSE))
 
  return(df1[-t1_ind,])
}



contracts <- t1_check(contracts, file.path(temp_path, paste0(f_year, "_cleaned_contracts.csv")))

