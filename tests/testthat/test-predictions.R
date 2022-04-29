
test_that("metrics works", {
  data <- indices(demo_data) %>%
    select(sample_id, response, question) %>%
    dplyr::slice_sample(n = 4)
  expect_equal(nrow(data), 4)
})

test_that("assessment works", {
  skip('needs work')
  data <- assessment(demo_data) %>%
    select(sample_id, response, question) %>%
    dplyr::slice_sample(n = 4)
  expect_equal(nrow(data), 4)
})


test_that("predictions works", {
  data <- prediction(demo_data) %>%
    select(sample_id, response, question) %>%
    dplyr::slice_sample(n = 4)
  expect_equal(nrow(data), 4)
})

test_that("select prediction works", {
  demo_data <- hera::demo_data
  demo_data$parameter[demo_data$analysis_name %in%
    c(
      "FW_TX_WHPT",
      "FW_TAX_ID",
      "MIXTAX_TST"
    )] <- "River Invertebrates"
  data <- demo_data %>%
    select(
      sample_id,
      result_id,
      location_id,
      location_description,
      question,
      response,
      label,
      latitude,
      longitude,
      water_body_id,
      standard,
      date_taken,
      parameter,
      grid_reference
    )
  data <- data %>%
    filter(question %in% c(
      "WHPT NTAXA Abund",
      "WHPT ASPT Abund"
    ))

  predictors <- readr::read_csv(
    system.file("extdat", "predictors.csv", package = "hera")
  )
  predictors <- predictors %>% select(-grid_reference)
  data <- inner_join(data, predictors,
    by = c("location_id" = "location_id")
  )
  pred <- prediction(data, name = "rict") %>%
    select(sample_id, response, question) %>%
    dplyr::slice_sample(n = 4)
  expect_equal(nrow(pred), 4)
})
