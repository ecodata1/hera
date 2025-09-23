test_that("assess works", {
  # run subset
  data <- assess(demo_data[1:100, ]) %>%
    dplyr::select(sample_id, response, question) %>%
    dplyr::slice_sample(n = 4)
  expect_equal(nrow(data), 4)

  # Work in progress test from old sepaTools package - slight difference in EQR
  # from 0.49 to 0.50 due to change in mean alkalinity used.
  data <- hera::demo_data[hera::demo_data$sample_id == "2755381", ]
  data$parameter[is.na(data$parameter)] <- data$quality_element[is.na(data$parameter)]
  results <- assess(data, "DARLEQ3", metric = "TDI4")
  outcome <- results[results$sample_id == "2755381", ]
  testthat::expect_equal(round(
    as.numeric(outcome$response[outcome$question == "EQR_TDI4"][1]), 2
  ), 0.50)
})


test_that("darleq3 works", {
  # Use data from DARLEQ3 package but in 'hera' format and check same result.
  fpath <- system.file("extdat/darleq-test-data",
    "DARLEQ2TestData-update.xlsx",
    package = "hera"
  )
  data <- readxl::read_excel(fpath)
  # data$chemistry_site <- 1 # 242 + 408
  data$location_id <- as.character(data$location_id)
  data <- data %>% filter(location_id %in% c("36082", "34649"))
  output <- assess(data, "DARLEQ3", metric = "TDI4")
  fn <- system.file("extdata/DARLEQ2TestData.xlsx", package = "darleq3")
  d <- darleq3::read_DARLEQ(fn, "Rivers TDI Test Data")
  diatom_data <- d$diatom_data
  diatom_data <- diatom_data[row.names(diatom_data) %in%
    c("SPR001", "SPR002", "AUT001", "AUT002"), ]
  x <- darleq3::calc_Metric(diatom_data, metric = "TDI4")
  header <- d$header
  header <- header[header$SampleID %in%
    c("SPR001", "SPR002", "AUT001", "AUT002"), ]
  eqr <- darleq3::calc_EQR(x, header)
  sample_eqr <- eqr$EQR
  sample_eqr_result <- sample_eqr[sample_eqr$SiteID %in% c("36082", "34649"), ]
  sample_eqr_result <- sample_eqr_result[, c(
    "SampleID",
    "SiteID",
    "EQR_TDI4"
  )]
  output <- output[output$question == "EQR_TDI4", ]
  testthat::expect_equal(
    sort(eqr$EQR$EQR_TDI4),
    sort(as.numeric(output$response[output$question == "EQR_TDI4"]))
  )
})

test_that("bankside consistency works", {
  data <- hera::demo_data
  data <- data[data$sample_id == 3201863, ]
  output <- assess(data, "Bankside Consistency")
  # Test against pre-calculated results
  testthat::expect_equal(output$response, c(
    "SPR",
    "22.56",
    "6.94",
    "As expected",
    "neither",
    "14",
    "4.97142857142857",
    "Moderate",
    "Good",
    "2017",
    "6200"
  ))
})



test_that("Macroinvertebrate Metrics works", {
  data <- hera::demo_data
  data <- data[data$sample_id == 3201863, ]
  output <- assess(data, "Macroinvertebrate Metrics")
  # test on pre-calculated results
  testthat::expect_equal(
    as.character(round(as.numeric(output$response[14:16]), 2)),
    c("69.6", "4.97", "14")
  )
})

test_that("MPFF Compliance works", {
  data <- kraken::demo_iqi
  data$parameter <- "MPFF Compliance"
  output <- hera::assess(
    data,
    "MPFF Compliance",
    hera_format = FALSE,
    loess = TRUE,
    n_try = 10
  )
  # test on pre-calculated results
  testthat::expect_equal(
    round(
      as.numeric(
        output$response[grepl("area_95_confidence", output$question)]
      ),
      0
    ),
    round(89594.9653487682, 0)
  )
})
