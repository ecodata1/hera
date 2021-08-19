# Work In Progress ideas for API

library(sepaTools)
library(tidyverse)
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





