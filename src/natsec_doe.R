##Code to get DOE data to national security-related entries##

#Define a new dataframe that only holds national security-related DOE spending - this new spending dataframe should be used for IMPLAN.
doe_ns_spending <- doespending %>%
  filter((funding_office_name %in% doe_offices))

#Divide the sum of the national security-related DOE spending by the total statewide DOE spending to get a "DOE National Security proportion."
#This proportion will be used to apportion the total statewide DOE employment and statewide DOE SmartPay

doe_ns_adjustment = sum(doe_ns_spending$federal_action_obligation) / sum(doespending$federal_action_obligation)