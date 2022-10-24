



get_sepa_data <- function(location_id,
                          take,
                          date_from,
                          date_to,
                          year = NULL,
                          water_body_id = "",
                          dataset = "analytical_results") {
  message("Downloading data from SEPA internal only web services...")
  # Replocs query ------------------------------------------------------------
  if (dataset == "replocs") {
    data <- purrr::map_df(year, function(id) {
      stopifnot(!is.null(id))
      url <- parse_url("http://asb-app-asa01:8267/SEPAL/archive")
      url$path <-
        paste(url$path,
          "wfd/rep-locs",
          sep = "/"
        )

      site_url <- URLencode(URL = as.character(id), reserved = T)
      site_query <- paste0("year=", id)

      url$query <- site_query
      data <- purrr::map_df(water_body_id, function(id) {
        site_url <- URLencode(URL = as.character(id), reserved = T)
        query <- paste0(site_query, "&water-body=", id)
        url$query <- query
        request <- build_url(url)
        data <- jsonlite::fromJSON(request, flatten = TRUE)
        count <- data$count
        data <- data[["items"]]

        sepa_data_offset <- function(data,
                                     offset = 5000,
                                     query = NULL,
                                     sleep = 0.1,
                                     count_n = 5000,
                                     count = NULL) {
          while (count == count_n) {
            message(paste0("fetching records...", offset - count_n + 1, ":", offset))
            Sys.sleep(sleep)
            url$query <- paste(query, "&offset=", offset, sep = "")

            request <- build_url(url)
            offset_data <- jsonlite::fromJSON(request, flatten = TRUE)
            count <- offset_data$count
            offset_data <- offset_data[["items"]]

            n_offset <- count_n
            offset <- offset + n_offset
            data <- bind_rows(data, offset_data)
          }
          return(data)
        }
        data <- sepa_data_offset(data, count = count, query = url$query)
        Sys.sleep(0.1)
        return(data)
      })
      return(data)
    })
  } else if (dataset == "locations") {
    output <- purrr::map_df(location_id, function(id) {
      url <- parse_url("https://geospatial.cloudnet.sepa.org.uk/server/rest/services")
      url$path <-
        paste(url$path,
          "Hosted/All_Locations_22_12_2020_snapshot/FeatureServer/162/query",
          sep = "/"
        )
      url$query <- list(
        where = paste0(
          "LOCATION_CODE IN (",
          paste(id, collapse = ",", sep = ""),
          ")"
        ),
        outFields = "*",
        returnGeometry = "false",
        f = "geojson"
      )
      request <- build_url(url)
      geojson <- GET(request, cacert = FALSE) # skip server certificate check
      data <- suppressMessages(sf::st_read(geojson))
      data$hydro_code <- as.character(data$hydro_code)
      Sys.sleep(0.1)
      return(data)
    })
    return(output)
  } else if (dataset == "analytical_results") {
    # Analysis result query -----------------------------------------------------
    data <- purrr::map_df(location_id, function(id) {
      stopifnot(!is.null(id))
      url <- parse_url("http://asb-app-asa01:8267/SEPAL/archive")
      url$path <-
        paste(url$path,
          "analysis-results/ecology",
          sep = "/"
        )

      site_url <- URLencode(URL = as.character(id), reserved = T)
      site_query <- paste0("location=", id)

      url$query <- site_query

      request <- build_url(url)
      message(paste0("fetching records...1:5000 for ", id))
      data <- jsonlite::fromJSON(request, flatten = TRUE)
      count <- data$count
      data <- data[["items"]]
      offset <- 5000
      while (count == 5000) {
        Sys.sleep(0.1)
        message(paste0(
          "fetching records...",
          offset + 1, ":",
          offset, " for ",
          id
        ))
        url$query <- paste(site_query, "&offset=", offset, sep = "")

        request <- build_url(url)
        offset_data <- jsonlite::fromJSON(request, flatten = TRUE)
        count <- offset_data$count
        offset_data <- offset_data[["items"]]

        n_offset <- 5000
        offset <- offset + n_offset
        data <- bind_rows(data, offset_data)
      }
      data <- hera:::convert(data, convert_to = "hera", convert_from = "sepa")
      Sys.sleep(0.1)
      return(data)
    })
  } else {
    message(paste0(
      "You provided a `type =` argument of: ", type,
      "This didn't match any of the types supported e.g. 'locations', 'replocs'...etc"
    ))
    data <- NULL
  }
  return(data)
}
