filter_assessment <- function(model = NULL, name = NULL) {
  if (!is.null(name)) {
    model <- model %>%  filter(.data$assessment %in% name)
    if(nrow(model) < 1) {
      message("Assessment not found")
      return(NULL)
    }
    return(model)
  } else {
    return(model)
  }
}