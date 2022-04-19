#Creates a function to check if there is a district crosswalk file, and if so, to apply it to contracts.
#If not, say an error to create a district crosswalk

na_district_repair <- function(file, ){
if(file.exists(file)){
  for(i in 1:length(patterns)){
    val <- val | grepl(patterns[i], data, ignore.case = TRUE)
  }
} else {
  stop('Create contract district crosswalk')
}
return(val)
}