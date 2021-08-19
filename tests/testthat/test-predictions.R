
test_that("metrics works", {
  indices(demo_data) %>%
    select(sample_number, indices) %>%
    unnest(indices) %>%
    group_by(quality_elements) %>%
    slice_sample(n = 4)
})

test_that("metrics works", {
  classification(demo_data) %>%
    group_by(quality_elements) %>%
    slice_sample(n = 4) %>%
    select(sample_number, classification)
})


test_that("predictions works", {

  test <- suppressWarnings(prediction(demo_data))
  expect_equal(length(test), 24)
})
