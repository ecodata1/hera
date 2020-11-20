#' Calculate Observed Indices
#'
#' Calculates indices from raw data prior to predictions and classification.
#' @details
#' \code{indices()} calculates observed indices.
#'
#' @param data Dataframe of variables in WFD inter-change format
#'
#' @return Dataframe of predictions
#' @examples
#' indices <- indices(demo_data)
#' @importFrom rlang .data
#' @importFrom tibble tibble
#' @importFrom dplyr group_by inner_join mutate
#' @importFrom tidyr unnest nest
#' @importFrom magrittr `%>%`
#' @importFrom purrr map
#' @export
indices <- function(data) {
  message("Hello from hera, ...work in progress!")
  # Nest data by sample and analysis
  by_sample_number <- data %>%
    group_by(.data$sample_number, .data$analysis_repname) %>%
    nest()

  model_dataframe <- hera:::create_model_dataframe()
  # Join predictions dataframe to data
  by_sample_number <- inner_join(by_sample_number,
    model_dataframe[, c("analysis_repname", "indices_function")],
    by = c("analysis_repname" = "analysis_repname")
  )

  # Loop through each sample and apply indices function from 'model_dataframe'
  by_sample_number <- by_sample_number %>%
    mutate(indices = map(.data$data, .data$indices_function))

  # Unnest and return
  by_sample_number <- select(by_sample_number, -.data$indices_function)
  by_sample_number <- unnest(by_sample_number, cols = c(.data$indices, .data$data))
  return(by_sample_number)
}
