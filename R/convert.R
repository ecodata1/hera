#' @importFrom rlang .data
#' @importFrom tibble tibble
#' @importFrom dplyr filter group_by left_join summarise mutate_all select
#' @importFrom magrittr `%>%`
#' @importFrom utils read.csv
convert <- function(data, convert_to = "hera", convert_from = "sepa_lims") {
  names <- read.csv(system.file("extdat",
    "column-names.csv",
    package = "hera"
  ))

  if (convert_to == "hera" & convert_from == "sepa") {
    data$taxon_id <- NA
    data$nbn_code <- as.character(data$nbn_code)
    data$taxon_id[!is.na(data$nbn_code)] <-
      data$nbn_code[!is.na(data$nbn_code)]
    data$taxon_id[!is.na(data$maitland_code)] <-
      data$maitland_code[!is.na(data$maitland_code)]
    data$taxon_id[!is.na(data$whitton_code)] <-
      data$whitton_code[!is.na(data$whitton_code)]

    to_change <- which(names(data) %in% names$sepa_view[names$hera_latest != ""])
    change_to <- names$hera_latest[names$sepa_view %in% names(data) &
      names$hera_latest != ""]
    names(data)[to_change] <- change_to
    return(data)
  }

  if (convert_to == "hera" & convert_from == "sepa_lims") {
    data$SAMPLED_DATE <- as.Date(data$SAMPLED_DATE,format =  "%d/%m/%Y" )
    data$SAMPLED_DATE <- format.Date(data$SAMPLED_DATE, "%Y/%m/%d")
    # Add a label column for taxon name rows
    labels <- data %>%
      group_by(.data$TEST_NUMBER) %>%
      filter(.data$REPORTED_NAME == "Taxon name") %>%
      summarise(label = unique(.data$FORMATTED_ENTRY))
    data <- left_join(data, labels, by = "TEST_NUMBER")
    # Change records to match Hera standard
    data$REPORTED_NAME[data$REPORTED_NAME == "Abundance"] <- "Taxon abundance"
    data$ANALYSIS[data$ANALYSIS == "RIVER_DIATOMS"] <- "River Diatoms"
    data$ANALYSIS[data$ANALYSIS == "LAB_INVERTS"] <- "River Family Inverts"
    # Change column names to match hera standard
    changes <- names[names$sepa_lims != "" & names$hera_latest != "", ]
    data <- select(data, c(changes$sepa_lims, "label"))
    names(data) <- c(changes$hera_latest, "label")
    data <- data %>% mutate_all(as.character)
    return(data)
  }
  else {
    message(paste("No conversion rules created for", convert_to, "/", convert_from))
    return(NULL)
  }

}
