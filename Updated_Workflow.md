This document is the updated work flow that both versions of the master code should follow. Update as needed to make documentation of methods section easier

1. Clear R environment before running any code. This helps prevent any issues from having variables assigned the wrong data/ data that may not exist yet.

2. Set Working directory

3. Load libraries needed to run code/ function calls

4. Load parameters file after updating as needed

5. Load code for functions that obtain data and filter data

6. Call function to obtain USASpending data- will save contracts and grant data as separate files into temp folder 

7. Obtain data manually if needed (applies to several data sources, mostly for employment data & Smartpay spending data which requires an additional csv file to be made)

8. Run filters on spending & grants data- save output files to temp folder. This returns data on spending actually done in the state of California and limits data to necessary columns to reduce file size. #Would filtering out values with 0 spending be useful here too??

9. Load in error check code for contracts data- error check code is not in functions so code will run as soon as the file is loaded with "source" 
    - DEPRECIATED code first overwrites the two NAICS codes that return multiple IMPLAN code matches, then matches implan codes according to NAICS codes, pulls out lines that did not return a match and hardcode fixes them by adding in appropriate IMPLAN codes. It also checks for industries without a NAICS code, and hardcodes those to return a successful match to IMPLAN code values. This is a more limited way to run the check, and codes are likely to contain more errors than the newer error check version. This outputs cleaned contracts data with IMPLAN codes. 
    
    - New Master code: Starts by changing outdated NAICS codes from 2007 to their 2017 counterparts. Matches implan codes according to NAICS code using a DIFFERENT crosswalk than the DEPRECIATED code. This crosswalk includes 2012 to 2017 and 2002 to 2017 Naics code fixes. This code splits out any NAICS codes that have many IMPLAN codes. It makes a new column for weighted data then calculates the values of this column by,multiplying the value column [INSERT NAME OF COLUMN HERE] by the CEWRATIO column from the IMPLAN cross walk to return a more accurate value of spending. Note: This error checking file is still not complete. It returns data cleaned to the best of our ability but still does not fully take into consideration all of the issues inherent with construction naics vs implan codes (23xxxx) or the 92xxxx series Naics codes concerning government administrative payments. This code outputs to the output folder a file containing data with missing NAICS codes (that will later have to be manually fixed then added back into the main 'cleaned' document), any with unmatched NAICS to IMPLAN codes (Right now only NAICS codes from series 23 and 92)and the cleaned data itself (which outputs to the temp folder). 
    
10. Load in error check code for grants data- this code is also not in functions so it will run line by line as soon as the file is called by "source" This file splits out VA spending so it can be used later in a seperate upload. 

11. Concat files 

12. Error check for District values- fix NA and "90" values for Districts in data

13. Parse out data into sheets to put into IMPLAN

14. Deal with employment data

