#' Knit Together Model Functions
#'
#' A low-level function for package developers to update the dataframe of model
#' functions required for each WFD parameter.
#'
#' @examples
#' \dontrun{
#' catalogue <- hera:::create_catalogue()
#' usethis::use_data(catalogue, overwrite = TRUE)
#' }
#' @importFrom tibble tibble
create_catalogue <- function() {
  tibble(
    "standard" = c(
      "River Phytobenthos",
      "Lake Phytobenthos",
      "Rivers Invertebrates (General Degradation)"
    ),
    "quality_element" = c(
      "River Diatoms",
      "Lake Diatoms",
      "River Invertebrates"
    ),
    "analysis_repname" = c(
      "Diatom Taxa",
      "Lake Diatom Taxa",
      "invert"
    ),
    "validation_function" = c(
      NA,
      NA,
      NA
    ),
    "indices_function" = list(
      darleq_indices,
      darleq_indices,
      rict_indices
    ),
    "prediction_function" = list(
      darleq_prediction,
      darleq_prediction,
      rict_prediction
    ),
    "classification_function" = list(
      darleq_classification,
      darleq_classification,
      rict_classification
    )
  )
}
