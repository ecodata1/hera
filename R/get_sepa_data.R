



get_sepa_data <- function(location_id, take, date_from, date_to, year, water_body_id, type) {
  message("Downloading data from SEPA internal only web services...")
  # Replocs query ------------------------------------------------------------
  if (type == "replocs") {
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
        browser()
        site_url <- URLencode(URL = as.character(id), reserved = T)
        query <- paste0(site_query,"&water-body=", id)
        url$query <- query
      request <- build_url(url)
      data <- jsonlite::fromJSON(request, flatten = TRUE)
      count <- data$count
      data <- data[["items"]]
      offset <- 5000
      while (count == 5000) {
        message(paste0("fetching records...", offset-5000+1, ":", offset))
        Sys.sleep(0.1)
        url$query <- paste(url$query, "&offset=", offset, sep = "")

        request <- build_url(url)
        offset_data <- jsonlite::fromJSON(request, flatten = TRUE)
        count <- offset_data$count
        offset_data <- offset_data[["items"]]

        n_offset <- 5000
        offset <- offset + n_offset
        data <- bind_rows(data, offset_data)
      }

      Sys.sleep(0.1)
      return(data)
      })
      return(data)
    })
  }   else {
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
    data <- jsonlite::fromJSON(request, flatten = TRUE)
    count <- data$count
    data <- data[["items"]]
    offset <- 5000
    while (count == 5000) {
      Sys.sleep(0.1)
      url$query <- paste(url$query, "&offset=", offset, sep = "")

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
  }
  return(data)
}
