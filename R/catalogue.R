#' Catalogue of assessments
#'
#' A data frame containing descriptions, data and functions used by assessment
#' methods. This catalogue is automatically extended by knitting new assessment
#' vignettes and rebuilding the package.
#'
#' @format A data frame with 4 variables:
#' \describe{
#'   \item{assessment}{Name of assessment}
#'   \item{data}{List data frame describing the input and output data of the
#'   assessment}
#'   \item{assessment_function}{Assessment function that generates calculated
#'   output values}
#' }
#' @source Agency sampling data
"catalogue"
