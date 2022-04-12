#Define function to check if file exists, and from there, either write or append file

file_check <- function(file_path, file, dataframe) {
  path = file.path(file_path, file)
  if(file.exists(path)) {
    write.table(dataframe, path, append = TRUE, row.names = FALSE)
  } else {
    write.csv(dataframe, path, row.names = FALSE)
  }
}
