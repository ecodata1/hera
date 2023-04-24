
test_that("assess works", {
    data <- assess(demo_data[100, ]) %>%
    dplyr::select(sample_id, response, question) %>%
    dplyr::slice_sample(n = 4)
    expect_equal(nrow(data), 4)



   # data <- hera::demo_data[hera::demo_data$sample_id == "2755381", ]
   # outcome <- outcome[outcome$sample_id == "2755381", ]
   #  data$parameter[is.na(data$parameter)] <- data$quality_element[is.na(data$parameter)]
   #  results <- assess(data)
   #   expect_equal(round(
   #     as.numeric(outcome$response[outcome$question == "EQR_TDI4"][1]), 2), 0.49)
})


test_that("darleq3 works", {

  # Use data from DARLEQ3 package but in 'hera' format and check same result.
  data <- read_excel("inst/extdat/darleq-test-data/DARLEQ2TestData-update.xlsx")
  data$chemistry_site <- 1
  data <- data %>% filter(location_id %in% c("36082", "34649"))
  output <- assess(data, "DARLEQ3")
  fn <- system.file("extdata/DARLEQ2TestData.xlsx", package="darleq3")
  d <- darleq3::read_DARLEQ(fn, "Rivers TDI Test Data")
  x <- darleq3::calc_Metric(d$diatom_data, metric="TDI4")
  eqr <- darleq3::calc_EQR(x, d$header)
  eqr <- eqr$Uncertainty
  eqr <- eqr[eqr$SiteID %in% c("36082", "34649"), ]
  output <- output[is.na(output$sample_id), ]
  output <- output[output$question == "EQR", ]
  testthat::expect_equal(eqr$EQR,
                         as.numeric(output$response[output$question == "EQR"]))

})