test_that("NGR formatting", {
  predictors <- utils::read.csv(system.file("extdat",
    "predictors.csv",
    package = "hera"
  ), check.names = FALSE)

  # Check for spaces in grid_reference (need to split grid reference for RICT)
  # See rict.Rmd in hera package
  predictors$date <- as.Date(predictors$date)
  # use latest 'version' for each location_id
  predictors <- dplyr::arrange(predictors, desc(date))
  predictors <- predictors[!duplicated(predictors$location_id), ]


  errors <- predictors[!grepl(" ", predictors$grid_reference), ]
  errors2 <- predictors[!grepl(" ", predictors$original_grid_reference), ]

  errors <- dplyr::bind_rows(errors, errors2)
  errors <- dplyr::distinct(errors)
  # if ngr blank - exclude (i.e. diatom only chemistry site predictor)
  errors <- dplyr::filter(errors, grid_reference != "" |
    original_grid_reference != "")

  testthat::expect_equal(nrow(errors), expected = 0)
})

test_that("Date formatting", {
  predictors <- utils::read.csv(system.file("extdat",
                                            "predictors.csv",
                                            package = "hera"
  ), check.names = FALSE)

  # Check date format is correct YYYY-MM-DD
  date_errors <- predictors[
    !grepl("[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]",
    predictors$date),
    ]
  testthat::expect_equal(nrow(date_errors), expected = 0)


  predictors$date <- as.Date(predictors$date)
  testthat::expect_no_error(lubridate::year(predictors$date))
  predictors$year <- testthat::expect_no_warning(
    lubridate::year(predictors$date))

  testthat::expect_equal(min(predictors$year), 2019)
  testthat::expect_lt(max(predictors$year), 2040)
})


test_that("Chemistry site formatting", {
  predictors <- utils::read.csv(system.file("extdat",
                                            "predictors.csv",
                                            package = "hera"
  ), check.names = FALSE)

  predictors$date <- as.Date(predictors$date)
  # use latest 'version' for each location_id
  predictors <- dplyr::arrange(predictors, desc(date))
  predictors <- predictors[!duplicated(predictors$location_id), ]

  # Check for no missing chemistry sites
  # chemistry_errors <- predictors[is.na(predictors$chemistry_site), ]
  # testthat::expect_equal(nrow(date_errors), expected = 0)

})



test_that("Check NGR are correct", {
  testthat::skip(message = "needs local network connection")

  predictors <- utils::read.csv(system.file("extdat",
    "predictors.csv",
    package = "hera"
  ), check.names = FALSE)

  predictors$date <- as.Date(predictors$date)
  # use latest 'version' for each location_id
  predictors <- dplyr::arrange(predictors, desc(date))
  predictors <- predictors[!duplicated(predictors$location_id), ]

  sampling_points <- hera::get_data(
    location_id = predictors$location_id,
    dataset = "sampling_points"
  )

  sampling_points <- dplyr::select(sampling_points, sampling_point, ngr)
  predictors <- dplyr::left_join(
    predictors,
    sampling_points,
    by = dplyr::join_by(location_id == sampling_point)
  )

  testthat::expect_equal(predictors$original_grid_reference, predictors$ngr)

  # Due to some location not being in the temperature grid for RICT their ngr
  # is different from 'original_grid_reference'.
  mismatch_ngr <- predictors[predictors$grid_reference != predictors$ngr, ]

  # These ngrs are valid mismatches because the RICT temperature grid not
  # covering all land area
  testthat::expect_equal(mismatch_ngr$location_id, 134730)
})