#' Assess
#'
#' Run assessment
#' @details
#' \code{assess()} assess
#'
#' @param data Dataframe of variables in hera inter-change format
#' @param catalogue Dataframe of model_dataframe see `catalogue`
#' @param name Name of the assessment to be used
#'
#' @return Dataframe of assessments
#' @examples
#' \dontrun{
#' assessments <- assess(hera::demo_data)
#' }
#' @importFrom rlang .data
#' @importFrom tibble as_tibble
#' @importFrom dplyr group_by inner_join mutate bind_rows bind_cols filter
#' @importFrom magrittr `%>%`
#' @importFrom purrr map
#' @importFrom whpt whpt_predict
#' @importFrom darleq3 calc_Metric
#' @importFrom macroinvertebrateMetrics calc_epsi
#' @importFrom kraken kraken
#' @export
assess <- function(data = NULL, name = NULL, catalogue = NULL) {
  message("Hello from hera, ...work in progress!")
  data <- validation(data)
  if (is.null(catalogue)) {
    catalogue <- hera::catalogue
  }

  catalogue <- filter_assessment(model = catalogue, name = name)

  assessments <- purrr::map_df(
    split(catalogue, 1:nrow(catalogue)),
    function(model) {
      # No assessment available (perhaps being developed)
      if (is.null(model$assessment_function[[1]])) {
        return(NULL)
      }
      # Check data available for assessment function
      model_data <- model$data[[1]]
      if (!any(unique(na.omit(data$parameter)) %in%
        unique(na.omit(model_data$parameter)))) {
        return(NULL) # not the right data for this function  - skip
      }
      assessment_function <- model$assessment_function[[1]]
      data <- assessment_function(data)
      data$response <- as.character(data$response)
      return(data)
    }
  )

  assessments <- as_tibble(assessments)
  return(assessments)
}
