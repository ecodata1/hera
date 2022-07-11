#' Calculate Season from Date
#'
#' @param dates
#' List of dates with class of Date
#' @param winter
#' Winter's start date
#' @param spring
#' Spring's start date
#' @param summer
#' Summer's start date
#' @param autumn
#' Autumn's start date
#' @param dates
#' List of dates with class of Date
#' @param output
#' Options: numeric, shortname, fullname
#' @return
#' List of seasons as numbers based on seasons required for RICT. Broadly
#' the sampling 'seasons' used for routine sampling
#' @export
#'
#' @examples
#' \dontrun{
#' season <- season(Sys.Date())
#' }
season <- function(dates,
                       winter = "2012-12-1",
                       spring = "2012-3-1",
                       summer = "2012-6-1",
                       autumn = "2012-9-1", output = "numeric") {
  WS <- as.Date(winter, format = "%Y-%m-%d") # Winter Solstice
  SE <- as.Date(spring, format = "%Y-%m-%d") # Spring Equinox
  SS <- as.Date(summer, format = "%Y-%m-%d") # Summer Solstice
  FE <- as.Date(autumn, format = "%Y-%m-%d") # Fall Equinox


  d <- as.Date(strftime(dates, format = "2012-%m-%d"))
  # Convert dates from any year to 2012 dates
  if (output == "numeric") {
    return(ifelse(d >= WS | d < SE, "4",
                  ifelse(d >= SE & d < SS, "1",
                         ifelse(d >= SS & d < FE, "2", "3")
                  )
    ))
  }

  if (output == "shortname") {
    return(ifelse(d >= WS | d < SE, "WIN",
                  ifelse(d >= SE & d < SS, "SPR",
                         ifelse(d >= SS & d < FE, "SUM", "AUT")
                  )
    ))
  }

  if (output == "fullname") {
    return(ifelse(d >= WS | d < SE, "Winter",
                  ifelse(d >= SE & d < SS, "Spring",
                         ifelse(d >= SS & d < FE, "Summer", "Autumn")
                  )
    ))
  }
}