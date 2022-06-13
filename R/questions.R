#' Questions
#'
#' Return list of questions and assessments from the catalogue
#'
#' @return dataframe
#' @export
#'
#' @examples
#' questions <- questions(catalogue)
questions <- function() {
  data <- unnest(catalogue, data)
  data <- data[data$output == FALSE & !is.na(data$output), ]
  data <- select(data, assessment, question, source)
  return(data)
}