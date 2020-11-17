#' @importFrom rlang .data
#' @importFrom tibble tibble
#' @importFrom dplyr group_by inner_join mutate select arrange filter summarise ungroup
#' @importFrom tidyr unnest nest pivot_wider
#' @importFrom magrittr `%>%`
#' @importFrom purrr map

darleq_indices <- function(data) {
  # Make list of 3 data frames matching the data structure produced
  # by darleq3::read_DARLEQ()

  # 1. Prepare data frame of 'header' ----------------------------------
  # include: SampleID, Site.Name, SAMPLE_DATE, Alkalinity

  data$alkalinity <- 75
  # Combine mean alkalinity with other site headers
  header <- data %>%
    mutate(
      "SampleID" = as.factor(.data$sample_id),
      "DATE_TAKEN" = as.Date(.data$date_taken, tz = "GB")
    ) %>%
    select(.data$SampleID,
      "SiteID" = .data$location_code,
      "SAMPLE_DATE" = .data$date_taken,
      "Alkalinity" = .data$alkalinity
    ) %>%
    unique()

  # Loch samples also require an Alkalinity 'type';
  # 'HA' - High Alkalninty etc
  # This will be ignored if running river classification
  header$lake_TYPE <- NA
  header$lake_TYPE[header$Alkalinity > 50] <- "HA"
  header$lake_TYPE[header$Alkalinity >= 10 &
    header$Alkalinity <= 50] <- "MA"
  header$lake_TYPE[header$Alkalinity < 10] <- "LA"

  header$SiteID <- as.character(header$SiteID)
  ## Important: Arrange to match order of 'diatom_data' data frame.
  header <- arrange(header, .data$SampleID)

  # 2. Prepare dataframe of 'diatom_data' -------------------------------
  # - Include columns for each diatom ID (from NEMS Dares table)
  # - Values are abundances.
  # - row.names are SAMPLE_NUMBER.

  # DARES table
  # - must use table from NEMS - this links TAXON to TAXONLD code
  dares_table <- darleq3::darleq3_taxa
  # Filter for taxon abundance only
  diatom_taxon_abundance <- data %>%
    filter(.data$determinand == "Taxon abundance")

  # Join to S_TAXON_DARES table using Taxon name.
  diatom_taxonname <- diatom_taxon_abundance %>%
    select(.data$sample_id, .data$taxon, .data$value, .data$date_taken) %>%
    inner_join(dares_table[, c("TaxonName", "TaxonId", "TaxonNameSEPA")],
      by = c("taxon" = "TaxonNameSEPA")
    )

  # Sum value if duplicate taxon names entered within a single sample
  diatom_tidied <- diatom_taxonname %>%
    group_by(.data$sample_id, .data$TaxonId, .data$taxon, .data$date_taken) %>%
    summarise(value = sum(.data$value))
  # Arrange to keep in same order as 'taxon_names' data.frame
  diatom_tidied <- diatom_tidied %>%
    ungroup() %>%
    arrange(.data$taxon) %>%
    select(-.data$taxon)

  # DARLEQ3 requires Taxon IDs and Values pivoted into wide format
  diatom_data <- diatom_tidied %>% pivot_wider(
    names_from = .data$TaxonId,
    values_from = .data$value,
  )
  diatom_data[is.na(diatom_data)] <- 0

  # Arrange by sampled_date to match order of 'header' data frame.
  diatom_data <- arrange(diatom_data, .data$sample_id)
  # darleq3 requires row.names equal SAMPLE_NUMBER. Must convert
  # to be data.frame first (row.names deprecated on tibble).
  diatom_data <- data.frame(diatom_data, check.names = F)
  row.names(diatom_data) <- diatom_data$sample_id
  diatom_data <- select(diatom_data, -.data$sample_id, -.data$date_taken)

  # 3. Prepare dataframe of 'taxon_names'  ------------------------------
  # include columns 'TaxonCode','TaxonName'
  taxon_names <- diatom_taxonname %>%
    select("TaxonCode" = .data$TaxonId, "TaxonName" = .data$TaxonName) %>%
    unique()

  taxon_names <- arrange(taxon_names, .data$TaxonName)

  # Combine dataframes into named list ------------------------
  header <- data.frame(header)
  output <- darleq3::calc_Metric(diatom_data, metric = "TDI4")
  output <- darleq3::calc_EQR(output, header, truncate_EQR = TRUE, verbose = TRUE)
  return(output$EQR$TDI4)
}
