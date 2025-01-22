mean_alkalinity <- function(data, sample_n = 10) {
  # standardise names case
  names(data) <- toupper(names(data))
  # Filter out chemistry
  ecology_results <- data[data$PARAMETER != "PAC" &
    data$QUESTION == "Taxon abundance", ]
  # only requiresd columns to save memory
  ecology_results <- ecology_results[, c(
    "SAMPLE_ID",
    "CHEMISTRY_SITE",
    "DATE_TAKEN"
  )]
  # Filter out  Chemistry results in descending date order so 10 most
  # recent samples will be selected
  alkalinity_results <- data[data$PARAMETER == "PAC", ]
  alkalinity_results <- data[data$QUESTION %in% c("Alkalinity",
                                                  "Alk as CaCO3 (mg/L)"), ]
  alkalinity_results$RESPONSE <- gsub("<|>", "", alkalinity_results$RESPONSE)
  # only required columns to save memory
  alkalinity_results <- alkalinity_results[, c(
    "SAMPLE_ID",
    "LOCATION_ID",
    "RESPONSE",
    "DATE_TAKEN"
  )]

  alkalinity_results$DATE_TAKEN <- as.Date(alkalinity_results$DATE_TAKEN)
  alkalinity_results <-
    alkalinity_results[order(dplyr::desc(alkalinity_results$DATE_TAKEN)), ]
  # Convert RESULT to numeric (not using VALUE to allow backward compatibility
  # with alkalininty query used in NEMS for TDI3 - DIAT_R_SUM)
  alkalinity_results$RESPONSE <- as.numeric(alkalinity_results$RESPONSE)
  # If less than or equal to 0, set to 1. - Alkalinity can very rarely be negative!
  alkalinity_results$RESPONSE[alkalinity_results$RESPONSE <= 0] <- 1
  alkalinity_results$RESPONSE <- as.numeric(alkalinity_results$RESPONSE)
  # Loop through each ecology sample and find matching Alk results --------
  get_alk_diatom <- function(ecology_results, alkalinity_results, sample_n) {
    alk <- purrr::map_df(
      split(
        ecology_results,
        ecology_results$SAMPLE_ID
      ),
      function(eco_sample) {
        # Find matching alk results (less than ecology sampled date) ---------
        alk_filtered <- alkalinity_results[alkalinity_results$LOCATION_ID ==
          unique(eco_sample$CHEMISTRY_SITE) &
          alkalinity_results$DATE_TAKEN <=
            unique(eco_sample$DATE_TAKEN), ]

        if (sample_n == "all") {
          sample_n <- length(alk_filtered$RESPONSE[!is.na(alk_filtered$RESPONSE)])
        }
        # Average up to last 10 samples
        alkalinity <- mean(alk_filtered$RESPONSE[1:sample_n], na.rm = T)

        # If no alk samples taken before ecology sampled date, then
        # average up to 10 chem samples taken after ecology sampled date.
        if (is.na(alkalinity) | is.nan(alkalinity) | length(alkalinity) == 0) {
          alkalinity_results <- alkalinity_results[order(alkalinity_results$DATE_TAKEN), ]
          alk_filtered <-
            alkalinity_results[alkalinity_results$LOCATION_ID ==
              unique(eco_sample$CHEMISTRY_SITE), ]
          if (sample_n == 0) {
            sample_n <- length(alk_filtered$RESPONSE[!is.na(alk_filtered$RESPONSE)])
          }
          alkalinity <- mean(alk_filtered$RESPONSE[1:sample_n], na.rm = T)
        }

        samples_used <- alk_filtered$RESPONSE[!is.na(alk_filtered$RESPONSE)]
        if (length(samples_used) > sample_n) {
          samples_used <- sample_n
        } else {
          samples_used <- length(samples_used)
        }
        mean_result <- data.frame(alkalinity)
        mean_result <- mean_result %>% dplyr::mutate(
          sample_number = unique(eco_sample$SAMPLE_ID),
          sample_count = length(alk_filtered$RESPONSE[!is.na(alk_filtered$RESPONSE)]),
          samples_used = samples_used,
          min_date = min(alk_filtered$DATE_TAKEN[1:sample_n], na.rm = T),
          max_date = max(alk_filtered$DATE_TAKEN[1:sample_n], na.rm = T)
        )
        # if no Alkalinity value will be NaN so check are return NA instead
        mean_result$alkalinity[is.nan(mean_result$alkalinity)] <- NA
        if (is.na(mean_result$alkalinity)) {
          return(NULL)
        }
        return(mean_result)
      },
      .progress = TRUE
    )
    return(alk)
  }
  alk <- get_alk_diatom(ecology_results, alkalinity_results, sample_n)
  return(alk)
}
