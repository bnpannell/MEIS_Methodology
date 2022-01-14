#Defines function "concatenate_usaspending" 

concat_usaspending <- function(pattern) {
  files <- list.files(path = file.path(getwd(), "data", "temp"), pattern = pattern, full.names = TRUE)
  tables <- lapply(files, read.csv, header = TRUE)
  tables = tables[-3]
  return(do.call(rbind, tables))
}