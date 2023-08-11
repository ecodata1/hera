test_that("SEPA get_data works", {
  skip("internal web service only")
  data <- get_data(location_id = 8175)
  expect_equal(class(data), "data.frame")
})

test_that("SEPA get_data works", {
  data <- get_data(location_id = 1000, source = "ea", take = 100)
  expect_equal(ncol(data), 33)
  expect_equal(nrow(data), 100)
})
