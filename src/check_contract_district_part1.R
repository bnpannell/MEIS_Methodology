##PART 1: Check if contracts without a district value actually have one in the cleaned data##
#Read in needed contract files - the 1 missing only districts, the main errors file, and the cleaned file
error_contracts <- read.csv(file.path(output_path, paste0(f_year, contract_errors)))
clean_contracts <- read.csv(file.path(temp_path, paste0(f_year, clean_c_data)))

#Make a list of unique recipient names and zip codes from contract_errors
error_cont_biz <- unique(data.frame(recipient_name = error_contracts$recipient_name,
                                    recipient_zip_4_code = error_contracts$recipient_zip_4_code))

#Loop over this list to see if it's in the good contracts. If so, it will overwrite the NA district value with the right district
#Exception: if the business has more than 1 district assigned to it, it will be skipped over
for(i in 1:nrow(error_cont_biz)) {
  k <- grepl(error_cont_biz$recipient_name[i], clean_contracts$recipient_name) &
    grepl(error_cont_biz$recipient_zip_4_code[i], clean_contracts$recipient_zip_4_code)
  if(sum(k) > 0) {
    district <- clean_contracts$recipient_congressional_district[k]
    if(length(unique(district)) > 1) {
      next
    }
    error_contracts$recipient_congressional_district[k] <- district[1]
  }
}


#clean_unique_contracts <- clean_contracts %>%
#  distinct(recipient_name, recipient_zip_4_code, recipient_congressional_district)
#for (i in 1:nrow(clean_unique_contracts)) {
#  error_contracts$recipient_congressional_district[grepl(clean_unique_contracts$recipient_name[i],error_contracts$recipient_name) &
#                                                     grepl(clean_unique_contracts$recipient_zip_4_code[i],error_contracts$recipient_zip_4_code)] <- clean_unique_contracts$recipient_congressional_district[i]
#}

#index <- which(error_contracts$recipient_name %in% clean_unique_contracts$recipient_name &
#                 error_contracts$recipient_zip_4_code %in% clean_unique_contracts$recipient_zip_4_code)
#index2 <- which(clean_unique_contracts$recipient_name %in% error_contracts$recipient_name &
#                  clean_unique_contracts$recipient_zip_4_code %in% error_contracts$recipient_zip_4_code)
#error_contracts[index,] <- clean_unique_contracts[]
#error_contracts2 <- error_contracts[index,]


