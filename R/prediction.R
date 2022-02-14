#' Predict hera models
#'
#' Predicts hera model reference indices.
#' @details
#' \code{prediction()} predicts model indices.
#'
#' @param data Dataframe of variables in WFD inter-change format
#' @param model_dataframe Dataframe of model_dataframe see `model_dataframe`
#' @param combine Specify if predictions should be combined within location/sample attributes
#' @return Dataframe of predictions
#' @examples
#' predictions <- prediction(demo_data)
#' @importFrom rlang .data
#' @importFrom tibble tibble
#' @importFrom dplyr group_by inner_join mutate filter
#' @importFrom tidyr unnest nest
#' @importFrom magrittr `%>%`
#' @importFrom purrr map
#' @export
prediction <- function(data = NULL, model_dataframe = NULL, combine = TRUE) {
  message("Hello from hera, ...work in progress!")
  if (is.null(model_dataframe)) {
    model_dataframe <- hera::model_dataframe
  }

  predictions <- purrr::map_df(split(model_dataframe, 1:nrow(model_dataframe)), function(model) {
    if (is.null(model$prediction_function[[1]])) {
      return(NULL)
    }
    data <- data %>% dplyr::filter(parameter == model$analysis_name)
    if (any(names(model$predictors[[1]]) %in% "question")) {
      warning("Warning: question column shouldn't be required for prediction")
      data <- data %>% dplyr::filter(question %in% unique(model$predictors[[1]]$question))
    }

    if (nrow(data) == 0) {
      return(NULL)
    }
    prediction <- model$prediction_function[[1]](data)
    prediction$parameter <- model$analysis_name
    prediction$response <- as.character(prediction$response) # predictions can be character or numbers
    if (nrow(prediction) > 0) {
      prediction <- combine(prediction, data)

    } else {
      return(NULL)
    }

    return(prediction)
  })


  return(predictions)
}
