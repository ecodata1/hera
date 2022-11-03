test_that("survey import works", {
  file <- system.file("extdat",
    "demo-data/220421-SelfMon-N4952-CAV1-Enhanced.xlsx",
    package = "hera"
  )
  data <- survey_import(file)
})
