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
  # Calculate indices and predictions
  data <- prediction(data)

  # Join raw dataset to model_dataframe
  data <- inner_join(data,
    hera::model_dataframe[, c("analysis_name", "classification_function")],
    by = c("analysis_name" = "analysis_name")
  )

  # Loop through each sample and apply prediction function from 'model_dataframe'
  data <- data %>%
    mutate(classification = map(.data$data, .data$classification_function))

  # Unnest and return
  data <- unnest(data, .data$classification)

  return(data)
}
