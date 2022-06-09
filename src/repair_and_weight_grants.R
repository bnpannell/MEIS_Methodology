#R script to appropriately clean up grants dataframe for concatenation
#Read in CSV of cleaned grants data
clean_grants <- read.csv(file.path(temp_path, paste0(f_year, clean_g_data)))

#Drop unneeded columns from dataframe and write to file
clean_grants <- clean_grants %>%
  rename(spending = federal_action_obligation) %>%
  select(all_of(final_cols))

clean_grants$spending <- as.numeric(clean_grants$spending)
clean_grants$spending[is.na(clean_grants$spending)] <- 0

write.csv(clean_grants, file.path(temp_path, paste0(f_year, clean_g_data)), row.names = FALSE)
