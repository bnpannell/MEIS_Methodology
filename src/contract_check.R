#Scratch file for parsing thru construction NAICs codes and parsing them out by keywords

#Load in contracts_errors dataframe
#Load in list- from parameters file?
#Use grepl(pattern, string, ignore.case=FALSE) to match patterns- returns true if pattern is found in the string 

#Loop thru line by line, if true put record in dataframe A, if false record to dataframe B? 

contract_check <- function(patterns, data){
  val <- rep(FALSE, length(data))
  if(is.character(patterns)){
    for(i in 1:length(patterns)){
      val <- val | grepl(patterns[i], data, ignore.case = TRUE)
    }
  } else {
    stop('pattern must be a character vector')
  }
  return(val)
}