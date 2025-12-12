# DARLEQ3

## Welcome

This document has been created following the generic [assessment
guidance](https://ecodata1.github.io/hera/articles/development_guide.html).

## Description

Basic details about the assessment.

| question   | response                                                   |
|:-----------|:-----------------------------------------------------------|
| name_short | DARLEQ3                                                    |
| name_long  | UKTAG River Assessment Method Macrophytes and Phytobenthos |
| parameter  | River Diatoms                                              |
| status     | testing                                                    |
| type       | metric                                                     |

## Input

A list of questions required to run the assessment. Optional
‘alkalinity’ column can be included to provide a pre-calculated mean
alkalinity. If ‘alkalinity’ column not included, alkalinity will be
calculated from rows with ‘alkalinity’ question using the response
column value.

| location_id | sample_id | date_taken | question        | response | label                | parameter     |
|:------------|:----------|:-----------|:----------------|:---------|:---------------------|:--------------|
| 8175        | 12345     | 2019-11-21 | Taxon abundance | 12       | Gomphonema olivaceum | River Diatoms |
| 8175        | 12345     | 2019-11-21 | Alkalinity      | 45       | NA                   | Chemistry     |

## Assessment

Function code used to assess your input data and return an outcome.

Code

``` r
assessment_function <- function(data, metric = "TDI5LM") {
  require(dplyr)
  require(tidyr)
  require(magrittr)
  require(tibble)
  require(stringr)

  # Get alkalinity predictor if not present...
  if (!any(names(data) %in% "alkalinity")) {
    # predictor table for alkalinity if "chemistry_site" variable
    predictors <- utils::read.csv(
      system.file("extdat",
        "predictors.csv",
        package = "hera"
      ),
      stringsAsFactors = FALSE, check.names = FALSE
    )
    predictors$location_id <- as.character(predictors$location_id)
    predictors$date <- as.Date(predictors$date)
    predictors <- arrange(predictors, dplyr::desc(date))
    if (!any(names(data) %in% "chemistry_site")) {
      data <- left_join(data, predictors,
        by = c("location_id"),
        multiple = "first"
      )
    }

    if (!any(names(data) %in% c("alkalinity"))) {
      message("calculating alklainity...")
      alk <- hera:::mean_alkalinity(data)
      data$alkalinity <- NULL
      data <- inner_join(data, alk, by = join_by("sample_id" == "sample_number"))
    }
  }
  data <- filter(data, question == "Taxon abundance" &
    parameter == "River Diatoms")
  data$response <- as.numeric(data$response)
  data$alkalinity[is.na(data$alkalinity)] <- 75

  data$alkalinity <- as.numeric(data$alkalinity)
  # Combine mean alkalinity with other site headers
  header <- data %>%
    mutate(
      "SampleID" = as.factor(sample_id),
      "DATE_TAKEN" = as.Date(date_taken, tz = "GB")
    ) %>%
    select("SampleID",
      "SiteID" = "location_id",
      "SAMPLE_DATE" = "date_taken",
      "Alkalinity" = "alkalinity"
    ) %>%
    unique()

  # Loch samples also require an Alkalinity 'type';
  # 'HA' - High Alkalninty etc
  # This will be ignored if running river classification
  header$lake_TYPE <- NA
  header$lake_TYPE[header$Alkalinity > 50] <- "HA"
  header$lake_TYPE[header$Alkalinity >= 10 &
    header$Alkalinity <= 50] <- "MA"
  header$lake_TYPE[header$Alkalinity < 10] <- "LA"

  header$SiteID <- as.character(header$SiteID)
  ## Important: Arrange to match order of 'diatom_data' data frame.
  header <- arrange(header, SampleID)

  # Prepare dataframe of 'diatom_data' -------------------------------
  # Include columns for each diatom ID (from NEMS Dares table)
  # responses are abundances.
  # dataframe row.names are SAMPLE_NUMBER.

  # DARES table
  # - must use table from NEMS - this links TAXON to TAXONLD code
  dares_table <- darleq3::darleq3_taxa
  # Filter for taxon abundance only
  diatom_taxon_abundance <- data %>%
    filter(question == "taxon abundance" |
      question == "Taxon abundance")

  # Trim whitespace in Taxon name to help join.
  diatom_taxon_abundance$label <- trimws(diatom_taxon_abundance$label)
  dares_table$TaxonNameSEPA <- trimws(dares_table$TaxonNameSEPA)
  # Join to S_TAXON_DARES table using Taxon name.
  if (any(names(diatom_taxon_abundance) %in% c("taxon_ids"))) {
    diatom_taxonname <- diatom_taxon_abundance %>%
      select(
        "location_id",
        "sample_id",
        "taxon_ids",
        "label",
        "response",
        "date_taken"
      ) %>%
      inner_join(dares_table[, c("TaxonName", "TaxonId", "TaxonNameSEPA")],
        by = c("taxon_ids" = "TaxonId")
      )
    diatom_taxonname$TaxonId <- diatom_taxonname$taxon_ids
  } else {
    diatom_taxonname <- diatom_taxon_abundance %>%
      select(
        "location_id",
        "sample_id",
        "label",
        "response",
        "date_taken"
      ) %>%
      inner_join(dares_table[, c("TaxonName", "TaxonId", "TaxonNameSEPA")],
        by = c("label" = "TaxonNameSEPA")
      )
  }
  # Make sure numeric
  diatom_taxonname$response <-
    as.numeric(as.character(diatom_taxonname$response))
  # Sum response if duplicate taxon names entered within a single sample
  diatom_tidied <- diatom_taxonname %>%
    group_by(sample_id, TaxonId, label, date_taken) %>%
    summarise(response = sum(response, na.rm = TRUE), .groups = "drop")

  # Arrange to keep in same order as 'taxon_names' data.frame
  diatom_tidied <- diatom_tidied %>%
    ungroup() %>%
    arrange(label) %>%
    select(-"label")

  # DARLEQ3 requires Taxon IDs and responses pivoted into wide format
  diatom_data <- diatom_tidied %>% pivot_wider(
    names_from = TaxonId,
    values_from = response,
  )
  diatom_data[is.na(diatom_data)] <- 0


  # Arrange by sampled_date to match order of 'header' data frame.
  diatom_data <- arrange(diatom_data, sample_id)
  # darleq3 requires row.names equal SAMPLE_NUMBER. Must convert
  # to be data.frame first (row.names deprecated on tibble).
  diatom_data <- data.frame(diatom_data, check.names = FALSE)
  row.names(diatom_data) <- diatom_data$sample_id
  diatom_data <- select(diatom_data, -"sample_id", -"date_taken")

  # Prepare dataframe of 'taxon_names'  ------------------------------
  # include columns 'TaxonCode','TaxonName'
  taxon_names <- diatom_taxonname %>%
    select(
      "TaxonCode" = "TaxonId",
      "TaxonName" = "TaxonName"
    ) %>%
    unique()
  taxon_names <- arrange(taxon_names, TaxonName)
  # Combine dataframes into named list ------------------------
  header <- data.frame(header)
  header <- header[header$SampleID %in% row.names(diatom_data), ]
  header <- header[!duplicated(header$SampleID), ]
  row.names(header) <- header$SampleID
  header$SampleID <- as.character(header$SampleID)
  header$SAMPLE_DATE <- as.Date(header$SAMPLE_DATE)
  # make sure header and diatom_data are arranged in the same way even if
  # sampleID is character or numeric. sort character sample ids as numeric not
  # alphabetically
  header$row.names <- row.names(header)
  header <- arrange(header, str_rank(row.names, numeric = TRUE))
  row.names(header) <-  header$row.names 
  header$row.names <- NULL
  
  diatom_data$row.names <- row.names(diatom_data)
  diatom_data <- arrange(diatom_data, str_rank(row.names, numeric = TRUE))
  row.names(diatom_data) <-  diatom_data$row.names 
  diatom_data$row.names <- NULL
  
  output <- darleq3::calc_Metric(diatom_data, metric)
  output <- darleq3::calc_EQR(output,
    header,
    truncate_EQR = TRUE,
    verbose = TRUE
  )

  sample <- output$EQR
  sample <- sample %>% mutate_all(as.character)
  sample <- pivot_longer(sample,
    cols = c(-SampleID, -SiteID, -SAMPLE_DATE),
    names_to = "question",
    values_to = "response"
  )
  sample <- select(sample, -"SAMPLE_DATE")
  names(sample) <- c("sample_id", "location_id", "question", "response")

  location <- output$Uncertainty
  location <- location %>% mutate_all(as.character)
  location <- pivot_longer(location,
    cols = c(-SiteID),
    names_to = "question",
    values_to = "response"
  )
  names(location) <- c("location_id", "question", "response")
  results <- bind_rows(sample, location)
  results$parameter <- "Phytobenthos (diatoms)"
  results <- mutate(results,
    question = ifelse(question == "WFDClass",
      "Class",
      question
    )
  )

  years <- data %>%
    mutate("year" = lubridate::year(date_taken)) %>%
    filter(parameter == "River Diatoms") %>%
    group_by(location_id) %>%
    summarise("response" = paste(unique(.$year), collapse = ","))

  years$question <- "Years included"
  years$parameter <- "Phytobenthos (diatoms)"
  results <- bind_rows(results, years)
  return(results)
}
```

## Outcome

The outcome of your assessment.

    #> Loading required package: stringr

| question          | response         |
|:------------------|:-----------------|
| Alkalinity        | 121.9125401      |
| lake_TYPE         | HA               |
| Total_count       | 12               |
| Percent_in_TDI5LM | 100              |
| N_TDI5LM          | 1                |
| N2_TDI5LM         | 1                |
| Max_TDI5LM        | 100              |
| TDI5LM            | 50               |
| eTDI5LM           | 53.8155110499444 |
| EQR_TDI5LM        | 0.86609164482163 |
| Class_TDI5LM      | High             |
| Motile            | 0                |
| OrganicTolerant   | 0                |
| Planktic          | 0                |
| Saline            | 0                |
| Comments          |                  |
| N                 | 1                |
| EQR               | 0.86609          |
| Class             | High             |
| CoCH              | 68.69            |
| CoCG              | 24.38            |
| CoCM              | 5.86             |
| CoCP              | 1.01             |
| CoCB              | 0.05             |
| ROM               | 31.31            |
| CoCHG             | 93.07            |
| CoCMPB            | 6.93             |
| ROM_GM            | 6.93             |
| Years included    | 2019             |

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

## Test

This section tests if this assessment is usable using
[`assess()`](https://ecodata1.github.io/hera/reference/assess.md)
function.

    #> Warning in CPL_crs_from_input(x): GDAL Message 1: +init=epsg:XXXX syntax is
    #> deprecated. It might return a CRS with a non-EPSG compliant axis order.
    #> # A tibble: 237 × 5
    #>    sample_id location_id question          response          parameter          
    #>    <chr>     <chr>       <chr>             <chr>             <chr>              
    #>  1 648750    8175        Alkalinity        121.9125401       Phytobenthos (diat…
    #>  2 648750    8175        lake_TYPE         HA                Phytobenthos (diat…
    #>  3 648750    8175        Total_count       304               Phytobenthos (diat…
    #>  4 648750    8175        Percent_in_TDI5LM 100               Phytobenthos (diat…
    #>  5 648750    8175        N_TDI5LM          18                Phytobenthos (diat…
    #>  6 648750    8175        N2_TDI5LM         4.12              Phytobenthos (diat…
    #>  7 648750    8175        Max_TDI5LM        43.09             Phytobenthos (diat…
    #>  8 648750    8175        TDI5LM            69.6299342105263  Phytobenthos (diat…
    #>  9 648750    8175        eTDI5LM           53.8155110499444  Phytobenthos (diat…
    #> 10 648750    8175        EQR_TDI5LM        0.526065204658927 Phytobenthos (diat…
    #> # ℹ 227 more rows

## Launch app

Below is an interactive application displaying the results of your
assessment.
