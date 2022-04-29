
prepapre_input <- function(data) {

  # by sample number or by analysis at this stage???? ---------
  by_sample_number <- data %>%
    group_by(.data$sample_number, .data$analysis_repname) %>%
    nest()

  catalogue <- create_catalogue()
  # Join predictions dataframe to data
  by_sample_number <- inner_join(by_sample_number,
    catalogue[, c("analysis_repname", "indices_function")],
    by = c("analysis_repname" = "analysis_repname")
  )
}
