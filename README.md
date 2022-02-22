
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
data[1:5, c("sample_id", "parameter", "question", "response")]
#> # A tibble: 5 × 4
#>   sample_id parameter         question response         
#>   <chr>     <chr>             <chr>    <chr>            
#> 1 1840203   River Macrophytes class    poor             
#> 2 1840203   River Macrophytes eqr      0.635381220416031
#> 3 1840203   River Macrophytes status   classified       
#> 4 1840203   River Macrophytes level    4                
#> 5 3256506   River Macrophytes class    bad
```

Alternatively, breakdown each step in assessment:

``` r
library(hera)
validated <- validation(hera::demo_data) # Return validate data - placeholder function
indices <- indices(validated) # Calculate indices used for assessment (if required)
indices[1:5, c("sample_id", "parameter", "question", "response")]
#> # A tibble: 5 × 4
#>   sample_id parameter         question  response        
#>   <chr>     <chr>             <chr>     <chr>           
#> 1 1840203   River Macrophytes rmni      7.07013957800168
#> 2 1840203   River Macrophytes rn_a_taxa 6               
#> 3 1840203   River Macrophytes n_rfg     4               
#> 4 1840203   River Macrophytes rfa_pc    0               
#> 5 3256506   River Macrophytes rmni      6.22099043940684
predictions <- prediction(validated) # Predict the expected 
predictions[1:5, c("sample_id", "parameter", "question", "response")]
#> # A tibble: 5 × 4
#>   sample_id parameter         question  response        
#>   <chr>     <chr>             <chr>     <chr>           
#> 1 3256506   River Macrophytes ref_taxa  8.18193000184553
#> 2 3256506   River Macrophytes ref_algae 0.05            
#> 3 3256506   River Macrophytes ref_nfg   5.26620315804775
#> 4 3256506   River Macrophytes ref_rmni  5.96735638218237
#> 5 758729    River Macrophytes ref_taxa  8.18193000184553
assessments <- assessment(hera::demo_data) # Assess the observed data against the expected/predicted 
assessments[1:5, c("sample_id", "parameter", "question", "response")]
#> # A tibble: 5 × 4
#>   sample_id parameter         question response         
#>   <chr>     <chr>             <chr>    <chr>            
#> 1 1840203   River Macrophytes class    poor             
#> 2 1840203   River Macrophytes eqr      0.635381220416031
#> 3 1840203   River Macrophytes status   classified       
#> 4 1840203   River Macrophytes level    4                
#> 5 3256506   River Macrophytes class    bad
```
