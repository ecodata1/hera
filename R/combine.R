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
  # Get unique location attributes from data -------------------------------
  location_attributes <- select(
    data,
    -.data$sample_id,
    -.data$label,
    -.data$response,
    -.data$question,
    -.data$date_taken,
    -.data$parameter,
    -.data$units
  )
  # Needs refactor! Remove result level columns
  if(!is.null(data$result_id)) {
    location_attributes <- select(location_attributes, -.data$result_id)
  }
  if(!is.null(data$quality_element)) {
    location_attributes <- select(location_attributes, -.data$quality_element)
  }
  if(!is.null(data$standard)) {
    location_attributes <- select(location_attributes, -.data$standard)
  }
  if(!is.null(data$analysis_name)) {
    location_attributes <- select(location_attributes, -.data$analysis_name)
  }
  location_attributes <- unique(location_attributes)
  # Join to outcome
  outcome <- left_join(outcome, location_attributes, by = "location_id")

  # Get sample info ----------------------------------------------------
  sample_attributes <- select(
    data,
    .data$sample_id,
    .data$date_taken,
  )

  sample_attributes <- unique(sample_attributes)
  # Join to outcome
  outcome <- left_join(outcome, sample_attributes, by = "sample_id")

  # Bind with data
  combine <- bind_rows(outcome, data)
  return(combine)
}
