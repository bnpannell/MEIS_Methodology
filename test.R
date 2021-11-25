library(httr)
library(jsonlite)
library(tidyverse)


body = list(
  filters = list(
    prime_award_types = c("A", "B", "C", "D", "02", "03", "04", "05", "06", "10"),
    agencies = data.frame(
      type = c("awarding", "awarding", "awarding", "awarding"),
      tier = c("toptier", "toptier", "toptier", "toptier"),
      name = c("Department of Homeland Security", "Department of Defense", "Department of Veterans Affairs", "Department of Energy")
    ),
    date_type = "action_date",
    date_range = list(start_date = "2019-10-01",
                      end_date = "2020-09-30"),
    recipient_locations = data.frame(country = "USA",
                                     state = "CA",
                                     district = "NULL")
  ),
  file_format = "csv"
)


toJSON(body, pretty=T)

request <- POST(
  "https://api.usaspending.gov/api/v2/bulk_download/awards/",
  body = body,
  encode = "json",
  verbose()
)
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
temp_path = file.path(getwd(), "data", "temp")
download_path = file.path(temp_path, content(request)$file_name)

download.file(file_url, destfile = download_path)
unzip(download_path, exdir = temp_path)   

unlink(download_path)

