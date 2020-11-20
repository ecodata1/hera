#' Knit Together Model Functions
#'
#' A low-level function for package developers to update the dataframe of model
#' functions required for each WFD parameter
#' @examples
#' \dontrun{
#' model_dataframe <- hera:::create_model_dataframe()
#' usethis::use_data(model_dataframe, overwrite = TRUE)
#' }
#' @importFrom tibble tibble
create_model_dataframe <- function() {
  tibble(
    "analysis_repname" = c(
      "Diatom Taxa",
      "invert"
    ),
    "validation_function" = c(
      NA,
      NA
    ),
    "indices_function" = list(
      darleq_indices,
      rict_indices
    ),
    "prediction_function" = list(
      darleq_prediction,
      rict_prediction
    ),
    "classification_function" = list(
      darleq_classification,
      rict_classification
    )
  )
}
