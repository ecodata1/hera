# Development Guide

## Quick Start

To add a new assessment, install `hera` package.

    install.packages("devtools")
    devtools::install_github("aquaMetrics/hera", dependencies = TRUE)
    library(hera)

1.  Open a new File \> New File \> R Markdown
2.  Select ‘From Template’
3.  Search for ‘Assessment Template’ and open
4.  Change the `title: "Trophic Diatom Index"` title to match your
    assessment name
5.  Change the vignette entry
    `%\VignetteIndexEntry{Trophic Diatom Index}` to match the name of
    your assessment.
6.  Save the document using `name-of-your-assessment` format to the
    package vignette folder.

Congratulations! You now have a new assessment template ready to
populate.

Complete the following sections.

## Description

The first piece of information to add is details on what your assessment
is called and its status. This table shows the options to to choose from
and which fields are required.

| Columns    | Required | Details                                                                                                          |
|:-----------|:---------|:-----------------------------------------------------------------------------------------------------------------|
| name_short | TRUE     | Short name for assessment \< 26 characters for example an abbrivation like TDI                                   |
| name_long  | TRUE     | Long name for assessment                                                                                         |
| parameter  | TRUE     | Parameter or observation method being assessed for example Freshwater Diatoms, River Barriers or Estaurine Fish. |
| status     | FALSE    | Required - either: ‘prototype’, ‘development’,‘on-hold’, ‘consultation’,‘deprecated’ or ‘deployed’               |

#### Example

The code below creates a tibble/dataframe called ‘standard’ containing
metadata about the LEAFPACS parameter. This tibble will be later saved
into the ‘hera’ package for future reference.

Code:

``` r
description <- tribble(
  ~question, ~response,
  "name_short", "LEAFPACS",
  "name_long", "UKTAG River Assessment Method Macrophytes and Phytobenthos",
  "parameter", "River Macrophytes",
  "status", "testing"
)

description
```

    ## # A tibble: 4 × 2
    ##   question   response                                                  
    ##   <chr>      <chr>                                                     
    ## 1 name_short LEAFPACS                                                  
    ## 2 name_long  UKTAG River Assessment Method Macrophytes and Phytobenthos
    ## 3 parameter  River Macrophytes                                         
    ## 4 status     testing

## Input

Create a demo input data.

| Columns   | Required | Details                                                                                                                                    |
|:----------|:---------|:-------------------------------------------------------------------------------------------------------------------------------------------|
| sample_id | TRUE     | Sample ID for example 1234523                                                                                                              |
| question  | TRUE     | Question you have recorded a repsonse too                                                                                                  |
| response  | TRUE     | Example response                                                                                                                           |
| label     | FALSE    | Some question also have an associated ‘label’ for instance Taxon abundance will have a label for the Taxon name - is not required enter NA |
| …         | FALSE    | …                                                                                                                                          |

For example:

``` r
input <- tibble(
  sample_id = c("12345", "12345"),
  question = c("Taxon abundance", "Alkalinity"),
  response = c("12", "45"),
  label = c("Gomphonema olivaceum", NA),
  parameter = c("River Diatoms", "Chemistry"),
  type = c("number", "number"),
  max = c(NA, NA),
  min = c(NA, NA),
  source = c("sepa_ecology_results", "location_attributes")
)
input
```

    ## # A tibble: 2 × 9
    ##   sample_id question        response label    parameter type  max   min   source
    ##   <chr>     <chr>           <chr>    <chr>    <chr>     <chr> <lgl> <lgl> <chr> 
    ## 1 12345     Taxon abundance 12       Gomphon… River Di… numb… NA    NA    sepa_…
    ## 2 12345     Alkalinity      45       NA       Chemistry numb… NA    NA    locat…

## Assessment

This is where the magic happens…

Initially, it may be easier to write a placeholder for what you would
expect the function to return. An example of this is given in the
assessment template.

Your script must return a dataframe with three columns: `sample_id`,
`question` and `response`.

For instance, questions could be `EQR`, `Complaint`,
`Inspection Outcome`. And responses could be `0.6`, `TRUE`, `FAIL`.
`sample_id` will much your input data.

Using your input, write a function to assess your data. You may call on
a web service, import data for elsewhere, or run script from another
programming language (python, matlab etc).

## Outcome

This section display your outcome from the assessemnt function to show a
example outcome from your assessment.

## Checklist

**These final sections cover various check and test which don’t need to
be edited. However, they may indicate problems in your description,
input, assessment or outcomes.**

The data is formatted using the `hera_format` function to neatly present
within the documentation for this assessment.The `hera_format` function
will also check the data for errors or omissions.

``` r
standard_format <- hera:::hera_format(description = description) # format table
standard_format %>%
  knitr::kable()
```

[TABLE]

## Update

Access pre-existing metadata from within `hera` package. All metadata is
saved in the `catalogue` nested dataframe.

You may need to `unnest` the list columns to see all the information.

``` r
catalogue %>%
  filter(assessment == "Example") %>%
  unnest(data)
```

    ## # A tibble: 0 × 3
    ## # ℹ 3 variables: assessment <chr>, data <???>, assessment_function <list>

## Launch

TODO
