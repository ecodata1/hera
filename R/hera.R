#' Hera
#'
#' Validate, Predict and Classify.
#' @details
#' \code{classification()} classification
#'
#' @param data Dataframe of variables in WFD inter-change format
#'
#' @return Dataframe of classifications
#' @examples
#' classifications <- classification(demo_data)
#' @importFrom rlang .data
#' @importFrom tibble tibble
#' @importFrom dplyr group_by inner_join mutate
#' @importFrom tidyr unnest nest
#' @importFrom magrittr `%>%`
#' @importFrom purrr map
#' @export
hera <- function(data = NULL) {
  validations <- validation(demo_data)
  indices <- indices(validations)
  predictions <- prediction(indices)
  classifications <- classification(predictions)

  return(classifications)
}
