#' @importFrom utils URLencode
#' @importFrom stats na.omit
#' @importFrom httr parse_url
#' @importFrom rlang .data
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
            message(paste0(
              "fetching records...",
              offset - count_n + 1, ":", offset
            ))
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
    loops <- seq_len(floor(length(location_id) / 50))
    if(length(loops) == 0) {
      loops <- 1
    }
    output <- purrr::map_df(loops, function(loop) {
      max <- loop * 50
      min <- max - 49
      id <- location_id[min:max]
      id <- id[!is.na(id)]
      if (length(id) == 0) {
        return(NULL)
      }

      message(paste0("Downloading locations: ",
                     location_id[min],
                     " - ",
                     location_id[max]))
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
      data <- sf::st_read(geojson, quiet = TRUE)
      # remove rows with missing columns data
      if(!any(names(data) %in% "validated")) {
        return(NULL)
      }
      # remove rows with missing data
      # filter out rows with missing validate data
      data <- dplyr::filter(data, !is.na(.data$validated))
      # if remaining rows have latitude not numeric - return NULL
      if(class(data$latitude) == "character") {
        return(NULL)
      }
      # if data missing needs to be converted to numeric to match other rows
       data$river_number <- as.numeric(data$river_number)
       data$hydro_code <- as.numeric(data$hydro_code)
       data$hydro_distance <- as.numeric(data$hydro_distance)
       data$catchment_id <- as.numeric(data$catchment_id)
       # convert to tibble for nice formatting
      data <- tibble::as_tibble(data)
      Sys.sleep(0.1)
      return(data)
    })
    return(output)
  } else if (dataset == "sampling_points") {
    loops <- seq_len(floor(length(location_id) / 50))
    if(length(loops) == 0) {
      loops <- 1
    }
    output <- purrr::map_df(loops, function(loop) {
      max <- loop * 50
      min <- max - 49
      id <- location_id[min:max]
      id <- id[!is.na(id)]
      if (length(id) == 0) {
        return(NULL)
      }

      message(paste0("Downloading locations: ",
                     location_id[min],
                     " - ",
                     location_id[max]))
      url <- parse_url("https://geospatial.cloudnet.sepa.org.uk/server/rest/services")
      url$path <-
        paste(url$path,
              "Sampling_points/MapServer/0/query",
              sep = "/"
        )
      url$query <- list(
        where = paste0(
          "sampling_point IN (",
          paste(id, collapse = ",", sep = ""),
          ")"
        ),
        outFields = "*",
        returnGeometry = "false",
        f = "geojson"
      )
      request <- build_url(url)
      geojson <- GET(request, cacert = FALSE) # skip server certificate check
      data <- sf::st_read(geojson, quiet = TRUE)
      # remove rows with missing columns data
      # if(!any(names(data) %in% "validated")) {
      #   return(NULL)
      # }
      # remove rows with missing data
      # filter out rows with missing validate data
      # data <- dplyr::filter(data, !is.na(.data$validated))
      # if remaining rows have latitude not numeric - return NULL
      # if(class(data$latitude) == "character") {
      #   return(NULL)
      # }
      # if data missing needs to be converted to numeric to match other rows

      # convert to tibble for nice formatting
      data <- tibble::as_tibble(data)
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
        n_offset <- 5000
        message(paste0(
          "fetching records...",
          offset + 1, ":",
          offset + offset, " for ",
          id
        ))
        url$query <- paste(site_query, "&offset=", offset, sep = "")

        request <- build_url(url)
        offset_data <- jsonlite::fromJSON(request, flatten = TRUE)
        count <- offset_data$count
        offset_data <- offset_data[["items"]]


        offset <- offset + n_offset
        data <- bind_rows(data, offset_data)
      }
      # If no data found set to NULL (data could return an empty list at this
      # point)
      if (length(data) == 0) {
        return(NULL)
      } else {
        data <- convert(data, convert_to = "hera", convert_from = "sepa")
        Sys.sleep(0.1)
      }
      return(data)
    })
  } else if (dataset == "chem_analytical_results") {
    data <- purrr::map_df(location_id, function(id) {
      stopifnot(!is.null(id))
      url <- parse_url("http://asb-app-asa01:8267/SEPAL/archive")
      url$path <- paste(url$path, "analysis-results/chemistry",
        sep = "/"
      )
      site_url <- URLencode(URL = as.character(id), reserved = T)
      site_query <- paste0("location=", id)
      url$query <- site_query
      request <- build_url(url)
      message(paste0(
        "fetching records...1:5000 for ",
        id
      ))
      data <- jsonlite::fromJSON(request, flatten = TRUE)
      count <- data$count
      data <- data[["items"]]
      data$sign <- as.character(data$sign)
      data$loq_sign <- as.character(data$loq_sign)
      offset <- 5000
      while (count == 5000) {
        Sys.sleep(0.2)
        n_offset <- 5000
        message(paste0("fetching records...", offset +
          1, ":", offset + offset, " for ", id))
        url$query <- paste(site_query, "&offset=", offset,
          sep = ""
        )
        request <- build_url(url)
        offset_data <- jsonlite::fromJSON(request, flatten = TRUE)
        count <- offset_data$count
        offset_data <- offset_data[["items"]]
        offset <- offset + n_offset
        # Convert sing/loq_sign to character (appears to be variation in results
        # between character and logical)
        offset_data$sign <- as.character(offset_data$sign)
        data$sign <- as.character(data$sign)
        offset_data$loq_sign <- as.character(offset_data$loq_sign)
        data$loq_sign <- as.character(data$loq_sign)
        data <- bind_rows(data, offset_data)
      }
      if (length(data) == 0 | length(data$loq_sign) == 0) {
        return(NULL)
      }
      data <- data[data$determinand_code == "200200_2", ]
      Sys.sleep(0.2)
      # else {
      #   data <- convert(data, convert_to = "hera", convert_from = "sepa")
      #   Sys.sleep(0.1)
      # }
      return(data)
    })
  } else {
    message(paste0(
      "You provided a `type =` argument of: ", dataset,
      "This didn't match any of the dataset supported e.g. 'locations', 'replocs'...etc"
    ))
    data <- NULL
  }
  return(data)
}
