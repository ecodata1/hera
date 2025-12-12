# Get data

Import data from web services and convert into standard format for hera
regulatory assessment tool.

## Usage

``` r
get_data(
  location_id = NULL,
  take = 10000,
  date_from = NULL,
  date_to = NULL,
  dataset = "analytical_results",
  year = NULL,
  water_body_id = "",
  source = "sepa"
)
```

## Arguments

- location_id:

  Unique ID of location.

- take:

  Number of observation to download. For "ea" API services.

- date_from:

  Start of date taken window in string format: "2013-12-31".

- date_to:

  End of date taken window in string format: "2015-12-31".

- dataset:

  Default will get Ecology monitoring data, set to "replocs" to
  represent location data for SEPA

- year:

  Classification year

- water_body_id:

  Water body ID used for replocs table queries.

- source:

  Which data source, either "ea" or "sepa". SEPA is internal access
  only.

## Value

Data frame

## Examples

``` r
if (FALSE) { # \dontrun{
data <- get_data(location_id = 1000, source = "ea")
class <- assessment(data)
} # }
```
