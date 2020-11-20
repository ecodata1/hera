#' @importFrom rlang .data
#' @importFrom tibble tibble
#' @importFrom dplyr group_by inner_join mutate select arrange filter summarise ungroup
#' @importFrom tidyr unnest nest pivot_wider
#' @importFrom magrittr `%>%`
#' @importFrom purrr map

rict_prediction <- function(data) {
  # data <- demo_data

  bias <- 6.21
  analysis <- "FW_TX_WHPT"

  names(data) <- tolower(names(data))
  # Remove any duplicate chemistry samples
  # otherwise pivot will not work later
  # if (is.null(data$result_id)) {
  #   names(data) <- toupper(names(data))
  #   data <- sepaTools:::uniqueResultIdentifer(data)
  #   names(data) <- tolower(names(data))
  # }

  data <- data[!duplicated(data$result_id), ]

  # Add year  columns
  data$YEAR <- format.Date(data$date_taken, "%Y")
  data$YEAR <- as.integer(data$YEAR)

  # NGR columns
  data <- tidyr::separate(data,
    national_grid_reference,
    into = c(
      "NGR",
      "NGR_EASTING",
      "NGR_NORTHING"
    ),
    sep = " "
  )

  data <- data[data$analysis_name %in% c("SURVEY_INV", "F_BMWP_SUM", "FW_TX_WHPT"), ]
  # needs refactoring - but if no Alk results returned then add blanks/NAs
  data$alkalinity <- 75
  data$sample_count <- NA
  data$samples_used <- NA
  data$min_date <- NA
  data$max_date <- NA

  # Remove alkalinity samples (now that we have a mean alk for each ecology sample)
  # data <- dplyr::filter(data, is.na(determinand_no))

  # Only with matching BMWP and SURVEY_INV
  data <- purrr::map_df(split(data, data$sample_id), function(sample) {
    if (any(sample$analysis_name %in% analysis)) {
      return(sample)
    } else {
      return(NULL)
    }
  })

  if (nrow(data) == 0) {
    return(NULL)
  }


  data <- pivot_wider(data, names_from = determinand, values_from = value)
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
      check.names = FALSE
    )
  }
  template_nems <- rict_template()
  names(template_nems) <- tolower(names(template_nems))
  data$easting <- as.factor(data$easting)
  data$northing <- as.factor(data$northing)
  names(data) <- tolower(names(data))
  data <- dplyr::bind_rows(template_nems, data)

  # For each Ecology sample (survey_inv/F_BMWP_SUM) summarise
  data$location <- paste0(data$location_code, ": ", data$location_description)
  data$water_body_id <- 3100
  names(data) <- tolower(names(data))
  data <- data.frame(data, check.names = TRUE)
  summarise_data <- dplyr::group_by(
    data,
    location,
    ngr,
    ngr_easting,
    ngr_northing,
    sample_id,
    season,
    s_discharge_cat,
    water_body_id
  )
  # Suppress warning because of missing values
  summarise_data <- suppressWarnings(dplyr::summarise_all(
    summarise_data,
    ~ mean(.x, na.rm = TRUE)
  ))

  # Select
  rict_data <- dplyr::select(summarise_data,
    "SITE" = location,
    "Waterbody" = water_body_id,
    "Year" = year,
    "NGR" = ngr,
    "Easting" = ngr_easting,
    "Northing" = ngr_northing,
    "Altitude" = s_altitude,
    "Slope" = s_slope,
    "Discharge" = s_discharge_cat,
    "Dist_from_Source" = s_dist_from_source,
    "Mean_Width" = river.width..m.,
    "Mean_depth" = mean.depth..cm.,
    "Alkalinity" = alkalinity,
    "Total_samples" = sample_count,
    "Samples_used" = samples_used,
    "Alk_start" = min_date,
    "Alk_end" = max_date,
    Boulder_Cobbles = X..boulders.cobbles,
    Pebbles_Gravel = X..pebbles.gravel,
    Sand = X..sand,
    Silt_Clay = X..silt.clay,
    "Spr_Season_ID" = season,
    "Spr_TL2_WHPT_NTaxa (AbW,DistFam)" = "whpt.ntaxa.abund",
    "Spr_TL2_WHPT_ASPT (AbW,DistFam)" = "whpt.aspt.abund",
    "Sum_Season_ID" = season,
    "Sum_TL2_WHPT_NTaxa (AbW,DistFam)" = "whpt.ntaxa.abund",
    "Sum_TL2_WHPT_ASPT (AbW,DistFam)" = "whpt.aspt.abund",
    "Aut_Season_ID" = season,
    "Aut_TL2_WHPT_NTaxa (AbW,DistFam)" = "whpt.ntaxa.abund",
    "Aut_TL2_WHPT_ASPT (AbW,DistFam)" = "whpt.aspt.abund",
    sample_id,
    season = "season"
  )

  # Remove season not used.uniqueSampleIdentifer
  rict_data[
    rict_data$season == "AUT",
    grep("Sum_|Spr_", names(rict_data), perl = TRUE),
  ] <- NA
  rict_data[
    rict_data$season == "SUM",
    grep("Aut_|Spr_", names(rict_data), perl = TRUE),
  ] <- NA
  rict_data[
    rict_data$season == "SPR",
    grep("Sum_|Aut_", names(rict_data), perl = TRUE),
  ] <- NA

  # Add season id when required
  rict_data$Spr_Season_ID[!is.na(rict_data$Spr_Season_ID)] <- 1
  rict_data$Sum_Season_ID[!is.na(rict_data$Sum_Season_ID)] <- 2
  rict_data$Aut_Season_ID[!is.na(rict_data$Aut_Season_ID)] <- 3
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


  rict_data$Altitude <- 34
  rict_data$Slope <- 3
  rict_data$Discharge <- 4
  rict_data$Dist_from_Source <- 15

  rict_prediction <- rict::rict_validate(rict_data,stop_if_all_fail = FALSE)
  if(nrow(rict_prediction$data) == 0) {
    return(NULL)
  }
  rict_prediction <- rict::rict_predict(rict_data)
  return(rict_prediction)
}
