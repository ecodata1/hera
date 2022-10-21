test_that("filter samples function works", {

  data <- hera:::filter_samples(demo_data)
  expect_equal(nrow(data), 113)

  options <- tibble(
    classification_year = 2015,
    seasons = list(c("SPR", "AUT")),
    classification_window = 6,
    min_year = 1,
    max_year = 3,
    min_seasons = 2,
    max_seasons = 2,
    min_samples_per_season = 1,
    max_samples_per_season = 1,
    parameter = "River Diatoms"
  )
  data <- hera:::filter_samples(demo_data, options = options)
  expect_equal(nrow(data), 0)

  options <- tibble(
    classification_year = 2012,
    seasons = list(c("SPR", "AUT")),
    classification_window = 6,
    min_year = 1,
    max_year = 3,
    min_seasons = 2,
    max_seasons = 2,
    min_samples_per_season = 1,
    max_samples_per_season = 1,
    parameter = "River Diatoms"
  )
  data <- hera:::filter_samples(demo_data, options = options)
  expect_equal(nrow(data), 720)


})
