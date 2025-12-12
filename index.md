# hera

![Collage of hex logos for hera and related
packages](https://raw.githubusercontent.com/ecodata1/hera/main/man/figures/heraverse_logo_2.png)

WORK IN PROGRESS

Hera is a prototype package to explore the future of regulatory
environmental modelling. The package outlines approaches to creating a
shared research platform for building, testing and deploying models used
to assess environmental risk for regulatory purposes. See [Request for
comment](https://ecodata1.github.io/hera/articles/hera_specifications.html)
paper for an outline and broad technical specifications.

Hera is envisaged as an opinionated collections of R packages designed
for sharing environmental models. All packages share an underlying
design, grammar and data structure. This allows the separation of
concerns between data, models, post-modelling and visualisation.
Allowing greater collaboration and sharing of methods and tools.

[Heraclitus](https://en.wikipedia.org/wiki/Heraclitus):

> You Cannot Step Into the Same River Twice

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

Assess some demo data for various environmental risks:

``` r
library(hera)
data <- assess(hera::demo_data)
data[1:5, c("sample_id", "parameter", "question", "response")]
#> # A tibble: 5 × 4
#>   sample_id parameter              question          response        
#>   <chr>     <chr>                  <chr>             <chr>           
#> 1 1250462   Phytobenthos (diatoms) Alkalinity        121.9125401     
#> 2 1250462   Phytobenthos (diatoms) lake_TYPE         HA              
#> 3 1250462   Phytobenthos (diatoms) Total_count       312             
#> 4 1250462   Phytobenthos (diatoms) Percent_in_TDI5LM 99.3589743589744
#> 5 1250462   Phytobenthos (diatoms) N_TDI5LM          37
```

Alternatively, you can view the `catalogue` and select which assessments
to be run.

``` r
catalogue
#> # A tibble: 6 × 3
#>   assessment                data               assessment_function
#>   <chr>                     <list>             <list>             
#> 1 DARLEQ3                   <tibble [36 × 12]> <fn>               
#> 2 Bacterial Tufts           <tibble [10 × 12]> <fn>               
#> 3 Macroinvertebrate Metrics <tibble [22 × 10]> <fn>               
#> 4 Bankside Consistency      <tibble [17 × 12]> <fn>               
#> 5 MPFF Compliance           <tibble [34 × 10]> <fn>               
#> 6 RICT                      <tibble [30 × 12]> <fn>
```

Then select which assessment(s) you wish to run by name:

``` r
assessments <- assess(demo_data,
  name = c(
    "RICT",
    "Macroinvertebrate Metrics"
  )
)
assessments[1:5, c("sample_id", "parameter", "question", "response")]
#> # A tibble: 5 × 4
#>   sample_id parameter            question     response
#>   <chr>     <chr>                <chr>        <chr>   
#> 1 1672942   River Family Inverts sample_score 0       
#> 2 1672942   River Family Inverts ntaxa        1       
#> 3 1672942   River Family Inverts wfd_awic     0       
#> 4 1800006   River Family Inverts sample_score 0       
#> 5 1800006   River Family Inverts ntaxa        1
```

Heraclitus:

> Everything flows
