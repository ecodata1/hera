#' Classification
#'
#' Model classification.
#' @details
#' \code{classification()} classification
#'
#' @param data Dataframe of variables in hera inter-change format
#' @param model_dataframe Dataframe of model_dataframe see `model_dataframe`
#'
#' @return Dataframe of classifications
#' @examples
#' classifications <- classification(demo_data)
#' @importFrom rlang .data
#' @importFrom tibble tibble
#' @importFrom dplyr group_by inner_join mutate bind_rows bind_cols filter
#' @importFrom magrittr `%>%`
#' @importFrom purrr map
#' @export
classification <- function(data = NULL, model_dataframe = NULL) {
  message("Hello from hera, ...work in progress!")

  if (is.null(model_dataframe)) {
    model_dataframe <- hera::model_dataframe
  }
  browser()
  indices <- hera::indices(data = data, model_dataframe =  model_dataframe)
  predictions <- hera::prediction(data = data, model_dataframe =  model_dataframe)
  data <- bind_rows(data, indices, predictions)

  assessments <- purrr::map_df(split(model_dataframe, 1:nrow(model_dataframe)), function(model) {
    if (is.null(model$assessment_function[[1]])) {
      return(NULL)
    }
    browser()
    data <- data %>% dplyr::filter(parameter == model$analysis_name)
    data <- data %>% dplyr::filter(question %in% c(model$indices[[1]]$question) |
                                     question %in% c('ref_rmni',
                                                     'ref_taxa',
                                                     'ref_algae',
                                                     'ref_nfg'))
    assessment_table <- model$assessment_table[[1]]
    assessments <- model$assessment_function[[1]](data, assessment_table)
    # Add confidence in assessment

    data <- data %>%
      select(location_id, location_description, sample_id, date_taken) %>%
      distinct()
    assessments <- inner_join(data, assessments, by = "sample_id")


    confidences <- confidences(assessments,
                               confidence_function = model$confidence_function[[1]])
    assessments <- bind_rows(assessments, confidences)

    assessments <- assessments %>% select(-date_taken, -parameter) %>%
      pivot_wider(names_from = question, values_from = response)
    return(assessments)
  })


  return(assessments)
}
