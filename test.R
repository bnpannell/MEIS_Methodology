library(httr)
library(jsonlite)
library(tidyverse)

body <- list(filters=list(prime_award_types=c("A", "B", "C", "D"),
                       data_type="action_date",
                       date_range=list(start_date="2019-10-01",
                                       end_date="2020-09-30"),
                       recipient_locations = list(country ="United States", 
                                                  state = "California",
                                                  county = "Del Norte"),
                       agencies = list(type="awarding",
                                          tier="toptier",
                                          name="Department of Homeland Security",
                                          toptier_name="Department of Homeland Security")
),
file_format="csv"
)

r2 <- POST("https://api.usaspending.gov/api/v2/bulk_download/awards/", body = body)
content(r2)$results