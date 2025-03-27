test_that("NGR formatting", {

    predictors <- utils::read.csv(system.file("extdat",
                                            "predictors.csv",
                                            package = "hera"
  ), check.names = FALSE)

  # Check for spaces in grid_reference (need to split grid reference for RICT)
  # See rict.Rmd in hera package
   errors <- predictors[!grepl(" ", predictors$grid_reference), ]
   errors2 <- predictors[!grepl(" ", predictors$original_grid_reference), ]

   errors <- bind_rows(errors, errors2)
   errors <- distinct(errors)

   testthat::expect_equal(nrow(errors), expected = 0)
})