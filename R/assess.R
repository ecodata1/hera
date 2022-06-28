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
#' assessments <- assess(demo_data)
#' }
#' @importFrom rlang .data
#' @importFrom tibble tibble
#' @importFrom dplyr group_by inner_join mutate bind_rows bind_cols filter
#' @importFrom magrittr `%>%`
#' @importFrom purrr map
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
      if (is.null(model$assessment_function[[1]])) {
        return(NULL)
      }

      assessment_function <- model$assessment_function[[1]]
      data <- assessment_function(data)
      data$response <- as.character(data$response)
      description <- bind_rows(model$data)
      description <- filter(description, .data$question == "name_short")
      data$parameter <- description$response
      return(data)
    }
  )

  return(assessments)
}
