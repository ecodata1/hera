#' Questions
#'
#' Return list of questions and assessments from the catalogue
#'
#' @return dataframe
#' @export
#' @importFrom rlang .data
#' @examples
#' questions <- questions()
questions <- function() {
  data <- unnest(hera::catalogue, data)
  data <- data[data$output == FALSE & !is.na(data$output), ]
  data <- select(data, .data$assessment, .data$question, .data$source)
  return(data)
}