test_that("test convert function works", {
  # skip('csv import different from web services import? = capital letters??')
  # Data download from Recovered Datasets tool
  recovered_data <-
    read.csv(system.file("extdat",
      "demo-data/analysis-results-ecology.csv",
      package = "hera"
    ), check.names = FALSE)

  r <- recovered_data %>% hera:::convert(convert_from = "sepa")
  # Downloaded LIMS data (with test_number column added) from results data
  # explorer
  l <- lims_data %>% hera:::convert()
  class(r$location_id)
  class(l$location_id)
  data <- bind_rows(l, r) # Lims data doesn't have NGR currently - so add a default
  data$grid_reference <- "NO 41452 15796"

  # Run assessment
  test <- assess(
    data,
    "DARLEQ3"
  )

  # Check removing dreprecated Maitland Code (may not be included within
  # internal SEPA table) makes no difference
  recovered_data <- dplyr::select(recovered_data, -"Maitland Code")
  r <- recovered_data %>% hera:::convert(convert_from = "sepa")
  r <- filter(r, parameter == "River Family Inverts")
  test <- assess(
    r[1:10, ],
    "Macroinvertebrate Metrics"
  )
})
