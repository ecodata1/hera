ead <- function(site_id) {
  # Function to download EA data from data.gov.uk and convert into 'hera' format:
  # site_id = 43378
  site_id <- paste0("http://environment.data.gov.uk/ecology/site/bio/", site_id)
  obs <- ead::get_observations(
    site_id,
   type_id = "http://environment.data.gov.uk/ecology/def/bio/RiverInvMetricsObservation")
   site <- unique(obs$site_id)
  site_info <- ead::get_site_info(site_id = site)
  site_info_wide <- tidyr::pivot_wider(site_info,
                               names_from = properties.property_label,
                               values_from = properties.value )

  data <- dplyr::inner_join(obs, site_info_wide, by = c("site_id" = "site_id"))

  properties <- ead::get_properties()

  data <- dplyr::inner_join(data, properties, by = c("property_id" = "property"))

  sample_id <- strsplit(data$truncated_id,"/|-")
  sample_id <- map(sample_id, function(x) {
    x[2]
  })
  data$sample_id <- unlist(sample_id)


  data$grid_reference <- "SK 567005 578905" # todo (change RICT?)
  data$river.width..m. <- data$Width
  data$mean.depth..cm. <- data$Depth
  data$x..boulders.cobbles <- data$`Boulders/Cobbles`
  data$x..pebbles.gravel <- data$`Pebbles/Gravel`
  data$x..sand <- data$Sand
  data$x..silt.clay <- data$`Silt/Clay`
  data$result_id <- data$obs_id

  data$quality_element <- "River Invertebrates"
  data <- data %>%  dplyr::rename("question" = label.y,
                           "response" = result.value,
                           "date_taken" = date,
                           "location_id" = site_id,
                           "latitude" = lat,
                           "longitude" = long
                           )

  data$question[data$question == "WHPT_ASPT"] <- "WHPT ASPT Abund"
  data$question[data$question == "WPHT_N_TAXA"] <- "WHPT NTAXA Abund"


  data$Month <- lubridate::month(data$date_taken)
  data$season <- ifelse((data$Month >= 3) & (data$Month <= 5), "1",
                        ifelse((data$Month >= 6) & (data$Month <= 8), "2",
                               ifelse((data$Month >= 9) & (data$Month <= 11), "3", "4")))

  data <- data %>% dplyr::select(location_id,
                          sample_id,
                          date_taken,
                          season,
                          quality_element,
                          question,
                          response,
                          location_id,
                          latitude,
                          longitude,
                          grid_reference,
                          river.width..m.,
                          mean.depth..cm.,
                          x..boulders.cobbles,
                          x..pebbles.gravel,
                          x..sand,
                          x..silt.clay,
                          result_id,
                          northing,
                          easting
                          )

  # Predictions expected substrate/width etc results/ rows? todo (change hera expectations?)
  # prediction(data)


 return(data)
}