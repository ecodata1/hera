# Calculate Season from Date

Calculate Season from Date

## Usage

``` r
season(
  dates,
  winter = "2012-12-1",
  spring = "2012-3-1",
  summer = "2012-6-1",
  autumn = "2012-9-1",
  output = "numeric"
)
```

## Arguments

- dates:

  List of dates with class of Date

- winter:

  Winter's start date

- spring:

  Spring's start date

- summer:

  Summer's start date

- autumn:

  Autumn's start date

- output:

  Options: numeric, shortname, fullname

## Value

List of seasons as numbers based on seasons required for RICT. Broadly
the sampling 'seasons' used for routine sampling

## Examples

``` r
if (FALSE) { # \dontrun{
season <- season(Sys.Date())
} # }
```
