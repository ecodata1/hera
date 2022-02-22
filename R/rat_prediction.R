#' @importFrom rlang .data
#' @importFrom tibble tibble
#' @importFrom dplyr group_by inner_join mutate select arrange filter summarise ungroup bind_rows
#' @importFrom tidyr unnest nest pivot_wider
#' @importFrom magrittr `%>%`
#' @importFrom purrr map

rat_prediction <- function(data) {
 # data <- whpt::whpt_predict(data)
 data <- select(data, .data$index, .data$predicted_response)

 return(data)
}