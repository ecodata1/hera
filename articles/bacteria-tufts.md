# Bacteria Tufts

## Welcome

This document has been created following the generic [assessment
guidance](https://ecodata1.github.io/hera/articles/development_guide.html).

## Description

Basic details about the assessment. Update the ‘response’ values as
required.

    #> # A tibble: 5 × 2
    #>   question   response              
    #>   <chr>      <chr>                 
    #> 1 name_short Bacterial Tufts       
    #> 2 name_long  Bacterial Tufts Metric
    #> 3 parameter  SEWAGE_FUNGUS         
    #> 4 status     prototype             
    #> 5 type       metric

## Input

A list of questions required to run the assessment.

    #> # A tibble: 2 × 11
    #>   location_id sample_id date_taken question response label parameter type  max  
    #>   <chr>       <chr>     <date>     <chr>    <chr>    <lgl> <chr>     <chr> <lgl>
    #> 1 8175        12345     2019-11-21 Sewage … <30%     NA    SEWAGE_F… char… NA   
    #> 2 8175        12345     2019-11-21 Sewage … Thin     NA    SEWAGE_F… char… NA   
    #> # ℹ 2 more variables: min <lgl>, source <chr>

## Assessment

If applicable, write a function to assess your input data and return an
outcome. For example, a metric, statistic, prediction etc.

## Outcome

The outcome of your assessment.

    #> # A tibble: 3 × 11
    #>   location_id sample_id date_taken question response label parameter type  max  
    #>   <chr>       <chr>     <date>     <chr>    <chr>    <lgl> <chr>     <chr> <lgl>
    #> 1 8175        12345     2019-11-21 Sewage … <30%     NA    SEWAGE_F… char… NA   
    #> 2 8175        12345     2019-11-21 Sewage … Thin     NA    SEWAGE_F… char… NA   
    #> 3 8175        12345     2019-11-21 Bacteri… Moderate NA    Bacteria… char… NA   
    #> # ℹ 2 more variables: min <lgl>, source <chr>

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

    #> Warning in CPL_crs_from_input(x): GDAL Message 1: +init=epsg:XXXX syntax is
    #> deprecated. It might return a CRS with a non-EPSG compliant axis order.
    #> # A tibble: 0 × 0

## Launch app

Below is an interactive application displaying the results of your
assessment.
