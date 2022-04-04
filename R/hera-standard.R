#' @importFrom tidyr pivot_longer everything
hera_format <- function(standard = NULL) {

  # Format standard info
  standard <- pivot_longer(standard,
    names_to = "attribute",
    cols = (everything())
  )
  standard$optional <- c(TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE)

  # Return list of Data frames
  data <- list(standard)
  names(data) <- "standard"
  return(data)
}

#' @importFrom testthat test_that expect_equal
#' @importFrom tidyr pivot_longer everything
#' @importFrom tibble tibble
hera_test <- function(standard = NULL) {
  # Check standard info --------------------------------------------------------
  standard <- pivot_longer(standard,
    names_to = "attribute",
    cols = (everything())
  )
  standard$required <- NA
  standard$required[1:6] <-  c(TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE)

  standard_check <- tibble(
    standard_names = test_that("Correct Standard attributes", {
      expect_equal(length(standard$attribute[standard$attribute %in% c(
        "standard_short",
        "quality_element",
        "parameter",
        "standard_long",
        "aggregation",
        "status"
      ) ] ),6
        ,
        info = "Correct Standard attributes"
      )
    }),
    standard_required = test_that("Correct Standard attributes", {
      expect_equal(
        length(standard$attribute[standard$required == TRUE]),
        length(standard$required[standard$required == TRUE]),
        info = "Correct required attributes"
      )
    }),
    standard_required_values =
      if (is.null(standard$value[is.na(standard$value) &
                               standard$required == TRUE])) {
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
