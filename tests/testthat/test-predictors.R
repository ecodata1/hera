test_that("NGR formatting", {

    predictors <- utils::read.csv(system.file("extdat",
                                            "predictors.csv",
                                            package = "hera"
  ), check.names = FALSE)

  # Check for spaces in grid_reference (need to split grid reference for RICT)
  # See rict.Rmd in hera package


    predictors$date <-  as.Date(predictors$date)
    # use latest 'version' for each location_id
    predictors <- dplyr::arrange(predictors, desc(date))
    predictors <- predictors[!duplicated(predictors$location_id), ]


   errors <- predictors[!grepl(" ", predictors$grid_reference), ]
   errors2 <- predictors[!grepl(" ", predictors$original_grid_reference), ]

   errors <- dplyr::bind_rows(errors, errors2)
   errors <- dplyr::distinct(errors)
   # if ngr blank - exclude (i.e. diatom only chemsitry sife predictor)
   errors <- dplyr::filter(errors, grid_reference != "" |
                      original_grid_reference != "")

   testthat::expect_equal(nrow(errors), expected = 0)
})