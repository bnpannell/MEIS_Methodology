## Pseudo code for file:

#Load "multi_implan_codes" file
#Load implan crosswalk, limited to naics code and the multiplier listed in the 'CewAvgRatio' column

##NAICS code 335220 can be IMPLAN code 325, 326, 327 or 328
#NAICS code 111191 can be IMPLAN code 1 or 2
#NAICS code 111366 can be IMPLAN code 4 or 5
#NAICS code 332117 can be IMPLAN code 231 or 232

#Using above figure out whether to duplicate line in "multi_implan_codes" file 2 or 4x
#Re-code duplicates to the correct IMPLAN code ?While duplicating?
#Multiply $ column by multiplier and overwrite value

#Concat altered data frame to the cleaned data file 