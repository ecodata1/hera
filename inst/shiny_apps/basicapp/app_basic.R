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
library(ggplot2)


# Define UI for application
ui <- tagList(
  #  shinythemes::themeSelector(),
  navbarPage(
    # theme = "cerulean",  # <--- To use a theme, uncomment this
    "hera",
    tabPanel(
      "Metrics", sidebarPanel(
        h3("Options"),
        fileInput("dataset", "Choose CSV File exported from LIMS",
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
        htmlOutput("indices"),
        htmlOutput("data_table"),
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
      data <- hera:::convert(data)
    }
  })

  output$app <- renderUI({
    data <- reactiveA()
    if (!is.null(data)) {
      indices <- assess(data)
      indices <- hera:::combine(indices, data)

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

      if (!is.null(data$longitude)) {
        map_data <- select(
          data,
          longitude,
          latitude,
          location_id
        )
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
      }

      chart_data <- indices
      chart_data$response <- as.numeric(chart_data$response)
      chart_data <- chart_data %>% filter(!is.na(response))
      options(digits = 3)
      chart_data$response <- as.numeric(chart_data$response)
      if (nrow(indices) > 0) {
        chart <- ggplot(chart_data, aes(x = date_taken, y = response)) +
          geom_point() +
          facet_wrap(vars(question), scales = "free_y")
      } else {
        chart <- NULL
      }
      indices$date_taken <- format.Date(indices$date_taken, "%Y/%m/%d")
      output$data_table <- renderUI(list(
        h3("Data"), DT::renderDataTable({
          select(
            indices,
            location_id,
            location_description,
            sample_id,
            date_taken,
            question,
            response,
            parameter
          )
        })
      ))
      output$indices <- renderUI(list(
        renderUI({
          downloadButton("download_file", "Download Outputs")
        })
      ))
      return(NULL)
    }
  })
}

# Run the application
shinyApp(ui = ui, server = server)
