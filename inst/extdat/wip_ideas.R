
# hera

# Building Environmental Models Together?
# - expects consistent input and output
# - framework for defining models
# - run models

# blether
# Convert data in to standard format for modelling
# - linked data format? LD-JSON? Work with GIS data too?
# - relies on agency / data source specific packages
# - then converts data to consistent format for modelling

# sepadata
# Get SEPA data
# - access sepadata via web services / data

# eadata
# Get EA data
# - access to ea web services / data

# sepaverse
# Tool kit for SEPA R users
# - Reporting templates
# Load common packages (tidyverse, hera, blether etc)
# - models (hera)
# - data (blether)


# Work In Progress ideas for API

library(sepaTools)
library(dplyr)
library(purrr)
library(tidyr)
library(magrittr)
library(ranger)

# data
data <-
  import_data(
    start_date = "01-JAN-2015",
    end_date = "01-JAN-2020",
    determinand = "Suspended Solid",
    include = "sampling_point"
  )



# check anomalies

# split in training/testing
data <- arrange(data, date_taken)
training_data <- data[1: 10000, ]
testing_data <- data[10000: 20000, ]

# Models
# random forest
model <-
  ranger(training_data,
    `suspended solid` ~
    slope,
    alititude,
    distance_from_source,
    alalinity,
    date_taken
  )

# predictors?

# Compare models
# predict
predictions <- predict(testing_data)
plot(predictions$value, testing_data$value)


# Explolate catchment points
sagis <- get_sagis
sagis_map <- predict(model, sagis)

# check
plot(sagis["lat", "long"])

# export
st_as_sf()
st_write(data, shp)


# update?

# metric, prediction, assessment, report??

metric(data)
prediction(data)
assessment(data)
report(data)

  # skeleton.Rmd -> questions, metric, prediction, assessment, report
  # # Get list of fields from restapi?
  # # Basis for questions?
  # # https://map.sepa.org.uk/arcgis/rest/services
  # questions.Rmd -> dataset?
  # metric.Rmd -> whpt, tdi, rmni
  # prediction.Rmd -> darleq, leafpacs, rict
  # assessment.Rmd -> rict_eqr, leafpacs_eqr
  # report.Rmd  -> wfd_parameter, consistency_check, investigation?






