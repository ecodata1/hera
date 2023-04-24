#' Convert
#'
#' Convert input data into internal `hera` structure. This allows data from
#' different sources to be used as input.
#'
#' @param data Data as raw input from a number of sources
#'
#' @param convert_to Convert data to `hera` format by default. Currently, a
#'   reverse convert back to the original input format is not possible.
#' @param convert_from Specify the structure of the input data. This can be
#'   'sepa' or 'sepa_lims'. 'sepa' is the internal, historic reportable analysis
#'   results structure, 'lims' is the new results structure direct from the lab
#'   info system.
#'
#' @importFrom rlang .data
#' @importFrom tibble tibble
#' @importFrom dplyr filter group_by left_join summarise mutate_all select
#' @importFrom magrittr `%>%`
#' @importFrom utils read.csv
#' @return Dataframe in `hera` structure. See `demo_data`
#' @examples
#'  data <-
#' read.csv(system.file("extdat",
#'                     "demo-data/analysis-results-ecology.csv",
#'                     package = "hera"
#' ), check.names = FALSE)
#'
#' r <- convert(data, convert_from = "sepa")
#'
#' @export
convert <- function(data, convert_to = "hera", convert_from = "sepa_lims") {
  names <- read.csv(system.file("extdat",
    "column-names.csv",
    package = "hera"
  ))

  if (convert_to == "hera" & convert_from == "sepa") {
    names(data) <- tolower(names(data))
    # Add '_' if from data recover citrix app (web services doesn't need this)
    names(data) <- gsub(" ", "_", names(data))
    data$determinand[data$determinand == "Abundance"] <- "Taxon abundance"
    data$`analysis_name`[data$`analysis_repname` == "Diatom Taxa"] <- "River Diatoms"
    data$`analysis_name`[data$`analysis_repname` == "Invert Taxa Family Lab"] <- "River Family Inverts"
    # data$`analysis_name`[data$`analysis_repname` == "Invert Physical Data"] <- "Invert Physical Data"
    data$taxon_id <- NA
    data$determinand[data$determinand ==
                         "% Boulders/Cobbles"] <-  "boulders_cobbles"
    data$determinand[data$determinand ==
                         "% Pebbles/Gravel"] <-  "pebbles_gravel"
    data$determinand[data$determinand ==
                         "% Sand"] <- "sand"
    data$determinand[data$determinand ==
                         "% Silt/Clay"] <- "silt_clay"
    data$determinand[data$determinand ==
                         "River Width (m)"] <- "river_width"
    data$determinand[data$determinand ==
                         "Mean Depth (cm)"] <- "mean_depth"


    data$`nbn_code` <- as.character(data$`nbn_code`)
    data$taxon_id[!is.na(data$`nbn_code`)] <-
      data$`nbn_code`[!is.na(data$`nbn_code`)]
    # Current 'infolink' internally in SEPA is missing maitland_code column, so
    # make this optional for inclusion in the taxon_id column. Maitland code is
    # historic not currently required as a lookup for any assessments (so can
    # live without it).
    if (any(names(data) %in% "maitland_code")) {
      data$taxon_id[!is.na(data$`maitland_code`)] <-
        data$`maitland_code`[!is.na(data$`maitland_code`)]
      data <- data %>% select(
        -.data$`maitland_code`
      )
    }
    data$taxon_id[!is.na(data$`whitton_code`)] <-
      data$`whitton_code`[!is.na(data$`whitton_code`)]
    data$taxon_id[data$taxon_id == ""] <- NA
    data <- data %>% select(
      -.data$`whitton_code`,
      -.data$`nbn_code`
    )
    names(data) <- gsub(" ", "_", names(data))
    to_change <- which(names(data) %in% names$sepa_view[names$hera_latest != ""])
    change_to <- names$hera_latest[names$sepa_view %in% names(data) &
      names$hera_latest != ""]
    names(data)[to_change] <- change_to
    data <- data %>% mutate_all(as.character)
    data$date_taken <- as.Date(data$date_taken)
    return(data)
  }
  if (convert_to == "hera" & convert_from == "sepa_chem") {
    names(data) <- tolower(names(data))
    # Add '_' if from data recover citrix app (web services doesn't need this)
    names(data) <- gsub(" ", "_", names(data))

    to_change <- which(names(data) %in% names$sepa_chem[names$hera_latest != ""])
    change_to <- names$hera_latest[names$sepa_chem %in% names(data) &
                                     names$hera_latest != ""]
    names(data)[to_change] <- change_to
    data <- data %>% mutate_all(as.character)
    data$date_taken <- as.Date(data$date_taken)
    return(data)
  }

  if (convert_to == "hera" & convert_from == "sepa_lims") {
    data$SAMPLED_DATE <- as.Date(data$SAMPLED_DATE, format = "%d/%m/%Y")
    data$SAMPLED_DATE <- format.Date(data$SAMPLED_DATE, "%Y-%m-%d")
    # Add a label column for taxon name rows
    labels <- data %>%
      group_by(.data$TEST_NUMBER) %>%
      filter(.data$REPORTED_NAME == "Taxon name") %>%
      summarise(label = unique(.data$FORMATTED_ENTRY))
    data <- left_join(data, labels, by = "TEST_NUMBER")
    # Change records to match Hera standard
    data$REPORTED_NAME[data$REPORTED_NAME == "Abundance"] <- "Taxon abundance"

    data$REPORTED_NAME[data$REPORTED_NAME ==
                    "Pebbles/Gravel (2-64mm)"] <- "pebbles_gravel"
    data$REPORTED_NAME[data$REPORTED_NAME ==
                    "Sand (0.06-2mm)" ] <- "sand"
    data$REPORTED_NAME[data$REPORTED_NAME ==
                    "Silt/Clay (<0.06mm)" ] <- "silt_clay"
    data$REPORTED_NAME[data$REPORTED_NAME ==
                    "Boulders/Cobbles (>64mm)" ] <- "boulders_cobbles"
       data$REPORTED_NAME[data$REPORTED_NAME ==
                    "River Width"] <- "river_width"

    # Change column names to match hera standard
    changes <- names[names$sepa_lims != "" & names$hera_latest != "", ]
    data <- select(data, c(changes$sepa_lims, "label"))
    names(data) <- c(changes$hera_latest, "label")
    data <- data %>% mutate_all(as.character)
    data$date_taken <- as.Date(data$date_taken)
    data$analysis_repname <- data$parameter
    data$parameter[data$parameter == "RIVER_DIATOMS"] <- "River Diatoms"
    data$parameter[data$parameter == "LAB_INVERTS"] <- "River Family Inverts"
    data$parameter[data$parameter == "FW_INVERTS_FIELD"] <- "River Family Inverts"
    data$analysis_repname[data$analysis_repname == "FW_INVERTS_FIELD"] <- "Invert Physical Data"
    return(data)
  } else {
    message(paste("No conversion rules created for", convert_to, "/", convert_from))
    return(NULL)
  }
}
