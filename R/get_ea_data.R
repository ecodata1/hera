get_ea_data <- function(location_id, take, date_from, date_to) {
  message("Downloading data from data.gov.uk web services...")
  location_id <- paste0(
    "http://environment.data.gov.uk/ecology/site/bio/",
    location_id
  )
  obs <- get_observations(
    location_id,
    date_from = date_from,
    date_to = date_to,
    take = take
  )
  if (length(obs) == 0) {
    return()
  }

  # Join taxa table ------------------------------------------------------------
  taxa <- get_taxa()

  ultimate_foi_id <- strsplit(obs$ultimate_feature_of_interest_id, "/|-")
  ultimate_foi_id <- map(ultimate_foi_id, function(x) {
    x[7]
  })

  obs$ultimate_foi_id <- unlist(ultimate_foi_id)
  obs <- dplyr::left_join(obs, taxa, by = c("ultimate_foi_id" = "notation"))

  # Join site info -------------------------------------------------------------
  site <- unique(obs$site_id)

  site_info <- get_site_info(site_id = site)
  site_info_wide <- tidyr::pivot_wider(site_info,
    names_from = "properties.property_label",
    values_from = "properties.value"
  )

  site_info_wide$location_description <- site_info_wide$label
  site_info_wide$label <- NULL
  data <- dplyr::inner_join(obs, site_info_wide, by = c("site_id" = "site_id"))

  # Join properties of the observations ----------------------------------------
  properties <- eadata::get_properties()
  data <- dplyr::inner_join(data, properties,
    by = c("property_id" = "property")
  )

  # Format columns -------------------------------------------------------------
  sample_id <- strsplit(data$survey_id, "/|-")
  sample_id <- map(sample_id, function(x) {
    x[7]
  })
  data$sample_id <- unlist(sample_id)

  data$grid_reference <- en_to_os(select(data, "easting", "northing"))
  data$grid_reference <- paste0(
    substr(data$grid_reference, 1, 2),
    " ",
    substr(data$grid_reference, 3, 6),
    "0 ",
    substr(data$grid_reference, 7, 10),
    "0"
  )
  data$parameter <- NA
  data$parameter[data$observation_type == "http://environment.data.gov.uk/ecology/def/bio/RiverDiatTaxaObservation"] <- "River Diatoms"
  data$parameter[data$observation_type == "http://environment.data.gov.uk/ecology/def/bio/RiverDiatMetricsObservation"] <- "River Diatoms"
  data$parameter[data$observation_type == "http://environment.data.gov.uk/ecology/def/bio/RiverInvMetricsObservation"] <- "River Invertebrates"
  data$parameter[data$observation_type == "http://environment.data.gov.uk/ecology/def/bio/RiverInvTaxaObservation" &
    data$taxonRank == "Family"] <- "River Family Inverts"
  data$parameter[data$observation_type == "http://environment.data.gov.uk/ecology/def/bio/RiverMacpMetricsObservation"] <- "River Macrophytes"
  data$parameter[data$observation_type == "http://environment.data.gov.uk/ecology/def/bio/RiverMacpTaxaObservation"] <- "River Macrophytes"
  data <- data %>% dplyr::rename(
    "question" = "label.y",
    "response" = "simple_result",
    "date_taken" = "date",
    "location_id" = "site_id",
    "latitude" = "lat",
    "longitude" = "long",
    # "water_body_id" = "WFD Waterbody ID",
    "water_body_type" = "Waterbody Type",
    "water_body" = "Water Body",
    # "dist_from_source" = "Distance from Source",
    # "source_altitude" = "Source Altitude",
     "label" = "pref_label",
    "units" = "property_id"
  )
  # Not all locations have these attributes:
  if (!is.null(data$Sand)) {
    data <- data %>% dplyr::rename(
      "river_width" = "Width",
      "mean_depth" = "Depth",
      "boulders_cobbles" = "Boulders/Cobbles",
      "pebbles_gravel" = "Pebbles/Gravel",
      "sand" = "Sand",
      "silt_clay" = "Silt/Clay",
      "discharge_category" = "Discharge",
    )
  }
  data$question[grep("-percentageCoverBand", data$result_id)] <-
    "PercentageCoverBand"
  data$question[data$question == "WHPT_ASPT"] <- "WHPT ASPT Abund"
  data$question[data$question == "WPHT_N_TAXA"] <- "WHPT NTAXA Abund"
  data$question <- tolower(data$question)
  data$question[grep("unitsFound", data$result_id)] <- "Taxon abundance"
  data$question[data$question == "total_abundance"] <- "Taxon abundance"
  # Generate season -----------------------------------------------------------
  data$Month <- lubridate::month(data$date_taken)
  data$season <- ifelse((data$Month >= 3) & (data$Month <= 5), "1",
    ifelse((data$Month >= 6) & (data$Month <= 8), "2",
      ifelse((data$Month >= 9) & (data$Month <= 11), "3", "4")
    )
  )
  data$full_result_id <- NULL
  data$result.result_id <- NULL
  data <- data %>% dplyr::select(contains(c(
    "location_id",
    "location_description",
    "sample_id",
    "date_taken",
    "season",
    "parameter",
    "question",
    "response",
    "label",
    "result_id",
    "units",
    "latitude",
    "longitude",
    "grid_reference",
    "Alkalinity",
    "river_width",
    "mean_depth",
    "boulders_cobbles",
    "pebbles_gravel",
    "sand",
    "silt_clay",
    "northing",
    "easting",
    "dist_from_source",
    "altitude",
    "Slope",
    "grid_reference",
    "discharge_category",
    "water_body_id",
    "water_body_type",
    "water_body"
  )))

  names(data) <- tolower(names(data))
  data <- utils::type.convert(data, as.is = TRUE)
  data$sample_id <- as.character(data$sample_id)
  data$response <- as.character(data$response)
  data$label.x <- NULL
  data <- tibble(data)
  return(data)
}
