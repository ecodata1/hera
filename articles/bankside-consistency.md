# Bankside Consistency

## Welcome

This document has been created following the generic [assessment
guidance](https://ecodata1.github.io/hera/articles/development_guide.html).

This is the Rapid Assessment Technique (RAT) for results from bankside
invertebrates analysis to check consistency with Water Body Status.

## Description

Basic details about the assessment.

| question   | response                                                        |
|:-----------|:----------------------------------------------------------------|
| name_short | Bankside Consistency                                            |
| name_long  | Rapid Assessment of Bankside Consistency with Water Body Status |
| parameter  | River Family Inverts                                            |
| status     | testing                                                         |
| type       | metric                                                          |

## Input

A list of questions required to run the assessment.

| location_id | sample_id | date_taken | question        | response | label    | parameter            |
|:------------|:----------|:-----------|:----------------|:---------|:---------|:---------------------|
| 206972      | 12345     | 2019-11-21 | Taxon abundance | 12       | Baetidae | River Family Inverts |
| 206972      | 54321     | 2025-11-21 | Live abundance  | 21       | Baetidae | BANKSIDE_INVERTS     |

## Assessment

Function code used to run this assessment.

Code

``` r
assessment_function <- function(data, ...) {
  # Some calculated a statistic...
  # Note, any non-standard base R library must be called using require().
  require(dplyr)
  require(tidyr)
  require(magrittr)
  require(tibble)
  require(whpt)
  require(macroinvertebrateMetrics)
  data$date_taken <- as.character(format.Date(data$date_taken, "%Y/%m/%d"))
  catalogue <- hera::catalogue
  metric_function <- catalogue[catalogue$assessment ==
    "Macroinvertebrate Metrics", 3][[1]]
  output <- metric_function[[1]](data)
  output <- filter(output, question %in% c("WHPT_ASPT", "WHPT_NTAXA"))
  predictors <- utils::read.csv(system.file("extdat",
    "gis-predictors.csv",
    package = "whpt"
  ), check.names = FALSE)

# Downgrade Typical class for testing worst-case scenario
#   predictors$`Typical ASPT Class`[predictors$`Typical ASPT Class` == "Poor"] <- "Bad"
#     predictors$`Typical ASPT Class`[predictors$`Typical ASPT Class` == "Moderate"] <- "Poor"
#       predictors$`Typical ASPT Class`[predictors$`Typical ASPT Class` == "Good"] <- "Moderate"
#         predictors$`Typical ASPT Class`[predictors$`Typical ASPT Class` == "Good"] <- "Moderate"
#           predictors$`Typical ASPT Class`[predictors$`Typical ASPT Class` == "High"] <- "Good"
# 
# 
# predictors$`Typical NTAXA Class`[predictors$`Typical NTAXA Class` == "Poor"] <- "Bad"
#     predictors$`Typical NTAXA Class`[predictors$`Typical NTAXA Class` == "Moderate"] <- "Poor"
#       predictors$`Typical NTAXA Class`[predictors$`Typical NTAXA Class` == "Good"] <- "Moderate"
#         predictors$`Typical NTAXA Class`[predictors$`Typical NTAXA Class` == "Good"] <- "Moderate"
#           predictors$`Typical NTAXA Class`[predictors$`Typical NTAXA Class` == "High"] <- "Good"

  
  predictors$location_id <- as.character(predictors$location_id)
  predict_data <- filter(predictors, location_id %in% unique(data$location_id))
  output_location <- inner_join(output,
    data[, c(
      "location_id",
      "sample_id",
      "date_taken"
    )],
    by = "sample_id",
    relationship = "many-to-many"
  )
  output_location$location_id <-
    as.character(output_location$location_id)
  whpt_input <- inner_join(output_location,
    predict_data,
    by = "location_id"
  )
  whpt_input$question[whpt_input$question == "WHPT_ASPT"] <-
    "WHPT ASPT Abund"
  whpt_input$question[whpt_input$question == "WHPT_NTAXA"] <-
    "WHPT NTAXA Abund"
  if (nrow(whpt_input) < 1) {
    return(NULL)
  } else {
    whpt_input <- unique(whpt_input)
    whpt_input$response <- as.numeric(whpt_input$response)
    consistency_check <- whpt::whpts(whpt_input)
    consistency_check$response <-
      as.character(consistency_check$response)
  }

report <- tidyr::pivot_wider(consistency_check, names_from = question, values_from = response)
vars <- c("location_id", "location_description", "sample_id", "date_taken")
location_ids <- dplyr::select(data, any_of(vars)) %>%  unique()
location_ids$season <- hera:::season(location_ids$date_taken, output = "shortname")
report <- inner_join(report, location_ids, by = join_by(sample_id))

new_predictors <- read.csv(
  system.file("extdat", "gis-predictors.csv", package = "whpt"),
  check.names = FALSE)

report <- dplyr::inner_join(report, new_predictors, by = join_by(location_id))

whpt_wide <- tidyr::pivot_wider(output, names_from = question, values_from = response)
report <- dplyr::inner_join(report, whpt_wide, by = join_by(sample_id))

vars <- c(
"water body sampled",
"sample_id", 
"date_taken",
"location_id",
"location_description",
"season",
"Reference NTAXA",
"Reference ASPT", 
"assessment",
"driver", 
"WHPT_NTAXA",
"WHPT_ASPT",
"Typical ASPT Class",
"Typical NTAXA Class",
"Reported WHPT Class Year"
)

report <- dplyr::select(report, any_of(vars))
vars <- c(
"season",
"Reference NTAXA",
"Reference ASPT", 
"assessment",
"driver", 
"WHPT_NTAXA",
"WHPT_ASPT",
"Typical ASPT Class",
"Typical NTAXA Class",
"Reported WHPT Class Year",
"water body sampled"
)
report$`water body sampled` <- as.character(report$`water body sampled`)
report$`Reported WHPT Class Year` <- as.character(report$`Reported WHPT Class Year`)
consistency_check <- pivot_longer(report, cols = all_of(vars), names_to = "question", values_to = "response")
 consistency_check$date_taken <- as.Date(consistency_check$date_taken)
  consistency_check$parameter <- "Bankside Consistency"
  return(consistency_check)
}
```

## Outcome

The outcome of your assessment.

| question                 | response                |
|:-------------------------|:------------------------|
| season                   | AUT                     |
| Reference NTAXA          | 21.14                   |
| Reference ASPT           | 7.32                    |
| assessment               | Likely problem detected |
| driver                   | ntaxa                   |
| WHPT_NTAXA               | 1                       |
| WHPT_ASPT                | 5.9                     |
| Typical ASPT Class       | Poor                    |
| Typical NTAXA Class      | Poor                    |
| Reported WHPT Class Year | 2013                    |
| water body sampled       | 23020                   |

## Check

Run checks on the assessment.

    #> Test passed with 1 success 🥇.
    #> Test passed with 1 success 🎉.

| check                    | value |
|:-------------------------|:------|
| standard_names           | TRUE  |
| standard_required        | TRUE  |
| standard_required_values | TRUE  |

## Update

Update the catalogue of assessments to make them available.

After **updating the catalogue, rebuild the package**, click on Build \>
Install and Restart menu or ‘Install and Restart’ button in the Build
pane.

## Test

This section tests if this assessment is usable using
[`assess()`](https://ecodata1.github.io/hera/reference/assess.md)
function.

## Launch app

Below is an interactive application displaying the results of your
assessment.
