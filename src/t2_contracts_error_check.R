#Define function to error check contracts - TIER 2

##TIER 2 =
##From what remains of the contracts dataframe, pull out values without a district (regardless of NAICS) that should have an IMPLAN code.
##IF IT HAS IMPLAN CODE + NO DISTRICT, IS PULLED OUT AND WRITTEN INTO ITS OWN FILE. Use that file to generate the district crosswalk - match company to district.
##Taken out of the contracts dataframe and is written to our error file in output
#if file exists, then append. If not, then make file. Subsequently, deletes that written data from the contracts dataframe.