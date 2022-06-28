#' @importFrom dplyr bind_rows select right_join
#' @importFrom rlang .data
combine_assessment <- function(data, assessment) {
  # Rejoin output from assessment_function to input data
  data_attributes <- data %>%
    select(-.data$question, -.data$response, -.data$result_id, -.data$label, ) %>%
    unique()

  if (!is.null(indexes)) {
    indexes <- right_join(data_attributes, indexes,
      by = c("sample_id" = "sample_id")
    )
  } else {
    indexes <- data_attributes
  }

  data$response <- as.character(data$response)
  indexes$response <- as.character(indexes$response)
  combined_data <- bind_rows(data, indexes)

  return(combined_data)
}


#' @importFrom dplyr bind_rows
#' @importFrom tibble tibble
#' @importFrom usethis use_data
update_catalogue <- function(description = NULL,
                             input = NULL,
                             assessment_function = NULL,
                             output = NULL) {
  catalogue <- hera::catalogue
  input <- input[input$sample_id == input$sample_id[1], ]
  input$output <- FALSE
  output <- output[output$sample_id == output$sample_id[1] |
    is.na(output$sample_id), ]
  parameter <- description$response[description$question == "name_long"]
  output$parameter <- parameter
  output$output <- TRUE
  output$response <- as.character(output$response)
  input$response <- as.character(input$response)
  description$response <- as.character(description$response)

  # bind description, input and output data into single table
  data <- bind_rows(input, output, description)

  data <- list(data[data$sample_id == input$sample_id[1] |
    is.na(data$sample_id), ])
  model <- tibble(
    assessment = description$response[description$question == "name_long"],
    data = data,
    assessment_function = list(assessment_function)
  )

  catalogue <- catalogue[catalogue$assessment != description$response[description$question == "name_long"], ]
  catalogue <- bind_rows(catalogue, model)
  usethis::use_data(catalogue, overwrite = TRUE)
}

#' @importFrom tidyr pivot_longer everything
#' @importFrom dplyr select filter
#' @importFrom rlang .data
hera_format <- function(description = NULL) {
  description <- filter(description, .data$question %in%
    c(
      "name_short",
      "name_long",
      "parameter",
      "status"
    ))


  description$optional <- c(FALSE, FALSE, FALSE, FALSE)


  # Return list of Data frames
  description <- list(description)
  names(description) <- "description"

  return(description)
}

#' @importFrom testthat test_that expect_equal
#' @importFrom tidyr pivot_longer everything
#' @importFrom tibble tibble
hera_test <- function(description = NULL) {
  # Check standard info --------------------------------------------------------
  description$required <- NA
  description$required <- c(TRUE, TRUE, TRUE, TRUE)

  standard_check <- tibble(
    standard_names = test_that("Correct Standard attributes", {
      expect_equal(length(description$question[description$question %in% c(
        "name_short",
        "parameter",
        "name_long",
        "status"
      )]), 4,
      info = "Correct Standard attributes"
      )
    }),
    standard_required = test_that("Correct Standard attributes", {
      expect_equal(
        length(description$question[description$required == TRUE]),
        length(description$required[description$required == TRUE]),
        info = "Correct required attributes"
      )
    }),
    standard_required_values =
      if (is.null(description$response[is.na(description$response) &
        description$required == TRUE])) {
        FALSE
      } else {
        TRUE
      }
  )

  standard_check <- pivot_longer(standard_check,
    names_to = "check",
    cols = (everything())
  )

  # Return list of Data frames
  data <- list(standard_check)
  names(data) <- "standard_check"
  return(data)
}
