#' @importFrom dplyr inner_join right_join select filter
#' @importFrom rlang .data
combine <- function(output, data) {
  model <- hera::model_dataframe %>% filter(.data$analysis_name == unique(output$parameter))
  if (any(names(output) %in% "sample_id") && any(names(data) %in% "sample_id")) {
    sample_ids <- data %>%
      select(
        .data$location_id,
        .data$location_description,
        .data$sample_id,
        .data$date_taken,
        .data$grid_reference,
        .data$latitude,
        .data$longitude,
        names(model$predictors[[1]]),
        names(data)[!names(data) %in% names(c(
          model$questions[[1]],
          model$predictions[[1]]
        ))]
      )
    sample_ids <- sample_ids %>% unique()
    output <- inner_join(output, sample_ids, by = "sample_id")
  } else if (any(names(output) %in% "location_id") &&
    any(names(data) %in% "longitude")) {
    location_ids <- data %>%
      select(
        .data$location_id,
        .data$location_description,
        .data$grid_reference,
        .data$latitude,
        .data$longitude,
        names(model$predictors[[1]]),
        names(data)[!names(data) %in%
          names(c(model$questions[[1]], model$predictions[[1]]))]
      )
    location_ids <- location_ids %>% unique()
    output <- inner_join(output, location_ids, by = "location_id")
    if (any(names(data) %in% "sample_id")) {
      if (nrow(output) < 1) {
        return(NULL) # TODO - add to validation check instead (if location_id is NA etc)
      }
      sample_ids <- data %>%
        filter(.data$parameter == unique(output$parameter)) %>%
        select(
          .data$location_id,
          .data$sample_id,
          .data$date_taken,
          names(data)[!names(data) %in%
            names(c(
              model$questions[[1]],
              model$predictions[[1]]
            ))]
        )
      sample_ids <- sample_ids %>% unique()
      output <- inner_join(sample_ids,
        output,
        by = c(
          "location_id",
          names(data)[!names(data) %in%
            names(c(
              model$questions[[1]],
              model$predictions[[1]]
            ))]
        )
      )
    }
    output <- output %>% unique()
    return(output)
  } else {
    message("You provided prediction data without `sample_id` or
    `latitude/longitude`. Provide these variables if you wish predictions to be
    associated with location or observation data")
    return(output)
  }
}