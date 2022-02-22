#' Hera
#'
#' Validate, Predict and Assess
#' @details
#' \code{assessment()} assessment
#'
#' @param data Dataframe of variables in `hera` inter-change format
#'
#' @return Dataframe of assessments
#' @examples
#' assessments <- hera(demo_data)
#' @importFrom rlang .data
#' @importFrom tibble tibble
#' @importFrom dplyr group_by inner_join mutate
#' @importFrom tidyr unnest nest
#' @importFrom magrittr `%>%`
#' @importFrom purrr map
#' @export
hera <- function(data = NULL) {
  assessments <- assessment(data)
  return(assessments)
}
