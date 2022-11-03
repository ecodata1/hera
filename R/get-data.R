#' Get data
#'
#' Import data from web services and convert into standard format for `hera`
#' regulatory assessment tool.
#'
#' @param location_id Unique ID of location.
#' @param take Number of observation to download. For "EA" API services.
#' @param date_from Start of date taken window in string format: "2013-12-31".
#' @param date_to End of date taken window in string format: "2015-12-31".
#' @param dataset Default will get Ecology monitoring data, set to "replocs" to
#'   represent location data for SEPA
#' @param year Classification year
#' @param water_body_id Water body ID used for replocs table queries.
#' @param source Which data source, either "EA or "SEPA". SEPA is internal access
#'   only.
#'
#' @return Data frame
#' @export
#' @importFrom rlang .data
#' @importFrom dplyr rename select contains
#' @importFrom tidyr pivot_wider
#' @importFrom eadata get_observations get_taxa get_site_info
#' @importFrom tibble tibble
#' @importFrom magrittr `%>%`
#' @importFrom purrr map
#' @importFrom httr GET parse_url build_url
#' @examples
#' \dontrun{
#' data <- get_data(location_id = 1000, source = "ea")
#' class <- assessment(data)
#' }
get_data <- function(location_id = NULL,
                     take = 10000,
                     date_from = NULL,
                     date_to = NULL,
                     dataset = "analytical_results",
                     year = NULL,
                     water_body_id = "",
                     source = "sepa") {
  if (source == "ea") {
    data <- get_ea_data(location_id, take, date_from, date_to)
  }

  if (source == "sepa") {
    data <- get_sepa_data(
      location_id,
      take,
      date_from,
      date_to,
      year,
      water_body_id,
      dataset
    )
  }

  return(data)
}
