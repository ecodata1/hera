#' Open hera web app
#'
#' Open hera as an interactive shiny web app.
#'
#' @details
#' \code{hera_app()} opens hera as an interactive shiny app.
#'
#' @importFrom shiny runApp
#'
#' @examples
#' \dontrun{
#' hera_app()
#' }
#'
#' @export

hera_app <- function() {
  appDir <- system.file("shiny_apps", "heraapp", package = "hera")
  if (appDir == "") {
    stop("Could not find example directory. Try re-installing `rict`.", call. = FALSE)
  }
  runApp(appDir, display.mode = "normal", launch.browser = TRUE)
}
