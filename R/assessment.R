#' Assessment
#'
#' Run assessment
#' @details
#' \code{assessment()} assessment
#'
#' @param data Dataframe of variables in hera inter-change format
#' @param catalogue Dataframe of model_dataframe see `catalogue`
#' @param name Name of the assessment to be used
#'
#' @return Dataframe of assessments
#' @examples
#' assessments <- assessment(demo_data)
#' @importFrom rlang .data
#' @importFrom tibble tibble
#' @importFrom dplyr group_by inner_join mutate bind_rows bind_cols filter
#' @importFrom magrittr `%>%`
#' @importFrom purrr map
#' @export
assessment <- function(data = NULL, name = NULL, catalogue = NULL) {
  message("Hello from hera, ...work in progress!")

  if (is.null(catalogue)) {
    catalogue <- hera::catalogue
  }

  catalogue <- filter_assessment(model = catalogue, name = name)

  data <- validation(data)
  indices <- hera::indices(data = data, catalogue = catalogue)
  predictions <- hera::prediction(data = data, catalogue = catalogue)
  data <- bind_rows(data, indices, predictions)

  assessments <- purrr::map_df(
    split(catalogue, 1:nrow(catalogue)),
    function(model) {
      if (is.null(model$assessment_function[[1]])) {
        return(NULL)
      }

      data <- data %>% dplyr::filter(.data$parameter == model$analysis_name)
      data <- data %>% dplyr::filter(.data$question %in% c(model$indices[[1]]$question) |
        .data$question %in% c(model$predictions[[1]]$question))
      assessment_table <- model$assessment_table[[1]]
      assessments <- model$assessment_function[[1]](data, assessment_table)
      # Add confidence in assessment
      assessments$parameter <- model$analysis_name

      data <- data %>%
        select(
          .data$location_id,
          .data$location_description,
          .data$sample_id,
          .data$ date_taken,
          c(names(data)[!names(data) %in% names(c(model$questions[[1]], model$predictions[[1]]))])
        ) %>%
        unique()
      if (length(assessments) < 2) {
        assessments <- NULL
      } else {
        assessments <- inner_join(data, assessments, by = "sample_id")
      }

      confidences <- confidences(assessments,
        confidence_function = model$confidence_function[[1]]
      )
      if (length(confidences) < 2) {
        confidences <- NULL
      } else {
        confidences <- inner_join(data, confidences, by = c(
          "sample_id",
          "location_id",
          "location_description"
        ))
      }
      assessments <- bind_rows(assessments, confidences)

      # assessments <- assessments %>% select(-date_taken, -parameter) %>%
      #   pivot_wider(names_from = question, values_from = response)
      return(assessments)
    }
  )

  return(assessments)
}
