

districts_vets$county_or_part <- as.numeric(districts_vets$county_or_part)
dist_vets <- rename(districts_vets, dist_vets = B21001_002E)
counties_vets$county <- as.numeric(counties_vets$county)
cnty_vets <- rename(counties_vets, cnty_vets = B21001_002E)

result <- merge(x=dist_vets, y=cnty_vets, by.x="county_or_part", by.y="county", x.all=FALSE, y.all=FALSE)

#work on making new column and calculating % of county total next 