PKGENVIR <- new.env(parent=emptyenv())
#' Launch hera app
#'
#' Launches hera shiny app with optional data and `model_dataframe`.
#'
#' @param data Dataframe of variables in WFD inter-change format
#' @param new_model_dataframe Dataframe of model_dataframe see `model_dataframe`
#' @return Shiny app
#' @examples
#' \dontrun{
#' launch_app()
#' }
#' @export
launch_app <- function(new_model_dataframe = NULL, data = NULL){

  if(!is.null(data)) {
    data <- hera::validation(data)
  } else {
    data <- hera::demo_data
  }
  PKGENVIR$data <- data
  if(!is.null(new_model_dataframe)) {
    PKGENVIR$new_model_dataframe <- new_model_dataframe
  }

  shiny::shinyAppDir(appDir = system.file("shiny_apps/heraapp",
                                          package = "hera"))
}
