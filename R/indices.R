#' Calculate Observed Indices
#'
#' Calculates indices from raw data prior to predictions and classification.
#' @details
#' \code{indices()} calculates observed indices.
#'
#' @param data Dataframe of variables in WFD inter-change format
#' @param name Name of the assessment to be used
#' @param model_dataframe Dataframe of model_dataframe see `model_dataframe`
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
indices <- function(data, name = NULL, model_dataframe = NULL) {
  message("Hello from hera, ...work in progress!")

  if (is.null(model_dataframe)) {
    model_dataframe <- hera::model_dataframe
  }

  model_dataframe <- filter_assessment(model = model_dataframe, name = name)

  indices <- purrr::map_df(split(model_dataframe, 1:nrow(model_dataframe)),
                           function(model) {

    if (is.null(model$indices_function[[1]])) {
      return(NULL)
    }
    data <- data %>% dplyr::filter(.data$parameter == model$analysis_name)
    if(any(unique(data$question) %in% model$indices[[1]]$question)) {
      message(paste("You provided indices for ", model$analysis_name,
                    "in data, therefore indices not calculated"))
      return(NULL)
    }
    data <- data %>%
      dplyr::filter(.data$question %in% unique(model$questions[[1]]$question))
    if(nrow(data) == 0) {
      return(NULL)
    }
    index <- model$indices_function[[1]](data)
    index$parameter <- model$analysis_name
    index$response <- as.character(index$response) # indices can be character or numbers
    if(nrow(index) > 0) {

      data <- data %>% select(-question,
                              -response,
                              -label,
                              -result_id,
                              -parameter,
                              -analysis_name)
      data <- unique(data)
      index <- inner_join(index, data, by = "sample_id")
      # index <- combine(index, data, name = model$assessment)

    } else {
      return(NULL)
    }
    return(index)
  })


}
