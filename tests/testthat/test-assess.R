
test_that("assess works", {
  data <- assess(demo_data) %>%
    dplyr::select(sample_id, response, question) %>%
    dplyr::slice_sample(n = 4)
  expect_equal(nrow(data), 4)
})



