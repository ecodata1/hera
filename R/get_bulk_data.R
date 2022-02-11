#' Get Environment Agency demo data
#'
#' @return dataframe of demo data for testing
#' @export
#' @importFrom rlang .data
#' @importFrom dplyr inner_join select
#' @importFrom stats complete.cases
#' @importFrom magrittr `%>%`
#' @importFrom tibble tibble
#' @examples
#' \dontrun{
#' data <- get_demo_data()
#' }
get_bulk_data <- function() {
  message("Downloading bulk data from data.gov.uk...")
  # Download data ------------------------------------------------------------
  temp <- tempfile(fileext = ".zip")
  url = "https://environment.data.gov.uk/ecology/explorer/downloads/MACP_OPEN_DATA.zip"
  wd <- getwd()
  td <- tempdir()
  setwd(td)
  download.file(url, temp)
  unzip(temp)
  # f <- list.files()
  indices <- utils::read.csv( "MACP_OPEN_DATA_METRICS.csv")
  predictors <- utils::read.csv("MACP_OPEN_DATA_SITE.csv")
  taxa <- utils::read.csv("MACP_OPEN_DATA_TAXA.csv")

  # temp <- tempfile(fileext = ".zip")
  # url = "https://environment.data.gov.uk/ecology/explorer/downloads/OPEN_DATA_TAXON_INFO.zip"
  # wd <- getwd()
  # td <- tempdir()
  # setwd(td)
  # download.file(url, temp)
  # unzip(temp)
  # # f <- list.files()
  # taxa_info <- utils::read.csv("OPEN_DATA_TAXON_INFO.csv")

  setwd(wd)

  # Join and format data -------------------------------------------------------

  data <- inner_join(indices, predictors, by = "SITE_ID")
  data <- select(data, -.data$REPLICATE_CODE)
  data <- data %>% filter(complete.cases(data))
  names(data) <- tolower(names(data))
  data$location_description <- paste(data$site_id, ": ", data$water_body)
  data <- data %>% rename(
    location_id = .data$site_id,
    date_taken = .data$sample_date,
    water_body_id = .data$wfd_waterbody_id,
    grid_reference = .data$ngr_10_fig
  )

  # data$grid_reference <- paste0(
  #   substr(data$grid_reference, 1, 2),
  #   " ",
  #   substr(data$grid_reference, 3, 6),
  #   "0 ",
  #   substr(data$grid_reference, 7, 10),
  #   "0"
  # )

  # Format date to match observation web services
  data$date_taken <- as.Date(data$date_taken, "%d/%m/%Y" )
  data$date_taken <- as.Date(data$date_taken, "%Y-%m-%d" )

  data <- data %>% select(.data$location_id,
                          .data$sample_id,
                          .data$date_taken,
                          .data$rmni,
                          .data$rn_a_taxa,
                          .data$n_rfg,
                          .data$rfa_pc,
                          .data$alkalinity,
                          .data$source_altitude,
                          .data$dist_from_source,
                          .data$slope,
                          .data$water_body_id,
                          .data$grid_reference,
                          .data$location_description)

  data$parameter <- "River Macrophytes"

  data <- data %>% pivot_longer(
    cols = c(.data$rmni, .data$rn_a_taxa, .data$n_rfg, .data$rfa_pc),
    names_to = "question",
    values_to = "response"
  )

  data$sample_id <- as.character(data$sample_id)
  data$response <- as.character(data$response)

  data <- tibble(data)
  return(data)
}