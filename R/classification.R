#' Classification
#'
#' Model classification.
#' @details
#' \code{classification()} classification
#'
#' @param data Dataframe of variables in hera inter-change format
#'
#' @return Dataframe of classifications
#' @examples
#' classifications <- classification(demo_data)
#' @importFrom rlang .data
#' @importFrom tibble tibble
#' @importFrom dplyr group_by inner_join mutate
#' @importFrom tidyr unnest nest
#' @importFrom magrittr `%>%`
#' @importFrom purrr map
#' @export
classification <- function(data = NULL) {
  message("Hello from hera, ...work in progress!")
  # Nest data
  # create 'outer' reference for nesting - retaining the original ref inside the
  data$sample_number <- data$sample_id
  data$quality_elements <- data$quality_element
  # Nest data
  data <- data %>%
    group_by(.data$sample_number, .data$quality_elements) %>%
    nest()

  model_dataframe <- create_model_dataframe()
  # Join raw dataset to model_dataframe
  data <- inner_join(data,
    model_dataframe[, c("quality_element", "classification_function")],
    by = c("quality_elements" = "quality_element")
  )

  # Loop through each sample and apply prediction function from 'model_dataframe'
  data <- data %>%
    mutate(classification = map(.data$data, .data$classification_function))
  # Unnest and return
  data <- select(data, -.data$classification_function)
  data <- unnest(data, cols = c(.data$classification))
  return(data)
}
