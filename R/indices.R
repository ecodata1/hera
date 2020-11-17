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
    group_by(.data$sample_number, .data$analysis_name, .data$mean_alkalinity) %>%
    nest()

  # Join predictions dataframe to data
  by_sample_number <- inner_join(by_sample_number,
    hera::model_dataframe[, c("analysis_name", "indices_function")],
    by = c("analysis_name" = "analysis_name")
  )

  # Loop through each sample and apply indices function from 'model_dataframe'
  by_sample_number <- by_sample_number %>%
    mutate(indices = map(.data$data, .data$indices_function))

  # Unnest and return
  by_sample_number <- unnest(by_sample_number, .data$indices)

  return(by_sample_number)
}
