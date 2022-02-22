#' @importFrom dplyr filter
#' @importFrom rlang .data
confidences <- function(data, confidence_function = NULL,
                        aggregates = c(
                          "sample_id",
                          "location_id",
                          "location_description"
                        )) {
  confidences <- purrr::map_df(split(hera::model_dataframe,
                                     1:nrow(hera::model_dataframe)),
                               function(model) {
    if (is.null(data)) {
      return(NULL)
    }
    if(any(names(data) %in% "parameter")) {
    data <- data %>% filter(.data$parameter == model$analysis_name)
    }
    if (nrow(data) == 0) {
      return(NULL)
    }
    if (is.null(confidence_function)) {
      return(NULL)
    }
    confidence <- confidence_function(data, aggregates = aggregates)
    confidence$parameter <- model$analysis_name
    return(confidence)
  })
  return(confidences)
}
