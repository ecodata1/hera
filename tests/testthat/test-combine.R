test_that("combine works", {
  data <- hera::demo_data
  sample_ids <- sample(data$sample_id, 5)
  data <- data[data$sample_id %in% sample_ids,]
  outcome <- assess(data)
  total <- nrow(data) + nrow(outcome)
  test <- hera:::combine(outcome, data)
  expect_equal(total, nrow(test))
})
