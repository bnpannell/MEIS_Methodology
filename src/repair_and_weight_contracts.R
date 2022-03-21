## Create new column "fao_weighted" that distributes federal_action_obligation spending by the CewAvgRatio weight for each implan code
contracts <- contracts %>%
  mutate(fao_weighted = federal_action_obligation * CewAvgRatio)

#Save contract data file with error lines REMOVED to temp folder "{YEAR}_cleaned_usaspending_contract_data" 

write.csv(contracts, file.path(getwd(), "data", "temp", paste0(year, "_cleaned_usaspending_contract_data.csv")))