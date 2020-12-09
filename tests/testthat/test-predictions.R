test_that("multiplication works", {

  test <- suppressWarnings(prediction(demo_data))
  expect_equal(length(test), 24)
})
