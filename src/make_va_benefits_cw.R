

districts_vets$county_or_part <- as.numeric(districts_vets$county_or_part)
dist_vets <- rename(districts_vets, dist_vets = B21001_002E)
counties_vets$county <- as.numeric(counties_vets$county)
cnty_vets <- rename(counties_vets, cnty_vets = B21001_002E)

result <- merge(x=dist_vets, y=cnty_vets, by.x="county_or_part", by.y="county", x.all=FALSE, y.all=FALSE)

#work on making new column and calculating % of county total next 

result$percent_cnty_total <- with(result, (dist_vets/cnty_vets))

#drop not needed columns and export file as csv to 'output/folder'

export <- subset(result, select = c('county_or_part', 'congressional_district', 'percent_cnty_total')) 
write_csv(export, file.path(getwd(), "data", "raw", paste0(f_year, "_va_apportioning.csv")))
#so for outputing to file in data/raw- the write csv will append data to an existing file. We could leave an empty file in the raw folder to hold 
#the data when it is calculated? And that way all user generated files are in raw- not output