#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
library(shiny)
library(tidyverse)
library(hera)
library(leaflet)
library(htmltools)

# Define UI for application
  ui <- tagList(
  #  shinythemes::themeSelector(),
    navbarPage(
      # theme = "cerulean",  # <--- To use a theme, uncomment this
      "hera",
      tabPanel("Validation",
               sidebarPanel(
      h3("Options"),
      fileInput("dataset", "Choose CSV File",
        accept = c(
          "text/csv",
          "text/comma-separated-values,text/plain",
          ".csv"
        )
      ),
      actionButton(inputId = "demo", label =  "demo"),
      htmlOutput("standard")
    ),
    # Show tables
    mainPanel(
      leafletOutput("map"),
      p(),
      htmlOutput("tables")
    )
  ),
  tabPanel("Indices", "This panel is intentionally left blank."),
  tabPanel("Predict", "This panel is intentionally left blank."),
  tabPanel("Classify", "This panel is intentionally left blank."),
  tabPanel("Aggregate", "This panel is intentionally left blank."),
  tabPanel("Compare", "This panel is intentionally left blank."),
  tabPanel("Diagnose", "This panel is intentionally left blank."),
  tabPanel("Scenarios", "This panel is intentionally left blank.")
)
)

# Define server logic ------------------------------------------------------------------
server <- function(input, output) {
  output$tables <- renderUI({
    if(input$demo) {
      input$dataset <- hera::demo_data
    }
    inFile <- input$dataset
    if (is.null(inFile)) {
      return(NULL)
    }
    # Create a Progress object
    progress <- shiny::Progress$new()
    # Make sure it closes when we exit this reactive, even if there's an error
    on.exit(progress$close())
    progress$set(message = "Calculating", value = 1)
    data <- read.csv(inFile$datapath, check.names = F)
    indices <- indices(data) %>%
      select(sample_number, indices) %>%
      unnest(indices)

    if (!is.null(data)) {
      output_files <- list("input_data" = data,
                           "indices" = indices)
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

    download_data <- renderUI({
      downloadButton("download_file", "Download Outputs")
    })

    map <- leaflet(data[1:10,]) %>%
             addTiles() %>%
              addMarkers(~longitude, ~latitude, popup = ~ htmlEscape(location_code))

    output$map <- renderLeaflet(map)

    output$standard <- renderUI(selectInput(inputId = "standard",
                                   label = "Select Standard",
                                   choices = unique(data$analysis_repname)))

    chart_data <- inner_join(data, indices, by = c("sample_number" = "sample_number"))
    options(digits = 3)
    chart_data$value.y <- as.numeric(chart_data$value.y)
    chart <- ggplot(chart_data, aes(x = date_taken, y = value.y)) +
      geom_point() +
      facet_wrap(vars(index), scales = "free_y")

    return(list(
      download_data,
      h3("Data"), DT::renderDataTable({
        select(data, location_code, location_description, sample_number, determinand, value)
      }),
      h3("Chart"), renderPlot({
        chart
      }),
      h3("Predictions"), DT::renderDataTable({
        indices
      })
    ))
  })
}

# Run the application
shinyApp(ui = ui, server = server)
