#Define function to error check contracts - TIER 1

##TIER 1 =
##Check and see if a file exists - if a saved cleaned contracts file exists in output
#Sort data based on if it has an implan_code and district
#Pull it from the contracts dataframe and save it as a file if a file doesn't exist
#if file exists, then append. If not, then make file. Subsequently, deletes that written data from the contracts dataframe.