
filter_samples <- function(data,
                           options = NULL,
                           classification_year_data = TRUE) {
 if(class(data$date_take) == "Date") {
  data <- mutate(data, year = lubridate::year(.data$date_taken))
 }
 else if(class(data$date_take) == "character") {
   data$year <- as.integer(substr(data$date_taken, 7, 10))
 } else {
   stop("date_taken must be either character or Date type in DD/MM/YYYY format")
 }

  # Create default option data frame if options not provided
  if (is.null(options)) {
    options <- tibble(
      classification_year = unique(max(data$year)),
      seasons = list(c("SPR", "AUT")),
      classification_window = 6,
      min_year = 1,
      max_year = 3,
      min_seasons = 2,
      max_seasons = 2,
      min_samples_per_season = 1,
      max_samples_per_season = 1,
      parameter = "River Family Inverts"
    )
  }

  # Filter to year and window
  data <- filter(data, .data$year <= options$classification_year &
    .data$year >= options$classification_year - options$classification_window + 1 &
    .data$parameter == options$parameter)

  # Make season
  data <- mutate(data, season = season(.data$date_taken, output = "shortname"))
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
    .data$season, .data$location_id,
  ) %>%
    dplyr::select(
      .data$sample_id,
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
    data <- group_by(data, .data$location_id) %>%
      mutate(max_year = max(.data$year))

    data <- filter(data, .data$max_year == options$classification_year)
  }
  return(data)
}
