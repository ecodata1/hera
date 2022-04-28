#' Dataframe of models for each WFD parameter
#'
#' A dataset containing a dataframe of functions to validate, calculate indices,
#' predict reference indices, and calculate classification.
#'
#' @format A data frame with 1 rows and 5 variables:
#' \describe{
#'   \item{analysis_name}{Name of WFD analysis}
#'   \item{assessment}{assessment}
#'   \item{standard}{standard}
#'   \item{location}{Meta data collected for Location}
#'   \item{sample}{Meta data collected for sample}
#'   \item{validation_function}{Function to validate data}
#'   \item{indices_function}{Function to calculate observed indices from raw
#'   data}
#'   \item{prediction_function}{Function to predict reference indices based on
#'   predictors}
#'   \item{assessment_function}{Function to
#'   assess predictions based on observed against predicted indices}
#'   \item{confidence_function}{Confidence function}
#'   \item{indices}{Indices}
#'   \item{assessment_table}{Assessment table}
#'   \item{questions}{Questions}
#'   \item{predictors}{Predictors}
#'   \item{predictions}{Predictions}
#' }
#' @source Agency sampling data
"catalogue"
