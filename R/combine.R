combine <- function(output, data) {
  model <- model_dataframe %>% filter(analysis_name == unique(output$parameter))
  if (any(names(output) %in% "sample_id") && any(names(data) %in% "sample_id")) {
    sample_ids <- data %>%
      select(location_id,
             location_description,
             sample_id,
             date_taken,
             grid_reference,
             latitude,
             longitude,
             names(model$predictors[[1]])
            )
    sample_ids <- sample_ids %>% unique()
    output <- right_join(output, sample_ids, by = "sample_id")
    return(output)
  } else if (any(names(output) %in% "location_id") && any(names(data) %in% "longitude")) {
    location_ids <- data %>%
      select(location_id,
             location_description,
             grid_reference,
             latitude,
             longitude,
             names(model$predictors[[1]])
            )
    location_ids <- location_ids %>% unique()
    output <- inner_join(output, location_ids, by = "location_id")
    if(any(names(data) %in% "sample_id")) {
      sample_ids <- data %>%
        select(location_id,
               sample_id,
               date_taken
            )
      sample_ids <- sample_ids %>% unique()
      output <- right_join(output, sample_ids, by = "location_id")
    }

    return(output)
  } else {
    message("You provided prediction data without `sample_id` or `location_id`.
            Provide these variables if you wish predictions to be associated with
            location or observation data")
    return(output)
  }
}
