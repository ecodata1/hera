#' Get data
#'
#' Import data from web services (currently EA only) and convert into standard
#' format for `hera` regulatory assessment tool.
#'
#' @param location_id Unique ID of location.
#' @param take Number of observation to download.
#' @param date_from Start of date taken window in string format: "2013-12-31".
#' @param date_to End of date taken window in string format: "2015-12-31".
#'
#' @return Data frame
#' @export
#' @importFrom rlang .data
#' @importFrom dplyr rename select contains
#' @importFrom tidyr pivot_wider
#' @importFrom eadata get_observations get_taxa get_site_info
#' @importFrom tibble tibble
#' @importFrom magrittr `%>%`
#' @importFrom purrr map
#' @examples
#' \dontrun{
#' data <- get_data(location_id = 100)
#' class <- assessment(data)
#' }
get_data <- function(location_id = NULL, take = 10000, date_from = NULL, date_to = NULL) {
  message("Downloading data from data.gov.uk web services...")
  location_id <- paste0("http://environment.data.gov.uk/ecology/site/bio/", location_id)
  obs <- get_observations(
    location_id,
    date_from = date_from,
    date_to = date_to,
    take = take
  )
  if (length(obs) == 0) {
    return()
  }

  # Join taxa table -------------------------------------------------------------
  taxa <- get_taxa()

  ultimate_foi_id <- strsplit(obs$ultimate_foi_id, "/|-")
  ultimate_foi_id <- map(ultimate_foi_id, function(x) {
    x[7]
  })

  obs$ultimate_foi_id <- unlist(ultimate_foi_id)
  obs <- dplyr::left_join(obs, taxa, by = c("ultimate_foi_id" = "notation"))

  # Join site info --------------------------------------------------------------
  site <- unique(obs$site_id)

  site_info <- get_site_info(site_id = site)
  site_info_wide <- tidyr::pivot_wider(site_info,
    names_from = .data$properties.property_label,
    values_from = .data$properties.value
  )

  site_info_wide$location_description <-  site_info_wide$label
  site_info_wide$label <- NULL
  data <- dplyr::inner_join(obs, site_info_wide, by = c("site_id" = "site_id"))

  # Join properties of the observations ----------------------------------------
  properties <- eadata::get_properties()
  data <- dplyr::inner_join(data, properties, by = c("property_id" = "property"))

  # Format columns --------------------------------------------------------------
  sample_id <- strsplit(data$truncated_id, "/|-")
  sample_id <- map(sample_id, function(x) {
    x[2]
  })
  data$sample_id <- unlist(sample_id)

  data$grid_reference <- en_to_os(select(data, .data$easting, .data$northing))
  data$grid_reference <- paste0(
    substr(data$grid_reference, 1, 2),
    " ",
    substr(data$grid_reference, 3, 6),
    "0 ",
    substr(data$grid_reference, 7, 10),
    "0"
  )

  data$parameter <- NA
  data$parameter[data$obs_type == "http://environment.data.gov.uk/ecology/def/bio/RiverDiatTaxaObservation"] <- "River Diatoms"
  data$parameter[data$obs_type == "http://environment.data.gov.uk/ecology/def/bio/RiverDiatMetricsObservation"] <- "River Diatoms"
  data$parameter[data$obs_type == "http://environment.data.gov.uk/ecology/def/bio/RiverInvMetricsObservation"] <- "River Invertebrates"
  data$parameter[data$obs_type == "http://environment.data.gov.uk/ecology/def/bio/RiverInvTaxaObservation"] <- "River Invertebrates"
  data$parameter[data$obs_type == "http://environment.data.gov.uk/ecology/def/bio/RiverMacpMetricsObservation"] <- "River Macrophytes"
  data$parameter[data$obs_type == "http://environment.data.gov.uk/ecology/def/bio/RiverMacpTaxaObservation"] <- "River Macrophytes"

  data <- data %>% dplyr::rename(
    "question" = .data$label.y,
    "response" = .data$simple_result,
    "date_taken" = .data$date,
    "location_id" = .data$site_id,
    "latitude" = .data$lat,
    "longitude" = .data$long,
    "sand" = .data$Sand,
    "water_body_id" = .data$`WFD Waterbody ID`,
    "water_body_type" = .data$`Waterbody Type`,
    "water_body" = .data$`Water Body`,
    "river_width" = .data$Width,
    "mean_depth" = .data$Depth,
    "boulders_cobbles" = .data$`Boulders/Cobbles`,
    "pebbles_gravel" = .data$`Pebbles/Gravel`,
    "silt_clay" = .data$`Silt/Clay`,
    "result_id" = .data$obs_id,
    "dist_from_source" = .data$`Distance from Source`,
    "source_altitude" = .data$`Source Altitude`,
    "label" = .data$pref_label,
    "units" = .data$property_id
  )

  data$question[grep("-percentageCoverBand", data$result_id)] <-
    "PercentageCoverBand"
  data$question[data$question == "WHPT_ASPT"] <- "WHPT ASPT Abund"
  data$question[data$question == "WPHT_N_TAXA"] <- "WHPT NTAXA Abund"
  data$question <- tolower(data$question)
  data$question[grep("unitsFound", data$result_id)] <- "Taxon abundance"
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
    "water_body_id",
    "water_body_type",
    "water_body"
  )))

  names(data) <- tolower(names(data))
  data <- utils::type.convert(data, as.is = TRUE)
  data$sample_id <- as.character(data$sample_id)
  data$label.x <- NULL
  data <- tibble(data)
  return(data)
}
