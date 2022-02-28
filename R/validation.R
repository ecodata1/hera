#' Validation
#'
#' Validation of input data.
#' @details
#' \code{validation()} Validation
#'
#' @param data Dataframe of variables in WFD inter-change format
#'
#' @return Dataframe of validation messages
#' @examples
#' validations <- validation(demo_data)
#' @importFrom rlang .data
#' @importFrom tibble tibble
#' @importFrom dplyr group_by inner_join mutate select
#' @importFrom tidyr unnest nest
#' @importFrom magrittr `%>%`
#' @importFrom lubridate year
#' @importFrom purrr map
#' @export
validation <- function(data = NULL) {
  message("Hello from hera, ...work in progress!")

  if(any(names(data) %in% "sample_id")) {
    data$sample_id <- as.character(data$sample_id)
  }


  if(any(names(data) %in% "location_id")) {
    data$location_id <- as.character(data$location_id)
  }

  if(any(names(data) %in% "grid_reference") & any(!names(data) %in% "latitude")) {
    if(any(is.na(data$grid_reference))) {
      stop("You provided a grid_reference column with missing values
           - all rows must have values")
    } else {
    data$grid_reference <- trimws(data$grid_reference)
    data$grid_reference <- gsub(" ", "", data$grid_reference)
    latlon <- rict::osg_parse(data$grid_reference, coord_system = "WGS84")
    data$latitude <- latlon$lat
    data$longitude <- latlon$lon
    }
  }

  data$year <- year(data$date_taken)

  if(any(names(data) %in% "result_id")) {
    data <- data %>% select(-.data$result_id)
  }
  if(any(names(data) %in% "analysis_name")) {
    data <- data %>% select(-.data$analysis_name)
  }
  if(any(names(data) %in% "units")) {
    data <- data %>% select(-.data$units)
  }

  return(data)
}
