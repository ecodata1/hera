#' Validation
#'
#' Validation of input data.
#' @details
#' \code{validation()} Validation
#'
#' @param data Dataframe of variables in WFD inter-change format
#'
#' @return Dataframe of validation messages
#' @examples
#' validations <- validation(demo_data)
#' @importFrom rlang .data
#' @importFrom tibble tibble
#' @importFrom dplyr group_by inner_join mutate
#' @importFrom tidyr unnest nest
#' @importFrom magrittr `%>%`
#' @importFrom purrr map
#' @export
validation <- function(data = NULL) {
  message("Hello from hera, ...work in progress!")

  if(any(names(data) %in% "sample_id")) {
    data$sample_id <- as.character(data$sample_id)
  }


  if(any(names(data) %in% "location_id")) {
    data$location_id <- as.character(data$location_id)
  }



  return(data)
}
