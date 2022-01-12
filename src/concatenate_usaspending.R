#Defines function "concatenate_usaspending" 

c_usaspending <- function(pattern) {
  files <- list.files(path = file.path(getwd(), "data", "temp"), pattern = pattern, full.names = TRUE)
  tables <- lapply(files, read.csv, header = TRUE, )
  tables = tables[-3]
  return(do.call(rbind, tables))
}

#c_usaspending <- function(file_name, outname) {
 # read.csv(file.path(getwd(), "data", "temp", file_name)) %>%
  #  return(do.call(rbind, file_name))
   # write.csv((file.path(getwd(), "data", "temp", out_name)))
#}
