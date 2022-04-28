PKGENVIR <- new.env(parent=emptyenv())
#' Launch hera app
#'
#' Launches hera shiny app with optional data and `catalogue`.
#'
#' @param data Dataframe of variables in WFD inter-change format
#' @param new_catalogue Dataframe of catalogue see `catalogue`
#' @return Shiny app
#' @examples
#' \dontrun{
#' launch_app()
#' }
#' @export
launch_app <- function(new_catalogue = NULL, data = NULL){

  if(!is.null(data)) {
    data <- hera::validation(data)
  } else {
    data <- hera::demo_data
  }
  PKGENVIR$data <- data
  if(!is.null(new_catalogue)) {
    PKGENVIR$new_catalogue <- new_catalogue
  }

  shiny::shinyAppDir(appDir = system.file("shiny_apps/heraapp",
                                          package = "hera"))
}
