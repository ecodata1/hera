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
#' @importFrom dplyr rename select
#' @importFrom tidyr pivot_wider
#' @importFrom eadata get_observations get_taxa get_site_info
#' @importFrom tibble tibble
#' @importFrom magrittr `%>%`
#' @importFrom purrr map
#' @examples
#' data <- get_data(location_id = 92751)
#' class <- leafpacs::leafpacs(data)
get_data <- function(location_id = NULL, take = 10000, date_from = NULL, date_to = NULL) {
  location_id <- paste0("http://environment.data.gov.uk/ecology/site/bio/", location_id)
  obs <- get_observations(
    location_id,
    date_from = date_from,
    date_to = date_to,
    take = take
  )
  if(length(obs) == 0) {
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
                                       names_from = properties.property_label,
                                       values_from = properties.value
  )

  data <- dplyr::inner_join(obs, site_info_wide, by = c("site_id" = "site_id"))

  # Join properties of the observations ----------------------------------------
  properties <- eadata::get_properties()
  data <- dplyr::inner_join(data, properties, by = c("property_id" = "property"))
  sample_id <- strsplit(data$truncated_id, "/|-")
  sample_id <- map(sample_id, function(x) {
    x[2]
  })

  # Format columns --------------------------------------------------------------
  data$location_description <- data$label.y
  data$sample_id <- unlist(sample_id)


  data$grid_reference <- hera:::en_to_os(dplyr::select(data, easting, northing))
  data$grid_reference <- paste0(substr(data$grid_reference, 1 ,2),
                                " ",
                                substr(data$grid_reference, 3 ,6),
                                "0 ",
                                substr(data$grid_reference, 7 ,10),
                                "0")

  data$quality_element <- NA
  data$quality_element[data$obs_type == "http://environment.data.gov.uk/ecology/def/bio/RiverDiatTaxaObservation"] <- "River Diatoms"
  data$quality_element[data$obs_type == "http://environment.data.gov.uk/ecology/def/bio/RiverDiatMetricsObservation"] <- "River Diatoms"
  data$quality_element[data$obs_type == "http://environment.data.gov.uk/ecology/def/bio/RiverInvMetricsObservation"] <- "River Invertebrates"
  data$quality_element[data$obs_type == "http://environment.data.gov.uk/ecology/def/bio/RiverInvTaxaObservation"] <- "River Invertebrates"
  data$quality_element[data$obs_type == "http://environment.data.gov.uk/ecology/def/bio/RiverMacpMetricsObservation"] <- "River Macrophytes"
  data$quality_element[data$obs_type == "http://environment.data.gov.uk/ecology/def/bio/RiverMacpTaxaObservation"] <- "River Macrophytes"


  data$river_width <- data$Width
  data$mean_depth <- data$Depth
  data$boulders_cobbles <- data$`Boulders/Cobbles`
  data$pebbles_gravel <- data$`Pebbles/Gravel`
  data$sand <- data$Sand
  data$silt_clay <- data$`Silt/Clay`
  data$result_id <- data$obs_id
  data$dist_from_source <- data$`Distance from Source`
  data$source_altitude <- data$`Source Altitude`


  data <- data %>% dplyr::rename(
    "question" = label,
    "response" = simple_result,
    "date_taken" = date,
    "location_id" = site_id,
    "latitude" = lat,
    "longitude" = long
  )


  data$question[grep("unitsFound", data$result_id)] <- "Taxon abundance"
  data$question[grep("-percentageCoverBand", data$result_id)] <- "PercentageCoverBand"

  data$question[data$question == "WHPT_ASPT"] <- "WHPT ASPT Abund"
  data$question[data$question == "WPHT_N_TAXA"] <- "WHPT NTAXA Abund"
  data$question <- tolower(data$question)

  data$Month <- lubridate::month(data$date_taken)
  data$season <- ifelse((data$Month >= 3) & (data$Month <= 5), "1",
                        ifelse((data$Month >= 6) & (data$Month <= 8), "2",
                               ifelse((data$Month >= 9) & (data$Month <= 11), "3", "4")
                        )
  )


  data <- data %>% dplyr::select(contains(c("location_id",
                                            "location_description",
                                            "sample_id",
                                            "date_taken",
                                            "season",
                                            "quality_element",
                                            "question",
                                            "response",
                                            "pref_label",
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
                                            "result_id",
                                            "northing",
                                            "easting",
                                            "dist_from_source",
                                            "source_altitude",
                                            "Slope",
                                            "grid_reference"
  )) )


  names(data) <- tolower(names(data))

  data <- data %>% dplyr::rename(taxon = pref_label)
  data$sample_id <- as.character(data$sample_id)
  data <- tibble(data)
}
