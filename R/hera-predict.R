#' Predict hera models
#'
#' Predicts hera model reference indices.
#' @details
#' \code{hera_predict()} predicts model indices.
#'
#' @param data Dataframe of variables in WFD inter-change format
#'
#' @return Dataframe of predictions
#' @examples
#' hera_predictions <- hera_predict(demo_data)
#'
#' @importFrom rlang .data
#' @importFrom tibble tibble
#' @importFrom dplyr group_by inner_join mutate
#' @importFrom tidyr unnest nest
#' @importFrom magrittr `%>%`
#' @importFrom purrr map
#' @export
hera_predict <- function(data) {
  message("Hello from hera, ...work in progress!")
  # Nest data by sample and analysis
  by_sample_number <- hera::demo_data %>%
    group_by(.data$sample_number, .data$analysis_name) %>%
    nest()

  # Create df with prediction model
  models <- tibble(
    "analysis_name" = "DIAT_TST",
    "class" = list(darleq)
  )

  # Join predictions dataframe to data
  by_sample_number <- inner_join(by_sample_number, models, by = c("analysis_name" = "analysis_name"))
  by_sample_number <- by_sample_number %>%
    mutate(prediction = map(.data$data, .data$class))

  by_sample_number <- unnest(by_sample_number, .data$prediction)

  return(by_sample_number)
}
