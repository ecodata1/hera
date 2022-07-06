#' Example dataset of raw LIMS data
#
# A dataset containing raw ecology data from Lab Info System. This can be
# converted to standard `hera` format by `hera::convert(lims_data)`
#'
#' @format A data frame with 42 rows and 16 variables:
#' \describe{
#'   \item{ORIGINAL_SAMPLE}{ORIGINAL_SAMPLE ID}
#'   \item{SAMPLE_NUMBER}{SAMPLE_NUMBER}
#'   \item{SAMPLING_POINT}{SAMPLING_POINT}
#'   \item{DESCRIPTION}{DESCRIPTION}
#'   \item{STATUS}{STATUS}
#'   \item{LOCATION}{LOCATION}
#'   \item{ANALYSIS}{ANALYSIS}
#'   \item{REPORTED_NAME}{REPORTED_NAME}
#'   \item{FORMATTED_ENTRY}{FORMATTED_ENTRY}
#'   \item{UNITS}{UNITS}
#'   \item{SAMPLED_DATE}{SAMPLED_DATE}
#'   \item{TEMPLATE}{TEMPLATE}
#'   \item{SAMPLED_BY}{SAMPLED_BY}
#'   \item{REPORTABLE}{REPORTABLE}
#'   \item{FORMULATION}{FORMULATION}
#'   \item{TEST_NUMBER}{TEST_NUMBER}
#' }
#' @source Agency sampling data
"lims_data"