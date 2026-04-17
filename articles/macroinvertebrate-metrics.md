# Macroinvertebrate Metrics

## Welcome

This document has been created following the generic [assessment
guidance](https://ecodata1.github.io/hera/articles/development_guide.html).

## Description

Basic details about the assessment.

| question   | response                             |
|:-----------|:-------------------------------------|
| name_short | Macroinvertebrate Metrics            |
| name_long  | Freshwater Macroinvertebrate Metrics |
| parameter  | River Invertebrates                  |
| status     | testing                              |
| type       | metric                               |

## Input

A list of questions required to run this assessment.

| sample_id | question        | response | label    | parameter            |
|:----------|:----------------|:---------|:---------|:---------------------|
| 12345     | Taxon abundance | 12       | Baetidae | River Family Inverts |
| 12346     | Live abundance  | 12       | Baetidae | BANKSIDE_INVERTS     |

## Assessment

Function code used to run this assessment.

Code

``` r
assessment_function <- function(data, ...) {
  # Calculated invert metrics...
  # Note, any non-standard base R library must be call using require().
  require(dplyr)
  require(whpt)
  require(macroinvertebrateMetrics)
  input <- data
  input$label <- trimws(input$label)
  input <- dplyr::filter(
    input,
    parameter %in% c(
      "River Family Inverts",
      "BANKSIDE_INVERTS",
      "F_BMWP_TST",
      "MTL_TL4",
      "MTL_TL5"
    )
  )
  input <- dplyr::filter(input, question %in% c(
    "Taxon abundance",
    "Live abundance"
  ))
   if(nrow(input) < 1) {
     return(NULL)
   }
  input <- ungroup(input)
  input <- dplyr::select(
    input, "sample_id", "question", "response", "label", "parameter"
  )
  output <- macroinvertebrateMetrics::calc_metric(input, metrics = c("epsi", "riverfly", "whpt"))
  sample_details <- select(input, sample_id, parameter)
  sample_details <- distinct(sample_details)
  output <- dplyr::select(
    output, sample_id, question, response
  )
  output <- inner_join(output, sample_details, by = join_by(sample_id))

  return(output)
}
```

## Outcome

The outcome of your assessment.

    #> Loading required package: whpt
    #> 
    #> Attaching package: 'whpt'
    #> The following object is masked from 'package:hera':
    #> 
    #>     demo_data
    #> Loading required package: macroinvertebrateMetrics
    #> 
    #> Attaching package: 'macroinvertebrateMetrics'
    #> The following object is masked from 'package:whpt':
    #> 
    #>     demo_data
    #> The following object is masked from 'package:hera':
    #> 
    #>     demo_data

| question           | response                          |
|:-------------------|:----------------------------------|
| EPSI Score TL2     | 100                               |
| EPSI Condition TL2 | Minimally sedimented/unsedimented |
| Riverfly Score     | 2                                 |
| Riverfly NTAXA     | 1                                 |
| Riverfly ASPT      | 2                                 |
| WHPT_SCORE         | 5.9                               |
| WHPT_ASPT          | 5.9                               |
| WHPT_NTAXA         | 1                                 |
| WHPT_P_SCORE       | 5.5                               |
| WHPT_P_ASPT        | 5.5                               |
| WHPT_P_NTAXA       | 1                                 |

## Check

Run checks on the assessment.

    #> Test passed with 1 success 🥇.
    #> Test passed with 1 success 🎊.

| check                    | value |
|:-------------------------|:------|
| standard_names           | TRUE  |
| standard_required        | TRUE  |
| standard_required_values | TRUE  |

## Update

Update the catalogue of assessments to make them available.

    #> ✔ Setting active project to "/home/runner/work/hera/hera".
    #> ✔ Saving "catalogue" to "data/catalogue.rda".
    #> ☐ Document your data (see <https://r-pkgs.org/data.html>).

After **updating the catalogue, rebuild the package**, click on Build \>
Install and Restart menu or ‘Install and Restart’ button in the Build
pane.

## Test

This section tests if this assessment is usable using `assessment`
function.

## Launch app

Below is an interactive application displaying the results of your
assessment.
