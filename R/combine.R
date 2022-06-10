#' Combine
#'
#' Output with all columns from data relevant to assessment name. Either by
#' sample_id or location_id (depending how output is calculated)
#'
#' @param outcome The output from prediction or other hera function
#' @param data The input data to prediction or other hera function
#' @importFrom dplyr left_join bind_rows select filter
#' @importFrom rlang .data
combine <- function(outcome, data) {
  # Get unique location attributes from data
  filter_data <- select(
    data,
    -sample_id,
    -label,
    -response,
    -question,
    -result_id,
    -date_taken,
    -analysis_name,
    -parameter,
    -units,
    -quality_element,
    -standard
  )
  location_attributes <- unique(filter_data)
  # Join to outcome
  outcome <- filter(outcome, !is.na(.data$location_id))
  outcome <- left_join(outcome, location_attributes, by = "location_id")
  # Bind with data
  combine <- bind_rows(outcome, data)
  return(combine)
}
