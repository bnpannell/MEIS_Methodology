#Defines function "concatenate_usaspending" to bring contracts and grants data together

concat_usaspending <- function(pattern) {
  files <- list.files(path = file.path(temp_path), pattern = pattern, full.names = TRUE)
  tables <- lapply(files, read.csv, header = TRUE)
  tables = tables[-3]
  return(do.call(rbind, tables))
}
