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
  # create 'outer' reference for nesting - retaining the original ref inside the
  data$sample_number <- data$sample_id
  data$quality_elements <- data$quality_element
  # nested data
  data <- data %>%
    group_by(.data$sample_number, .data$quality_elements) %>%
    nest()

  model_dataframe <- create_model_dataframe()
  # Join raw dataset to model_dataframe
  data <- inner_join(data,
    model_dataframe[, c("quality_element", "prediction_function")],
    by = c("quality_elements" = "quality_element")
  )

  # Loop through each sample and apply prediction function from 'model_dataframe'
  data <- data %>%
    mutate(prediction = map(.data$data, .data$prediction_function))

  # Unnest and return
  data <- select(data, -.data$prediction_function)
  data <- unnest(data, cols = c(.data$data))
  # data <- unnest(data, cols = c(.data$prediction),names_repair  = "universal")
  return(data)
}
