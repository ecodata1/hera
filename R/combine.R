#' Combine
#'
#' Output with all columns from data relevant to assessment name. Either by
#' sample_id and/or location_id (depending if sample or location level
#' assessment).
#'
#' @param outcome The output from `assess()` hera function
#' @param data The input data to `assess()` hera function
#' @importFrom dplyr left_join bind_rows select filter
#' @importFrom rlang .data
combine <- function(outcome, data) {
  # Result attributes ---------------------------------------------------------
  # plus sample_id (and location_id if metric is location not sample based) to
  # link to sample attributes:
  result_columns <- c(
    "sample_id",
    "location_id",
    "question",
    "response",
    "parameter",
    "units",
    "sign"
  )

  # Select result columns from the outcome where they match
  result_columns <- names(outcome)[names(outcome) %in% result_columns]

  outcome <- select(
    outcome,
    result_columns
  )

  # Sample attributes ---------------------------------------------------------
  # Include location_id key to join location attributes later
  sample_columns <- c(
    "sample_id",
    "location_id",
    "date_taken",
    "sample_number",
    "purpose",
    "alkalinity",
    "chemistry_site"
  )

  sample_columns <- names(data)[names(data) %in% sample_columns]
  sample_attributes <- select(
    data,
    sample_columns
  )

  sample_attributes <- unique(sample_attributes)
  # Join to outcome
  outcome <- left_join(outcome,
                            sample_attributes,
                            by = c("sample_id"),
                            multiple = "first" )

  if ("location_id.x" %in% colnames(outcome)) {
    outcome$location_id <- outcome$location_id.x
    outcome$location_id[is.na(outcome$location_id.x)] <-
      outcome$location_id.y[is.na(outcome$location_id.x)]
    outcome$location_id.x <- NULL
    outcome$location_id.y <- NULL
  }
  # Get unique location attributes from data ----------------------------------
  # Store list location atributes as data file? meta data file?
  location_columns <- c(
    "location_id",
    "location_description",
    "sampling_point_description",
    "easting",
    "northing",
    "latitude",
    "longitude",
    "grid_reference",
    "water_body_id"
  )

  location_columns <- names(data)[names(data) %in% location_columns]

  location_attributes <- select(
    data,
    any_of(location_columns)
  )

  location_attributes <- unique(location_attributes)
  outcome <- left_join(outcome, location_attributes, by = "location_id")

  # Add source as calculated to flag this as source of data -------------------
  outcome$source <- "calculated"

  # Bind outcome metrics with input data
  combine <- bind_rows(outcome, data)

  return(combine)
}
