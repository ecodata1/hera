test_that("assess works", {
 # run all data
  data <- assess(demo_data)

  # run subset
  data <- assess(demo_data[1:100, ]) %>%
    dplyr::select(sample_id, response, question) %>%
    dplyr::slice_sample(n = 4)
  expect_equal(nrow(data), 4)

  # Work in progress test from old sepaTools package - needs checking
  data <- hera::demo_data[hera::demo_data$sample_id == "2755381", ]
  data$parameter[is.na(data$parameter)] <- data$quality_element[is.na(data$parameter)]
  results <- assess(data)
  outcome <- results[results$sample_id == "2755381", ]
  #      expect_equal(round(
  #        as.numeric(outcome$response[outcome$question == "EQR_TDI4"][1]), 2), 0.49)
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
  output <- assess(data, "DARLEQ3")
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
