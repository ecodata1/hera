#' Predict hera models
#'
#' Predicts hera model reference indices.
#' @details
#' \code{prediction()} predicts model indices.
#'
#' @param data Dataframe of variables in WFD inter-change format
#' @param name Name of assessment to predict. Default is all possible
#'   assessments.
#' @param catalogue Dataframe of catalogue see `catalogue`
#' @return Dataframe of predictions
#' @examples
#' predictions <- prediction(demo_data)
#' @importFrom rlang .data
#' @importFrom tibble tibble
#' @importFrom dplyr group_by inner_join mutate filter transmute
#' @importFrom tidyr unnest nest pivot_longer
#' @importFrom magrittr `%>%`
#' @importFrom purrr map
#' @export
prediction <- function(data = NULL, name = NULL, catalogue = NULL) {

  message("Hello from hera, ...work in progress!")
  if (is.null(catalogue)) {
    catalogue <- hera::catalogue
  }

  catalogue <- filter_assessment(model = catalogue, name = name)

  data <- validation(data)
  predictions <- purrr::map_df(split(catalogue,
                                     1:nrow(catalogue)), function(model) {

    if (is.null(model$prediction_function[[1]])) {
      return(NULL)
    }

    data <- data %>% dplyr::filter(.data$parameter == model$analysis_name)

    if(!all(names(model$predictors[[1]]) %in% names(data))) {
      message("You provided data without predictor variables for ", model$assessment, " analysis")
      return(NULL)
    }

    if (any(names(model$predictors[[1]]) %in% "question")) {
      warning("Warning: question column shouldn't be required for prediction")
      data <- data %>%
        dplyr::filter(.data$question %in% unique(model$predictors[[1]]$question))
    }

    if (nrow(data) == 0) {
      return(NULL)
    }

    prediction <- model$prediction_function[[1]](data)
    prediction$parameter <- model$analysis_name
    prediction$response <- as.character(prediction$response) # predictions can be character or numbers
    prediction$question <- as.character(prediction$question) # if question NA can be logical class
    prediction$location_id <- as.character(prediction$location_id) # if location NA can be logical class

    if (nrow(prediction) > 0) {
      prediction <- combine(output = prediction, data = data, name = name)
    } else {
      return(NULL)
    }

    return(prediction)
  })


  return(predictions)
}
