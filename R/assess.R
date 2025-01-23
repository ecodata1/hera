#' Assess
#'
#' Calculate all assessments from the `catalogue`.
#' @details \code{assess()} assess
#'
#' @param data Dataframe of variables in hera inter-change format by default
#'   including columns for sample_id, question, response, label and parameter.
#'   See `demo_data` for example. This is specific for each assessment is held
#'   in `catalogue` data frame 'data' column for requirements. For details of
#'   optional columns and requirements of specific assessment, see refer to the
#'   vignettes.
#' @param name Limit the assessments calculated by name(s) see
#'   `catalogue` name column. By default all assessments are run and if relative
#'   input data, the function will return output. Where there is no relative
#'   data, no output will be returned.
#' @param catalogue Dataframe of assessments by default the built-in `catalogue`
#'   is used. But if developing new assessments a custom assessment dataframe
#'   could be used.
#' @param ... Other arguments passed on to methods. This optional parameters is
#'   only for testing. The DARLEQ3 assessment uses an option `metric` argument
#'   by default this is ""TDI5LM".
#'
#' @return Dataframe of assessments
#' @examples
#' \dontrun{
#' assessments <- assess(hera::demo_data)
#' selected_assessments <- assess(hera::demo_data, c("RICT", "DARLEQ3"))
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
assess <- function(data = NULL, name = NULL, catalogue = NULL, ...) {
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
      data <- assessment_function(data, ...)
      data$response <- as.character(data$response)
      return(data)
    }
  )

  assessments <- as_tibble(assessments)
  return(assessments)
}
