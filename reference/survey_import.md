# Import Survey Template

Import Survey Template

## Usage

``` r
survey_import(path = NULL)
```

## Arguments

- path:

  character file path to survey template

## Value

Data frame with 5 variables

- project_id:

  character project id

- sample_id:

  character sample id

- question:

  question - character question

- response:

  response - character response value

- label:

  label - Mainly used for labelling taxonomic observations

## Examples

``` r
if (FALSE) { # \dontrun{
file <- system.file("extdat",
  "survey-template/220421-SelfMon-N4952-CAV1-Enhanced.xlsx",
  package =
    "hera"
)
data <- survey_import(file)
} # }
```
