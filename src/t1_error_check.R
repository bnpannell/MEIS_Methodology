#Define function to error check USAspending data - TIER 1

##TIER 1 =
##Check and see if a file exists - if a saved cleaned contracts file exists in output
#Sort data based on if it has an implan_code and district
#Pull it from the contracts dataframe and save it as a file if a file doesn't exist
#if file exists, then append. If not, then make file. Subsequently, deletes that written data from the contracts dataframe.

##Call file_check within the t1_check function##
t1_check <- function(df1, file_path) {
  t1_ind <- which(!is.na(df1$recipient_county_name) & !is.na(df1$recipient_congressional_district) & !(df1$recipient_congressional_district == 90) & !is.na(df1$implan_code))
  if(length(t1_ind)>0) {
    write.table(df1[t1_ind,], file_path, append = file.exists(file_path), col.names = !file.exists(file_path), row.names = FALSE, sep = ",")
    val <- (df1[-t1_ind,])
    } 
  else {
    val <- df1
  }
  return(val)
}
