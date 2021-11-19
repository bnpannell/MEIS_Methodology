library(httr)
library(jsonlite)
library(tidyverse)

body = list(
  filters = list(
    prime_award_types = c("A", "B", "C", "D"),
    agencies = data.frame(
      type = "awarding",
      tier = "toptier",
      name = "Department of Homeland Security",
      toptier_name = "Department of Homeland Security"
    ),
    date_type = "action_date",
    date_range = list(start_date = "2019-10-01",
                      end_date = "2020-09-30"),
    recipient_locations = data.frame(country = "United States",
                                     state = "California",
                                     county = "Del Norte")
  ),
  file_format = "csv"
)
toJSON(body, pretty=T)
r2 <-
  POST("https://api.usaspending.gov/api/v2/bulk_download/awards/",
       body = body,
       encode="json",
       verbose())