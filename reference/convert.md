# Convert

Convert input data into internal hera structure. This allows data from
different sources to be used as input.

## Usage

``` r
convert(data, convert_to = "hera", convert_from = "sepa_lims")
```

## Arguments

- data:

  Data as raw input from a number of sources

- convert_to:

  Convert data to hera format by default. Currently, a reverse convert
  back to the original input format is not possible.

- convert_from:

  Specify the structure of the input data. This can be 'sepa' or
  'sepa_lims'. 'sepa' is the internal, historic reportable analysis
  results structure, 'lims' is the new results structure direct from the
  lab info system.

## Value

Dataframe in hera structure. See \`demo_data\`

## Examples

``` r
if (FALSE) { # \dontrun{
data <-
  read.csv(system.file("extdat",
    "demo-data/analysis-results-ecology.csv",
    package = "hera"
  ), check.names = FALSE)

r <- convert(data, convert_from = "sepa")
} # }
```
