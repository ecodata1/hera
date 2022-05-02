#' Calculate Observed Indices
#'
#' Calculates indices from raw data prior to predictions and classification.
#' @details
#' \code{indices()} calculates observed indices.
#'
#' @param data Dataframe of variables in WFD inter-change format
#' @param name Name of the assessment to be used
#' @param catalogue Dataframe of catalogue see `catalogue`
#'
#' @return Dataframe of predictions
#' @examples
#' indices <- indices(demo_data)
#' @importFrom rlang .data
#' @importFrom tibble tibble
#' @importFrom dplyr inner_join select filter
#' @importFrom magrittr `%>%`
#' @importFrom purrr map
#' @export
indices <- function(data, name = NULL, catalogue = NULL) {
  message("Hello from hera, ...work in progress!")
  data <- validation(data)
  if (is.null(catalogue)) {
    catalogue <- hera::catalogue
  }
  catalogue <- filter_assessment(model = catalogue, name = name)
  indices <- purrr::map_df(
    split(catalogue, 1:nrow(catalogue)),
    function(model) {
      if (is.null(model$indices_function[[1]])) {
        return(NULL)
      }
      data <- data %>% dplyr::filter(.data$parameter == model$analysis_name)
      if (any(unique(data$question) %in% model$indices[[1]]$question)) {
        message(paste(
          "You provided indices for ", model$analysis_name,
          "in data, therefore indices not calculated"
        ))
        return(NULL)
      }
      data <- data %>%
        dplyr::filter(.data$question %in% unique(model$questions[[1]]$question))
      if (nrow(data) == 0) {
        return(NULL)
      }
      index <- model$indices_function[[1]](data)
      index$parameter <- model$analysis_name
      # Indices can be character or numbers:
      index$response <- as.character(index$response)
      if (nrow(index) > 0) {
        data <- data %>% select(
          -question,
          -response,
          -label,
          -parameter
        )
        data <- unique(data)
        index <- inner_join(index, data, by = "sample_id")
      } else {
        return(NULL)
      }
      return(index)
    }
  )
}
