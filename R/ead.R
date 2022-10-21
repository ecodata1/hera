#' @importFrom rlang .data
#' @importFrom tibble tibble
#' @importFrom dplyr rename inner_join left_join select
#' @importFrom tidyr unnest nest pivot_wider pivot_longer
#' @importFrom magrittr `%>%`
#' @importFrom lubridate month
ead <- function(site_id) {
  # Function to download EA data from data.gov.uk and convert into 'hera' format:
  # site_id = c(43378, 43296)
  site_id <- paste0("http://environment.data.gov.uk/ecology/site/bio/", site_id)
  obs <- eadata::get_observations(
    site_id,
    # type_id = "http://environment.data.gov.uk/ecology/def/bio/RiverInvMetricsObservation",
    date_from = "2013-01-01",
    date_to = "2015-12-31",
    take = 2000
  )
  if(length(obs) == 0) {
    return()
  }
  taxa <- eadata::get_taxa()
  ultimate_foi_id <- strsplit(obs$ultimate_foi_id, "/|-")
  ultimate_foi_id <- map(ultimate_foi_id, function(x) {
    x[7]
  })
  obs$ultimate_foi_id <- unlist(ultimate_foi_id)
  obs <- left_join(obs, taxa, by = c("ultimate_foi_id" = "notation"))
  site <- unique(obs$site_id)
  site_info <- eadata::get_site_info(site_id = site)
  site_info_wide <- pivot_wider(site_info,
    names_from = .data$properties.property_label,
    values_from = .data$properties.value
  )

  data <- inner_join(obs, site_info_wide, by = c("site_id" = "site_id"))
  properties <- eadata::get_properties()
  data <- inner_join(data, properties, by = c("property_id" = "property"))
  sample_id <- strsplit(data$truncated_id, "/|-")
  sample_id <- map(sample_id, function(x) {
    x[2]
  })

  data$location_description <- data$label.y
  data$sample_id <- unlist(sample_id)


  data$grid_reference <- en_to_os(dplyr::select(data,
                                                .data$easting,
                                                .data$northing))
  data$grid_reference <- paste0(substr(data$grid_reference, 1 ,2),
                               " ",
                               substr(data$grid_reference, 3 ,6),
                               "0 ",
                               substr(data$grid_reference, 7 ,10),
                               "0")
  data$river.width..m. <- data$Width
  data$mean.depth..cm. <- data$Depth
  data$x..boulders.cobbles <- data$`Boulders/Cobbles`
  data$x..pebbles.gravel <- data$`Pebbles/Gravel`
  data$x..sand <- data$Sand
  data$x..silt.clay <- data$`Silt/Clay`
  data$result_id <- data$obs_id
  data$quality_element <- NA
  data$quality_element[data$obs_type == "http://environment.data.gov.uk/ecology/def/bio/RiverDiatTaxaObservation"] <- "River Diatoms"
  data$quality_element[data$obs_type == "http://environment.data.gov.uk/ecology/def/bio/RiverDiatMetricsObservation"] <- "River Diatoms"
  data$quality_element[data$obs_type == "http://environment.data.gov.uk/ecology/def/bio/RiverInvMetricsObservation"] <- "River Invertebrates"
  data$quality_element[data$obs_type == "http://environment.data.gov.uk/ecology/def/bio/RiverInvTaxaObservation" &
                       data$taxonRank == "Family"] <- "River Family Inverts"
  data$quality_element[data$obs_type == "http://environment.data.gov.uk/ecology/def/bio/RiverMacpMetricsObservation"] <- "River Macrophytes"


  data <- data %>% rename(
    "question" = .data$label,
    "response" = .data$result.value,
    "date_taken" = .data$date,
    "location_id" = .data$site_id,
    "latitude" = .data$lat,
    "longitude" = .data$long
  )
  data$question[grep("unitsFound", data$result_id)] <- "Taxon abundance"
  data$question[data$question == "WHPT_ASPT"] <- "WHPT ASPT Abund"
  data$question[data$question == "WPHT_N_TAXA"] <- "WHPT NTAXA Abund"


  data$Month <- month(data$date_taken)
  data$season <- ifelse((data$Month >= 3) & (data$Month <= 5), "1",
    ifelse((data$Month >= 6) & (data$Month <= 8), "2",
      ifelse((data$Month >= 9) & (data$Month <= 11), "3", "4")
    )
  )



  data <- data %>% select(
    .data$location_id,
    .data$location_description,
    .data$sample_id,
    .data$date_taken,
    .data$season,
    .data$quality_element,
    .data$question,
    .data$response,
    .data$pref_label,
    .data$latitude,
    .data$longitude,
    .data$grid_reference,
    .data$Alkalinity,
    .data$river.width..m.,
    .data$mean.depth..cm.,
    .data$x..boulders.cobbles,
    .data$x..pebbles.gravel,
    .data$x..sand,
    .data$x..silt.clay,
    .data$result_id,
    .data$northing,
    .data$easting
  )

  data <- data %>% rename(taxon = .data$pref_label, alkalinity = .data$Alkalinity)

  # Predictions expected substrate/width etc results/ rows? todo (change hera expectations?)
  # prediction(data)
  return(data)
}
