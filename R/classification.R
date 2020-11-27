#' Classification
#'
#' Model classification.
#' @details
#' \code{classification()} classification
#'
#' @param data Dataframe of variables in WFD inter-change format
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
  # Nest data by sample and analysis

  data <- data %>%
    group_by(.data$sample_number, .data$analysis_repname) %>%
    nest()

  model_dataframe <- create_model_dataframe()
  # Join raw dataset to model_dataframe
  data <- inner_join(data,
    model_dataframe[, c("analysis_repname", "classification_function")],
    by = c("analysis_repname" = "analysis_repname")
  )

  # Loop through each sample and apply prediction function from 'model_dataframe'
  data <- data %>%
    mutate(classification = map(.data$data, .data$classification_function))

  # Unnest and return
  data <- select(data, -.data$classification_function)
  data <- unnest(data, cols = c(.data$data, .data$classification))
  return(data)
}
