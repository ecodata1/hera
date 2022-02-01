
<!-- README.md is generated from README.Rmd. Please edit that file -->

# hera <img src='https://raw.githubusercontent.com/ecodata1/hera/main/man/figures/heraverse_logo_2.png' align="right" height="300" />

<!-- badges: start -->

[![Codecov test
coverage](https://codecov.io/gh/ecodata1/hera/branch/master/graph/badge.svg)](https://codecov.io/gh/ecodata1/hera?branch=master)
[![R build
status](https://github.com/ecodata1/hera/workflows/R-CMD-check/badge.svg)](https://github.com/ecodata1/hera/actions)
<!-- badges: end -->

WORK IN PROGRESS

Hera is a prototype package to explore the future of regulatory
environmental modelling. The package outlines possible approaches to
creating a shared research platform for building, testing and deploying
models used to assess environmental risk for regulatory purposes.

See [Request for
comment](https://ecodata1.github.io/hera/articles/hera_specifications.html)
paper for an outline and broad technical specifications.

Hera is envisaged as an opinionated collections of R packages designed
for sharing environmental models. All packages share an underlying
design, grammar and data structures. This allows the separation of the
concerns between data, models, post-modelling steps and visualisation.
Allowing greater collaboration and sharing of methods and tools.

## Installation

Install the development version from
[GitHub](https://github.com/ecodata1/hera) with:

``` r
# install.packages("devtools")
devtools::install_github("ecodata1/hera")
```

## Documentation

Read the [white paper article and documentation
website](https://ecodata1.github.io/hera/articles/hera_specifications.html)
(work in progress)

## Example

Classify some demo data for a number of different assessment parameters:

``` r
library(hera)
data <- hera(hera::demo_data)
data[1:5, c("sample_number", "quality_elements", "assessment", "value")]
#> # A tibble: 5 × 4
#> # Groups:   sample_number, quality_elements [4]
#>   sample_number quality_elements    assessment   value              
#>           <int> <chr>               <chr>        <chr>              
#> 1       3201863 River Invertebrates ""           ""                 
#> 2       3201863 River Diatoms       "EQR_TDI4"   "0.676305776770612"
#> 3       3201863 River Diatoms       "Class_TDI4" "Good"             
#> 4       3294945 River Invertebrates ""           ""                 
#> 5       3294945 River Diatoms       "EQR_TDI4"   "0.9829053877896"
```

Alternatively, breakdown each step in assessment chain:

``` r
library(hera)
validated <- validation(hera::demo_data) # Return validate data - placeholder function
indices <- indices(validated) # Calculate indices used for assessment (if required)
indices[1:5, ]
#> # A tibble: 5 × 24
#> # Groups:   sample_number, quality_elements [1]
#>   sample_number quality_elements  location_id location_descrip… easting northing
#>           <int> <chr>                   <int> <fct>               <dbl>    <dbl>
#> 1       3201863 River Invertebra…        8175 River Eden @ Kem…  341452   715796
#> 2       3201863 River Invertebra…        8175 River Eden @ Kem…  341452   715796
#> 3       3201863 River Invertebra…        8175 River Eden @ Kem…  341452   715796
#> 4       3201863 River Invertebra…        8175 River Eden @ Kem…  341452   715796
#> 5       3201863 River Invertebra…        8175 River Eden @ Kem…  341452   715796
#> # … with 18 more variables: latitude <dbl>, longitude <dbl>, date_taken <dttm>,
#> #   sample_id <int>, analysis_name <fct>, question <fct>, response <fct>,
#> #   units <fct>, taxon <fct>, mean_alkalinity <dbl>, result_id <chr>,
#> #   taxon_id <int>, grid_reference <chr>, standard <chr>,
#> #   quality_element <chr>, season <chr>, water_body_id <dbl>, indices <list>
predictions <- prediction(indices) # Predict the expected 
predictions[1:5, ]
#> # A tibble: 5 × 25
#> # Groups:   sample_number, quality_elements [1]
#>   sample_number quality_elements  location_id location_descrip… easting northing
#>           <int> <chr>                   <int> <fct>               <dbl>    <dbl>
#> 1       3201863 River Invertebra…        8175 River Eden @ Kem…  341452   715796
#> 2       3201863 River Invertebra…        8175 River Eden @ Kem…  341452   715796
#> 3       3201863 River Invertebra…        8175 River Eden @ Kem…  341452   715796
#> 4       3201863 River Invertebra…        8175 River Eden @ Kem…  341452   715796
#> 5       3201863 River Invertebra…        8175 River Eden @ Kem…  341452   715796
#> # … with 19 more variables: latitude <dbl>, longitude <dbl>, date_taken <dttm>,
#> #   sample_id <int>, analysis_name <fct>, question <fct>, response <fct>,
#> #   units <fct>, taxon <fct>, mean_alkalinity <dbl>, result_id <chr>,
#> #   taxon_id <int>, grid_reference <chr>, standard <chr>,
#> #   quality_element <chr>, season <chr>, water_body_id <dbl>, indices <list>,
#> #   prediction <list>
assessments <- classification(predictions) # Assess the observed data against the expected/predicted 
```
