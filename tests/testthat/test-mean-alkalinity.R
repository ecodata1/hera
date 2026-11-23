test_that("test mean_alkalinity works", {
  alk_test <- read.csv(
    system.file("extdat","demo-data/test_alk.csv",package = "hera"))
  alk_test <- hera:::mean_alkalinity(alk_test)
  alk_test <- alk_test %>% filter(sample_number == 239318)
  manual_check <- mean(
    c(
      129,
      71.0,
      100,
      100,
      107,
      141,
      116,
      110,
      128,
      118
    )
  )
  testthat::expect_equal(alk_test$alkalinity, manual_check)
})
