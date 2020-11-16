#' Dataframe of models for each WFD parameter
#'
#' A dataset containing a dataframe of functions to validate, calculate indices, predict
#' reference indices, and calculate classification.
#'
#' @format A data frame with 1 rows and 5 variables:
#' \describe{
#'   \item{analysis_name}{Name of WFD analysis}
#'   \item{validate_function}{Function to validate data}
#'   \item{indices_function}{Functoin to calculate observed indices from raw data}
#'   \item{predict_function}{Function to predict reference indices based on predictors}
#'   \item{classify_function}{Funciton to classify predictions based on observed against predicted indices}
#' }
#' @source Agency sampling data
"model_dataframe"
