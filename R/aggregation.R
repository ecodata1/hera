#' @importFrom rlang .data
#' @importFrom dplyr enquo mutate group_by_at summarise filter bind_rows n vars
#' @importFrom tidyr pivot_wider drop_na
#' @importFrom tibble tibble
#' @importFrom magrittr `%>%`
#' @importFrom purrr map
aggregation <- function(data = NULL, groups = NULL){

  groups <- enquo(groups)
  aggregation <- data %>%
    mutate(response = as.numeric(.data$response)) %>%
    group_by_at(vars(.data$question, !!groups)) %>%
    summarise(question = unique(.data$question),
              response = mean(.data$response, na.rm = TRUE),
              n_sample = n(),
              .groups = "drop") %>%
    drop_na()


   data <- data %>% filter(.data$parameter %in% c("River Diatoms", "River Macrophytes"))
   if(nrow(data) > 0 ) {
     combine <- data %>% filter(.data$question == "level") %>%
       mutate(response = as.numeric(.data$response)) %>%
       group_by_at(vars(.data$question, !!groups)) %>%
       summarise(question = unique(.data$question),
                 response = max(.data$response, na.rm = TRUE),
                 n_sample = n(), .groups = "drop") %>%
       drop_na()
     combine$parameter = "Combined Aquatic Plants"
   }
   aggregation <- bind_rows(aggregation, combine)
  return(aggregation)
}