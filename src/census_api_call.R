##Code that calls to Census API for data on veterans in California##

library(jsonlite)
library(httr)

# Build framework for mandatory filters first
body = list(
  filters = list(
    state = "06",
    variables = "B21001_001E"),
  file_format = "csv" 
)

#Format filter body 
toJSON(body, pretty=T)

#Post query to API
request <- GET(
  "https://api.census.gov/data/2019/acs/acs5?get=B21001_001E&for=county:*&in=state:06",
  body = body,
  encode = "json",
  verbose()
)

#Wait for file download to be prepared by site
Sys.sleep(5)
if(request$status_code == 200){
  status_check <- GET(url = content(request)$status_url)
  
  while(content(status_check)$status == "running"){
    print("System is still preparing the download link")
    Sys.sleep(30)
    status_check <- GET(url = content(request)$status_url)
  }
  
  file_url <- content(request)$file_url
}




##If we went the route of the census API R package...

#First, install and load the census API package

install.packages("censusapi")
library("censusapi")

#Look at the list of endpoints available


