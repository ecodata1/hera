#' @importFrom rlang .data
#' @importFrom tibble tibble
#' @importFrom dplyr group_by inner_join mutate select arrange filter summarise ungroup mutate_all
#' @importFrom tidyr unnest nest pivot_wider pivot_longer
#' @importFrom magrittr `%>%`
#' @importFrom purrr map

darleq_classification <- function(data) {
  # 1. Prepare 'header'  dataframe ----------------------------------
  # include: SampleID, Site.Name, SAMPLE_DATE, Alkalinity

  if (any(names(data) %in% "alkalinity")) {
    data$alkalinity[is.na(data$alkalinity)] <- 75
  } else {
    data$alkalinity <- 75
  }
  data$alkalinity <- as.numeric(data$alkalinity)
  # Combine mean alkalinity with other site headers
  header <- data %>%
    mutate(
      "SampleID" = as.factor(.data$sample_id),
      "DATE_TAKEN" = as.Date(.data$date_taken, tz = "GB")
    ) %>%
    select(.data$SampleID,
      "SiteID" = .data$location_id,
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

  # 2. Prepare 'diatom_data' dataframe -------------------------------
  # - Include columns for each diatom ID (from taxon table)
  # - Values are abundances.
  # - row.names are SAMPLE_NUMBER.

  # DARES table
  # - must use table from NEMS - this links TAXON to TaxonId code
  dares_table <- darleq3::darleq3_taxa
  # Filter for taxon abundance only
  diatom_taxon_abundance <- data %>%
    filter(.data$question == "Taxon abundance")

  # Join to S_TAXON_DARES table using Taxon name.
  diatom_taxonname <- diatom_taxon_abundance %>%
    select(.data$sample_id, .data$taxon, .data$response, .data$date_taken) %>%
    inner_join(dares_table[, c("TaxonName", "TaxonId", "TaxonNameSEPA")],
      by = c("taxon" = "TaxonNameSEPA")
    )

  # Make sure numeric
  diatom_taxonname$response <- as.numeric(as.character(diatom_taxonname$response))
  # Sum value if duplicate taxon names entered within a single sample
  diatom_tidied <- diatom_taxonname %>%
    group_by(.data$sample_id, .data$TaxonId, .data$taxon, .data$date_taken) %>%
    summarise(response = sum(.data$response))
  # Arrange to keep in same order as 'taxon_names' data.frame
  diatom_tidied <- diatom_tidied %>%
    ungroup() %>%
    arrange(.data$taxon) %>%
    select(-.data$taxon)

  # DARLEQ3 requires Taxon IDs and Values pivoted into wide format
  diatom_data <- diatom_tidied %>% pivot_wider(
    names_from = .data$TaxonId,
    values_from = .data$response,
  )
  diatom_data[is.na(diatom_data)] <- 0

  # Arrange by sampled_date to match order of 'header' data frame.
  diatom_data <- arrange(diatom_data, .data$sample_id)
  # darleq3 requires row.names equal SAMPLE_NUMBER. Must convert
  # to be data.frame first (row.names deprecated on tibble).
  diatom_data <- data.frame(diatom_data, check.names = F)
  row.names(diatom_data) <- diatom_data$sample_id
  diatom_data <- select(diatom_data, -.data$sample_id, -.data$date_taken)

  # 3. Prepare 'taxon_names' dataframe ------------------------------
  # include columns 'TaxonId','TaxonName'
  taxon_names <- diatom_taxonname %>%
    select("TaxonCode" = .data$TaxonId, "TaxonName" = .data$TaxonName) %>%
    unique()

  taxon_names <- arrange(taxon_names, .data$TaxonName)

  # 4. Combine dataframes into named list ------------------------
  header <- data.frame(header)
  header <- header[header$SampleID %in% row.names(diatom_data), ]
  output <- darleq3::calc_Metric(diatom_data, metric = "TDI4")
  output <- darleq3::calc_EQR(output, header, truncate_EQR = TRUE, verbose = TRUE)
  output <- output$EQR
  output <- output %>%
    mutate_all(as.character)
  output <- output %>% pivot_longer(!SampleID,
    names_to = "assessment",
    values_to = "value"
  )
  output$index <- "TDI4"
  output$assessment <- as.character(output$assessment)
  output <- dplyr::filter(output, assessment %in% c(
    "EQR_TDI4",
    "Class_TDI4"
  ))
  output <- dplyr::select(output, !SampleID)
  if (any(is.na(output$value))) {
    output$value <- "NA"
  }
  return(output)
}
