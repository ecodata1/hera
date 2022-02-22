
test_that("metrics works", {
  indices(demo_data) %>%
    select(sample_id, response, question) %>%
    dplyr::slice_sample(n = 4)
})

test_that("metrics works", {
  assessment(demo_data) %>%
    select(sample_id, response, question) %>%
    dplyr::slice_sample(n = 4)
})


test_that("predictions works", {
prediction(demo_data) %>%
  select(sample_id, response, question) %>%
    dplyr::slice_sample(n = 4)
})
