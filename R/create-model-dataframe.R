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
    "analysis_name" = "DIAT_TST",
    "validate_function" = NA,
    "indices_function" = list(darleq_indices),
    "prediction_function" = list(darleq_prediction),
    "classification_function" = list(darleq_classification)
  )
}
