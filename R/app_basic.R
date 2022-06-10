#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/

library(hera)
library(shiny)
library(dplyr)
library(purrr)
library(tidyr)
library(magrittr)
library(leaflet)
library(htmltools)
library(dplyr)
library(rict)


# Define UI for application
ui <- tagList(
  #  shinythemes::themeSelector(),
  navbarPage(
    # theme = "cerulean",  # <--- To use a theme, uncomment this
    "hera",
    tabPanel(
      "Validate", sidebarPanel(
        h3("Options"),
        fileInput("dataset", "Choose CSV File",
          accept = c(
            "text/csv",
            "text/comma-separated-values,text/plain",
            ".csv"
          )
        ),
        h4("Or run demo..."),
        actionButton(inputId = "click for demo", label = "Demo Data")
      ),
      # Show tables
      mainPanel(
        htmlOutput("app"),
        leafletOutput("map_first"),
        htmlOutput("data_table")
      )
    )
  )
)

# Define server logic ---------------------------------------------------------
server <- function(input, output) {

    reactiveA <- reactive({
    inFile <- input$dataset
    # Create a Progress object
    progress <- shiny::Progress$new()

    # Make sure it closes when we exit this reactive, even if there's an error
    on.exit(progress$close())

    if (is.null(inFile) & input$`click for demo`) {
      data <- hera::demo_data

    } else if (is.null(inFile)) {
      return(NULL)
    } else {
      data <- read.csv(inFile$datapath, check.names = FALSE)
    }
  })


  output$app <- renderUI({
    data <- reactiveA()

    if (!is.null(data)) {
      indices <- indices(data, catalogue = catalogue)
      indices <- bind_rows(indices, data)
      # indices <- bind_rows(data, indices)
      # %>%
      #   select(sample_number, indices) %>%
      #   unnest(indices)


      if (!is.null(data)) {
        output_files <- list(
          "input_data" = data,
          "indices" = indices
        )
      }

      output$download_file <- downloadHandler(
        filename = function() {
          paste("hera-files", "zip", sep = ".")
        },
        content = function(fname) {
          fs <- c()
          tmpdir <- tempdir()
          setwd(tempdir())
          for (i in seq_along(output_files)) {
            path <- paste0("output_", names(output_files)[i], ".csv")
            fs <- c(fs, path)
            write.csv(output_files[[i]], file = path)
          }
          zip(zipfile = fname, files = fs)
        }
      )

      map_data <- select(data, longitude, latitude, location_id)
      map_data <- distinct(map_data)
      map <- leaflet(map_data) %>%
        addTiles() %>%
        addMarkers(~longitude, ~latitude,
          popup = ~ htmlEscape(location_id),
          clusterOptions = markerClusterOptions(
            lng = ~longitude,
            lat = ~latitude
          )
        )

      output$map <- renderLeaflet(map)
      output$map_first <- renderLeaflet(map)

      output$standard <- renderUI(selectInput(
        inputId = "standard",
        label = "Select Standard",
        choices = unique(data$standard)
      ))

      indices$response <- as.numeric(indices$response)
      chart_data <- indices %>% filter(!is.na(response))
      options(digits = 3)
      chart_data$response <- as.numeric(chart_data$response)
      if (nrow(indices) > 0) {
        chart <- ggplot(chart_data, aes(x = date_taken, y = response)) +
          geom_point() +
          facet_wrap(vars(question), scales = "free_y")
      } else {
        chart <- NULL
      }

      output$data_table <- renderUI(list(
        h3("Data"), DT::renderDataTable({
          select(data, location_id, location_description, sample_id, question, response)
        })
      ))

      output$predictions <- renderUI(list(
        h3("Predictions"), DT::renderDataTable({
          predictions <- hera::prediction(data, catalogue = new_catalogue)
          predictions %>% select(location_id, sample_id, date_taken, parameter, question, response)
        })
      ))
      assessments <- assessment(data, catalogue = new_catalogue)

      filter_assessments <- assessments %>%
        select(-date_taken) %>%
        pivot_wider(names_from = question, values_from = response)
      output$compliance <- renderUI(list(
        h3("Compliance"), DT::renderDataTable({
          if (nrow(filter_assessments) == 0) {
            return(NULL)
          }
          filter_assessments <- filter_assessments %>% filter(!is.na(status))
          filter_assessments <- filter_assessments %>%
            select(
              location_id, parameter, sample_id, eqr,
              class, status, level, high,
              good, moderate, poor,
              bad
            ) %>%
            unique()
        })
      ))


      output$indices_filter <- renderUI(list(
        renderUI({
          selectInput(
            selectize = FALSE, "Question",
            label = "Questions",
            choices = unique(data$question),
            multiple = T,
            selected = unique(data$question)
          )
        })
      ))

      output$indices <- renderUI(list(
        renderUI({
          downloadButton("download_file", "Download Outputs")
        }),
        h3("Chart"), renderPlot({
          chart
        }),
        h3("Indices"), DT::renderDataTable({
          indices %>% select(location_id, sample_id, date_taken, parameter, question, response)
        })
      ))

      output$aggregation <- renderUI(list(
        h3("Aggregates"), DT::renderDataTable({
          aggregates <- hera:::aggregation(
            assessments,
            aggregation_variables <- c("parameter", "water_body_id", "year")
          )

          aggregates <- pivot_wider(aggregates,
            names_from = question,
            values_from = response
          )
          aggregates <- select(
            aggregates, parameter, water_body_id, year, level, eqr,
            high, good, moderate, poor, bad, level
          )
        })
      ))


      return(NULL)
    }
  })
}

# Run the application
shinyApp(ui = ui, server = server)
