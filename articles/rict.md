# RICT

## Welcome

This document has been created following the generic [assessment
guidance](https://ecodata1.github.io/hera/articles/development_guide.html).

## Description

Basic details about the assessment. Update the ‘response’ values as
required.

| question   | response                   |
|:-----------|:---------------------------|
| name_short | RICT                       |
| name_long  | RICT                       |
| parameter  | River Family Invertebrates |
| status     | testing                    |
| type       | metric                     |

## Input

A list of questions required to run this assessment.

| location_id | sample_id | date_taken | question        | response | label    | parameter            |
|:------------|:----------|:-----------|:----------------|:---------|:---------|:---------------------|
| 206972      | 12345     | 2019-11-21 | Taxon abundance | 12       | Baetidae | River Family Inverts |

## Assessment

Returns RICT output

Code

``` r
assessment_function <- function(data, ...) {
  # Calculated some statistic...
  # Note, any non-standard base R library must be call using require().
  require(rict)
  require(macroinvertebrateMetrics)
  require(dplyr)
  require(tidyr)
  require(magrittr)
  require(lubridate)
  message(unique(data$location_id))
  metric_function <- catalogue[catalogue$assessment ==
    "Macroinvertebrate Metrics", 3][[1]]
  input_data <- data
  input_data$location_id <- NULL
  output <- metric_function[[1]](input_data)
  if (is.null(output)) {
    return(NULL)
  }
  output <- dplyr::filter(output, question %in% c("WHPT_ASPT", "WHPT_NTAXA"))
  # Alkalinity ---------
  # if(!any(names(data) %in% c("alkalinity"))) {
  #   alk <- hera:::mean_alkalinity(data)
  #   data$alkalinity <- NULL
  #   data <- inner_join(data, alk, by = join_by("sample_id" == "sample_number"))
  # }
  if (!any(names(data) %in% "alkalinity")) {
    predictors <- utils::read.csv(system.file("extdat",
      "predictors.csv",
      package = "hera"
    ), check.names = FALSE)
    predictors$location_id <- as.character(predictors$location_id)
    predict_data <- filter(predictors, location_id %in% unique(data$location_id))
    predict_data$date <- as.Date(predict_data$date)
    predict_data <- arrange(predict_data, dplyr::desc(date))

    output_location <- inner_join(output,
      unique(data[, c(
        "location_id",
        "sample_id",
        "date_taken"
      )]),
      by = "sample_id",
      relationship = "many-to-many"
    )
    whpt_input <- inner_join(
      output_location,
      predict_data,
      by = "location_id",
      multiple = "first"
    )
  } else {
    # function to average predictors for each year? See sepaTools package?::
    final_data <- data
    final_data <- filter(final_data, analysis_repname == "Invert Physical Data")
    if (nrow(final_data) < 1) {
      return(NULL)
    }
    
    final_data$year <- lubridate::year(final_data$date_taken)
    summarise_data <- select(
      final_data,
      "location_id",
      "sample_id",
      "year",
      "question",
      "response"
    )

    summarise_data <- map_df(split(
      summarise_data,
      summarise_data$sample_id
    ), function(sample) {
      # get a row to add to bottom when mean_depth calculated
      row <- sample[1, ]
      row$question <- "mean_depth"
      if (!any(sample$question %in% "mean_depth")) {
        depths <- filter(sample, question %in% c(
          "River Depth 1",
          "River Depth 2",
          "River Depth 3",
          "Depth 1",
          "Depth 2",
          "Depth 3"
        ))
        if (nrow(depths) < 1) {
          # some samples don't have Depths or mean_depth...so return NA
          row$response <- NA
        } else {
          mean_depth <- mean(as.numeric(depths$response), na.rm = TRUE)

          row$response <- as.character(mean_depth)
        }
        sample <- bind_rows(sample, row)
        return(sample)
      } else {
        return(sample)
      }
    })

    summarise_data <- summarise_data %>%
      filter(question %in% c(
        "sand",
        "silt_clay",
        "boulders_cobbles",
        "pebbles_gravel",
        "river_width",
        "mean_depth"
      ))
    summarise_data <- tidyr::pivot_wider(summarise_data,
      names_from = question,
      values_from = response
    )
    
    # if no river_width then stop (maybe from lake)
    name <- "river_width"
      if (!name %in% colnames(summarise_data)) {
      return(NULL)
    }
    
    summarise_data <- type.convert(summarise_data, as.is = TRUE)
    summarise_data <- select(summarise_data, -"sample_id")
    summarise_data <- dplyr::group_by(
      summarise_data,
      location_id
    )
    # Suppress warning because of missing values
    summarise_data <- suppressWarnings(dplyr::summarise_all(
      summarise_data,
      ~ mean(.x, na.rm = TRUE)
    ))
    summarise_data$location_id <- as.character(summarise_data$location_id)
    data <- left_join(data, summarise_data, by = join_by(location_id == location_id))
    data <- data %>%
      group_by(location_id) %>%
      mutate("alkalinity" = mean(alkalinity, na.rm = TRUE))
    data <- ungroup(data)
    data <- select(
      data,
      "sample_id",
      "location_id",
      "date_taken",
      "grid_reference",
      "alkalinity",
      "river_width",
      "mean_depth",
      "boulders_cobbles",
      "pebbles_gravel",
      "sand",
      "silt_clay",
      # "northing",
      # "easting",
      "dist_from_source",
      "altitude",
      "slope",
      "grid_reference",
      "discharge_category"
    )
    whpt_input <- inner_join(output,
      unique(data),
      by = "sample_id"
    )
  }
  whpt_input$question[whpt_input$question == "WHPT_ASPT"] <- "WHPT ASPT Abund"
  whpt_input$question[whpt_input$question == "WHPT_NTAXA"] <- "WHPT NTAXA Abund"
  data <- whpt_input

  bias <- 1.62
  analysis <- "whpt ntaxa abund"

  names(data) <- tolower(names(data))
  data <- data[!is.na(data$river_width), ]
  # if no river width...return NULL
  check <- FALSE
  if (nrow(data) < 1) {
    return(NULL)
  }
  # Add year  columns
  data$year <- format.Date(data$date_taken, "%Y")
  data$year <- as.integer(data$year)
  rict_output <- purrr::map(unique(data$location_id), function(location_id) {
    data <- data[data$location_id == location_id, ]
    if (!is.null(data$river_width)) {
      if (any(!is.na(data$river_width))) {
        data$river_width <- as.numeric(data$river_width)
        data$mean_depth <- as.numeric(data$mean_depth)
        data$boulders_cobbles <- as.numeric(data$boulders_cobbles)
        data$pebbles_gravel <- as.numeric(data$pebbles_gravel)
        data$silt_clay <- as.numeric(data$silt_clay)
        data$sand <- as.numeric(data$sand)
        check <- TRUE
      } else {
        data <- select(
          data,
          -"river_width",
          -"mean_depth",
          -"boulders_cobbles",
          -"pebbles_gravel",
          -"sand",
          -"silt_clay"
        )
      }
    }
    # NGR columns

    data <- tidyr::separate(data,
      grid_reference,
      into = c(
        "NGR",
        "NGR_EASTING",
        "NGR_NORTHING"
      ),
      sep = " "
    )
    # needs refactoring - but if no Alk results returned then add blanks/NAs
    # data$alkalinity <- 75
    data$sample_count <- NA
    data$samples_used <- NA
    data$min_date <- NA
    data$max_date <- NA

    data$response <- as.numeric(as.character(data$response))
    data <- tidyr::pivot_wider(data,
      names_from = question,
      values_from = response
    )
    # Join to template
    rict_template <- function() {
      template <- data.frame(
        "LOCATION" = character(),
        "Waterbody" = character(),
        "YEAR" = integer(),
        "NGR" = character(),
        "EASTING" = character(),
        "NORTHING" = character(),
        "S_ALTITUDE" = numeric(),
        "S_SLOPE" = numeric(),
        "S_DISCHARGE_CAT" = numeric(),
        "S_DIST_FROM_SOURCE" = numeric(),
        "River Width (m)" = numeric(),
        "Mean Depth (cm)" = numeric(),
        "Alkalinity" = numeric(),
        "% Boulders/Cobbles" = numeric(),
        "% Pebbles/Gravel" = numeric(),
        "% Sand" = numeric(),
        "% Silt/Clay" = numeric(),
        "Spr_Season_ID" = numeric(),
        "Spr_TL2_WHPT_NTaxa (AbW,DistFam)" = numeric(),
        "Spr_TL2_WHPT_ASPT (AbW,DistFam)" = numeric(),
        "Sum_Season_ID" = numeric(),
        "Sum_TL2_WHPT_NTaxa (AbW,DistFam)" = numeric(),
        "Sum_TL2_WHPT_ASPT (AbW,DistFam)" = numeric(),
        "Aut_Season_ID" = numeric(),
        "Aut_TL2_WHPT_NTaxa (AbW,DistFam)" = numeric(),
        "Aut_TL2_WHPT_ASPT (AbW,DistFam)" = numeric(),
        sample_id = character(),
        check.names = check
      )
    }

    template_nems <- rict_template()
    names(template_nems) <- tolower(names(template_nems))
    data$easting <- as.factor(data$NGR_EASTING)
    data$northing <- as.factor(data$NGR_EASTING)
    names(data) <- tolower(names(data))
    data <- dplyr::bind_rows(template_nems, data)

    # For each Ecology sample (survey_inv/F_BMWP_SUM) summarise
    # data$location <- paste0(data$location_id, ": ", data$location_description)
    data$water_body_id <- 3100
    names(data) <- tolower(names(data))
    data <- data.frame(data, check.names = TRUE)
    names(data) <- tolower(names(data))

    data$date_taken <- as.Date(data$date_taken)
    data$season <- season(data$date_taken)
    data <- dplyr::filter(data, season != 4)

    # summarise_data <- dplyr::group_by(
    #   data,
    #   location_id,
    #   ngr,
    #   ngr_easting,
    #   ngr_northing,
    #   sample_id,
    #   season,
    #   discharge_category,
    #   water_body_id,
    #   .name_repair = TRUE
    # )
    # Suppress warning because of missing values
    # summarise_data <- suppressWarnings(dplyr::summarise_all(
    #   summarise_data,
    #   ~ mean(.x, na.rm = TRUE)
    # ))
    # Select

    rict_data <- dplyr::select(data,
      "SITE" = "location_id",
      "Waterbody" = "water_body_id",
      "Year" = "year",
      "NGR" = "ngr",
      "Easting" = "ngr_easting",
      "Northing" = "ngr_northing",
      "Altitude" = "altitude",
      "Slope" = "slope",
      "Discharge" = "discharge_category",
      "Dist_from_Source" = "dist_from_source",
      "Mean_Width" = "river_width",
      "Mean_depth" = "mean_depth",
      "Alkalinity" = "alkalinity",
      "Total_samples" = "sample_count",
      "Samples_used" = "samples_used",
      "Alk_start" = "min_date",
      "Alk_end" = "max_date",
      "Boulder_Cobbles" = "boulders_cobbles",
      "Pebbles_Gravel" = "pebbles_gravel",
      "Sand" = "sand",
      "Silt_Clay" = "silt_clay",
      "Spr_Season_ID" = "season",
      "Spr_TL2_WHPT_NTaxa (AbW,DistFam)" = "whpt.ntaxa.abund",
      "Spr_TL2_WHPT_ASPT (AbW,DistFam)" = "whpt.aspt.abund",
      "Sum_Season_ID" = "season",
      "Sum_TL2_WHPT_NTaxa (AbW,DistFam)" = "whpt.ntaxa.abund",
      "Sum_TL2_WHPT_ASPT (AbW,DistFam)" = "whpt.aspt.abund",
      "Aut_Season_ID" = "season",
      "Aut_TL2_WHPT_NTaxa (AbW,DistFam)" = "whpt.ntaxa.abund",
      "Aut_TL2_WHPT_ASPT (AbW,DistFam)" = "whpt.aspt.abund",
      "sample_id",
      "season" = "season"
    )
    # Remove season not used

    cols <- grep("Sum_|Spr_", names(rict_data), perl = TRUE)
    rict_data[rict_data$season == 3, cols] <- NA

    cols <- grep("Spr_|Aut_", names(rict_data), perl = TRUE)
    rict_data[rict_data$season == 2, cols] <- NA

    cols <- grep("Sum_|Aut_", names(rict_data), perl = TRUE)
    rict_data[rict_data$season == 1, cols] <- NA

    # Add season id when required
    rict_data$Spr_Season_ID <- 1
    rict_data$Sum_Season_ID <- 2
    rict_data$Aut_Season_ID <- 3
    # Bias where required
    rict_data$SPR_NTAXA_BIAS <- bias
    rict_data$SUM_NTAXA_BIAS <- bias
    rict_data$AUT_NTAXA_BIAS <- bias

    rict_data$VELOCITY <- NA
    rict_data$HARDNESS <- NA
    rict_data$CALCIUM <- NA
    rict_data$CONDUCTIVITY <- NA
    # Replace NANs
    is.nan.data.frame <- function(x) {
      do.call(cbind, lapply(x, is.nan))
    }
    rict_data[is.nan(rict_data)] <- NA
    # Discharge must be numeric to pass validation
    rict_data$Discharge <- as.numeric(rict_data$Discharge)
    rict_data <- data.frame(rict_data, check.names = FALSE)
    # rict_data <- rict_data[rict_data$sample_id != "1582198", ]
    # rict_data <- rict_data[rict_data$sample_id != "1017980", ]
    if (nrow(rict_data) == 0) {
      return(NULL)
    }
    rict_valid <- rict::rict_validate(rict_data, stop_if_all_fail = FALSE)
    if (nrow(rict_valid$data) == 0) {
      return(NULL)
    }
    rict_multi_year <- rict_data %>%
      group_by(SITE, Year) %>%
      select("SITE", "Year", contains("_WHPT_")) %>%
      summarise_all(~ mean(.x, na.rm = TRUE))
    predictors <- rict_data %>%
      select(-"Year", -"season", -contains("_WHPT_"), -"sample_id") %>%
      unique()
    multi <- inner_join(rict_multi_year, predictors, by = c("SITE"))
    multi <- data.frame(multi, check.names = FALSE)
    multi_predict <- rict_predict(multi)
    multi_predict <- select(multi_predict, "SITE", "SuitCode", "SuitText")
    multi_predict <- unique(multi_predict)
    multi_class <- rict::rict(multi, year_type = "multi")
    multi_class <- inner_join(multi_class, multi_predict, by = join_by(SITE))
    multi_year_ntaxa <- select(
      multi_class,
      "SITE",
      "H" = "H_NTAXA_spr_aut",
      "G" = "G_NTAXA_spr_aut",
      "M" = "M_NTAXA_spr_aut",
      "P" = "P_NTAXA_spr_aut",
      "B" = "B_NTAXA_spr_aut",
      "Class" = "mostProb_NTAXA_spr_aut",
      "EQR" = "NTAXA_aver_spr_aut",
      "Suit Code" = "SuitCode",
      "Suit Text" = "SuitText"
    )
    multi_year_ntaxa$parameter <- "Macroinvertebrates (NTAXA)"
    multi_year_aspt <- select(
      multi_class,
      "SITE",
      "H" = "H_ASPT_spr_aut",
      "G" = "G_ASPT_spr_aut",
      "M" = "M_ASPT_spr_aut",
      "P" = "P_ASPT_spr_aut",
      "B" = "B_ASPT_spr_aut",
      "Class" = "mostProb_ASPT_spr_aut",
      "EQR" = "ASPT_aver_spr_aut",
      "Suit Code" = "SuitCode",
      "Suit Text" = "SuitText"
    )

    multi_year_aspt$parameter <- "Macroinvertebrates (ASPT)"
    multi_year_output <- bind_rows(
      multi_year_aspt,
      multi_year_ntaxa
    )
    multi_year_output <- multi_year_output[complete.cases(multi_year_output), ]
    multi_year_output <- mutate_all(multi_year_output, as.character)
    multi_year_output <- pivot_longer(multi_year_output,
      names_to = "question",
      values_to = "response",
      cols = c(-parameter, -SITE)
    )
    # rict_class <- inner_join(rict_class,
    #                          rict_data[, c("SITE","sample_id")],
    #                          by = "sample_id")
    multi_year_output <-
      rename(multi_year_output, "location_id" = SITE)

    predict_single <- rict::rict_predict(rict_data, all_indices = TRUE)
    # predict_single$sample_id <- rict_data$sample_id

    sample_season <- select(data, "location_id", "sample_id", "season")
    sample_season <- unique(sample_season)
    sample_season$season <- as.numeric(sample_season$season)
    predict_single <- select(
      predict_single,
      "SuitCode", "SuitText",
      "SEASON", "SITE",
      "TL2_08_Group_ARMI_Score",
      "TL2_08_Group_ARMI_NTaxa",
      "TL2_WHPT_Score_AbW_DistFam",
      "TL2_WHPT_NTAXA_AbW_DistFam",
      "TL2_WHPT_ASPT_AbW_DistFam"
    )
    predict_single <- unique(predict_single)
    predict_single <- inner_join(sample_season,
      predict_single,
      by = join_by(
        season == SEASON,
        location_id == SITE
      )
    )

    single_predict <- predict_single
    # single_predict <- select(predict_single, sample_id, SuitCode, SuitText)
    # single_predict <- unique(single_predict)
    # ISSUE - rict_output is not in same 'sample' order as rict_data input!
    # try running data using sample_id as SITE. Then later join location using
    # sample_id
    rict_data$location_id <- rict_data$SITE
    rict_data$SITE <- rict_data$sample_id
    rict_output <- rict::rict(rict_data, year_type = "single")
    # Hot fix...try to arrange by year ascending to match output? Works(maybe!).
    # rict_data <- arrange(rict_data, Year)
    rict_output <- inner_join(rict_output, sample_season, by = join_by(SITE == sample_id))
    rict_output$sample_id <- rict_output$SITE
    rict_output$SITE <- rict_output$location_id
    rict_output <- unique(rict_output)

    rict_output <- rict_output[rict_output$sample_id %in% single_predict$sample_id, ]
    rict_data <- unique(rict_data)

    rict_output <- inner_join(rict_output, single_predict, by = join_by(sample_id))

    spr_ntaxa <- select(
      rict_output,
      "sample_id",
      "H" = "H_NTAXA_spr",
      "G" = "G_NTAXA_spr",
      "M" = "M_NTAXA_spr",
      "P" = "P_NTAXA_spr",
      "B" = "B_NTAXA_spr",
      "Class" = "mostProb_NTAXA_spr",
      "EQR" = "NTAXA_eqr_av_spr",
      "Suit Code" = "SuitCode",
      "Suit Text" = "SuitText"
    )
    spr_ntaxa$parameter <- "Macroinvertebrates (NTAXA)"

    sum_ntaxa <- select(
      rict_output,
      "sample_id",
      "H" = "H_NTAXA_sum",
      "G" = "G_NTAXA_sum",
      "M" = "M_NTAXA_sum",
      "P" = "P_NTAXA_sum",
      "B" = "B_NTAXA_sum",
      "Class" = "mostProb_NTAXA_sum",
      "EQR" = "NTAXA_eqr_av_sum",
      "Suit Code" = "SuitCode",
      "Suit Text" = "SuitText"
    )
    sum_ntaxa$parameter <- "Macroinvertebrates (NTAXA)"

    aut_ntaxa <- select(
      rict_output,
      "sample_id",
      "H" = "H_NTAXA_aut",
      "G" = "G_NTAXA_aut",
      "M" = "M_NTAXA_aut",
      "P" = "P_NTAXA_aut",
      "B" = "B_NTAXA_aut",
      "Class" = "mostProb_NTAXA_aut",
      "EQR" = "NTAXA_eqr_av_aut",
      "Suit Code" = "SuitCode",
      "Suit Text" = "SuitText"
    )
    aut_ntaxa$parameter <- "Macroinvertebrates (NTAXA)"

    aut_aspt <- select(
      rict_output,
      "sample_id",
      "H" = "H_ASPT_aut",
      "G" = "G_ASPT_aut",
      "M" = "M_ASPT_aut",
      "P" = "P_ASPT_aut",
      "B" = "B_ASPT_aut",
      "Class" = "mostProb_ASPT_aut",
      "EQR" = "ASPT_eqr_av_aut",
      "Suit Code" = "SuitCode",
      "Suit Text" = "SuitText"
    )
    aut_aspt$parameter <- "Macroinvertebrates (ASPT)"

    spr_aspt <- select(
      rict_output,
      "sample_id",
      "H" = "H_ASPT_spr",
      "G" = "G_ASPT_spr",
      "M" = "M_ASPT_spr",
      "P" = "P_ASPT_spr",
      "B" = "B_ASPT_spr",
      "Class" = "mostProb_ASPT_spr",
      "EQR" = "ASPT_eqr_av_spr",
      "Suit Code" = "SuitCode",
      "Suit Text" = "SuitText"
    )
    spr_aspt$parameter <- "Macroinvertebrates (ASPT)"

    sum_aspt <- select(
      rict_output,
      "sample_id",
      "H" = "H_ASPT_sum",
      "G" = "G_ASPT_sum",
      "M" = "M_ASPT_sum",
      "P" = "P_ASPT_sum",
      "B" = "B_ASPT_sum",
      "Class" = "mostProb_ASPT_sum",
      "EQR" = "eqr_av_sum_aspt",
      "Suit Code" = "SuitCode",
      "Suit Text" = "SuitText"
    )
    sum_aspt$parameter <- "Macroinvertebrates (ASPT)"
    rict_class <- bind_rows(
      spr_aspt,
      sum_aspt,
      aut_aspt,
      spr_ntaxa,
      sum_ntaxa,
      aut_ntaxa
    )

    rict_class <- rict_class[complete.cases(rict_class), ]
    rict_class <- mutate_all(rict_class, as.character)
    rict_class <- pivot_longer(rict_class,
      names_to = "question",
      values_to = "response",
      cols = c(-sample_id, -parameter)
    )
    rict_class <- inner_join(rict_class,
      rict_data[, c("location_id", "sample_id")],
      by = "sample_id",
      relationship = "many-to-many"
    )
    # rict_class <- rename(rict_class, "location_id" = SITE)
    rict_aspt <- tibble(
      "location_id" = predict_single$location_id,
      "sample_id" = predict_single$sample_id,
      "question" = "RICT Reference WHPT ASPT",
      "response" = as.character(predict_single$TL2_WHPT_ASPT_AbW_DistFam)
    )
    rict_ntaxa <- tibble(
      "location_id" = predict_single$location_id,
      "sample_id" = predict_single$sample_id,
      "question" = "RICT Rerference WHPT NTAXA",
      "response" = as.character(predict_single$TL2_WHPT_NTAXA_AbW_DistFam)
    )
    rict_river_score <- tibble(
      "location_id" = predict_single$location_id,
      "sample_id" = predict_single$sample_id,
      "question" = "RICT Rerference ARMI Score",
      "response" = as.character(predict_single$TL2_08_Group_ARMI_Score)
    )
    rict_river_ntaxa <- tibble(
      "location_id" = predict_single$location_id,
      "sample_id" = predict_single$sample_id,
      "question" = "RICT Rerference ARMI NTAXA",
      "response" = as.character(predict_single$TL2_08_Group_ARMI_NTaxa)
    )

    predict_single <- bind_rows(rict_aspt, rict_ntaxa, rict_river_score, rict_river_ntaxa)
    predict_single$parameter <- "RICT Prediction"
    rict_prediction <- bind_rows(
      predict_single,
      rict_class,
      multi_year_output
    )
    # create row for years included in multi-year
    row <- rict_prediction[is.na(rict_prediction$sample_id), ]
    row <- row[1:2, ]
    row$parameter[1] <- "Macroinvertebrates (ASPT)"
    row$parameter[2] <- "Macroinvertebrates (NTAXA)"
    row$question <- "Years included"
    row$response <- paste(unique(rict_data$Year), collapse = ",")
    rict_prediction <- bind_rows(rict_prediction, row)
  })

  output <- bind_rows(rict_output)
  if (nrow(output) < 1) {
    return(NULL)
  }
  output <- unique(output)
  output <- mutate(output,
    question = ifelse(question == "M",
      "CoCM",
      question
    ),
    question = ifelse(question == "P",
      "CoCP",
      question
    ),
    question = ifelse(question == "B",
      "CoCB",
      question
    ),
    question = ifelse(question == "H",
      "CoCH",
      question
    ),
    question = ifelse(question == "G",
      "CoCG",
      question
    )
  )


  output <- mutate(output,
    response = ifelse(response == "H",
      "High",
      response
    ),
    response = ifelse(response == "G",
      "Good",
      response
    ),
    response = ifelse(response == "M",
      "Moderate",
      response
    ),
    response = ifelse(response == "P",
      "Poor",
      response
    ),
    response = ifelse(response == "B",
      "Bad",
      response
    )
  )

  return(output)
}
```

## Outcome

The outcome of this assessment.

| question                   | response          |
|:---------------------------|:------------------|
| RICT Reference WHPT ASPT   | 6.70423763296175  |
| RICT Rerference WHPT NTAXA | 23.3958436732449  |
| RICT Rerference ARMI Score | 13.5271425604722  |
| RICT Rerference ARMI NTAXA | 5.82390315155402  |
| CoCH                       | 22.83             |
| CoCG                       | 30.05             |
| CoCM                       | 31.64             |
| CoCP                       | 10.48             |
| CoCB                       | 4.99              |
| Class                      | Moderate          |
| EQR                        | 0.868839670474072 |
| Suit Code                  | 1                 |
| Suit Text                  | \>5%              |
| Years included             | 2019              |

## Check

Run checks on this assessment.

    #> Test passed with 1 success 🌈.
    #> Test passed with 1 success 😀.

| check                    | value |
|:-------------------------|:------|
| standard_names           | TRUE  |
| standard_required        | TRUE  |
| standard_required_values | TRUE  |

## Update

Update the catalogue of assessments to make them available.

    #> ✔ Setting active project to "/home/runner/work/hera/hera".
    #> ✔ Saving "catalogue" to "data/catalogue.rda".
    #> ☐ Document your data (see <https://r-pkgs.org/data.html>).

After **updating the catalogue, rebuild the package**, click on Build \>
Install and Restart menu or ‘Install and Restart’ button in the Build
pane.

## Test

This section tests if this assessment is usable using
[`assess()`](https://ecodata1.github.io/hera/reference/assess.md)
function.

    #> 8175
    #> Variables for the 'physical' model detected - applying relevant checks.
    #> Grid reference values detected for 'GB' - applying relevant checks.
    #> Success, all validation checks passed!
    #> Variables for the 'physical' model detected - applying relevant checks.
    #> Grid reference values detected for 'GB' - applying relevant checks.
    #> Success, all validation checks passed!
    #> Variables for the 'physical' model detected - applying relevant checks.
    #> Grid reference values detected for 'GB' - applying relevant checks.
    #> Success, all validation checks passed!
    #> Classifying...
    #> Variables for the 'physical' model detected - applying relevant checks.
    #> Grid reference values detected for 'GB' - applying relevant checks.
    #> Success, all validation checks passed!
    #> Warning in data.frame(..., check.names = FALSE): row names were found from a
    #> short variable and have been discarded
    #> Warning in inner_join(sample_season, predict_single, by = join_by(season == : Detected an unexpected many-to-many relationship between `x` and `y`.
    #> ℹ Row 2 of `x` matches multiple rows in `y`.
    #> ℹ Row 4 of `y` matches multiple rows in `x`.
    #> ℹ If a many-to-many relationship is expected, set `relationship =
    #>   "many-to-many"` to silence this warning.
    #> Variables for the 'physical' model detected - applying relevant checks.
    #> Grid reference values detected for 'GB' - applying relevant checks.
    #> Success, all validation checks passed!
    #> Classifying...
    #> Warning in inner_join(rict_output, single_predict, by = join_by(sample_id)): Detected an unexpected many-to-many relationship between `x` and `y`.
    #> ℹ Row 2 of `x` matches multiple rows in `y`.
    #> ℹ Row 2 of `y` matches multiple rows in `x`.
    #> ℹ If a many-to-many relationship is expected, set `relationship =
    #>   "many-to-many"` to silence this warning.

## Launch app

Below is an interactive application displaying the results of your
assessment.
