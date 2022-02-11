
aggregation <- function(data = NULL, groups = NULL){

  groups <- enquo(groups)
  aggregation <- data %>%
    mutate(response = as.numeric(response)) %>%
    group_by_at(vars(question, !!groups)) %>%
    summarise(question = unique(question),
              response = mean(response, na.rm = TRUE),
              n_sample = n(), .groups = "drop")

  return(aggregation)
}