# library(dplyr)
# library(hera)
# library(purrr)
# data <- read.csv("C:/Users/Tim.Foster/OneDrive - Scottish Environment Protection Agency/Reports/Classification-tool/2023-classification/2023-data-final.csv")
# data2 <- data %>% filter(location_id %in% c(
#                           320571
#                         # 3490,
#                         # 3402,
#                         # 3798,
#                         # 4411,
#                         # 5982,
#                         # 8507,
#                         # 14058,
#                         # 129912,
#                         # 135238,
#                         # 200630,
#                         # 301972,
#                         # 338805,
#                         # 487596,
#                         # 488482,
#                         # 545147
#                         )
# )
#
# data2$location_id <- as.character(data2$location_id)
# data2$sample_id <- as.character(data2$sample_id)
#
# # data2$location_id <- as.integer(data2$location_id)
# # data2$sample_id <- as.integer(data2$sample_id)
#
# convert_rict <- function(data) {
#   browser()
#   require(macroinvertebrateMetrics)
#   require(dplyr)
#   message(unique(data$location_id))
#   metric_function <- catalogue[catalogue$assessment ==
#     "Macroinvertebrate Metrics", 3][[1]]
#   input_data <- data
#   input_data$location_id <- NULL
#   output <- metric_function[[1]](input_data)
#   if (is.null(output)) {
#     return(NULL)
#   }
#   output <- dplyr::filter(output, question %in% c("WHPT_ASPT", "WHPT_NTAXA"))
#
#
#   # Alkalinity ---------
#   # if(!any(names(data) %in% c("alkalinity"))) {
#   #   alk <- hera:::mean_alkalinity(data)
#   #   data$alkalinity <- NULL
#   #   data <- inner_join(data, alk, by = join_by("sample_id" == "sample_number"))
#   # }
#   if (!any(names(data) %in% "alkalinity")) {
#     predictors <- utils::read.csv(system.file("extdat",
#       "predictors.csv",
#       package = "hera"
#     ), check.names = FALSE)
#     predictors$location_id <- as.character(predictors$location_id)
#     predict_data <- filter(predictors, location_id %in% unique(data$location_id))
#     predict_data$date <- as.Date(predict_data$date)
#     predict_data <- arrange(predict_data, dplyr::desc(date))
#
#     output_location <- inner_join(output,
#       unique(data[, c(
#         "location_id",
#         "sample_id",
#         "date_taken"
#       )]),
#       by = "sample_id",
#       relationship = "many-to-many"
#     )
#
#     whpt_input <- inner_join(output_location, predict_data, by = "location_id", multiple = "first")
#   } else {
#     # function to average predictors for each year? See sepaTools package?::
#     final_data <- data
#     final_data <- filter(final_data, analysis_repname == "Invert Physical Data")
#     if (nrow(final_data) < 1) {
#       return(NULL)
#     }
#     summarise_data <- select(
#       final_data,
#       "location_id",
#       "sample_id",
#       "year",
#       "question",
#       "response"
#     )
#
#     summarise_data <- map_df(split(
#       summarise_data,
#       summarise_data$sample_id
#     ), function(sample) {
#       # get a row to add to bottom when mean_depth calculated
#       row <- sample[1, ]
#       row$question <- "mean_depth"
#       if (!any(sample$question %in% "mean_depth")) {
#         depths <- filter(sample, question %in% c(
#           "River Depth 1",
#           "River Depth 2",
#           "River Depth 3"
#         ))
#         if (nrow(depths) < 1) {
#           # some samples don't have Depths or mean_depth...so return NA
#           row$response <- NA
#         } else {
#           mean_depth <- mean(as.numeric(depths$response), na.rm = TRUE)
#
#           row$response <- as.character(mean_depth)
#         }
#         sample <- bind_rows(sample, row)
#         return(sample)
#       } else {
#         return(sample)
#       }
#     })
#
#     summarise_data <- summarise_data %>%
#       filter(question %in% c(
#         "sand",
#         "silt_clay",
#         "boulders_cobbles",
#         "pebbles_gravel",
#         "river_width",
#         "mean_depth"
#       ))
#     summarise_data <- tidyr::pivot_wider(summarise_data,
#       names_from = question,
#       values_from = response
#     )
#     summarise_data <- type.convert(summarise_data, as.is = TRUE)
#     summarise_data <- select(summarise_data, -"sample_id")
#     summarise_data <- dplyr::group_by(
#       summarise_data,
#       location_id
#     )
#     # Suppress warning because of missing values
#     summarise_data <- suppressWarnings(dplyr::summarise_all(
#       summarise_data,
#       ~ mean(.x, na.rm = TRUE)
#     ))
#     summarise_data$location_id <- as.character(summarise_data$location_id)
#     data <- left_join(data, summarise_data, by = join_by(location_id == location_id))
#     data <- data %>%
#       group_by(location_id) %>%
#       mutate("alkalinity" = mean(alkalinity, na.rm = TRUE))
#     data <- ungroup(data)
#
#     data <- select(
#       data,
#       "sample_id",
#       "location_id",
#       "date_taken",
#       "grid_reference",
#       "alkalinity",
#       "river_width",
#       "mean_depth",
#       "boulders_cobbles",
#       "pebbles_gravel",
#       "sand",
#       "silt_clay",
#       # "northing",
#       # "easting",
#       "dist_from_source",
#       "altitude",
#       "slope",
#       "grid_reference",
#       "discharge_category"
#     )
#     whpt_input <- inner_join(output,
#       unique(data),
#       by = "sample_id"
#     )
#   }
#   whpt_input$question[whpt_input$question == "WHPT_ASPT"] <- "WHPT ASPT Abund"
#   whpt_input$question[whpt_input$question == "WHPT_NTAXA"] <- "WHPT NTAXA Abund"
#   data <- whpt_input
#
#   bias <- 1.62
#   analysis <- "whpt ntaxa abund"
#
#   names(data) <- tolower(names(data))
#   data <- data[!is.na(data$river_width), ]
#   # if no river width...return NULL
#   check <- FALSE
#   if (nrow(data) < 1) {
#     return(NULL)
#   }
#   # Add year  columns
#   data$year <- format.Date(data$date_taken, "%Y")
#   data$year <- as.integer(data$year)
#   rict_input <- purrr::map_df(unique(data$location_id), function(location_id) {
#     data <- data[data$location_id == location_id, ]
#     if (!is.null(data$river_width)) {
#       if (any(!is.na(data$river_width))) {
#         data$river_width <- as.numeric(data$river_width)
#         data$mean_depth <- as.numeric(data$mean_depth)
#         data$boulders_cobbles <- as.numeric(data$boulders_cobbles)
#         data$pebbles_gravel <- as.numeric(data$pebbles_gravel)
#         data$silt_clay <- as.numeric(data$silt_clay)
#         data$sand <- as.numeric(data$sand)
#         check <- TRUE
#       } else {
#         data <- select(
#           data,
#           -"river_width",
#           -"mean_depth",
#           -"boulders_cobbles",
#           -"pebbles_gravel",
#           -"sand",
#           -"silt_clay"
#         )
#       }
#     }
#     # NGR columns
#
#     data <- tidyr::separate(data,
#       grid_reference,
#       into = c(
#         "NGR",
#         "NGR_EASTING",
#         "NGR_NORTHING"
#       ),
#       sep = " "
#     )
#     # needs refactoring - but if no Alk results returned then add blanks/NAs
#     # data$alkalinity <- 75
#     data$sample_count <- NA
#     data$samples_used <- NA
#     data$min_date <- NA
#     data$max_date <- NA
#
#     data$response <- as.numeric(as.character(data$response))
#     data <- tidyr::pivot_wider(data,
#       names_from = question,
#       values_from = response
#     )
#     # Join to template
#     rict_template <- function() {
#       template <- data.frame(
#         "LOCATION" = character(),
#         "Waterbody" = character(),
#         "YEAR" = integer(),
#         "NGR" = character(),
#         "EASTING" = character(),
#         "NORTHING" = character(),
#         "S_ALTITUDE" = numeric(),
#         "S_SLOPE" = numeric(),
#         "S_DISCHARGE_CAT" = numeric(),
#         "S_DIST_FROM_SOURCE" = numeric(),
#         "River Width (m)" = numeric(),
#         "Mean Depth (cm)" = numeric(),
#         "Alkalinity" = numeric(),
#         "% Boulders/Cobbles" = numeric(),
#         "% Pebbles/Gravel" = numeric(),
#         "% Sand" = numeric(),
#         "% Silt/Clay" = numeric(),
#         "Spr_Season_ID" = numeric(),
#         "Spr_TL2_WHPT_NTaxa (AbW,DistFam)" = numeric(),
#         "Spr_TL2_WHPT_ASPT (AbW,DistFam)" = numeric(),
#         "Sum_Season_ID" = numeric(),
#         "Sum_TL2_WHPT_NTaxa (AbW,DistFam)" = numeric(),
#         "Sum_TL2_WHPT_ASPT (AbW,DistFam)" = numeric(),
#         "Aut_Season_ID" = numeric(),
#         "Aut_TL2_WHPT_NTaxa (AbW,DistFam)" = numeric(),
#         "Aut_TL2_WHPT_ASPT (AbW,DistFam)" = numeric(),
#         sample_id = character(),
#         check.names = check
#       )
#     }
#
#     template_nems <- rict_template()
#     names(template_nems) <- tolower(names(template_nems))
#     data$easting <- as.factor(data$NGR_EASTING)
#     data$northing <- as.factor(data$NGR_EASTING)
#     names(data) <- tolower(names(data))
#     data <- dplyr::bind_rows(template_nems, data)
#
#     # For each Ecology sample (survey_inv/F_BMWP_SUM) summarise
#     # data$location <- paste0(data$location_id, ": ", data$location_description)
#     data$water_body_id <- 3100
#     names(data) <- tolower(names(data))
#     data <- data.frame(data, check.names = TRUE)
#     names(data) <- tolower(names(data))
#
#     data$date_taken <- as.Date(data$date_taken)
#     data$season <- season(data$date_taken)
#     data <- dplyr::filter(data, season != 4)
#
#     # summarise_data <- dplyr::group_by(
#     #   data,
#     #   location_id,
#     #   ngr,
#     #   ngr_easting,
#     #   ngr_northing,
#     #   sample_id,
#     #   season,
#     #   discharge_category,
#     #   water_body_id,
#     #   .name_repair = TRUE
#     # )
#     # Suppress warning because of missing values
#     # summarise_data <- suppressWarnings(dplyr::summarise_all(
#     #   summarise_data,
#     #   ~ mean(.x, na.rm = TRUE)
#     # ))
#     # Select
#
#     rict_data <- dplyr::select(data,
#       "SITE" = "location_id",
#       "Waterbody" = "water_body_id",
#       "Year" = "year",
#       "NGR" = "ngr",
#       "Easting" = "ngr_easting",
#       "Northing" = "ngr_northing",
#       "Altitude" = "altitude",
#       "Slope" = "slope",
#       "Discharge" = "discharge_category",
#       "Dist_from_Source" = "dist_from_source",
#       "Mean_Width" = "river_width",
#       "Mean_depth" = "mean_depth",
#       "Alkalinity" = "alkalinity",
#       "Total_samples" = "sample_count",
#       "Samples_used" = "samples_used",
#       "Alk_start" = "min_date",
#       "Alk_end" = "max_date",
#       "Boulder_Cobbles" = "boulders_cobbles",
#       "Pebbles_Gravel" = "pebbles_gravel",
#       "Sand" = "sand",
#       "Silt_Clay" = "silt_clay",
#       "Spr_Season_ID" = "season",
#       "Spr_TL2_WHPT_NTaxa (AbW,DistFam)" = "whpt.ntaxa.abund",
#       "Spr_TL2_WHPT_ASPT (AbW,DistFam)" = "whpt.aspt.abund",
#       "Sum_Season_ID" = "season",
#       "Sum_TL2_WHPT_NTaxa (AbW,DistFam)" = "whpt.ntaxa.abund",
#       "Sum_TL2_WHPT_ASPT (AbW,DistFam)" = "whpt.aspt.abund",
#       "Aut_Season_ID" = "season",
#       "Aut_TL2_WHPT_NTaxa (AbW,DistFam)" = "whpt.ntaxa.abund",
#       "Aut_TL2_WHPT_ASPT (AbW,DistFam)" = "whpt.aspt.abund",
#       "sample_id",
#       "season" = "season"
#     )
#     # Remove season not used
#
#     cols <- grep("Sum_|Spr_", names(rict_data), perl = TRUE)
#     rict_data[rict_data$season == 3, cols] <- NA
#
#     cols <- grep("Spr_|Aut_", names(rict_data), perl = TRUE)
#     rict_data[rict_data$season == 2, cols] <- NA
#
#     cols <- grep("Sum_|Aut_", names(rict_data), perl = TRUE)
#     rict_data[rict_data$season == 1, cols] <- NA
#
#
#     # Add season id when required
#     rict_data$Spr_Season_ID <- 1
#     rict_data$Sum_Season_ID <- 2
#     rict_data$Aut_Season_ID <- 3
#     # Bias where required
#     rict_data$SPR_NTAXA_BIAS <- bias
#     rict_data$SUM_NTAXA_BIAS <- bias
#     rict_data$AUT_NTAXA_BIAS <- bias
#
#     rict_data$VELOCITY <- NA
#     rict_data$HARDNESS <- NA
#     rict_data$CALCIUM <- NA
#     rict_data$CONDUCTIVITY <- NA
#     # Replace NANs
#     is.nan.data.frame <- function(x) {
#       do.call(cbind, lapply(x, is.nan))
#     }
#     rict_data[is.nan(rict_data)] <- NA
#     # Discharge must be numeric to pass validation
#     rict_data$Discharge <- as.numeric(rict_data$Discharge)
#     rict_data <- data.frame(rict_data, check.names = FALSE)
#     # rict_data <- rict_data[rict_data$sample_id != "1582198", ]
#     # rict_data <- rict_data[rict_data$sample_id != "1017980", ]
#     if (nrow(rict_data) == 0) {
#       return(NULL)
#     }
#     rict_valid <- rict::rict_validate(rict_data, stop_if_all_fail = FALSE)
#     if (nrow(rict_valid$data) == 0) {
#       return(NULL)
#     }
#     rict_multi_year <- rict_data %>%
#       group_by(SITE, Year) %>%
#       select("SITE", "Year", contains("_WHPT_")) %>%
#       summarise_all(~ mean(.x, na.rm = TRUE))
#     predictors <- rict_data %>%
#       select(-"Year", -"season", -contains("_WHPT_"), -"sample_id") %>%
#       unique()
#     multi <- inner_join(rict_multi_year, predictors, by = c("SITE"))
#     multi <- data.frame(multi, check.names = FALSE)
#     if(unique(multi$SITE) == "545147") {
#     browser()
#     }
#     multi_predict <- rict::rict_predict(multi)
#     multi_predict <- select(multi_predict, "SITE", "SuitCode", "SuitText")
#     multi_predict <- unique(multi_predict)
#     return(multi)
#   })
#   return(rict_input)
# }
#
#
# results <- map_df(c(2017), function(class_year) {
#   browser()
#   ids <- unique(data2[data2$max_year == class_year, c("sample_id", "parameter")])
#   filter_data <- inner_join(data2,
#                             ids, by = join_by(sample_id, parameter))
#
#   filtered_data <- filter_data %>%
#     filter(year <= class_year) %>%
#     hera:::filter_samples(classification_year_data = FALSE)
#
#
#   wfd_results <- map_df(split(filtered_data, filtered_data$location_id), function(location) {
#     message(unique(location$location_id))
#     # if(unique(location$location_id) == "5982") {
#     #   browser()
#     # }
#     # wfd_result <- assess(location,
#     #                      name = c(
#     #                        "DARLEQ3",
#     #                        "RICT"
#     #                      )
#     # )
#     wfd_result <- convert_rict(location)
#
#   }, .progress = TRUE)
#
# })
#
# # input_data <- convert_rict(filtered_data)
# # # write.csv(results, "rict-input-final.csv", row.names = FALSE)
