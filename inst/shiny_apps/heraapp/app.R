#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/

library(hera)
library(shiny)
library(tidyverse)
library(leaflet)
library(htmltools)

# Define UI for application
ui <- tagList(
  #  shinythemes::themeSelector(),
  navbarPage(
    # theme = "cerulean",  # <--- To use a theme, uncomment this
    HTML("<A href='https://ecodata1.github.io/hera/index.html'>hera</A>"),
    tabPanel(
      "Validation", sidebarPanel(
        h3("Options"),
        fileInput("dataset", "Choose CSV File",
          accept = c(
            "text/csv",
            "text/comma-separated-values,text/plain",
            ".csv"
          )
        ),
        h4("Or click me!..."),
        actionButton(inputId = "demo", label = "Demo Data"),
        p()
      ),
      # Show tables
      mainPanel(
        htmlOutput("app"),
        leafletOutput("map_first"),
        # p(),
        htmlOutput("data_table")
      )
    ),
    tabPanel(
      "Indices",
      #    sidebarPanel(
      # h3("Options"),
      # fileInput("dataset", "Choose CSV File",
      #   accept = c(
      #     "text/csv",
      #     "text/comma-separated-values,text/plain",
      #     ".csv"
      #   )
      # ),
      # h4("On try..."),
      # actionButton(inputId = "demo", label =  "Demo Data"),
      # p(),
      # htmlOutput("standard")
      # )
      # ,
      # Show tables
      mainPanel(
        leafletOutput("map"),
        p(),
        htmlOutput("tables")
      )
    ),
    tabPanel("Predict", mainPanel(
      htmlOutput("predictions")
    )),
    tabPanel("Compliance", mainPanel(
      htmlOutput("compliance")
    )),
    tabPanel("Aggregate", "This panel is intentionally left blank."),
    tabPanel("Compare", "This panel is intentionally left blank."),
    tabPanel("Diagnose", "This panel is intentionally left blank."),
    tabPanel("Scenarios", "This panel is intentionally left blank.")
  )
)

# Define server logic ------------------------------------------------------------------
server <- function(input, output) {

  output$app <- renderUI({
    inFile <- input$dataset
    # Create a Progress object
    progress <- shiny::Progress$new()
    # Make sure it closes when we exit this reactive, even if there's an error
    on.exit(progress$close())
    progress$set(message = "Calculating", value = 1)
    if (is.null(inFile) & input$demo) {
      input_data <- hera::demo_data
    }
    else if (is.null(inFile)) {
      return(NULL)
    } else {
      input_data <- read.csv(inFile$datapath, check.names = F)
    }
    indices <- indices(input_data) %>%
      select(sample_number, indices) %>%
      unnest(indices)

    if (!is.null(input_data)) {
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

    download_data <- renderUI({
      downloadButton("download_file", "Download Outputs")
    })

    map <- leaflet(unique(input_data[, c("longitude", "latitude", "location_id")])) %>%
      addTiles() %>%
      addMarkers(~longitude, ~latitude, popup = ~ htmlEscape(location_id))

    output$map <- renderLeaflet(map)
    output$map_first <- renderLeaflet(map)

    output$standard <- renderUI(selectInput(
      inputId = "standard",
      label = "Select Standard",
      choices = unique(data$standard)
    ))

    chart_data <- inner_join(input_data, indices, by = c("sample_id" = "sample_number"))
    options(digits = 3)
    chart_data$value <- suppressWarnings(as.numeric(chart_data$value))
    chart <- ggplot(chart_data, aes(x = date_taken, y = value)) +
      geom_point() +
      facet_wrap(vars(index), scales = "free_y")

    output$data_table <- renderUI(list(
      h3("Data"), DT::renderDataTable({
        select(input_data, location_id, location_description, sample_id, question, response)
      })
    ))

    output$predictions <- renderUI(list(
      h3("Predictions"), DT::renderDataTable({
        prediction(input_data[1:2200, ]) %>%
          group_by(quality_elements) %>%
          select(sample_number, prediction) %>%
          unnest(prediction)
      })
    ))

    output$compliance <- renderUI(list(
      h3("Compliance"), DT::renderDataTable({
        classification(input_data) %>%
          group_by(quality_elements) %>%
          slice_sample(n = 4) %>%
          select(sample_number, classification)
      })
    ))

    output$tables <- renderUI(list(
      download_data,
      # h3("Data"), DT::renderDataTable({
      #   select(data, location_id, location_description, sample_id, question, response)
      # }),
      h3("Chart"), renderPlot({
        chart
      }),
      h3("Predictions"), DT::renderDataTable({
        indices
      })
    ))

    return()
  })

}

# Run the application
shinyApp(ui = ui, server = server)
