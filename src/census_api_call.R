##Code that calls to Census API for data on veterans in California##

library(jsonlite)
library(httr)



##Method #1: Lines 8-16 work to read the Census API into a dataframe... only need the jsonlite package for this

data <- url("https://api.census.gov/data/2020/acs/acs5?get=B21001_002E,NAME&for=county:*&in=state:06")

datanew <- fromJSON(data)

dataframe1 <- as.data.frame(datanew)
names(dataframe1) <- c("total_vets", "county", "state_fips", "county_fips")  
dataframe1 <- dataframe1[-c(1),]



##Method #2: Lines 20-31 also work to read the Census API into a dataframe, but using both httr and jsonlite

censusapi_url <- paste0("https://api.census.gov/data/2020/acs/acs5?get=B21001_002E,NAME&for=county:*&in=state:06")
result <- httr::GET(censusapi_url)

#Check out result - in this list, we need the "content" in it. That holds the data.
content <- httr::content(result, as ="text")
content_json <- jsonlite::fromJSON(content)

dataframe2 <- as.data.frame(content_json)
names(dataframe2) <- c("total_vets", "county", "state_fips", "county_fips")  
dataframe2 <- dataframe2[-c(1),]



##If we went the route of the census API R package...

#First, install and load the census API package

#install.packages("censusapi")
#library("censusapi")

#Look at the list of endpoints available
