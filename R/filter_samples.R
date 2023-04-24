#' @importFrom purrr map_df
#' @importFrom rlang .data
filter_samples <- function(data,
                           options = NULL,
                           classification_year_data = TRUE) {
  data <- dplyr::mutate(data, year = lubridate::year(.data$date_taken))
  # Create default option data frame if options not provided
  if (is.null(options)) {
    options <- tibble::tibble(
      seasons = c(list(c("SPR", "AUT")), list(c("SPR","SUM", "AUT"))),
      classification_window = c(6, 6),
      min_year = c(1, 1),
      max_year = c(3, 3),
      min_seasons = c(2, 2),
      max_seasons = c(2, 3),
      min_samples_per_season = c(1, 1),
      max_samples_per_season = c(1, 1),
      parameter = c("River Family Inverts", "River Diatoms")
    )
  }
  # Add classification year based on input data max year
  if(!any(names(options) %in% "classification_year")) {
    options$classification_year = unique(max(data$year))
  }
  # Loop through each parameter and apply parameter filters/options
  data_filtered <- purrr::map_df(split(options, options$parameter), function(options) {
    # Filter to year and window
    data <- dplyr::filter(data, .data$year <= options$classification_year &
      .data$year >= options$classification_year - options$classification_window + 1 &
      .data$parameter %in% options$parameter)

    if(nrow(data) < 1) {
      return(NULL)
    }

    # Make season
    data <- dplyr::mutate(data, season = season(.data$date_taken,
      output = "shortname"
    ))
    # ----------------------------------------
    # Filter samples with only matching seasons
    data <- dplyr::filter(data, .data$season %in% options$seasons[[1]])
    data <- dplyr::group_by(data, .data$year, .data$location_id) %>%
      dplyr::mutate(season_count = length(unique(.data$season)))
    data <- dplyr::filter(data, .data$season_count >= options$min_seasons &
      .data$season_count <= options$max_seasons)

    # If multiple samples from one season - filter to max_samples_per_season
    data <- dplyr::arrange(data, .data$date_taken)

    sample_order <- dplyr::group_by(
      data, .data$year,
      .data$season, .data$location_id, .data$analysis_repname
    ) %>%
      dplyr::select(
        .data$sample_id,
        .data$analysis_repname,
        .data$date_taken,
        .data$year,
        .data$season,
        .data$location_id
      ) %>%
      unique() %>%
      dplyr::mutate(
        sample_order = order(.data$date_taken, decreasing = FALSE)
      )

    sample_order <- dplyr::filter(
      sample_order,
      sample_order >= options$min_samples_per_season &
        sample_order <= options$max_samples_per_season
    )

    samples <- sample_order$sample_id
    data <- dplyr::filter(
      data,
      .data$sample_id %in% samples
    )

    # Filter max number of years
    years <- dplyr::ungroup(data) %>%
      dplyr::select(.data$location_id, .data$year) %>%
      unique() %>%
      dplyr::arrange(-year) %>%
      dplyr::group_by(.data$location_id) %>%
      dplyr::mutate(label = 1) %>%
      dplyr::mutate(label_CUM = cumsum(.data$label)) %>%
      dplyr::filter(.data$label_CUM <= options$max_year)

    data <- dplyr::inner_join(data,
      years[, c("location_id", "year")],
      by = c(
        "location_id" = "location_id",
        "year" = "year"
      )
    )

    # Filtering out years without correct number of seasons or samples may mean
    # classification year doesn't have any 'new' data. So check all locations have
    # some validate data from the classification year
    if (classification_year_data == TRUE) {
      data <- dplyr::group_by(data, .data$location_id) %>%
        dplyr::mutate(max_year = max(.data$year))

      data <- dplyr::filter(data, .data$max_year == options$classification_year)
    }
    return(data)
  })
  return(data_filtered)
}
