
confidences <- function(data, confidence_function = NULL) {
  confidences <- purrr::map_df(split(model_dataframe, 1:nrow(model_dataframe)), function(model) {
  if (nrow(data) == 0) {
    return(NULL)
  }
  if (is.null(confidence_function)) {
    return(NULL)
  }
  confidence <-
    confidence_function(data)
  return(confidence)
})
  return(confidences)
}