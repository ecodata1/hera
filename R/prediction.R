#' Predict hera models
#'
#' Predicts hera model reference indices.
#' @details
#' \code{prediction()} predicts model indices.
#'
#' @param data Dataframe of variables in WFD inter-change format
#'
#' @return Dataframe of predictions
#' @examples
#' predictions <- prediction(demo_data)
#' @importFrom rlang .data
#' @importFrom tibble tibble
#' @importFrom dplyr group_by inner_join mutate
#' @importFrom tidyr unnest nest
#' @importFrom magrittr `%>%`
#' @importFrom purrr map
#' @export
prediction <- function(data = NULL) {
  message("Hello from hera, ...work in progress!")
  # Nest data by sample and analysis
  data <- indices(data)

  # Join raw dataset to model_dataframe
  data <- inner_join(data,
    hera::model_dataframe[, c("analysis_name", "prediction_function")],
    by = c("analysis_name" = "analysis_name")
  )

  # Loop through each sample and apply prediction function from 'model_dataframe'
  data <- data %>%
    mutate(prediction = map(.data$data, .data$prediction_function))

  # Unnest and return
  data <- unnest(data, .data$prediction)

  return(data)
}
