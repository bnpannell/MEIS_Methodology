#R script to appropriately calculate contract $$ for those entries with multiple IMPLAN codes
#Read in CSV of cleaned contracts data
clean_contracts <- read.csv(file.path(temp_path, paste0(f_year, clean_c_data)))

#Modify CewAvgRatio column so any NA values are simply 1
clean_contracts$Ratio[is.na(clean_contracts$Ratio)] <- 1

#Multiply the spending column by the CewAvgRatio column to get the weighted spending data
clean_contracts <- clean_contracts %>%
  mutate(fao_weighted = federal_action_obligation * Ratio)

#Drop unneeded columns from dataframe and write to file
clean_contracts <- clean_contracts %>%
  rename(spending = fao_weighted) %>%
  select(all_of(final_cols))

write.csv(clean_contracts, file.path(temp_path, paste0(f_year, clean_c_data)), row.names = FALSE)